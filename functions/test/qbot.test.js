const assert = require("node:assert");
const {test} = require("node:test");
const {DAILY_MESSAGE_LIMIT, askQBot} = require("../qbot");

function fakeDb(initial) {
  const stored = {value: initial};
  const reference = {};
  return {
    stored,
    collection: () => ({doc: () => reference}),
    runTransaction: (callback) =>
      callback({
        get: async () => ({
          get: (field) => stored.value && stored.value[field],
        }),
        set: (_, value) => {
          stored.value = value;
        },
      }),
  };
}

const request = {auth: {uid: "u1"}, data: {message: "hello"}};
const now = Date.UTC(2026, 10, 8);
const okFetch = async () => ({
  ok: true,
  json: async () => ({
    candidates: [{content: {parts: [{text: "Hi there"}]}}],
  }),
});

test("returns the Gemini answer and counts the message", async () => {
  const db = fakeDb();
  const result = await askQBot(db, request, {
    apiKey: "k",
    fetchImpl: okFetch,
    now,
  });
  assert.deepStrictEqual(result, {answer: "Hi there"});
  assert.deepStrictEqual(db.stored.value, {day: "2026-11-08", count: 1});
});

test("requires a signed-in customer", async () => {
  await assert.rejects(
      askQBot(fakeDb(), {data: {message: "hi"}}, {apiKey: "k"}),
      {code: "unauthenticated"},
  );
});

test("stops at the daily limit", async () => {
  const db = fakeDb({day: "2026-11-08", count: DAILY_MESSAGE_LIMIT});
  await assert.rejects(
      askQBot(db, request, {apiKey: "k", fetchImpl: okFetch, now}),
      {code: "resource-exhausted"},
  );
});

test("resets the limit on a new day", async () => {
  const db = fakeDb({day: "2026-11-07", count: DAILY_MESSAGE_LIMIT});
  await askQBot(db, request, {apiKey: "k", fetchImpl: okFetch, now});
  assert.strictEqual(db.stored.value.count, 1);
});

test("reports a Gemini failure", async () => {
  await assert.rejects(
      askQBot(fakeDb(), request, {
        apiKey: "k",
        fetchImpl: async () => ({ok: false}),
        now,
      }),
      {code: "unavailable"},
  );
});
