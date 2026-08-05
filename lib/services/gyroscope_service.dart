import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shake/shake.dart';
import '../models/game_state.dart';

enum GyroPuzzleType {
  shakeTop,
  rotate,
  tilt,
  reflection,
}

class GyroscopeService {
  static final GyroscopeService _instance = GyroscopeService._internal();
  factory GyroscopeService() => _instance;
  GyroscopeService._internal();

  GameState? _gameState;
  bool _isListening = false;
  bool _gyroAvailable = false;
  ShakeDetector? _shakeDetector;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  final _puzzleController = StreamController<GyroPuzzleEvent>.broadcast();
  Stream<GyroPuzzleEvent> get puzzleStream => _puzzleController.stream;

  double _shakeIntensity = 0.0;
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  double _rotationZ = 0.0;
  int _shakeCount = 0;
  DateTime? _lastShakeTime;

  bool get isGyroAvailable => _gyroAvailable;
  double get shakeIntensity => _shakeIntensity;
  double get tiltX => _tiltX;
  double get tiltY => _tiltY;
  double get rotationZ => _rotationZ;
  int get shakeCount => _shakeCount;

  Future<void> init(GameState gameState) async {
    _gameState = gameState;

    try {
      _accelerometerSubscription = accelerometerEvents.listen((event) {
        _processAccelerometer(event);
      });

      try {
        _gyroscopeSubscription = gyroscopeEvents.listen((event) {
          _rotationZ = event.z;
        });
      } catch (e) {
        debugPrint('Gyroscope not available: $e');
      }

      try {
        _magnetometerSubscription = magnetometerEvents.listen((event) {});
      } catch (e) {
        debugPrint('Magnetometer not available: $e');
      }

      _shakeDetector = ShakeDetector.autoStart(
        onPhoneShake: () {
          _onShake();
        },
        shakeThresholdGravity: 2.5,
        shakeSlopTimeMS: 100,
        shakeCountResetTime: 3000,
        minimumShakeCount: 1,
      );

      _gyroAvailable = true;
      _gameState?.setGyroAvailable(true);
    } catch (e) {
      debugPrint('Sensors not available: $e');
      _gyroAvailable = false;
      _gameState?.setGyroAvailable(false);
    }

    _isListening = true;
  }

  void _processAccelerometer(AccelerometerEvent event) {
    _tiltX = event.x;
    _tiltY = event.y;

    final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    _shakeIntensity = magnitude - 9.8;

    if (_shakeIntensity > 10) {
      _puzzleController.add(GyroPuzzleEvent(
        type: GyroPuzzleType.shakeTop,
        intensity: _shakeIntensity,
        value: magnitude,
      ));
    }

    if (event.y > 7 && event.y < 10) {
      _puzzleController.add(GyroPuzzleEvent(
        type: GyroPuzzleType.tilt,
        intensity: 1.0,
        value: event.y,
        direction: 'up',
      ));
    }
  }

  void _onShake() {
    final now = DateTime.now();
    if (_lastShakeTime != null && now.difference(_lastShakeTime!).inMilliseconds < 300) {
      return;
    }
    _lastShakeTime = now;
    _shakeCount++;

    _puzzleController.add(GyroPuzzleEvent(
      type: GyroPuzzleType.shakeTop,
      intensity: 1.0,
      value: _shakeCount.toDouble(),
      shakeCount: _shakeCount,
    ));
  }

  void startPuzzleMode(GyroPuzzleType type) {
    _shakeCount = 0;
    _puzzleController.add(GyroPuzzleEvent(
      type: type,
      intensity: 0.0,
      value: 0.0,
      isStart: true,
    ));
  }

  void resetShakeCount() {
    _shakeCount = 0;
  }

  void manualInput(GyroPuzzleType type, double value) {
    _puzzleController.add(GyroPuzzleEvent(
      type: type,
      intensity: 1.0,
      value: value,
      isManual: true,
    ));
  }

  void stopListening() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _magnetometerSubscription?.cancel();
    _shakeDetector?.stopListening();
    _isListening = false;
  }

  void dispose() {
    stopListening();
    _puzzleController.close();
  }
}

class GyroPuzzleEvent {
  final GyroPuzzleType type;
  final double intensity;
  final double value;
  final int? shakeCount;
  final String? direction;
  final bool isStart;
  final bool isManual;

  const GyroPuzzleEvent({
    required this.type,
    required this.intensity,
    required this.value,
    this.shakeCount,
    this.direction,
    this.isStart = false,
    this.isManual = false,
  });
}
