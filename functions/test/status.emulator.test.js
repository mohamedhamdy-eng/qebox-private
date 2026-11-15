const assert = require("node:assert");
const {beforeEach, test} = require("node:test");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {cancelOrder, placeOrder, updateOrderStatus} = require("../orders");

initializeApp({projectId: "demo-qebox"});
const db = getFirestore();

const NOW = Date.UTC(2026, 10, 8);
const ID = "QB-1700000000000-A3F9";
const caller = (uid) => ({uid, token: {firebase: {sign_in_provider: "password"}}});
const customer = {
  uid: "u1",
  token: {phone_number: "+201000000000", firebase: {sign_in_provider: "phone"}},
};

const orderRef = () => db.collection("orders").doc(ID);
const read = async () => (await orderRef().get()).data();

const setStatus = (status, expectedRevision, requestId, uid = "prep") =>
  updateOrderStatus(db, {
    auth: caller(uid),
    data: {orderId: ID, status, expectedRevision, requestId},
  });
const cancel = () =>
  cancelOrder(db, {auth: customer, data: {orderId: ID, reason: "Changed"}});

// Matches an HttpsError with the Preparation error code in details.code.
const failsWith = (code) => (error) => {
  assert.strictEqual(error.details && error.details.code, code);
  return true;
};

beforeEach(async () => {
  await db.recursiveDelete(db.collection("orders"));
  await db.collection("products").doc("milk").set({
    name: "Milk", price: 65, stockQuantity: 5, active: true,
  });
  await db.collection("preparationAccounts").doc("prep").set({active: true});
  await db.collection("admins").doc("staff").set({active: true});
  await placeOrder(db, {
    auth: customer,
    data: {
      orderId: ID,
      items: [{productId: "milk", quantity: 2}],
      expectedTotal: 150,
      paymentMethod: "cash",
      substitutionPreference: "contactMe",
      customerName: "Test",
      deliveryStart: NOW + 3600000,
      deliveryEnd: NOW + 7200000,
      address: {label: "Home", line: "Alexandria"},
    },
  }, {now: NOW});
});

test("Preparation starts an order and records who did it", async () => {
  const result = await setStatus("Preparing", 1, "start-1");
  assert.deepStrictEqual(result, {status: "Preparing", revision: 2});
  const saved = await read();
  assert.strictEqual(saved.status, "Preparing");
  assert.strictEqual(saved.revision, 2);
  assert.deepStrictEqual(saved.statusChangedBy, {uid: "prep", role: "preparation"});
  assert.ok(saved.updatedAt.toMillis() >= saved.createdAt.toMillis());
  const change = await orderRef().collection("statusChanges").doc("start-1").get();
  assert.strictEqual(change.get("from"), "Pending");
  assert.deepStrictEqual(change.get("actor"), {uid: "prep", role: "preparation"});
});

test("the customer cannot cancel after preparation starts", async () => {
  await setStatus("Preparing", 1, "start-1");
  await assert.rejects(cancel(), /no longer be cancelled/);
  assert.strictEqual((await read()).status, "Preparing");
});

test("a repeated requestId returns the first answer and changes nothing", async () => {
  const first = await setStatus("Preparing", 1, "start-1");
  const again = await setStatus("Preparing", 1, "start-1");
  assert.deepStrictEqual(again, first);
  assert.strictEqual((await read()).revision, 2);
  const changes = await orderRef().collection("statusChanges").get();
  assert.strictEqual(changes.size, 1);
});

test("a requestId cannot be reused for another status", async () => {
  await setStatus("Preparing", 1, "start-1");
  await assert.rejects(
      setStatus("Driver Assigned", 2, "start-1", "staff"),
      failsWith("INVALID_ARGUMENT"),
  );
});

test("an old revision is refused with the current one", async () => {
  await assert.rejects(setStatus("Preparing", 0, "start-1"), (error) => {
    assert.strictEqual(error.code, "aborted");
    assert.deepStrictEqual(error.details, {
      code: "REVISION_MISMATCH", status: "Pending", revision: 1,
    });
    return true;
  });
  const retry = await setStatus("Preparing", 1, "start-2");
  assert.strictEqual(retry.revision, 2);
});

