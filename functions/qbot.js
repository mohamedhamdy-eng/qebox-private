const {HttpsError} = require("firebase-functions/v2/https");

const MODEL = "gemini-2.5-flash";
const DAILY_MESSAGE_LIMIT = 50;
const MAX_MESSAGE_LENGTH = 1000;
const SYSTEM_PROMPT =
  "You are Q Bot, the friendly Qebox grocery shopping assistant. Give " +
  "concise, helpful answers about shopping, products, orders, delivery, " +
  "checkout, promotions, and accounts. Never invent an order status, price, " +
  "refund, or policy. Never claim that you added, removed, or changed cart " +
  "items; cart actions are handled by the app. Tell the customer when staff " +
  "assistance is needed.";

async function consumeDailyQuota(db, uid, now) {
  const day = new Date(now).toISOString().slice(0, 10);
  const reference = db.collection("qbotUsage").doc(uid);
  await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(reference);
    const count = snapshot.get("day") === day ? snapshot.get("count") : 0;
    if (count >= DAILY_MESSAGE_LIMIT) {
      throw new HttpsError("resource-exhausted", "Daily limit reached.");
    }
    tx.set(reference, {day, count: count + 1});
  });
}

/**
 * Sends one customer message to Gemini. The API key stays on the server.
 * @param {object} db The Firestore instance.
 * @param {object} request The callable request.
 * @param {object} options The apiKey, fetchImpl, and now options.
 * @return {Promise<object>} The answer.
 */
async function askQBot(db, request, {apiKey, fetchImpl = fetch, now} = {}) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Please sign in.");
  }
  const message = request.data && request.data.message;
  if (
    typeof message !== "string" ||
    message.trim() === "" ||
    message.length > MAX_MESSAGE_LENGTH
  ) {
    throw new HttpsError("invalid-argument", "The message is not valid.");
  }
  await consumeDailyQuota(
      db, request.auth.uid, now === undefined ? Date.now() : now,
  );

  const response = await fetchImpl(
      `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-goog-api-key": apiKey,
        },
        body: JSON.stringify({
          systemInstruction: {parts: [{text: SYSTEM_PROMPT}]},
          contents: [{role: "user", parts: [{text: message}]}],
          generationConfig: {temperature: 0.4, maxOutputTokens: 350},
        }),
        signal: AbortSignal.timeout(20000),
      },
  );
  if (!response.ok) {
    throw new HttpsError("unavailable", "The assistant is not available.");
  }
  const body = await response.json();
  const parts =
    (body.candidates && body.candidates[0] && body.candidates[0].content &&
      body.candidates[0].content.parts) || [];
  const answer = parts.map((part) => part.text || "").join("\n").trim();
  if (!answer) {
    throw new HttpsError("unavailable", "The assistant is not available.");
  }
  return {answer};
}

module.exports = {DAILY_MESSAGE_LIMIT, askQBot};
