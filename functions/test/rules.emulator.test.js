const fs = require("node:fs");
const path = require("node:path");
const {after, before, beforeEach, test} = require("node:test");
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require("@firebase/rules-unit-testing");
const {
  collection,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
} = require("firebase/firestore");

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-qebox",
    firestore: {
      rules: fs.readFileSync(
          path.join(__dirname, "..", "..", "firestore.rules"), "utf8",
      ),
    },
  });
});

after(() => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "products/milk"), {active: true, price: 65});
    await setDoc(doc(db, "products/hidden"), {active: false, price: 1});
    await setDoc(doc(db, "coupons/c1"), {code: "SAVE20", active: true});
    await setDoc(doc(db, "orders/o1"), {customerId: "u1", status: "Pending"});
    await setDoc(doc(db, "admins/staff"), {active: true});
    await setDoc(doc(db, "admins/former"), {active: false});
    await setDoc(doc(db, "customers/u1"), {name: "A", phone: "010"});
  });
});

const guest = () => env.unauthenticatedContext().firestore();
const user = (uid) => env.authenticatedContext(uid).firestore();

test("guests read active products only", async () => {
  const products = collection(guest(), "products");
  await assertSucceeds(getDocs(query(products, where("active", "==", true))));
  await assertFails(getDocs(products));
  await assertFails(getDoc(doc(guest(), "products/hidden")));
});

test("customers cannot change catalog prices", async () => {
  await assertFails(updateDoc(doc(user("u1"), "products/milk"), {price: 1}));
});

test("active staff can change the catalog, former staff cannot", async () => {
  await assertSucceeds(
      updateDoc(doc(user("staff"), "products/milk"), {price: 70}),
  );
  await assertFails(
      updateDoc(doc(user("former"), "products/milk"), {price: 1}),
  );
});

test("customers cannot read or list coupons", async () => {
  await assertFails(getDoc(doc(user("u1"), "coupons/c1")));
  await assertFails(getDocs(collection(user("u1"), "coupons")));
});

test("customers read only their own orders", async () => {
  await assertSucceeds(getDoc(doc(user("u1"), "orders/o1")));
  await assertFails(getDoc(doc(user("u2"), "orders/o1")));
  const orders = collection(user("u1"), "orders");
  await assertSucceeds(
      getDocs(query(orders, where("customerId", "==", "u1"))),
  );
  await assertFails(getDocs(orders));
});

test("customers cannot create or change orders directly", async () => {
  await assertFails(
      setDoc(doc(user("u1"), "orders/new"), {customerId: "u1", total: 1}),
  );
  await assertFails(
      updateDoc(doc(user("u1"), "orders/o1"), {status: "Delivered"}),
  );
});

test("customers manage only their own profile fields", async () => {
  await assertSucceeds(
      updateDoc(doc(user("u1"), "customers/u1"), {name: "B"}),
  );
  await assertFails(getDoc(doc(user("u2"), "customers/u1")));
  await assertFails(
      updateDoc(doc(user("u1"), "customers/u1"), {rewardPoints: 9999}),
  );
});

test("customers manage only their own addresses", async () => {
  const data = {label: "Home"};
  await assertSucceeds(
      setDoc(doc(user("u1"), "customers/u1/addresses/a1"), data),
  );
  await assertFails(
      setDoc(doc(user("u2"), "customers/u1/addresses/a1"), data),
  );
});

test("customers cannot grant themselves staff access", async () => {
  await assertFails(setDoc(doc(user("u1"), "admins/u1"), {active: true}));
});
