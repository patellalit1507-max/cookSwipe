import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/core/services/notification_service.dart';
import 'src/presentation/providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final firebaseReady = await _initFirebase();

  // Ads and notifications are best-effort: the app must always start,
  // even with no network and no Firebase configuration.
  unawaited(_initAds());
  final notificationService = NotificationService();
  await notificationService.init(firebaseEnabled: firebaseReady);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        firebaseAvailableProvider.overrideWithValue(firebaseReady),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const CookSwipeApp(),
    ),
  );
}

/// Initializes Firebase + Crashlytics + anonymous auth.
///
/// Returns false (and the app falls back to fully-local mode using the
/// bundled dataset) when Firebase has not been configured yet — i.e. before
/// `flutterfire configure` has replaced lib/firebase_options.dart.
Future<bool> _initFirebase() async {
  if (!DefaultFirebaseOptions.isConfigured) {
    debugPrint(
      'CookSwipe: Firebase is not configured. Run `flutterfire configure` '
      '(see docs/FIREBASE_SETUP.md). Running in local-only mode.',
    );
    return false;
  }
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    if (!kDebugMode) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    // Anonymous auth gives every install a stable uid for Firestore docs
    // without forcing a login screen.
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    return true;
  } catch (e, s) {
    debugPrint('CookSwipe: Firebase init failed ($e). Running in local-only mode.\n$s');
    return false;
  }
}

Future<void> _initAds() async {
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('CookSwipe: AdMob init failed: $e');
  }
}
