# Preparation integration: the Qebox side

This file answers the "What to send back" list in the Qebox ↔ Preparation API
Integration Guide. It describes what the Qebox backend does in this
repository.

## Projects and access

| Item | Value |
| --- | --- |
| Test project | `qeboxprivate-dev` |
| Production project | `qeboxprivate` |
| Orders collection | `orders` (the document ID is the order ID) |
| Function | `updateOrderStatus`, a callable function in `us-central1` |
| Account | Email/Password user. Its UID is in `preparationAccounts/{uid}` with `active: true` |
| Security rules | [firestore.rules](../firestore.rules) |

The Preparation account can:

- List orders only with a `status` filter inside `Pending`, `Scheduled` and
  `Preparing`, for example `where("status", "in", ["Pending", "Scheduled"])`.
  The rules refuse a query without that filter.
- Get any order by its ID, to check a cancellation.
- Call `updateOrderStatus`, only to set `Preparing`.

It cannot write any document, and cannot read customers, coupons, coupon
redemptions or staff records.

An order document also holds `customerPhone` and `addressSnapshot` (the
delivery address). Firestore rules cannot hide single fields, so the
Preparation account can read them. Please do not store or show them.

## Field mapping

Qebox keeps its own field names. Money is a number in EGP, not a string:
format it with two decimals (`36.5` becomes `"36.50"`). Dates are Firestore
Timestamps.

| Guide field | Qebox field | Notes |
| --- | --- | --- |
| `sourceOrderId` | `id` | Same as the document ID, for example `QB-1731567600000-A3F9` |
| `revision` | `revision` | 1 at creation, +1 on every change |
| `updatedAt` | `updatedAt` | Timestamp of the last change |
| `status` | `status` | Exact names from the guide. New orders are `Pending`. Qebox does not use `Scheduled` today |
| `placedAt` | `createdAt` | Timestamp |
| `deliverySlot.startAt` | `deliveryStart` | Timestamp |
| `deliverySlot.endAt` | `deliveryEnd` | Timestamp |
| `customer.displayName` | `customerName` | |
| `customer.addressLabel` | `addressSnapshot.label` | `Home`, `Work` or `Other`. `branchName` holds the same label: do not use it as a branch |
| `branch` | none | Use the default branch |
| `lines` | `items` | |
| `lines[].sourceLineId` | `items[].product_id` | Unique in an order: Qebox merges repeats of a product into one line |
| `lines[].sku` | `items[].product_id` | The Qebox product document ID. There is no other SKU. Bundles are `bundle:<bundle ID>` |
| `lines[].name` | `items[].product_name` | |
| `lines[].unit` | none | Always `EACH` |
| `lines[].quantity` | `items[].quantity` | Whole number from 1 to 999 |
| `lines[].price` | `items[].price` | Unit price in EGP before the coupon discount |
| `lines[].bundleItems[]` | `items[].bundle_items[]` | Each: `product_id` (SKU), `product_name`, `quantity` per bundle. Unit is `EACH` |
| `subtotal`, `discount`, `deliveryFee`, `totalAmount` | same names | EGP. `totalAmount = subtotal − discount + deliveryFee` |
| `paymentMethod` | `paymentMethod` | `cash` (lower case) |
| `cancelledAt`, `cancellationReason` | same names | Set when the customer cancels |

Qebox also stores these fields, which the guide does not list yet:

| Qebox field | Meaning |
| --- | --- |
| `substitutionPreference` | What to do when an item is missing, for the whole order: `replaceAutomatically`, `contactMe` or `removeItem` |
| `orderNote` | The customer's note, or null |
| `deliveryInstruction` | For example `Call on arrival` |
| `statusChangedBy`, `statusChangedAt` | Who made the last status change (`uid`, and a `role` of `preparation` or `staff`) and when |

Answers to item 6: order lines carry no barcode. Qebox has no weighed items:
every quantity is a whole number of pieces or packs, so there are no `GRAM`
lines.

A sample order with fake data, in Qebox's shape:

```json
{
  "id": "QB-1731567600000-A3F9",
  "revision": 1,
  "status": "Pending",
  "createdAt": "<Timestamp 2026-11-14T08:40:00+02:00>",
  "updatedAt": "<Timestamp 2026-11-14T08:40:00+02:00>",
  "deliveryStart": "<Timestamp 2026-11-14T12:00:00+02:00>",
  "deliveryEnd": "<Timestamp 2026-11-14T14:00:00+02:00>",
  "customerId": "test-customer-uid",
  "customerName": "Sample Customer",
  "addressSnapshot": {"label": "Home", "line": "Test street"},
  "branchName": "Home",
  "paymentMethod": "cash",
  "subtotal": 254, "discount": 10, "deliveryFee": 20, "totalAmount": 264,
  "substitutionPreference": "contactMe",
  "items": [
    {
      "product_id": "bundle:breakfast", "product_name": "Breakfast box",
      "price": 95, "quantity": 2, "image_url": null,
      "bundle_items": [
        {"product_id": "milk-1l", "product_name": "Full-cream milk 1 L", "quantity": 1},
        {"product_id": "toast", "product_name": "Sliced toast bread", "quantity": 2}
      ]
    },
    {"product_id": "black-tea-100", "product_name": "Black tea, 100 bags", "price": 64, "quantity": 1, "image_url": null}
  ]
}
```

## updateOrderStatus

The request is the one in the guide:

```json
{"orderId": "QB-1731567600000-A3F9", "status": "Preparing", "expectedRevision": 1, "requestId": "start-QB-1731567600000-A3F9-7f2c"}
```

`requestId` is 1 to 128 characters: letters, digits, `.`, `_`, `:` and `-`,
starting with a letter or digit. A repeat with the same `requestId` returns the
first answer and changes nothing. Reusing a `requestId` for a different status
is refused.

A success returns `{"status": "Preparing", "revision": 2}`. An error is an
`HttpsError`. Its `details.code` is the code from the guide, and most errors
also carry the order's current `status` and `revision`:

| Case | `details.code` | HttpsError code | `details` also has |
| --- | --- | --- | --- |
| Customer cancelled first | `ORDER_CANCELLED` | `failed-precondition` | `status`, `revision` |
| Order changed since `expectedRevision` | `REVISION_MISMATCH` | `aborted` | `status`, `revision` |
| Transition not allowed | `INVALID_TRANSITION` | `failed-precondition` | `status`, `revision` |
| Unknown order | `NOT_FOUND` | `not-found` | |
| Not the Preparation account or staff | `PERMISSION_DENIED` | `permission-denied` | |
| Not signed in | `UNAUTHENTICATED` | `unauthenticated` | |
| Bad request | `INVALID_ARGUMENT` | `invalid-argument` | |

Cancellation is checked first, then the revision, then the transition. The
change and the customer's cancellation run in transactions on the same
document, so only one of them can succeed.

Each change is also stored in `orders/{orderId}/statusChanges/{requestId}`
with the actor, the time, the old status and the new revision.

The first call after a quiet period can take a few seconds while the function
starts. If the 5-second limit matters, Qebox can keep one instance warm at a
small monthly cost.

## Still open

- The Preparation account email: send it after the account is created.
- The branch list: later.
- A technical contact for the joint tests.
