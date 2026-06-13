// PLACEHOLDER FILE — replace by running:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// That command connects the app to your Firebase project and regenerates
// this file with real keys. Until then the app runs in local-only mode
// (bundled dataset, local favorites/history, no analytics/crashlytics).
//
// See docs/FIREBASE_SETUP.md for the full walkthrough.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const String _placeholder = 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE';

  /// True once `flutterfire configure` has regenerated this file.
  static bool get isConfigured => !android.apiKey.contains('REPLACE_WITH');

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web — '
        'run flutterfire configure.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS support: run `flutterfire configure` and select iOS — '
          'the Dart codebase needs no changes.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCL92aVtSe1UwcpHl-kN49jQJiWt50Zhls',
    appId: '1:840413887064:android:9bd0c06cd3d6a2603ee82d',
    messagingSenderId: '840413887064',
    projectId: 'cookswipe-e2fc1',
    storageBucket: 'cookswipe-e2fc1.firebasestorage.app',
  );
}
