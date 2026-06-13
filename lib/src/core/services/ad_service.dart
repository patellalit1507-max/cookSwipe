import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/app_constants.dart';
import 'local_storage_service.dart';

/// CookSwipe monetization — intentionally minimal:
///
///   * Interstitial ads ONLY (no banner / rewarded / app-open / native).
///   * At most ONE interstitial per user per day.
///   * Shown only after the FIRST successful meal selection of the day.
///   * The shown-date is stored locally, so the cap survives restarts.
class AdService {
  AdService(this._storage);

  final LocalStorageService _storage;
  bool _inFlight = false;

  bool get _alreadyShownToday =>
      _storage.lastAdShownDate == LocalStorageService.todayKey();

  /// Call after every successful right-swipe. Internally enforces the
  /// one-per-day rule; on every call after the first daily ad it returns
  /// immediately without loading anything.
  Future<void> maybeShowPostSelectionAd() async {
    if (_inFlight || _alreadyShownToday) return;
    _inFlight = true;
    try {
      final done = Completer<void>();
      await InterstitialAd.load(
        adUnitId: AdConfig.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (_) {
                // Mark the day only when the ad actually displays.
                _storage.setLastAdShownDate(LocalStorageService.todayKey());
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                if (!done.isCompleted) done.complete();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('Interstitial failed to show: $error');
                ad.dispose();
                if (!done.isCompleted) done.complete();
              },
            );
            ad.show();
          },
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial failed to load: $error');
            if (!done.isCompleted) done.complete();
          },
        ),
      );
      // Never block the UX for long if the network is slow.
      await done.future.timeout(const Duration(seconds: 30), onTimeout: () {});
    } catch (e) {
      debugPrint('AdService error: $e');
    } finally {
      _inFlight = false;
    }
  }
}
