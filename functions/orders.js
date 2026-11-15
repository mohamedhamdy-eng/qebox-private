const {HttpsError} = require("firebase-functions/v2/https");
const {FieldValue, Timestamp} = require("firebase-admin/firestore");
const {
  calculateTotals,
  couponWindowProblem,
  toPiastres,
  toPounds,
} = require("./pricing");

const ORDER_ID_PATTERN = /^QB-\d{10,16}-[0-9A-F]{4}$/;
const BUNDLE_PREFIX = "bundle:";
const CANCELLABLE_STATUSES = new Set(["Pending", "Scheduled"]);
const SUBSTITUTIONS = new Set([
  "replaceAutomatically",
  "contactMe",
  "removeItem",
]);
const MAX_ITEMS = 100;
const MAX_QUANTITY = 999;
const MAX_SCHEDULE_AHEAD_MS = 60 * 24 * 60 * 60 * 1000;

const invalid = (message) => new HttpsError("invalid-argument", message);
function rejected(template, args = []) {
  const message = args.reduce(
      (text, value, index) => text.replace(`{${index}}`, value),
      template,
  );
  return new HttpsError("failed-precondition", message, {template, args});
}

function requireCustomer(request, allowAnonymous) {
  const auth = request.auth;
  if (!auth) throw new HttpsError("unauthenticated", "Please sign in.");
  const provider = auth.token.firebase && auth.token.firebase.sign_in_provider;
  if (provider === "anonymous" && !allowAnonymous) {
    throw new HttpsError("unauthenticated", "Please sign in.");
  }
  return auth;
}

function text(value, field, maxLength, {required = false} = {}) {
  if (value == null || value === "") {
    if (required) throw invalid(`${field} is required.`);
    return null;
  }
  if (typeof value !== "string" || value.length > maxLength) {
    throw invalid(`${field} is not valid.`);
  }
  return value.trim();
}

function parseItems(rawItems) {
  if (
    !Array.isArray(rawItems) ||
    rawItems.length === 0 ||
    rawItems.length > MAX_ITEMS
  ) {
    throw invalid("The order items are not valid.");
  }
  const quantities = new Map();
  for (const item of rawItems) {
    const id = text(item && item.productId, "Product", 200, {required: true});
    const quantity = item.quantity;
    if (!Number.isInteger(quantity) || quantity < 1) {
      throw invalid("The item quantity is not valid.");
    }
    const merged = (quantities.get(id) || 0) + quantity;
    if (merged > MAX_QUANTITY) throw invalid("The item quantity is too large.");
    quantities.set(id, merged);
  }
  return quantities;
}

function parseOrderInput(data, now) {
  if (!data || !ORDER_ID_PATTERN.test(String(data.orderId))) {
    throw invalid("The order number is not valid.");
  }
  if (data.paymentMethod !== "cash") {
    throw rejected("Only cash on delivery is available.");
  }
  if (!SUBSTITUTIONS.has(data.substitutionPreference)) {
    throw invalid("The substitution preference is not valid.");
  }
  if (!Number.isFinite(data.expectedTotal)) {
    throw invalid("The order total is not valid.");
  }
  const {deliveryStart, deliveryEnd} = data;
  if (
    !Number.isInteger(deliveryStart) ||
    !Number.isInteger(deliveryEnd) ||
    deliveryEnd <= deliveryStart ||
    deliveryEnd <= now ||
    deliveryStart > now + MAX_SCHEDULE_AHEAD_MS
  ) {
    throw rejected("Please choose a new delivery time.");
  }
  const address = data.address || {};
  return {
    orderId: data.orderId,
    quantities: parseItems(data.items),
    expectedTotal: toPiastres(data.expectedTotal),
    promoCode: text(data.promoCode, "Promo code", 40),
    customerReference: text(data.customerReference, "Customer", 128) || "",
    customerName: text(data.customerName, "Name", 100, {required: true}),
    customerPhone: text(data.customerPhone, "Phone", 20) || "",
    orderNote: text(data.orderNote, "Order note", 1000),
    substitutionPreference: data.substitutionPreference,
    deliveryInstruction:
      text(data.deliveryInstruction, "Delivery instruction", 200) || "",
    deliveryStart,
    deliveryEnd,
    address: {
      label: text(address.label, "Address label", 50, {required: true}),
      line: text(address.line, "Address", 300, {required: true}),
      building: text(address.building, "Building", 50),
      floor: text(address.floor, "Floor", 50),
      apartment: text(address.apartment, "Apartment", 50),
      landmark: text(address.landmark, "Landmark", 200),
    },
  };
}

