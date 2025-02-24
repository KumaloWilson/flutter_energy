class UserSettings {
  final double energyRate;
  final String currency;
  final bool darkMode;
  final bool notificationsEnabled;
  final double dailyEnergyTarget;
  final List<String> notificationPreferences;

  UserSettings({
    required this.energyRate,
    required this.currency,
    required this.darkMode,
    required this.notificationsEnabled,
    required this.dailyEnergyTarget,
    required this.notificationPreferences,
  });
}

