import '../models/user_settings.dart';

class SettingsService {
  Future<UserSettings> getUserSettings() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    return UserSettings(
      energyRate: 0.12,
      currency: 'USD',
      darkMode: false,
      notificationsEnabled: true,
      dailyEnergyTarget: 3000,
      notificationPreferences: [
        'usage_alerts',
        'cost_alerts',
        'schedule_reminders',
      ],
    );
  }

  Future<void> updateSettings(UserSettings settings) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }
}

