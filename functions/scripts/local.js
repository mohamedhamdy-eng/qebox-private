// Test data for running Qebox on the local emulators, for the joint tests
// with the Preparation app. It only talks to the emulators: the demo-qebox
// project exists nowhere else.
//
// Usage, from the functions folder, while the emulators run:
//   node scripts/local.js seed              products, a bundle and the accounts
//   node scripts/local.js place normal      a normal order
//   node scripts/local.js place bundle      an order with a bundle
//   node scripts/local.js cancel <orderId>  the customer cancels
//   node scripts/local.js edit <orderId>    staff change an item (+1 revision)
//   node scripts/local.js prepare <orderId> staff set Preparing by hand
//   node scripts/local.js list              every order with its status
process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8086";
process.env.FIREBASE_AUTH_EMULATOR_HOST = "127.0.0.1:9098";

const {initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {FieldValue, getFirestore} = require("firebase-admin/firestore");
const {cancelOrder, placeOrder, updateOrderStatus} = require("../orders");

initializeApp({projectId: "demo-qebox"});
const db = getFirestore();

// Works only on the emulator.
const PREPARATION = {
  uid: "prep-local",
  email: "preparation@qebox.test",
  password: "qebox-local",
};
const STAFF = {uid: "staff-local"};
const CUSTOMER = {
  uid: "customer-local",
  token: {phone_number: "+201000000001", firebase: {sign_in_provider: "phone"}},
};

const PRODUCTS = {
  "milk-1l": {name: "Full-cream milk 1 L", categoryId: "dairy", price: 36.5},
  "toast": {name: "Sliced toast bread", categoryId: "bakery", price: 28},
  "black-tea-100": {name: "Black tea, 100 bags", categoryId: "drinks", price: 64},
  "bananas-1kg": {name: "Bananas 1 kg", categoryId: "fruit", price: 32},
};
const CATEGORIES = {
  dairy: {name: "Dairy", nameAr: "ألبان", sortOrder: 1},
  bakery: {name: "Bakery", nameAr: "مخبوزات", sortOrder: 2},
  drinks: {name: "Drinks", nameAr: "مشروبات", sortOrder: 3},
  fruit: {name: "Fruit", nameAr: "فاكهة", sortOrder: 4},
};
const BUNDLE = {
  id: "breakfast",
  name: "Breakfast box",
  price: 95,
  productIds: ["milk-1l", "toast", "toast"],
};
const CARTS = {
  normal: {
    items: [
      {productId: "milk-1l", quantity: 2},
      {productId: "black-tea-100", quantity: 1},
    ],
    total: 2 * 36.5 + 64 + 20,
  },
  bundle: {
    items: [
      {productId: "bundle:breakfast", quantity: 2},
      {productId: "bananas-1kg", quantity: 1},
    ],
    total: 2 * 95 + 32 + 20,
  },
};

async function seed() {
  const batch = db.batch();
  for (const [id, category] of Object.entries(CATEGORIES)) {
    batch.set(db.doc(`categories/${id}`), {...category, active: true});
  }
  for (const [id, product] of Object.entries(PRODUCTS)) {
    batch.set(db.doc(`products/${id}`), {
      ...product, stockQuantity: 500, active: true,
    });
  }
  batch.set(db.doc(`bundles/${BUNDLE.id}`), {
    name: BUNDLE.name, price: BUNDLE.price,
    productIds: BUNDLE.productIds, active: true,
  });
  batch.set(db.doc(`preparationAccounts/${PREPARATION.uid}`), {active: true});
  batch.set(db.doc(`admins/${STAFF.uid}`), {active: true});
  await batch.commit();
  await getAuth().deleteUser(PREPARATION.uid).catch(() => {});
  await getAuth().createUser(PREPARATION);
  console.log("Seeded products, the Breakfast box bundle and the accounts.");
  console.log(`Preparation account: ${PREPARATION.email} / ${PREPARATION.password}`);
}

async function place(kind) {
  const cart = CARTS[kind];
  if (!cart) throw new Error("Use: place normal | place bundle");
  const now = Date.now();
  const suffix = Math.floor(Math.random() * 0x10000)
      .toString(16).toUpperCase().padStart(4, "0");
  const result = await placeOrder(db, {auth: CUSTOMER, data: {
    orderId: `QB-${now}-${suffix}`,
    items: cart.items,
    expectedTotal: cart.total,
    paymentMethod: "cash",
    substitutionPreference: "contactMe",
    customerName: "Sample Customer",
    deliveryInstruction: "Call on arrival",
    deliveryStart: now + 2 * 3600000,
    deliveryEnd: now + 4 * 3600000,
    address: {label: "Home", line: "Test street 1"},
  }}, {now});
  console.log(`Placed ${result.orderId}: total EGP ${result.total}`);
}

async function cancel(orderId) {
  await cancelOrder(db, {auth: CUSTOMER, data: {orderId, reason: "Test cancellation"}});
  console.log(`Cancelled ${orderId}`);
}

// The way a staff edit must look: +1 revision and the server time.
async function edit(orderId) {
  const ref = db.doc(`orders/${orderId}`);
  await db.runTransaction(async (tx) => {
    const order = (await tx.get(ref)).data();
    if (!order) throw new Error(`No order ${orderId}`);
    const items = order.items.map((item, index) =>
      index === 0 ? {...item, quantity: item.quantity + 1} : item);
    const subtotal = items.reduce((sum, i) => sum + i.price * i.quantity, 0);
    tx.update(ref, {
      items,
      itemCount: items.reduce((sum, i) => sum + i.quantity, 0),
      subtotal,
      totalAmount: subtotal - order.discount + order.deliveryFee,
      revision: (Number.isInteger(order.revision) ? order.revision : 1) + 1,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
  console.log(`Edited ${orderId}: one more of the first item`);
}

async function prepare(orderId) {
  const order = (await db.doc(`orders/${orderId}`).get()).data();
  if (!order) throw new Error(`No order ${orderId}`);
  const result = await updateOrderStatus(db, {auth: {uid: STAFF.uid, token: {}}, data: {
    orderId, status: "Preparing",
    expectedRevision: Number.isInteger(order.revision) ? order.revision : 1,
    requestId: `staff-${Date.now()}`,
  }});
  console.log(`Staff set ${orderId} to ${result.status}, revision ${result.revision}`);
}

async function list() {
  const snapshot = await db.collection("orders").orderBy("createdAt").get();
  if (snapshot.empty) console.log("No orders yet.");
  for (const doc of snapshot.docs) {
    const o = doc.data();
    console.log(`${doc.id}  ${o.status.padEnd(16)} revision ${o.revision}  EGP ${o.totalAmount}`);
  }
}

const commands = {seed, place, cancel, edit, prepare, list};
const [name, arg] = process.argv.slice(2);
if (!commands[name] || (["cancel", "edit", "prepare"].includes(name) && !arg)) {
  console.error("Use: seed | place normal|bundle | cancel <id> | edit <id> | prepare <id> | list");
  process.exitCode = 1;
} else {
  commands[name](arg).catch((error) => {
    const code = error.details && error.details.code;
    console.error(`Failed: ${error.message}${code ? ` (${code})` : ""}`);
    process.exitCode = 1;
  });
}
