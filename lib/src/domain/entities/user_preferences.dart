import '../../core/constants/app_constants.dart';

class UserPreferences {
  const UserPreferences({
    required this.foodPreference,
    required this.region,
    required this.timePreference,
    this.notificationsEnabled = true,
  });

  final FoodPreference foodPreference;
  final String region;
  final TimePreference timePreference;
  final bool notificationsEnabled;

  UserPreferences copyWith({
    FoodPreference? foodPreference,
    String? region,
    TimePreference? timePreference,
    bool? notificationsEnabled,
  }) {
    return UserPreferences(
      foodPreference: foodPreference ?? this.foodPreference,
      region: region ?? this.region,
      timePreference: timePreference ?? this.timePreference,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toMap() => {
        'foodPreference': foodPreference.name,
        'region': region,
        'timePreference': timePreference.name,
        'notificationsEnabled': notificationsEnabled,
      };

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      foodPreference: FoodPreference.fromId(map['foodPreference'] as String? ?? ''),
      region: map['region'] as String? ?? 'Other',
      timePreference: TimePreference.fromId(map['timePreference'] as String? ?? ''),
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
    );
  }
}
