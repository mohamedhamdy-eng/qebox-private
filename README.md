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
