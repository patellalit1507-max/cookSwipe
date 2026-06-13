# CookSwipe — Firebase Setup Guide

The app **runs out of the box without Firebase** (local mode: bundled
1,000+ dish dataset, on-device favorites/menu/history). Follow this guide
to enable cloud sync, analytics, crashlytics, FCM, and the admin panel.

## 1. Create the Firebase project

1. Go to <https://console.firebase.google.com> → **Add project** → name it
   `cookswipe` (any name works).
2. Enable **Google Analytics** for the project when asked (required for
   Firebase Analytics events).

## 2. Connect the Flutter app

```bash
# One-time tooling
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli

# From the project root
flutterfire configure
```

Select your Firebase project and the **android** platform. This:

* registers the Android app (`com.cookswipe.cookswipe`),
* downloads `android/app/google-services.json`,
* regenerates `lib/firebase_options.dart` with real keys.

> The Gradle build applies the `google-services` and `crashlytics` plugins
> automatically once `google-services.json` exists — no Gradle edits needed.

## 3. Enable services in the console

| Service | Console location | Setting |
|---|---|---|
| Authentication | Build → Authentication → Sign-in method | Enable **Anonymous** |
| Firestore | Build → Firestore Database | Create database (production mode) |
| Storage | Build → Storage | Get started |
| Crashlytics | Release & Monitor → Crashlytics | Enable |
| Cloud Messaging | Engage → Messaging | Nothing to enable; used for campaigns |

## 4. Deploy security rules

```bash
firebase init firestore storage   # accept existing firestore.rules / storage.rules
firebase deploy --only firestore:rules,storage
```

The rules in `firestore.rules` / `storage.rules` enforce:

* `foodItems` — public read, **admin-only** write
* `users/{uid}` — owner only; the `role` field can never be set from the client
* `favorites`, `selections` — owner only; selections are append-only
* `food_images/*` in Storage — public read, admin-only upload (≤ 5 MB, images only)

## 5. Seed the food dataset (1,066 dishes)

```bash
# One time: Project settings → Service accounts → Generate new private key
# Save as tool/serviceAccountKey.json  (DO NOT COMMIT)

npm install firebase-admin
node tool/seed_firestore.mjs
```

To regenerate the dataset first: `dart run tool/generate_dataset.dart`.

## 6. Create an admin user

1. Run the app once on a device — anonymous sign-in creates `users/{uid}`
   the first time preferences are saved (finish onboarding).
2. Find the uid: Firebase console → Authentication → Users.
3. Firestore → `users` → that uid → add field `role` = `"admin"` (string).
4. Restart the app → **Settings → Admin → Manage food items** appears.

## 7. Firestore schema

```text
foodItems/{id}
  id: string            # slug, e.g. "masala-dosa_breakfast"
  name: string
  category: string      # breakfast | lunch | snacks | dinner
  imageUrl: string
  region: string        # state name or "All India"
  isVeg: boolean
  prepTime: number      # minutes
  difficulty: string    # easy | medium | hard
  popularityScore: number  # 0–100

users/{uid}
  foodPreference: string   # vegetarian | nonVegetarian | both
  region: string
  timePreference: string   # under15 | under30 | any
  notificationsEnabled: boolean
  role: string             # optional, "admin" (set via console only)
  updatedAt: timestamp

favorites/{uid}_{foodId}
  userId: string
  food: map                # full FoodItem snapshot
  createdAt: timestamp

selections/{uuid}
  id, foodId, foodName, imageUrl, category, isVeg, prepTime: …
  selectedAt: string (ISO)
  userId: string
  date: string             # yyyy-MM-dd
  createdAt: timestamp
```

## 8. Analytics events tracked

| Event | When |
|---|---|
| `meal_category_opened` | A meal card is tapped on Home |
| `dish_viewed` | A card appears in the swipe deck |
| `dish_selected` | Right swipe |
| `dish_skipped` | Left swipe |
| `favorite_added` | Selection auto-added to favorites |
| `search_performed` | Search submitted |

## 9. AdMob (before release)

1. Create an app + one **Interstitial** ad unit at <https://apps.admob.com>.
2. Replace the test APPLICATION_ID in `android/app/src/main/AndroidManifest.xml`.
3. Replace `_prodInterstitialId` in `lib/src/core/constants/app_constants.dart`.

The frequency cap (one interstitial per user per day, only after the first
meal selection) is enforced in `lib/src/core/services/ad_service.dart` and
stored locally — do not add other ad formats.

## 10. Notifications

Daily reminders (11:00 lunch, 18:00 dinner) are **local notifications** —
they work with zero server setup and survive reboots. FCM is also wired:
devices subscribe to the `meal_reminders` topic, so you can send campaigns
from Firebase console → Messaging targeting that topic.

## iOS later

Run `flutterfire configure` again and select iOS — the Dart codebase needs
no changes (Firebase, ads, notifications all use cross-platform plugins).
