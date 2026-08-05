import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../utils/theme.dart';

class JumpscareWidget extends StatefulWidget {
  final double intensity;

  const JumpscareWidget({
    super.key,
    this.intensity = 0.5,
  });

  @override
  State<JumpscareWidget> createState() => _JumpscareWidgetState();
}

class _JumpscareWidgetState extends State<JumpscareWidget> with TickerProviderStateMixin {
  late AnimationController _flashController;
  late AnimationController _shakeController;
  late AnimationController _scaleController;
  final Random _random = Random();
  Timer? _timer;
  bool _showImage = false;
  bool _flashOn = false;
  int _shakeCount = 0;
  int _currentImageIndex = 0;

  final List<String> _ghostFaces = [
    '👻', '😱', '💀', '👹', '😈',
  ];

  @override
  void initState() {
    super.initState();
    
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _triggerJumpscare();
  }

  void _triggerJumpscare() async {
    _currentImageIndex = _random.nextInt(_ghostFaces.length);

    await Future.delayed(const Duration(milliseconds: 100));
    
    if (mounted) {
      setState(() {
        _flashOn = true;
        _showImage = true;
      });
    }

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: (500 * widget.intensity).round());
    }

    _flashController.forward().then((_) {
      _flashController.reverse();
    });

    _scaleController.forward();

    _startShaking();

    final duration = (800 + 400 * widget.intensity).round();
    _timer = Timer(Duration(milliseconds: duration), () {
      if (mounted) {
        setState(() {
          _showImage = false;
        });
      }
    });
  }

  void _startShaking() {
    const shakeDuration = Duration(milliseconds: 50);
    Timer.periodic(shakeDuration, (timer) {
      if (!mounted || _shakeCount > 20) {
        timer.cancel();
        return;
      }
      setState(() {
        _shakeCount++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flashController.dispose();
    _shakeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showImage) return const SizedBox.shrink();

    final dx = _random.nextDouble() * 20 * widget.intensity - 10 * widget.intensity;
    final dy = _random.nextDouble() * 20 * widget.intensity - 10 * widget.intensity;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          if (_flashOn)
            AnimatedBuilder(
              animation: _flashController,
              builder: (context, child) {
                return Container(
                  color: Colors.white.withOpacity((1 - _flashController.value) * 0.8),
                );
              },
            ),
          Center(
            child: AnimatedBuilder(
              animation: _scaleController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.3 + _scaleController.value * (0.5 + widget.intensity * 0.5),
                  child: Transform.translate(
                    offset: Offset(dx * (_shakeCount % 2 == 0 ? 1 : -1), dy),
                    child: child,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _ghostFaces[_currentImageIndex],
                        style: TextStyle(
                          fontSize: 200 + widget.intensity * 100,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '啊！！！',
                        style: TextStyle(
                          fontSize: 50 + widget.intensity * 30,
                          color: HorrorTheme.bloodRed,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ChineseBrush',
                          shadows: [
                            Shadow(
                              color: HorrorTheme.bloodRed.withOpacity(0.8),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: HorrorTheme.bloodRed.withOpacity(widget.intensity * 0.5),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
