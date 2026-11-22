const assert = require("node:assert");
const {test} = require("node:test");
const {calculateTotals, couponWindowProblem} = require("../pricing");

const lines = [{price: 6500, quantity: 2}];
const at = (millis) => ({toMillis: () => millis});

test("adds the delivery fee to the subtotal", () => {
  assert.deepStrictEqual(calculateTotals(lines, null), {
    subtotal: 13000,
    discount: 0,
    deliveryFee: 2000,
    total: 15000,
  });
});

test("calculates a percentage discount on the current subtotal", () => {
  const totals = calculateTotals(lines, {type: "percentage", value: 20});
  assert.strictEqual(totals.discount, 2600);
  assert.strictEqual(totals.total, 12400);
});

test("limits a fixed discount to the subtotal", () => {
  const totals = calculateTotals(lines, {type: "fixed", value: 500});
  assert.strictEqual(totals.discount, 13000);
  assert.strictEqual(totals.total, 2000);
});

test("ignores a negative coupon value", () => {
  const totals = calculateTotals(lines, {type: "fixed", value: -50});
  assert.strictEqual(totals.discount, 0);
});

test("rejects coupons outside their date window or usage limit", () => {
  const active = {active: true};
  assert.strictEqual(couponWindowProblem(active, 100), null);
  assert.match(
      couponWindowProblem({...active, startsAt: at(200)}, 100),
      /not active yet/,
  );
  assert.match(
      couponWindowProblem({...active, endsAt: at(100)}, 100),
      /expired/,
  );
  assert.match(
      couponWindowProblem({...active, usageLimit: 1, usedCount: 1}, 100),
      /usage limit/,
  );
});