const orderSummary = (order) => ({
  orderId: order.id,
  subtotal: order.subtotal,
  discount: order.discount,
  deliveryFee: order.deliveryFee,
  total: order.totalAmount,
});

const isBundleId = (id) => id.startsWith(BUNDLE_PREFIX);

async function readBundles(db, tx, quantities) {
  const ids = [...quantities.keys()].filter(isBundleId);
  if (ids.length === 0) return new Map();
  const refs = ids.map((id) =>
    db.collection("bundles").doc(id.slice(BUNDLE_PREFIX.length)),
  );
  const snapshots = await tx.getAll(...refs);
  const bundles = new Map();
  snapshots.forEach((snapshot, index) => {
    if (!snapshot.exists || snapshot.get("active") !== true) {
      throw rejected("A bundle in your cart is no longer available.");
    }
    bundles.set(ids[index], snapshot.data());
  });
  return bundles;
}

function requiredStock(quantities, bundles) {
  const required = new Map();
  const add = (id, quantity) =>
    required.set(id, (required.get(id) || 0) + quantity);
  for (const [id, quantity] of quantities) {
    if (isBundleId(id)) {
      for (const productId of bundles.get(id).productIds || []) {
        add(String(productId), quantity);
      }
    } else {
      add(id, quantity);
    }
  }
  return required;
}

async function readProducts(db, tx, productIds) {
  if (productIds.length === 0) return new Map();
  const refs = productIds.map((id) => db.collection("products").doc(id));
  const snapshots = await tx.getAll(...refs);
  const products = new Map();
  snapshots.forEach((snapshot, index) => {
    if (snapshot.exists) {
      products.set(productIds[index], {ref: refs[index], data: snapshot.data()});
    }
  });
  return products;
}

// One entry per product in the bundle, with its quantity in one bundle.
function bundleContents(bundle, products) {
  const counts = new Map();
  for (const productId of bundle.productIds || []) {
    const id = String(productId);
    counts.set(id, (counts.get(id) || 0) + 1);
  }
  return [...counts].map(([id, quantity]) => ({
    product_id: id,
    product_name: products.get(id).data.name || id,
    quantity,
  }));
}

function buildLines(quantities, bundles, products) {
  const lines = [];
  for (const [id, quantity] of quantities) {
    if (isBundleId(id)) {
      const bundle = bundles.get(id);
      lines.push({
        id,
        name: bundle.name || id,
        price: toPiastres(bundle.price),
        quantity,
        imageUrl: bundle.imageUrl || null,
        bundleItems: bundleContents(bundle, products),
      });
      continue;
    }
    const product = products.get(id).data;
    if (
      product.maxQuantityPerOrder != null &&
      quantity > product.maxQuantityPerOrder
    ) {
      throw rejected(
          "You can order up to {0} of {1}.",
          [product.maxQuantityPerOrder, product.name],
      );
    }
    lines.push({
      id,
      name: product.name || id,
      price: toPiastres(product.price),
      quantity,
      imageUrl: product.imageUrl || null,
    });
  }
  return lines;
}

function checkStock(required, products) {
  for (const [id, quantity] of required) {
    const product = products.get(id);
    if (!product || product.data.active !== true) {
      throw rejected("An item in your cart is no longer available.");
    }
    if ((product.data.stockQuantity || 0) < quantity) {
      throw rejected("There is not enough stock of {0}.", [product.data.name]);
    }
  }
}

async function readCoupon(db, tx, code) {
  const snapshot = await tx.get(
      db.collection("coupons")
          .where("code", "==", code)
          .where("active", "==", true)
          .limit(1),
  );
  return snapshot.empty ? null : snapshot.docs[0];
}

