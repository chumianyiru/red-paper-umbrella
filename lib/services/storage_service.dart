import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _keyFirstPlay = 'first_play';
  static const String _keyDisclaimerAccepted = 'disclaimer_accepted';
  static const String _keyVolume = 'volume';
  static const String _keySfxEnabled = 'sfx_enabled';
  static const String _keyBgmEnabled = 'bgm_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';
  static const String _keySaveData = 'save_data';
  static const String _keyHintsUsed = 'hints_used';

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  bool get isFirstPlay => _prefs.getBool(_keyFirstPlay) ?? true;
  bool get isDisclaimerAccepted => _prefs.getBool(_keyDisclaimerAccepted) ?? false;
  double get volume => _prefs.getDouble(_keyVolume) ?? 0.8;
  bool get sfxEnabled => _prefs.getBool(_keySfxEnabled) ?? true;
  bool get bgmEnabled => _prefs.getBool(_keyBgmEnabled) ?? true;
  bool get vibrationEnabled => _prefs.getBool(_keyVibrationEnabled) ?? true;
  int get hintsUsed => _prefs.getInt(_keyHintsUsed) ?? 0;

  Future<void> setFirstPlay(bool value) async {
    await _prefs.setBool(_keyFirstPlay, value);
  }

  Future<void> setDisclaimerAccepted(bool value) async {
    await _prefs.setBool(_keyDisclaimerAccepted, value);
  }

  Future<void> setVolume(double value) async {
    await _prefs.setDouble(_keyVolume, value);
  }

  Future<void> setSfxEnabled(bool value) async {
    await _prefs.setBool(_keySfxEnabled, value);
  }

  Future<void> setBgmEnabled(bool value) async {
    await _prefs.setBool(_keyBgmEnabled, value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    await _prefs.setBool(_keyVibrationEnabled, value);
  }

  Future<void> incrementHintsUsed() async {
    await _prefs.setInt(_keyHintsUsed, hintsUsed + 1);
  }

  Future<void> saveGame(Map<String, dynamic> saveData) async {
    final jsonStr = jsonEncode(saveData);
    await _prefs.setString(_keySaveData, jsonStr);
  }

  Map<String, dynamic>? loadGame() {
    final jsonStr = _prefs.getString(_keySaveData);
    if (jsonStr == null) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSave() async {
    await _prefs.remove(_keySaveData);
  }

  Future<void> resetSettings() async {
    await _prefs.remove(_keyVolume);
    await _prefs.remove(_keySfxEnabled);
    await _prefs.remove(_keyBgmEnabled);
    await _prefs.remove(_keyVibrationEnabled);
  }

  Future<void> clearGameData() async {
    await _prefs.remove(_keySaveData);
    await _prefs.remove(_keyHintsUsed);
  }
}
