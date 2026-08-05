import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _jumpscarePlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();

  GameState? _gameState;
  String? _currentBgm;
  bool _isInitialized = false;
  double _volume = 0.8;
  bool _sfxEnabled = true;
  bool _bgmEnabled = true;

  Future<void> init() async {
    if (_isInitialized) return;

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    await _sfxPlayer.setReleaseMode(ReleaseMode.release);
    await _jumpscarePlayer.setReleaseMode(ReleaseMode.release);

    _isInitialized = true;
  }

  void setGameState(GameState gameState) {
    _gameState = gameState;
    _volume = gameState.volume;
    _sfxEnabled = gameState.sfxEnabled;
    _bgmEnabled = gameState.bgmEnabled;
  }

  void _updateSettings() {
    if (_gameState != null) {
      _volume = _gameState!.volume;
      _sfxEnabled = _gameState!.sfxEnabled;
      _bgmEnabled = _gameState!.bgmEnabled;
    }
  }

  Future<void> playBgm(String bgmName) async {
    _updateSettings();
    if (!_bgmEnabled) return;
    if (_currentBgm == bgmName) return;

    _currentBgm = bgmName;
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.play(
        AssetSource('audio/bgm/$bgmName'),
        volume: _volume * 0.5,
      );
    } catch (e) {
      debugPrint('BGM play error: $e');
    }
  }

  Future<void> stopBgm() async {
    _currentBgm = null;
    await _bgmPlayer.stop();
  }

  Future<void> playSfx(String sfxName) async {
    _updateSettings();
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(
        AssetSource('audio/sfx/$sfxName'),
        volume: _volume,
      );
    } catch (e) {
      debugPrint('SFX play error: $e');
    }
  }

  Future<void> playJumpscare(String soundName) async {
    _updateSettings();
    if (!_sfxEnabled) return;
    try {
      await _jumpscarePlayer.stop();
      await _jumpscarePlayer.play(
        AssetSource('audio/jumpscares/$soundName'),
        volume: _volume * 1.2,
      );
    } catch (e) {
      debugPrint('Jumpscare sound error: $e');
    }
  }

  Future<void> playAmbient(String soundName) async {
    _updateSettings();
    if (!_sfxEnabled) return;
    try {
      await _ambientPlayer.stop();
      await _ambientPlayer.play(
        AssetSource('audio/sfx/$soundName'),
        volume: _volume * 0.3,
      );
    } catch (e) {
      debugPrint('Ambient sound error: $e');
    }
  }

  Future<void> stopAmbient() async {
    await _ambientPlayer.stop();
  }

  Future<void> pauseAll() async {
    await _bgmPlayer.pause();
    await _ambientPlayer.pause();
  }

  Future<void> resumeAll() async {
    _updateSettings();
    if (_currentBgm != null) {
      await _bgmPlayer.resume();
    }
    await _ambientPlayer.resume();
  }

  Future<void> stopAll() async {
    await _bgmPlayer.stop();
    await _sfxPlayer.stop();
    await _jumpscarePlayer.stop();
    await _ambientPlayer.stop();
    _currentBgm = null;
  }

  void updateVolume() {
    _updateSettings();
    _bgmPlayer.setVolume(_volume * 0.5);
    _sfxPlayer.setVolume(_volume);
    _jumpscarePlayer.setVolume(_volume * 1.2);
    _ambientPlayer.setVolume(_volume * 0.3);
  }

  void dispose() {
    stopAll();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    _jumpscarePlayer.dispose();
    _ambientPlayer.dispose();
    _isInitialized = false;
  }
}
