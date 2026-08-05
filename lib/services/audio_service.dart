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
    'audio/bgm/main_menu.mp3',
    'audio/bgm/chapter_01.mp3',
    'audio/bgm/chapter_02.mp3',
    'audio/bgm/chapter_03.mp3',
    'audio/bgm/exploration_01.mp3',
    'audio/bgm/exploration_02.mp3',
    'audio/bgm/exploration_03.mp3',
    'audio/bgm/tension_01.mp3',
    'audio/bgm/tension_02.mp3',
    'audio/bgm/tension_03.mp3',
    'audio/bgm/puzzle_01.mp3',
    'audio/bgm/puzzle_02.mp3',
    'audio/bgm/chase_01.mp3',
    'audio/bgm/chase_02.mp3',
    'audio/bgm/safe_room.mp3',
    'audio/bgm/ending_good.mp3',
    'audio/bgm/ending_bad.mp3',
    'audio/bgm/ending_true.mp3',
    'audio/bgm/flashback_01.mp3',
    'audio/bgm/flashback_02.mp3',
    'audio/bgm/ritual.mp3',
    'audio/bgm/ghost_appear.mp3',
    'audio/bgm/whispers.mp3',
    'audio/bgm/heartbeat.mp3',
    'audio/bgm/breathing.mp3',
    'audio/bgm/creak_01.mp3',
    'audio/bgm/creak_02.mp3',
    'audio/bgm/wind_howl.mp3',
    'audio/bgm/rain.mp3',
    'audio/bgm/drip.mp3',
    'audio/bgm/bell.mp3',
    'audio/bgm/drum.mp3',
    'audio/bgm/dizi.mp3',
    'audio/bgm/erhu.mp3',
    'audio/bgm/guzheng.mp3',
  ];

  final Map<String, List<String>> _sfxEffects = {
    'door_open': ['audio/sfx/door_open_01.mp3', 'audio/sfx/door_open_02.mp3'],
    'door_close': ['audio/sfx/door_close_01.mp3'],
    'footstep': ['audio/sfx/footstep_01.mp3', 'audio/sfx/footstep_02.mp3', 'audio/sfx/footstep_03.mp3'],
    'item_pickup': ['audio/sfx/item_pickup.mp3'],
    'item_use': ['audio/sfx/item_use.mp3'],
    'paper_flip': ['audio/sfx/paper_flip.mp3'],
    'candle_light': ['audio/sfx/candle_light.mp3'],
    'candle_blow': ['audio/sfx/candle_blow.mp3'],
    'water_drop': ['audio/sfx/water_drop.mp3'],
    'thunder': ['audio/sfx/thunder_01.mp3', 'audio/sfx/thunder_02.mp3'],
    'window_knock': ['audio/sfx/window_knock.mp3'],
    'whisper': ['audio/sfx/whisper_01.mp3', 'audio/sfx/whisper_02.mp3', 'audio/sfx/whisper_03.mp3'],
    'heartbeat': ['audio/sfx/heartbeat_fast.mp3'],
    'breath': ['audio/sfx/heavy_breath.mp3'],
    'key_turn': ['audio/sfx/key_turn.mp3'],
    'lock_pick': ['audio/sfx/lock_pick.mp3'],
    'mirror_break': ['audio/sfx/mirror_break.mp3'],
    'gust': ['audio/sfx/gust.mp3'],
    'puzzle_success': ['audio/sfx/puzzle_success.mp3'],
    'puzzle_fail': ['audio/sfx/puzzle_fail.mp3'],
    'item_combine': ['audio/sfx/item_combine.mp3'],
    'inventory_open': ['audio/sfx/inventory_open.mp3'],
    'dialogue_open': ['audio/sfx/dialogue_open.mp3'],
    'save': ['audio/sfx/save.mp3'],
    'damage': ['audio/sfx/damage.mp3'],
    'sanity_down': ['audio/sfx/sanity_down.mp3'],
    'examine': ['audio/sfx/paper_flip.mp3'],
    'jumpscare': ['audio/sfx/thunder_01.mp3', 'audio/sfx/mirror_break.mp3'],
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
    final assetPath = trackPath.startsWith('assets/') ? trackPath.substring(7) : trackPath;
    if (_currentBgm == assetPath && !_isBgmPaused) return;
    await _bgmPlayer.stop();
    _currentBgm = assetPath;
    _isBgmPaused = false;
    await _bgmPlayer.setVolume(_isMuted ? 0 : _bgmVolume);
    await _bgmPlayer.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
    await _bgmPlayer.play(AssetSource(assetPath));
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
      effect = 'audio/sfx/$effectName.mp3';
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
    final assetPath = sound.startsWith('assets/') ? sound.substring(7) : sound;
    await _jumpscarePlayer.setVolume(_isMuted ? 0 : _jumpscareVolume);
    await _jumpscarePlayer.play(AssetSource(assetPath));
  }

  Future<void> playJumpscareWithVibration(List<String> sounds) async {
    await playJumpscare(sounds);
  }

  Future<void> playVoice(String voicePath) async {
    final assetPath = voicePath.startsWith('assets/') ? voicePath.substring(7) : voicePath;
    await _voicePlayer.setVolume(_isMuted ? 0 : _voiceVolume);
    await _voicePlayer.play(AssetSource(assetPath));
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

  Future<void> init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _sfxPlayer.setReleaseMode(ReleaseMode.release);
    await _jumpscarePlayer.setReleaseMode(ReleaseMode.release);
    await _voicePlayer.setReleaseMode(ReleaseMode.release);
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

  @override
  void dispose() {
    _bgmPlayer.stop();
    _sfxPlayer.stop();
    _jumpscarePlayer.stop();
    _voicePlayer.stop();
    for (final player in _activePlayers) {
      player.stop();
    }
    _activePlayers.clear();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    _jumpscarePlayer.dispose();
    _voicePlayer.dispose();
    super.dispose();
  }
}
