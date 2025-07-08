import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _favoriteArtworksKey = 'favoriteArtworks';
  static const String _lastVisitedKey = 'lastVisited';
  static const String _themePreferenceKey = 'themePreference';
  static const String _hasSeenIntroKey = 'hasSeenIntro';

  // Get SharedPreferences instance
  static Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  // Save favorite artworks
  static Future<void> saveFavoriteArtworks(List<String> artworkTitles) async {
    final prefs = await _prefs;
    await prefs.setStringList(_favoriteArtworksKey, artworkTitles);
  }

  // Get favorite artworks
  static Future<List<String>> getFavoriteArtworks() async {
    final prefs = await _prefs;
    return prefs.getStringList(_favoriteArtworksKey) ?? [];
  }

  // Save last visited timestamp
  static Future<void> saveLastVisitedTimestamp() async {
    final prefs = await _prefs;
    await prefs.setString(_lastVisitedKey, DateTime.now().toIso8601String());
  }

  // Get last visited timestamp
  static Future<DateTime?> getLastVisitedTimestamp() async {
    final prefs = await _prefs;
    final timestamp = prefs.getString(_lastVisitedKey);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  // Save theme preference (light/dark)
  static Future<void> saveThemePreference(String theme) async {
    final prefs = await _prefs;
    await prefs.setString(_themePreferenceKey, theme);
  }

  // Get theme preference
  static Future<String?> getThemePreference() async {
    final prefs = await _prefs;
    return prefs.getString(_themePreferenceKey);
  }

  // Set has seen intro flag
  static Future<void> setHasSeenIntro(bool hasSeenIntro) async {
    final prefs = await _prefs;
    await prefs.setBool(_hasSeenIntroKey, hasSeenIntro);
  }

  // Get has seen intro flag
  static Future<bool> getHasSeenIntro() async {
    final prefs = await _prefs;
    return prefs.getBool(_hasSeenIntroKey) ?? false;
  }

  // Clear all stored data
  static Future<void> clearAllData() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
