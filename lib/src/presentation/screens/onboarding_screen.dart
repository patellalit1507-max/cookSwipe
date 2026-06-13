import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/user_preferences.dart';
import '../providers/providers.dart';
import 'home_shell.dart';

/// First-launch preference capture (3 quick steps). Also reused from
/// Settings with [editMode] to update preferences later.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.editMode = false});

  final bool editMode;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  FoodPreference? _foodPreference;
  String? _region;
  TimePreference? _timePreference;

  @override
  void initState() {
    super.initState();
    if (widget.editMode) {
      final current = ref.read(userPreferencesProvider);
      _foodPreference = current?.foodPreference;
      _region = current?.region;
      _timePreference = current?.timePreference;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _canContinue => switch (_page) {
        0 => _foodPreference != null,
        1 => _region != null,
        _ => _timePreference != null,
      };

  Future<void> _next() async {
    if (_page < 2) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    final storage = ref.read(localStorageProvider);
    final notifications = ref.read(notificationServiceProvider);
    final prefs = UserPreferences(
      foodPreference: _foodPreference!,
      region: _region!,
      timePreference: _timePreference!,
      notificationsEnabled: storage.notificationsEnabled,
    );
    await ref.read(userPreferencesProvider.notifier).save(prefs);
    await storage.setOnboardingComplete();

    if (!widget.editMode && storage.notificationsEnabled) {
      final granted = await notifications.requestPermission();
      if (granted) await notifications.scheduleDailyReminders();
    }

    if (!mounted) return;
    if (widget.editMode) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.editMode
          ? AppBar(title: const Text('Edit Preferences'))
          : null,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Step indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppTheme.saffron
                        : AppTheme.saffron.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _StepPage(
                    emoji: '🥗',
                    title: 'What do you eat?',
                    subtitle: 'We only suggest dishes that match.',
                    child: Column(
                      children: [
                        for (final option in FoodPreference.values)
                          _OptionCard(
                            label: option.label,
                            selected: _foodPreference == option,
                            onTap: () =>
                                setState(() => _foodPreference = option),
                          ),
                      ],
                    ),
                  ),
                  _StepPage(
                    emoji: '📍',
                    title: 'Where are you from?',
                    subtitle: 'Local favourites get suggested first.',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final region in AppRegions.options)
                          ChoiceChip(
                            label: Text(region),
                            selected: _region == region,
                            selectedColor:
                                AppTheme.saffron.withValues(alpha: 0.18),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _region == region
                                  ? AppTheme.saffron
                                  : AppTheme.deepCharcoal,
                            ),
                            onSelected: (_) =>
                                setState(() => _region = region),
                          ),
                      ],
                    ),
                  ),
                  _StepPage(
                    emoji: '⏱️',
                    title: 'How much time do you have?',
                    subtitle: 'Only quick dishes if you want.',
                    child: Column(
                      children: [
                        for (final option in TimePreference.values)
                          _OptionCard(
                            label: option.label,
                            selected: _timePreference == option,
                            onTap: () =>
                                setState(() => _timePreference = option),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: FilledButton(
                onPressed: _canContinue ? _next : null,
                child: Text(_page < 2
                    ? 'Continue'
                    : (widget.editMode ? 'Save' : 'Start Cooking')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepPage extends StatelessWidget {
  const _StepPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: selected ? AppTheme.saffron.withValues(alpha: 0.12) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppTheme.saffron : Colors.grey.shade200,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? AppTheme.saffron
                          : AppTheme.deepCharcoal,
                    ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: selected ? AppTheme.saffron : Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
