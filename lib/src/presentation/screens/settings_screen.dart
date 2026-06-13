import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/providers.dart';
import 'admin/admin_food_list_screen.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _toggleNotifications(bool enabled) async {
    final storage = ref.read(localStorageProvider);
    final notifications = ref.read(notificationServiceProvider);
    final prefs = ref.read(userPreferencesProvider);

    if (enabled) {
      final granted = await notifications.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Notifications are blocked — allow them in system settings.'),
          ));
        }
        return;
      }
      await notifications.scheduleDailyReminders();
    } else {
      await notifications.cancelAll();
    }
    await storage.setNotificationsEnabled(enabled);
    if (prefs != null) {
      await ref
          .read(userPreferencesProvider.notifier)
          .save(prefs.copyWith(notificationsEnabled: enabled));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(localStorageProvider);
    final prefs = ref.watch(userPreferencesProvider);
    final isAdmin = ref.watch(isAdminProvider).asData?.value ?? false;
    final firebaseOn = ref.watch(firebaseAvailableProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel('Preferences'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.tune_rounded, color: AppTheme.saffron),
              title: const Text('Food preferences',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: prefs == null
                  ? const Text('Not set')
                  : Text(
                      '${prefs.foodPreference.label} • ${prefs.region} • ${prefs.timePreference.label}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OnboardingScreen(editMode: true),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel('Notifications'),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_active_rounded,
                  color: AppTheme.saffron),
              title: const Text('Meal reminders',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('11:00 AM for lunch • 6:00 PM for dinner'),
              value: storage.notificationsEnabled,
              activeColor: AppTheme.saffron,
              onChanged: _toggleNotifications,
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 16),
            _SectionLabel('Admin'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings_rounded,
                    color: AppTheme.saffron),
                title: const Text('Manage food items',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Add, edit, delete dishes and images'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminFoodListScreen(),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _SectionLabel('About'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.restaurant_menu_rounded,
                      color: AppTheme.saffron),
                  title: Text('CookSwipe',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('v1.0.0 — Never wonder what to cook again.'),
                ),
                ListTile(
                  leading: Icon(
                    firebaseOn ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                    color: firebaseOn ? AppTheme.vegGreen : Colors.grey,
                  ),
                  title: Text(
                    firebaseOn ? 'Cloud sync active' : 'Local mode',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    firebaseOn
                        ? 'Connected to Firebase'
                        : 'Firebase not configured — data stays on this device',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}
