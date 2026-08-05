import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import 'audio_service.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  final AudioService _audioService = AudioService();
  final Random _random = Random();
  GameState? _gameState;

  bool _isAdPlaying = false;
  int _adDuration = 30;
  int _currentSeconds = 0;
  Timer? _adTimer;
  final _adController = StreamController<AdEvent>.broadcast();

  Stream<AdEvent> get adStream => _adController.stream;
  bool get isAdPlaying => _isAdPlaying;
  int get currentSeconds => _currentSeconds;
  int get adDuration => _adDuration;

  final List<String> _simulatedAds = [
    '恐怖电影预告：《纸新娘》',
    '密室逃脱广告：敢来挑战吗？',
    '恐怖游戏推荐：《深夜回门》',
    '鬼屋冒险宣传：勇气试炼',
    '恐怖小说广告：《红衣》',
    '万圣节活动：惊魂夜派对',
    '恐怖解谜：《冥婚》',
    '密室广告：《停尸间》',
  ];

  String? _currentAdContent;
  String? get currentAdContent => _currentAdContent;

  void init(GameState gameState) {
    _gameState = gameState;
  }

  Future<bool> showAdForHint() async {
    if (_isAdPlaying) return false;

    _isAdPlaying = true;
    _currentSeconds = 0;
    _currentAdContent = _simulatedAds[_random.nextInt(_simulatedAds.length)];
    _gameState?.setPhase(GamePhase.advertisement);

    _adController.add(AdEvent(
      type: AdEventType.start,
      content: _currentAdContent!,
      duration: _adDuration,
    ));

    _audioService.playSfx('ad_start.mp3');

    final completer = Completer<bool>();

    _adTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentSeconds++;
      _adController.add(AdEvent(
        type: AdEventType.progress,
        content: _currentAdContent!,
        currentSecond: _currentSeconds,
        duration: _adDuration,
      ));

      if (_currentSeconds >= _adDuration) {
        timer.cancel();
        _isAdPlaying = false;
        _adController.add(AdEvent(
          type: AdEventType.complete,
          content: _currentAdContent!,
        ));
        _gameState?.setPhase(GamePhase.playing);
        completer.complete(true);
      }
    });

    return completer.future;
  }

  void skipAd() {
    if (!_isAdPlaying) return;
    _adTimer?.cancel();
    _isAdPlaying = false;
    _adController.add(AdEvent(
      type: AdEventType.skipped,
      content: _currentAdContent,
    ));
    _gameState?.setPhase(GamePhase.playing);
  }

  void dispose() {
    _adTimer?.cancel();
    _adController.close();
  }
}

enum AdEventType {
  start,
  progress,
  complete,
  skipped,
}

class AdEvent {
  final AdEventType type;
  final String? content;
  final int? currentSecond;
  final int? duration;

  const AdEvent({
    required this.type,
    this.content,
    this.currentSecond,
    this.duration,
  });
}