test("a cancelled order cannot start", async () => {
  await cancel();
  assert.strictEqual((await read()).revision, 2);
  await assert.rejects(setStatus("Preparing", 1, "start-1"), (error) => {
    assert.deepStrictEqual(error.details, {
      code: "ORDER_CANCELLED", status: "Cancelled", revision: 2,
    });
    return true;
  });
});

test("cancellation and the start of preparation cannot both win", async () => {
  for (let round = 0; round < 5; round++) {
    await db.recursiveDelete(orderRef().collection("statusChanges"));
    await orderRef().update({status: "Pending", revision: 1});
    const [cancelled, started] = await Promise.allSettled([
      cancel(),
      setStatus("Preparing", 1, `race-${round}`),
    ]);
    const winners = [cancelled, started].filter((r) => r.status === "fulfilled");
    assert.strictEqual(winners.length, 1);
    const saved = await read();
    assert.strictEqual(
        saved.status,
        cancelled.status === "fulfilled" ? "Cancelled" : "Preparing",
    );
    assert.strictEqual(saved.revision, 2);
  }
});

test("Preparation can only set Preparing", async () => {
  await setStatus("Preparing", 1, "start-1");
  await assert.rejects(
      setStatus("Driver Assigned", 2, "next-1"),
      failsWith("INVALID_TRANSITION"),
  );
  await assert.rejects(
      setStatus("Preparing", 2, "start-2"),
      failsWith("INVALID_TRANSITION"),
  );
});

test("staff move an order forward one step at a time", async () => {
  await setStatus("Preparing", 1, "start-1");
  await assert.rejects(
      setStatus("Delivered", 2, "skip-1", "staff"),
      failsWith("INVALID_TRANSITION"),
  );
  await setStatus("Driver Assigned", 2, "s-1", "staff");
  await setStatus("Out For Delivery", 3, "s-2", "staff");
  const done = await setStatus("Delivered", 4, "s-3", "staff");
  assert.deepStrictEqual(done, {status: "Delivered", revision: 5});
  assert.deepStrictEqual((await read()).statusChangedBy, {
    uid: "staff", role: "staff",
  });
});

test("an order placed before revisions existed counts as revision 1", async () => {
  await orderRef().update({revision: null});
  const result = await setStatus("Preparing", 1, "start-1");
  assert.strictEqual(result.revision, 2);
});

test("refuses unknown orders, other accounts and bad input", async () => {
  await assert.rejects(
      updateOrderStatus(db, {
        auth: caller("prep"),
        data: {
          orderId: "QB-1700000000009-FFFF",
          status: "Preparing", expectedRevision: 1, requestId: "x",
        },
      }),
      failsWith("NOT_FOUND"),
  );
  await assert.rejects(
      setStatus("Preparing", 1, "start-1", "u1"),
      failsWith("PERMISSION_DENIED"),
  );
  await db.collection("preparationAccounts").doc("prep").set({active: false});
  await assert.rejects(
      setStatus("Preparing", 1, "start-1"),
      failsWith("PERMISSION_DENIED"),
  );
  await assert.rejects(
      updateOrderStatus(db, {data: {orderId: ID}}),
      failsWith("UNAUTHENTICATED"),
  );
  for (const data of [
    {status: "Ready", expectedRevision: 1, requestId: "a"},
    {status: "Preparing", expectedRevision: "1", requestId: "a"},
    {status: "Preparing", expectedRevision: 1, requestId: "a/b"},
    {status: "Preparing", expectedRevision: 1},
  ]) {
    await assert.rejects(
        updateOrderStatus(db, {auth: caller("staff"), data: {orderId: ID, ...data}}),
        failsWith("INVALID_ARGUMENT"),
    );
  }
  assert.strictEqual((await read()).status, "Pending");
});
