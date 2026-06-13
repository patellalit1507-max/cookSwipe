# CookSwipe 🍳

**Never wonder what to cook again.**

CookSwipe removes meal-decision fatigue: pick a meal (Breakfast, Lunch,
Snacks, Dinner), swipe through dish suggestions one at a time, swipe right
on the one you want. That's the whole app — no recipes, no videos, no
social feed.

## Features

* **Swipe to decide** — right = "I'll cook this", left = "show another"
* **Smart suggestions** — filtered by veg/non-veg, region, and cooking-time
  preference; avoids recently seen/selected dishes, boosts local favourites
* **Today's Menu** — one slot per meal, replaceable any time, resets daily
* **Favorites** — every selected dish is saved automatically
* **History** — last 30 selections
* **Instant search** — in-memory name search over the full dataset
* **1,066-dish dataset** — bundled offline; also seedable into Firestore
* **Admin panel** — in-app CRUD + image upload (Firestore role-gated)
* **Monetization** — interstitial ads only, max **one per user per day**,
  shown only after the first meal selection of the day
* **Reminders** — daily local notifications at 11:00 and 18:00 (toggleable)
* **Offline-first** — fully usable with no network and no Firebase config

## Tech stack

Flutter (Material 3) · Riverpod · Clean Architecture + Repository Pattern ·
Firebase (Auth, Firestore, Analytics, Crashlytics, Messaging, Storage) ·
Google Mobile Ads · flutter_card_swiper · cached_network_image

## Project structure

```text
lib/
  main.dart                     # bootstrap: Firebase, Crashlytics, Ads, DI
  firebase_options.dart         # placeholder → run `flutterfire configure`
  src/
    app.dart                    # MaterialApp + theme
    core/
      constants/app_constants.dart   # enums, regions, storage keys, ad config
      theme/app_theme.dart
      services/                 # local storage, analytics, ads, notifications
    domain/                     # entities, repository contracts, SuggestionEngine
    data/                       # Firestore/local implementations + models
    presentation/
      providers/                # Riverpod wiring, notifiers, SwipeController
      screens/                  # splash, onboarding, home shell + tabs,
                                # swipe, search, settings, admin/
      widgets/                  # FoodCard, MealCategoryCard, VegIndicator, …
assets/data/food_dataset.json   # generated 1,066-dish dataset
tool/generate_dataset.dart      # dataset generator (dart run tool/generate_dataset.dart)
tool/seed_firestore.mjs         # Firestore seeding script (firebase-admin)
firestore.rules / storage.rules # security rules
docs/FIREBASE_SETUP.md          # full Firebase walkthrough
```

## Build & run

```bash
flutter pub get
flutter run                # debug, works immediately in local mode
flutter test               # suggestion-engine unit tests
flutter analyze
```

No Firebase needed to try the app: it detects the placeholder config and
runs fully offline from the bundled dataset.

### Enable Firebase (cloud sync, analytics, admin, FCM)

See **[docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md)** — short version:

```bash
dart pub global activate flutterfire_cli
flutterfire configure                      # regenerates lib/firebase_options.dart
node tool/seed_firestore.mjs               # seed 1,066 dishes
firebase deploy --only firestore:rules,storage
```

### Release build

1. Replace the AdMob test ids (`AndroidManifest.xml` + `app_constants.dart`).
2. Create a signing key and configure `android/app/build.gradle`
   (currently signs release with the debug key for easy testing):
   ```bash
   keytool -genkey -v -keystore cookswipe-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cookswipe
   ```
3. Build:
   ```bash
   flutter build apk --release        # or: flutter build appbundle
   ```

### iOS later

The codebase is platform-agnostic. Run
`flutter create . --platforms ios`, then `flutterfire configure` for iOS,
add the AdMob iOS App ID to `Info.plist` — no Dart changes required.

## Dataset

`dart run tool/generate_dataset.dart` regenerates
`assets/data/food_dataset.json` (currently 1,066 dishes: 147 breakfast,
370 lunch, 128 snacks, 421 dinner) with deterministic ids, realistic prep
times, difficulty, regional tags and popularity scores. Image URLs are
seeded placeholders (picsum.photos) — replace with real food photography
via the admin panel before launch.
