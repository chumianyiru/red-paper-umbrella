import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

enum AudioType { bgm, sfx, jumpscare, voice }

class AudioService extends ChangeNotifier {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _jumpscarePlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer();
  final List<AudioPlayer> _activePlayers = [];

  double _bgmVolume = 0.5;
  double _sfxVolume = 0.7;
  double _jumpscareVolume = 1.0;
  double _voiceVolume = 0.8;
  bool _isMuted = false;
  String? _currentBgm;
  bool _isBgmPaused = false;

  final List<String> _bgmTracks = [
    'audio/bgm/main_menu.mp3',
    'audio/bgm/chapter_01.mp3',
  ];

  final Map<String, List<String>> _sfxEffects = {
    'door_open': ['audio/sfx/door_open_01.mp3'],
    'door_close': ['audio/sfx/door_close_01.mp3'],
    'footstep': ['audio/sfx/footstep_01.mp3'],
    'item_pickup': ['audio/sfx/item_pickup.mp3'],
    'item_use': ['audio/sfx/item_use.mp3'],
    'paper_flip': ['audio/sfx/paper_flip.mp3'],
    'examine': ['audio/sfx/paper_flip.mp3'],
    'jumpscare': ['audio/sfx/thunder_01.mp3'],
    'wind_howling': ['audio/bgm/wind_howl.mp3'],
    'water_drip': ['audio/bgm/drip.mp3'],
    'creaking_door': ['audio/sfx/door_open_01.mp3'],
    'wedding_music_box': ['audio/bgm/ritual.mp3'],
  };

  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  double get jumpscareVolume => _jumpscareVolume;
  double get voiceVolume => _voiceVolume;
  bool get isMuted => _isMuted;
  String? get currentBgm => _currentBgm;

  Future<void> playBgm(String trackPath, {bool loop = true}) async {
    // AssetSource already adds 'assets/' prefix, so remove if present
    final assetPath = trackPath.startsWith('assets/') ? trackPath.substring(7) : trackPath;
    if (_currentBgm == assetPath && !_isBgmPaused) return;
    try {
      await _bgmPlayer.stop();
      _currentBgm = assetPath;
      _isBgmPaused = false;
      await _bgmPlayer.setVolume(_isMuted ? 0 : _bgmVolume);
      await _bgmPlayer.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
      await _bgmPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing BGM: $e');
    }
  }

  Future<void> playRandomBgm(List<String> tracks) async {
    if (tracks.isEmpty) return;
    final random = Random();
    final track = tracks[random.nextInt(tracks.length)];
    await playBgm(track);
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
      _currentBgm = null;
    } catch (e) {
      debugPrint('Error stopping BGM: $e');
    }
  }

  Future<void> pauseBgm() async {
    try {
      await _bgmPlayer.pause();
      _isBgmPaused = true;
    } catch (e) {
      debugPrint('Error pausing BGM: $e');
    }
  }

  Future<void> resumeBgm() async {
    try {
      await _bgmPlayer.resume();
      _isBgmPaused = false;
    } catch (e) {
      debugPrint('Error resuming BGM: $e');
    }
  }

  Future<void> playSfx(String effectName, {bool loop = false}) async {
    try {
      List<String> effects = _sfxEffects[effectName] ?? [];
      String effect;
      if (effects.isEmpty) {
        effect = 'audio/sfx/$effectName.mp3';
      } else {
        final random = Random();
        effect = effects[random.nextInt(effects.length)];
      }
      final assetPath = effect.startsWith('assets/') ? effect.substring(7) : effect;
      await _sfxPlayer.setVolume(_isMuted ? 0 : _sfxVolume);
      if (loop) {
        await _sfxPlayer.setReleaseMode(ReleaseMode.loop);
      } else {
        await _sfxPlayer.setReleaseMode(ReleaseMode.release);
      }
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing SFX: $e');
    }
  }

  Future<void> playJumpscare(List<String> sounds) async {
    if (sounds.isEmpty) return;
    try {
      final random = Random();
      final sound = sounds[random.nextInt(sounds.length)];
      final assetPath = sound.startsWith('assets/') ? sound.substring(7) : sound;
      await _jumpscarePlayer.setVolume(_isMuted ? 0 : _jumpscareVolume);
      await _jumpscarePlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing jumpscare: $e');
    }
  }

  Future<void> playVoice(String voicePath) async {
    try {
      final assetPath = voicePath.startsWith('assets/') ? voicePath.substring(7) : voicePath;
      await _voicePlayer.setVolume(_isMuted ? 0 : _voiceVolume);
      await _voicePlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing voice: $e');
    }
  }

  Future<void> stopVoice() async {
    try {
      await _voicePlayer.stop();
    } catch (e) {
      debugPrint('Error stopping voice: $e');
    }
  }

  Future<void> stopSfx() async {
    try {
      await _sfxPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping SFX: $e');
    }
  }

  void setBgmVolume(double volume) {
    _bgmVolume = volume.clamp(0.0, 1.0);
    _bgmPlayer.setVolume(_isMuted ? 0 : _bgmVolume);
    notifyListeners();
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setJumpscareVolume(double volume) {
    _jumpscareVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setVoiceVolume(double volume) {
    _voiceVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _bgmPlayer.setVolume(_isMuted ? 0 : _bgmVolume);
    notifyListeners();
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    _bgmPlayer.setVolume(_isMuted ? 0 : _bgmVolume);
    notifyListeners();
  }

  Future<void> init() async {
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _sfxPlayer.setReleaseMode(ReleaseMode.release);
      await _jumpscarePlayer.setReleaseMode(ReleaseMode.release);
      await _voicePlayer.setReleaseMode(ReleaseMode.release);
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
  }

  Future<void> stopAll() async {
    try {
      await _bgmPlayer.stop();
      await _sfxPlayer.stop();
      await _jumpscarePlayer.stop();
      await _voicePlayer.stop();
      for (final player in _activePlayers) {
        await player.stop();
      }
      _activePlayers.clear();
    } catch (e) {
      debugPrint('Error stopping all: $e');
    }
  }

  @override
  void dispose() {
    stopAll();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    _jumpscarePlayer.dispose();
    _voicePlayer.dispose();
    super.dispose();
  }
}
