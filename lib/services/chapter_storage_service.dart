import 'package:shared_preferences/shared_preferences.dart';

class ChapterStorageService {
  static const String _lastCheckedKey = 'last_checked_timestamp';
  static const String _pollingEnabledKey = 'polling_enabled';
  static const String _pollIntervalKey = 'poll_interval_minutes';

  Future<DateTime?> getLastChecked() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastCheckedKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> markChecked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCheckedKey, DateTime.now().toIso8601String());
  }

  Future<bool> getPollingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pollingEnabledKey) ?? true;
  }

  Future<void> savePollingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pollingEnabledKey, enabled);
  }

  Future<int> getPollIntervalMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pollIntervalKey) ?? 60;
  }

  Future<void> savePollIntervalMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pollIntervalKey, minutes);
  }
}
