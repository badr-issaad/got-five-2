import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/game_state.dart';

class LocalGameStorage {
  static const _savedGameKey = 'got_five_saved_game_state_v1';
  static const _themeModeKey = 'got_five_theme_mode';
  static const _localeKey = 'got_five_preferred_locale';
  static const _soundEnabledKey = 'got_five_sound_enabled';
  static const _hapticEnabledKey = 'got_five_haptic_enabled';
  static const _reducedMotionKey = 'got_five_reduced_motion';

  final SharedPreferences _prefs;

  LocalGameStorage(this._prefs);

  static Future<LocalGameStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalGameStorage(prefs);
  }

  /// Save active game state
  Future<void> saveGame(GameState state) async {
    final jsonStr = jsonEncode(state.toJson());
    await _prefs.setString(_savedGameKey, jsonStr);
  }

  /// Load saved game state if any
  GameState? loadSavedGame() {
    final jsonStr = _prefs.getString(_savedGameKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return GameState.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Clear saved game when completed or abandoned
  Future<void> clearSavedGame() async {
    await _prefs.remove(_savedGameKey);
  }

  /// Save player deduction notes & 5 guess boxes per match and per player
  Future<void> savePlayerNotes({
    required String gameId,
    required String playerId,
    required Set<int> crossedOut,
    required List<String> guesses,
    Set<int> autoFilledSlots = const {},
  }) async {
    final crossedKey = 'got_five_notes_${gameId}_${playerId}_crossed';
    final guessesKey = 'got_five_notes_${gameId}_${playerId}_guesses';
    final autoFilledKey = 'got_five_notes_${gameId}_${playerId}_autofilled';
    await _prefs.setString(crossedKey, jsonEncode(crossedOut.toList()));
    await _prefs.setString(guessesKey, jsonEncode(guesses));
    await _prefs.setString(autoFilledKey, jsonEncode(autoFilledSlots.toList()));
  }

  /// Load player deduction notes & 5 guess boxes per match and per player
  ({Set<int> crossedOut, List<String> guesses, Set<int> autoFilledSlots}) loadPlayerNotes({
    required String gameId,
    required String playerId,
  }) {
    final crossedKey = 'got_five_notes_${gameId}_${playerId}_crossed';
    final guessesKey = 'got_five_notes_${gameId}_${playerId}_guesses';
    final autoFilledKey = 'got_five_notes_${gameId}_${playerId}_autofilled';

    Set<int> crossed = {};
    final crossedStr = _prefs.getString(crossedKey);
    if (crossedStr != null && crossedStr.isNotEmpty) {
      try {
        final list = (jsonDecode(crossedStr) as List).cast<int>();
        crossed = list.toSet();
      } catch (_) {}
    }

    List<String> guesses = List.filled(5, '');
    final guessesStr = _prefs.getString(guessesKey);
    if (guessesStr != null && guessesStr.isNotEmpty) {
      try {
        final list = (jsonDecode(guessesStr) as List).cast<String>();
        if (list.length == 5) {
          guesses = list;
        }
      } catch (_) {}
    }

    Set<int> autoFilled = {};
    final autoFilledStr = _prefs.getString(autoFilledKey);
    if (autoFilledStr != null && autoFilledStr.isNotEmpty) {
      try {
        final list = (jsonDecode(autoFilledStr) as List).cast<int>();
        autoFilled = list.toSet();
      } catch (_) {}
    }

    return (crossedOut: crossed, guesses: guesses, autoFilledSlots: autoFilled);
  }

  /// Settings: Locale
  String getPreferredLocale() {
    return _prefs.getString(_localeKey) ?? 'ar'; // Default Arabic as requested
  }

  Future<void> setPreferredLocale(String localeCode) async {
    await _prefs.setString(_localeKey, localeCode);
  }

  /// Settings: Theme mode ('light', 'dark', 'system')
  String getThemeMode() {
    return _prefs.getString(_themeModeKey) ?? 'dark'; // Sleek dark default
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_themeModeKey, mode);
  }

  /// Settings: Audio & Haptics
  bool isSoundEnabled() => _prefs.getBool(_soundEnabledKey) ?? true;
  Future<void> setSoundEnabled(bool value) => _prefs.setBool(_soundEnabledKey, value);

  bool isHapticEnabled() => _prefs.getBool(_hapticEnabledKey) ?? true;
  Future<void> setHapticEnabled(bool value) => _prefs.setBool(_hapticEnabledKey, value);

  bool isReducedMotion() => _prefs.getBool(_reducedMotionKey) ?? false;
  Future<void> setReducedMotion(bool value) => _prefs.setBool(_reducedMotionKey, value);
}
