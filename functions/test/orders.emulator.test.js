const assert = require("node:assert");
const {beforeEach, test} = require("node:test");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");
const {cancelOrder, placeOrder, previewCoupon} = require("../orders");

initializeApp({projectId: "demo-qebox"});
const db = getFirestore();

const NOW = Date.UTC(2026, 10, 8);
const ID = "QB-1700000000000-A3F9";
const auth = (uid = "u1") => ({
  uid,
  token: {phone_number: "+201000000000", firebase: {sign_in_provider: "phone"}},
});

function order(overrides = {}) {
  return {
    orderId: ID,
    items: [{productId: "milk", quantity: 2}],
    expectedTotal: 150,
    paymentMethod: "cash",
    substitutionPreference: "contactMe",
    deliveryInstruction: "Call on arrival",
    customerName: "Test",
    customerPhone: "010",
    deliveryStart: NOW + 3600000,
    deliveryEnd: NOW + 7200000,
    address: {label: "Home", line: "Alexandria"},
    ...overrides,
  };
}

const place = (data, uid) =>
  placeOrder(db, {auth: auth(uid), data}, {now: NOW});
const stockOf = async (id) =>
  (await db.collection("products").doc(id).get()).get("stockQuantity");

async function clear(name) {
  const snapshot = await db.collection(name).get();
  await Promise.all(snapshot.docs.map((doc) => doc.ref.delete()));
}

beforeEach(async () => {
  for (const name of [
    "products", "bundles", "coupons", "orders", "couponRedemptions",
  ]) {
    await clear(name);
  }
  await db.collection("products").doc("milk").set({
    name: "Milk", price: 65, stockQuantity: 5, active: true,
  });
  await db.collection("products").doc("bread").set({
    name: "Bread", price: 10, stockQuantity: 5, active: true,
    maxQuantityPerOrder: 2,
  });
  await db.collection("coupons").doc("c1").set({
    code: "SAVE20", type: "percentage", value: 20, minimumOrder: 100,
    active: true, usageLimit: 10, usedCount: 0, perCustomerLimit: 1,
  });
  await db.collection("bundles").doc("b1").set({
    name: "Breakfast", price: 70, active: true,
    productIds: ["milk", "bread"],
  });
});

test("creates the order with server prices and reserves stock", async () => {
  const result = await place(order());
  assert.deepStrictEqual(result, {
    orderId: ID, subtotal: 130, discount: 0, deliveryFee: 20, total: 150,
  });
  const saved = (await db.collection("orders").doc(ID).get()).data();
  assert.strictEqual(saved.customerId, "u1");
  assert.strictEqual(saved.customerPhone, "+201000000000");
  assert.strictEqual(saved.status, "Pending");
  assert.strictEqual(saved.items[0].price, 65);
  assert.strictEqual(await stockOf("milk"), 3);
});

test("rejects a total that does not match the server price", async () => {
  await assert.rejects(place(order({expectedTotal: 1})), /Prices have changed/);
  assert.strictEqual(await stockOf("milk"), 5);
});

test("a retry with the same order number does not reserve twice", async () => {
  await place(order());
  const second = await place(order());
  assert.strictEqual(second.total, 150);
  assert.strictEqual(await stockOf("milk"), 3);
});

test("another customer cannot reuse an order number", async () => {
  await place(order());
  await assert.rejects(place(order(), "u2"), {code: "already-exists"});
});

test("concurrent orders cannot oversell the last items", async () => {
  await db.collection("products").doc("milk").update({stockQuantity: 2});
  const results = await Promise.allSettled([
    place(order({orderId: "QB-1700000000001-AAAA"})),
    place(order({orderId: "QB-1700000000002-BBBB"})),
    place(order({orderId: "QB-1700000000003-CCCC"})),
  ]);
  const placed = results.filter((r) => r.status === "fulfilled");
  assert.strictEqual(placed.length, 1);
  assert.strictEqual(await stockOf("milk"), 0);
});

test("rejects inactive products and excess quantities", async () => {
  await db.collection("products").doc("milk").update({active: false});
  await assert.rejects(place(order()), /no longer available/);
  await assert.rejects(
      place(order({
        items: [{productId: "bread", quantity: 3}], expectedTotal: 50,
      })),
      /up to 2/,
  );
});