const redemptionRef = (db, couponId, uid) =>
  db.collection("couponRedemptions").doc(`${couponId}_${uid}`);

async function readValidCoupon(db, tx, code, uid, subtotal, now) {
  const document = await readCoupon(db, tx, code);
  if (!document) throw rejected("This promo code is not valid.");
  const coupon = document.data();
  const problem = couponWindowProblem(coupon, now);
  if (problem) throw rejected(problem);
  if (subtotal < toPiastres(coupon.minimumOrder || 0)) {
    throw rejected("The minimum order is EGP {0}.", [coupon.minimumOrder]);
  }
  const redemption = redemptionRef(db, document.id, uid);
  if (coupon.perCustomerLimit != null) {
    const used = await tx.get(redemption);
    if ((used.get("count") || 0) >= coupon.perCustomerLimit) {
      throw rejected("You have already used this promo code.");
    }
  }
  return {reference: document.ref, redemption, data: coupon};
}

/**
 * Creates the order, reserves the stock, and uses the coupon in one
 * transaction. The server calculates every price. The client only sends
 * product IDs, quantities, and the total that the customer saw.
 * @param {object} db The Firestore instance.
 * @param {object} request The callable request.
 * @param {object} options The allowAnonymous and now options.
 * @return {Promise<object>} The order totals.
 */
async function placeOrder(db, request, {allowAnonymous = false, now} = {}) {
  const currentTime = now === undefined ? Date.now() : now;
  const auth = requireCustomer(request, allowAnonymous);
  const input = parseOrderInput(request.data, currentTime);
  const orderRef = db.collection("orders").doc(input.orderId);

  return db.runTransaction(async (tx) => {
    const existing = await tx.get(orderRef);
    if (existing.exists) {
      if (existing.get("customerId") !== auth.uid) {
        throw new HttpsError("already-exists", "Please try again.");
      }
      return orderSummary(existing.data());
    }

    const bundles = await readBundles(db, tx, input.quantities);
    const required = requiredStock(input.quantities, bundles);
    const products = await readProducts(db, tx, [...required.keys()]);
    checkStock(required, products);
    const lines = buildLines(input.quantities, bundles, products);
    const subtotal = lines.reduce((sum, l) => sum + l.price * l.quantity, 0);

    const coupon = input.promoCode ?
      await readValidCoupon(
          db, tx, input.promoCode, auth.uid, subtotal, currentTime,
      ) :
      null;
    const totals = calculateTotals(lines, coupon && coupon.data);

    if (Math.abs(totals.total - input.expectedTotal) > 1) {
      throw rejected(
          "Prices have changed. Please review your cart and try again.",
      );
    }

    for (const [id, quantity] of required) {
      tx.update(products.get(id).ref, {
        stockQuantity: FieldValue.increment(-quantity),
      });
    }
    if (coupon) {
      tx.update(coupon.reference, {usedCount: FieldValue.increment(1)});
      tx.set(
          coupon.redemption,
          {count: FieldValue.increment(1)},
          {merge: true},
      );
    }

    const order = {
      id: input.orderId,
      customerId: auth.uid,
      customerReference: input.customerReference,
      customerName: input.customerName,
      customerPhone: auth.token.phone_number || input.customerPhone,
      items: lines.map((line) => ({
        product_id: line.id,
        product_name: line.name,
        price: toPounds(line.price),
        quantity: line.quantity,
        image_url: line.imageUrl,
        ...(line.bundleItems && {bundle_items: line.bundleItems}),
      })),
      itemCount: lines.reduce((sum, line) => sum + line.quantity, 0),
      branchName: input.address.label,
      subtotal: toPounds(totals.subtotal),
      discount: toPounds(totals.discount),
      deliveryFee: toPounds(totals.deliveryFee),
      totalAmount: toPounds(totals.total),
      paymentMethod: "cash",
      status: "Pending",
      addressSnapshot: input.address,
      deliveryStart: Timestamp.fromMillis(input.deliveryStart),
      deliveryEnd: Timestamp.fromMillis(input.deliveryEnd),
      orderNote: input.orderNote,
      promoCode: coupon ? coupon.data.code : null,
      couponId: coupon ? coupon.reference.id : null,
      stockReservations: Object.fromEntries(required),
      substitutionPreference: input.substitutionPreference,
      deliveryInstruction: input.deliveryInstruction,
      revision: 1,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    };
    tx.create(orderRef, order);
    return orderSummary(order);
  });
}

