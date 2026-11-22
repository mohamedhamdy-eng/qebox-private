// All money values in this file are integer piastres. This prevents
// floating-point errors in order totals.
const DELIVERY_FEE = 2000;

const toPiastres = (pounds) => Math.round(Number(pounds) * 100);

const toPounds = (piastres) => piastres / 100;

function couponDiscount(coupon, subtotal) {
  const discount =
    coupon.type === "percentage" ?
      Math.round((subtotal * Number(coupon.value)) / 100) :
      toPiastres(coupon.value);
  return Math.min(Math.max(discount, 0), subtotal);
}

function calculateTotals(lines, coupon) {
  const subtotal = lines.reduce(
      (sum, line) => sum + line.price * line.quantity,
      0,
  );
  const discount = coupon ? couponDiscount(coupon, subtotal) : 0;
  return {
    subtotal,
    discount,
    deliveryFee: DELIVERY_FEE,
    total: subtotal - discount + DELIVERY_FEE,
  };
}

/**
 * Returns the reason that the coupon cannot be used, or null if it is valid.
 * @param {object} coupon The coupon document data.
 * @param {number} now The current time in milliseconds.
 * @return {string|null} The reason, or null.
 */
function couponWindowProblem(coupon, now) {
  if (coupon.active !== true) return "This promo code is not active.";
  if (coupon.startsAt && coupon.startsAt.toMillis() > now) {
    return "This promo code is not active yet.";
  }
  if (coupon.endsAt && coupon.endsAt.toMillis() <= now) {
    return "This promo code has expired.";
  }
  if (
    coupon.usageLimit != null &&
    (coupon.usedCount || 0) >= coupon.usageLimit
  ) {
    return "This promo code has reached its usage limit.";
  }
  return null;
}

module.exports = {
  DELIVERY_FEE,
  calculateTotals,
  couponWindowProblem,
  toPiastres,
  toPounds,
};
