const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {setGlobalOptions} = require("firebase-functions/v2");
const {defineSecret} = require("firebase-functions/params");
const {onCall} = require("firebase-functions/v2/https");
const orders = require("./orders");
const qbot = require("./qbot");

initializeApp();
setGlobalOptions({maxInstances: 10});

const db = getFirestore();
const geminiApiKey = defineSecret("GEMINI_API_KEY");

// The development app signs in anonymously. Production requires phone login.
const allowAnonymous = process.env.GCLOUD_PROJECT === "qeboxprivate-dev";

exports.placeOrder = onCall((request) =>
  orders.placeOrder(db, request, {allowAnonymous}),
);

exports.cancelOrder = onCall((request) =>
  orders.cancelOrder(db, request, {allowAnonymous}),
);

exports.previewCoupon = onCall((request) => orders.previewCoupon(db, request));

exports.askQBot = onCall({secrets: [geminiApiKey]}, (request) =>
  qbot.askQBot(db, request, {apiKey: geminiApiKey.value()}),
);
