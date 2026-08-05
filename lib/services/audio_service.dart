import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

enum AudioType { bgm, sfx, jumpscare, voice }

class AudioService with ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

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
    'assets/audio/bgm/main_menu.mp3',
    'assets/audio/bgm/chapter_01.mp3',
    'assets/audio/bgm/chapter_02.mp3',
    'assets/audio/bgm/chapter_03.mp3',
    'assets/audio/bgm/exploration_01.mp3',
    'assets/audio/bgm/exploration_02.mp3',
    'assets/audio/bgm/exploration_03.mp3',
    'assets/audio/bgm/tension_01.mp3',
    'assets/audio/bgm/tension_02.mp3',
    'assets/audio/bgm/tension_03.mp3',
    'assets/audio/bgm/puzzle_01.mp3',
    'assets/audio/bgm/puzzle_02.mp3',
    'assets/audio/bgm/chase_01.mp3',
    'assets/audio/bgm/chase_02.mp3',
    'assets/audio/bgm/safe_room.mp3',
    'assets/audio/bgm/ending_good.mp3',
    'assets/audio/bgm/ending_bad.mp3',
    'assets/audio/bgm/ending_true.mp3',
    'assets/audio/bgm/flashback_01.mp3',
    'assets/audio/bgm/flashback_02.mp3',
    'assets/audio/bgm/ritual.mp3',
    'assets/audio/bgm/ghost_appear.mp3',
    'assets/audio/bgm/whispers.mp3',
    'assets/audio/bgm/heartbeat.mp3',
    'assets/audio/bgm/breathing.mp3',
    'assets/audio/bgm/creak_01.mp3',
    'assets/audio/bgm/creak_02.mp3',
    'assets/audio/bgm/wind_howl.mp3',
    'assets/audio/bgm/rain.mp3',
    'assets/audio/bgm/drip.mp3',
    'assets/audio/bgm/bell.mp3',
    'assets/audio/bgm/drum.mp3',
    'assets/audio/bgm/dizi.mp3',
    'assets/audio/bgm/erhu.mp3',
    'assets/audio/bgm/guzheng.mp3',
  ];

  final Map<String, List<String>> _sfxEffects = {
    'door_open': ['assets/audio/sfx/door_open_01.mp3', 'assets/audio/sfx/door_open_02.mp3'],
    'door_close': ['assets/audio/sfx/door_close_01.mp3'],
    'footstep': ['assets/audio/sfx/footstep_01.mp3', 'assets/audio/sfx/footstep_02.mp3', 'assets/audio/sfx/footstep_03.mp3'],
    'item_pickup': ['assets/audio/sfx/item_pickup.mp3'],
    'item_use': ['assets/audio/sfx/item_use.mp3'],
    'paper_flip': ['assets/audio/sfx/paper_flip.mp3'],
    'candle_light': ['assets/audio/sfx/candle_light.mp3'],
    'candle_blow': ['assets/audio/sfx/candle_blow.mp3'],
    'water_drop': ['assets/audio/sfx/water_drop.mp3'],
    'thunder': ['assets/audio/sfx/thunder_01.mp3', 'assets/audio/sfx/thunder_02.mp3'],
    'window_knock': ['assets/audio/sfx/window_knock.mp3'],
    'whisper': ['assets/audio/sfx/whisper_01.mp3', 'assets/audio/sfx/whisper_02.mp3', 'assets/audio/sfx/whisper_03.mp3'],
    'heartbeat': ['assets/audio/sfx/heartbeat_fast.mp3'],
    'breath': ['assets/audio/sfx/heavy_breath.mp3'],
    'key_turn': ['assets/audio/sfx/key_turn.mp3'],
    'lock_pick': ['assets/audio/sfx/lock_pick.mp3'],
    'mirror_break': ['assets/audio/sfx/mirror_break.mp3'],
    'gust': ['assets/audio/sfx/gust.mp3'],
    'puzzle_success': ['assets/audio/sfx/puzzle_success.mp3'],
    'puzzle_fail': ['assets/audio/sfx/puzzle_fail.mp3'],
    'item_combine': ['assets/audio/sfx/item_combine.mp3'],
    'inventory_open': ['assets/audio/sfx/inventory_open.mp3'],
    'dialogue_open': ['assets/audio/sfx/dialogue_open.mp3'],
    'save': ['assets/audio/sfx/save.mp3'],
    'damage': ['assets/audio/sfx/damage.mp3'],
    'sanity_down': ['assets/audio/sfx/sanity_down.mp3'],
    'examine': ['assets/audio/sfx/paper_flip.mp3'],
    'jumpscare': ['assets/audio/sfx/thunder_01.mp3', 'assets/audio/sfx/mirror_break.mp3'],
    'wind_howling': ['assets/audio/bgm/wind_howl.mp3'],
    'water_drip': ['assets/audio/bgm/drip.mp3'],
    'creaking_door': ['assets/audio/sfx/door_open_01.mp3'],
    'wedding_music_box': ['assets/audio/bgm/ritual.mp3'],
  };

  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  double get jumpscareVolume => _jumpscareVolume;
  double get voiceVolume => _voiceVolume;
  bool get isMuted => _isMuted;
  String? get currentBgm => _currentBgm;

  Future<void> playBgm(String trackPath, {bool loop = true}) async {
    if (_currentBgm == trackPath && !_isBgmPaused) return;
    await _bgmPlayer.stop();
    _currentBgm = trackPath;
    _isBgmPaused = false;
    await _bgmPlayer.setVolume(_isMuted ? 0 : _bgmVolume);
    await _bgmPlayer.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
    await _bgmPlayer.play(AssetSource(trackPath));
  }

  Future<void> playRandomBgm(List<String> tracks) async {
    final random = Random();
    final track = tracks[random.nextInt(tracks.length)];
    await playBgm(track);
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
    _currentBgm = null;
  }

  Future<void> pauseBgm() async {
    await _bgmPlayer.pause();
    _isBgmPaused = true;
  }

  Future<void> resumeBgm() async {
    await _bgmPlayer.resume();
    _isBgmPaused = false;
  }

  Future<void> playSfx(String effectName, {bool loop = false}) async {
    List<String> effects = _sfxEffects[effectName] ?? [];
    String effect;
    if (effects.isEmpty) {
      effect = 'assets/audio/sfx/$effectName.mp3';
    } else {
      final random = Random();
      effect = effects[random.nextInt(effects.length)];
    }
    await _sfxPlayer.setVolume(_isMuted ? 0 : _sfxVolume);
    if (loop) {
      await _sfxPlayer.setReleaseMode(ReleaseMode.loop);
    } else {
      await _sfxPlayer.setReleaseMode(ReleaseMode.release);
    }
    await _sfxPlayer.play(AssetSource(effect));
  }

  Future<void> playJumpscare(List<String> sounds) async {
    if (sounds.isEmpty) return;
    final random = Random();
    final sound = sounds[random.nextInt(sounds.length)];
    await _jumpscarePlayer.setVolume(_isMuted ? 0 : _jumpscareVolume);
    await _jumpscarePlayer.play(AssetSource(sound));
  }

  Future<void> playJumpscareWithVibration(List<String> sounds) async {
    await playJumpscare(sounds);
  }

  Future<void> playVoice(String voicePath) async {
    await _voicePlayer.setVolume(_isMuted ? 0 : _voiceVolume);
    await _voicePlayer.play(AssetSource(voicePath));
  }

  Future<void> stopVoice() async {
    await _voicePlayer.stop();
  }

  Future<void> stopSfx() async {
    await _sfxPlayer.stop();
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

  Future<void> stopAll() async {
    await _bgmPlayer.stop();
    await _sfxPlayer.stop();
    await _jumpscarePlayer.stop();
    await _voicePlayer.stop();
    for (final player in _activePlayers) {
      await player.stop();
    }
    _activePlayers.clear();
  }

  Future<void> dispose() async {
    await stopAll();
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
    await _jumpscarePlayer.dispose();
    await _voicePlayer.dispose();
  }
}