test("sends a translatable template with customer errors", async () => {
  await db.collection("products").doc("milk").update({stockQuantity: 1});
  await assert.rejects(place(order()), (error) => {
    assert.strictEqual(error.message, "There is not enough stock of Milk.");
    assert.deepStrictEqual(error.details, {
      template: "There is not enough stock of {0}.",
      args: ["Milk"],
    });
    return true;
  });
});

test("rejects non-cash payment and missing login", async () => {
  await assert.rejects(place(order({paymentMethod: "card"})), /cash/);
  await assert.rejects(
      placeOrder(db, {data: order()}, {now: NOW}),
      {code: "unauthenticated"},
  );
});

test("rejects anonymous sessions unless allowed", async () => {
  const request = {
    auth: {uid: "a", token: {firebase: {sign_in_provider: "anonymous"}}},
    data: order(),
  };
  await assert.rejects(
      placeOrder(db, request, {now: NOW}),
      {code: "unauthenticated"},
  );
  const result = await placeOrder(db, request, {
    now: NOW, allowAnonymous: true,
  });
  assert.strictEqual(result.total, 150);
});

test("applies a coupon on the server and enforces its limits", async () => {
  const withCoupon = order({promoCode: "SAVE20", expectedTotal: 124});
  const result = await place(withCoupon);
  assert.strictEqual(result.discount, 26);
  const coupon = await db.collection("coupons").doc("c1").get();
  assert.strictEqual(coupon.get("usedCount"), 1);
  await assert.rejects(
      place({...withCoupon, orderId: "QB-1700000000004-DDDD"}),
      /already used/,
  );
});

test("enforces the coupon minimum on the current cart", async () => {
  await assert.rejects(
      place(order({
        items: [{productId: "milk", quantity: 1}],
        promoCode: "SAVE20",
        expectedTotal: 72,
      })),
      /minimum order/,
  );
});

test("rejects an expired coupon", async () => {
  await db.collection("coupons").doc("c1").update({
    endsAt: Timestamp.fromMillis(NOW - 1),
  });
  await assert.rejects(
      place(order({promoCode: "SAVE20", expectedTotal: 124})),
      /expired/,
  );
});

test("a bundle uses the bundle price and reserves each product", async () => {
  const result = await place(order({
    items: [{productId: "bundle:b1", quantity: 1}], expectedTotal: 90,
  }));
  assert.strictEqual(result.subtotal, 70);
  assert.strictEqual(await stockOf("milk"), 4);
  assert.strictEqual(await stockOf("bread"), 4);
});

test("cancelling returns stock and coupon use once", async () => {
  await place(order({promoCode: "SAVE20", expectedTotal: 124}));
  const request = {auth: auth(), data: {orderId: ID, reason: "Changed"}};
  await cancelOrder(db, request);
  await cancelOrder(db, request);
  const saved = (await db.collection("orders").doc(ID).get()).data();
  assert.strictEqual(saved.status, "Cancelled");
  assert.strictEqual(saved.cancellationReason, "Changed");
  assert.strictEqual(await stockOf("milk"), 5);
  const coupon = await db.collection("coupons").doc("c1").get();
  assert.strictEqual(coupon.get("usedCount"), 0);
});

test("only the owner can cancel, and only before preparation", async () => {
  await place(order());
  const data = {orderId: ID, reason: "Changed"};
  await assert.rejects(
      cancelOrder(db, {auth: auth("u2"), data}),
      {code: "not-found"},
  );
  await db.collection("orders").doc(ID).update({status: "Preparing"});
  await assert.rejects(
      cancelOrder(db, {auth: auth(), data}),
      /no longer be cancelled/,
  );
  assert.strictEqual(await stockOf("milk"), 3);
});

test("the coupon preview hides unusable codes", async () => {
  const valid = await previewCoupon(db, {data: {code: "SAVE20"}}, NOW);
  assert.deepStrictEqual(valid, {
    code: "SAVE20", type: "percentage", value: 20, minimumOrder: 100,
  });
  assert.strictEqual(
      await previewCoupon(db, {data: {code: "NOPE"}}, NOW),
      null,
  );
});