/**
 * Cancels the order of the signed-in customer and returns its stock and
 * coupon use in one transaction.
 * @param {object} db The Firestore instance.
 * @param {object} request The callable request.
 * @param {object} options The allowAnonymous option.
 * @return {Promise<object>} The new order status.
 */
async function cancelOrder(db, request, {allowAnonymous = false} = {}) {
  const auth = requireCustomer(request, allowAnonymous);
  const data = request.data || {};
  if (!ORDER_ID_PATTERN.test(String(data.orderId))) {
    throw invalid("The order number is not valid.");
  }
  const reason = text(data.reason, "Reason", 200, {required: true});
  const orderRef = db.collection("orders").doc(data.orderId);

  return db.runTransaction(async (tx) => {
    const snapshot = await tx.get(orderRef);
    if (!snapshot.exists || snapshot.get("customerId") !== auth.uid) {
      throw new HttpsError("not-found", "Order not found.");
    }
    const order = snapshot.data();
    if (order.status === "Cancelled") return {status: "Cancelled"};
    if (!CANCELLABLE_STATUSES.has(order.status)) {
      throw rejected("This order can no longer be cancelled.");
    }

    const reservations = Object.entries(order.stockReservations || {});
    const products = await readProducts(
        db, tx, reservations.map(([id]) => id),
    );
    const couponRef = order.couponId ?
      db.collection("coupons").doc(order.couponId) :
      null;
    const coupon = couponRef ? await tx.get(couponRef) : null;

    for (const [id, quantity] of reservations) {
      const product = products.get(id);
      if (product) {
        tx.update(product.ref, {stockQuantity: FieldValue.increment(quantity)});
      }
    }
    if (coupon && coupon.exists) {
      tx.update(couponRef, {usedCount: FieldValue.increment(-1)});
      tx.set(
          redemptionRef(db, order.couponId, auth.uid),
          {count: FieldValue.increment(-1)},
          {merge: true},
      );
    }
    tx.update(orderRef, {
      status: "Cancelled",
      cancellationReason: reason,
      cancelledAt: FieldValue.serverTimestamp(),
      revision: revisionOf(order) + 1,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return {status: "Cancelled"};
  });
}

// Orders placed before revisions existed count as revision 1.
const revisionOf = (order) =>
  Number.isInteger(order.revision) ? order.revision : 1;

const STATUSES = new Set([
  "Pending",
  "Scheduled",
  "Preparing",
  "Driver Assigned",
  "Out For Delivery",
  "Delivered",
  "Cancelled",
]);
// The Preparation system only reports that picking has started.
const PREPARATION_STEPS = {
  "Pending": "Preparing",
  "Scheduled": "Preparing",
};
// Staff move an order forward one step at a time.
const STAFF_STEPS = {
  ...PREPARATION_STEPS,
  "Preparing": "Driver Assigned",
  "Driver Assigned": "Out For Delivery",
  "Out For Delivery": "Delivered",
};
const REQUEST_ID_PATTERN = /^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$/;

// details.code is the error code that the Preparation system reads.
const statusError = (httpCode, code, message, details = {}) =>
  new HttpsError(httpCode, message, {code, ...details});

function parseStatusInput(data) {
  const input = data || {};
  const bad = (message) =>
    statusError("invalid-argument", "INVALID_ARGUMENT", message);
  if (!ORDER_ID_PATTERN.test(String(input.orderId))) {
    throw bad("The order number is not valid.");
  }
  if (!STATUSES.has(input.status)) throw bad("The status is not valid.");
  if (!Number.isInteger(input.expectedRevision) || input.expectedRevision < 0) {
    throw bad("expectedRevision must be a whole number.");
  }
  if (
    typeof input.requestId !== "string" ||
    !REQUEST_ID_PATTERN.test(input.requestId)
  ) {
    throw bad("requestId is not valid.");
  }
  return input;
}

async function actorRole(db, uid) {
  const [preparation, staff] = await db.getAll(
      db.collection("preparationAccounts").doc(uid),
      db.collection("admins").doc(uid),
  );
  if (preparation.get("active") === true) return "preparation";
  if (staff.get("active") === true) return "staff";
  return null;
}

/**
 * Changes the status of an order for the Preparation system or for staff.
 * It runs in a transaction on the same document as cancelOrder, so a
 * customer cancellation and the start of preparation cannot both succeed.
 * A repeat with the same requestId returns the first answer.
 * @param {object} db The Firestore instance.
 * @param {object} request The callable request.
 * @return {Promise<object>} The new status and revision.
 */
async function updateOrderStatus(db, request) {
  if (!request.auth) {
    throw statusError("unauthenticated", "UNAUTHENTICATED", "Please sign in.");
  }
  const input = parseStatusInput(request.data);
  const uid = request.auth.uid;
  const role = await actorRole(db, uid);
  if (!role) {
    throw statusError(
        "permission-denied", "PERMISSION_DENIED",
        "This account cannot change order status.",
    );
  }
  const steps = role === "preparation" ? PREPARATION_STEPS : STAFF_STEPS;
  const orderRef = db.collection("orders").doc(input.orderId);
  const changeRef = orderRef.collection("statusChanges").doc(input.requestId);

  return db.runTransaction(async (tx) => {
    const [snapshot, previous] = await tx.getAll(orderRef, changeRef);
    if (!snapshot.exists) {
      throw statusError("not-found", "NOT_FOUND", "Order not found.");
    }
    if (previous.exists) {
      if (previous.get("status") !== input.status) {
        throw statusError(
            "invalid-argument", "INVALID_ARGUMENT",
            "This requestId was already used for another status.",
        );
      }
      return previous.get("response");
    }

    const order = snapshot.data();
    const current = {status: order.status, revision: revisionOf(order)};
    if (order.status === "Cancelled") {
      throw statusError(
          "failed-precondition", "ORDER_CANCELLED",
          "The customer cancelled this order.", current,
      );
    }
    if (input.expectedRevision !== current.revision) {
      throw statusError(
          "aborted", "REVISION_MISMATCH",
          "The order changed. Read it again and retry.", current,
      );
    }
    if (steps[order.status] !== input.status) {
      throw statusError(
          "failed-precondition", "INVALID_TRANSITION",
          `The order cannot move from ${order.status} to ${input.status}.`,
          current,
      );
    }

    const response = {status: input.status, revision: current.revision + 1};
    tx.update(orderRef, {
      status: input.status,
      revision: response.revision,
      updatedAt: FieldValue.serverTimestamp(),
      statusChangedAt: FieldValue.serverTimestamp(),
      statusChangedBy: {uid, role},
    });
    tx.create(changeRef, {
      from: order.status,
      status: input.status,
      revision: response.revision,
      actor: {uid, role},
      at: FieldValue.serverTimestamp(),
      response,
    });
    return response;
  });
}

/**
 * Looks up one promo code so that the client never needs read access to the
 * coupons collection.
 * @param {object} db The Firestore instance.
 * @param {object} request The callable request.
 * @param {number} now The current time in milliseconds.
 * @return {Promise<object|null>} The public coupon fields, or null.
 */
async function previewCoupon(db, request, now = Date.now()) {
  const code = text(request.data && request.data.code, "Code", 40, {
    required: true,
  });
  const snapshot = await db.collection("coupons")
      .where("code", "==", code)
      .where("active", "==", true)
      .limit(1)
      .get();
  if (snapshot.empty) return null;
  const coupon = snapshot.docs[0].data();
  if (couponWindowProblem(coupon, now)) return null;
  return {
    code: coupon.code,
    type: coupon.type || "fixed",
    value: coupon.value || 0,
    minimumOrder: coupon.minimumOrder || 0,
  };
}

module.exports = {cancelOrder, placeOrder, previewCoupon, updateOrderStatus};
