# Qebox

Qebox is a grocery delivery app. The client is Flutter. The backend is
Firebase (phone login, Firestore, and Cloud Functions).

## Environments

Debug and profile builds use the `qeboxprivate-dev` Firebase project. Release
builds use the `qeboxprivate` production project. To override the default, use
`--dart-define=APP_ENV=development` or `--dart-define=APP_ENV=production`.

## Deploy the backend

The app needs the Cloud Functions to place orders. The Firebase project must
use the Blaze plan.

Before you deploy the rules, add an `admins/{uid}` document with `active: true`
for each staff account. The rules block staff writes without this document.

```powershell
cd functions
npm install
cd ..
firebase use dev
firebase functions:secrets:set GEMINI_API_KEY
firebase deploy --only functions,firestore:rules
```

Do the same with `firebase use default` for production. Create the Gemini key
in Google AI Studio. Do not commit the key.

## Preparation integration

The Preparation system reads orders from Firestore and calls the
`updateOrderStatus` function when picking starts. The contract and the field
mapping are in [docs/preparation-integration.md](docs/preparation-integration.md).

To connect it to a project:

1. In Firebase Authentication, turn on the Email/Password sign-in method.
2. Add a user for the Preparation server. Create its password in a password
   manager. Do not send the password by email or chat.
3. In Firestore, add a `preparationAccounts/{uid}` document with
   `active: true`, where `uid` is the new user's ID. Do not add this user to
   `admins`. The rules let it read orders and nothing else.
4. Deploy the functions and the rules.
5. Give orders placed before this release a revision. Run a dry run first:

   ```powershell
   cd functions
   node scripts/backfill-revisions.js qeboxprivate-dev
   node scripts/backfill-revisions.js qeboxprivate-dev --write
   ```

To turn the account off, set `active` to `false`.

### Test with the Preparation app on one computer, for free

The emulators use their own ports (Auth 9098, Firestore 8086, Functions 5002,
UI 4010), so they run beside the Preparation emulators. They need Java.

```powershell
firebase emulators:start --only auth,firestore,functions --project demo-qebox --export-on-exit .emulator-data
```

Add `--import .emulator-data` after the first run to keep the test data. In a
second terminal, add the test data and orders:

```powershell
cd functions
node scripts/local.js seed
node scripts/local.js place normal
node scripts/local.js place bundle
node scripts/local.js list
```

`seed` creates the Preparation account `preparation@qebox.test` with the
password `qebox-local`, which works only on the emulator. During the joint
tests, `cancel <orderId>` cancels as the customer, `edit <orderId>` changes an
item as staff, and `prepare <orderId>` sets `Preparing` as staff.

The Preparation server connects to:

| What | Local address |
| --- | --- |
| Project ID | `demo-qebox` |
| Auth | `127.0.0.1:9098` |
| Firestore | `127.0.0.1:8086` |
| `updateOrderStatus` | `http://127.0.0.1:5002/demo-qebox/us-central1/updateOrderStatus` |

To use the Qebox app on a phone with the emulators, connect the phone to the
same Wi-Fi as the computer and run the app with the computer's address
(`ipconfig` shows it):

```powershell
flutter run --dart-define=EMULATOR_HOST=192.168.1.14
```

Debug builds then send login, data and orders to the emulators. Log in with any
phone number. No text message is sent; the code is in the emulator UI under
Authentication. Windows Firewall must allow ports 9098, 8086, and 5002 from
the local network. Release builds ignore `EMULATOR_HOST`.

Order status changes only through `updateOrderStatus`. The Preparation account
can only set `Preparing`. Staff accounts move an order forward one step at a
time, up to `Delivered`. A staff edit to any other order field must raise
`revision` by one and set `updatedAt` to the server time.

## Languages

The app supports English and Arabic. It follows the device language, and the
customer can change it from the language button on the Account screen.

To add or change text, wrap the English text in `tr()` and add the Arabic text
to `lib/core/l10n/translations_ar.dart`. A test fails if the Arabic text is
missing. Add a `nameAr` field to products and categories to show Arabic names.

## Coupon fields

Coupons in the `coupons` collection accept these fields: `code` (uppercase),
`type` (`percentage` or `fixed`), `value`, `minimumOrder`, `active`, `startsAt`,
`endsAt`, `usageLimit`, `usedCount`, and `perCustomerLimit`. Only `code`,
`type`, `value`, and `active` are required.

## Android release signing

Create `android/key.properties`. Do not commit this file.

```properties
storeFile=C:/path/to/release.jks
storePassword=...
keyAlias=...
keyPassword=...
```

## Tests

```powershell
flutter test
cd functions
npm test
npm run test:emulator
```

The emulator tests need Java and the Firebase CLI.
