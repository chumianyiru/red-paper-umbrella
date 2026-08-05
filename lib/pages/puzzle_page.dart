import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../theme/horror_theme.dart';
import '../widgets/horror_painter.dart';
import '../models/scene.dart';
import '../models/game_state.dart';
import '../services/audio_service.dart';
import '../services/gyroscope_service.dart';

class PuzzlePage extends StatefulWidget {
  final PuzzleType puzzleType;
  final VoidCallback onComplete;

  const PuzzlePage({
    super.key,
    required this.puzzleType,
    required this.onComplete,
  });

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> with TickerProviderStateMixin {
  final _audioService = AudioService();
  final _gyroService = GyroscopeService();
  final _random = Random();

  late AnimationController _puzzleAnimController;
  late AnimationController _successController;
  late Animation<double> _spinAnimation;
  late Animation<double> _successFade;
  late Animation<double> _successScale;

  bool _gyroAvailable = false;
  bool _isManualMode = false;
  bool _isCompleted = false;
  double _gyroX = 0;
  double _gyroY = 0;
  double _gyroZ = 0;
  double _manualRotation = 0;
  double _targetRotation = 0;
  double _currentRotation = 0;
  int _shakeCount = 0;
  int _requiredShakes = 8;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();

    _puzzleAnimController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _spinAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _puzzleAnimController, curve: Curves.linear),
    );
    _successFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successController, curve: Curves.easeIn),
    );
    _successScale = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _targetRotation = _random.nextDouble() * 2 * pi;
    _initSensors();
    _playPuzzleAmbient();
  }

  Future<void> _initSensors() async {
    _gyroAvailable = await _gyroService.isGyroAvailable();
    if (mounted) {
      setState(() {});
    }

    if (_gyroAvailable && !_isManualMode) {
      gyroscopeEventStream().listen((event) {
        if (!mounted || _isCompleted) return;
        setState(() {
          _gyroX = event.x;
          _gyroY = event.y;
          _gyroZ = event.z;
          _updateGyroRotation();
        });
      });

      accelerometerEventStream().listen((event) {
        if (!mounted || _isCompleted || _isManualMode) return;
        final acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        if (acceleration > 20) {
          _onShake();
        }
      });
    }
  }

  void _updateGyroRotation() {
    _currentRotation += _gyroZ * 0.05;
    _checkSolution();
  }

  void _onShake() {
    _shakeCount++;
    try {
      _audioService.playSfx('shake.mp3');
    } catch (_) {}
    if (_shakeCount >= _requiredShakes) {
      _completePuzzle();
    }
    setState(() {});
  }

  void _playPuzzleAmbient() {
    try {
      _audioService.playAmbient('puzzle_ambient.mp3');
    } catch (_) {}
  }

  void _toggleManualMode() {
    setState(() => _isManualMode = !_isManualMode);
    try {
      _audioService.playSfx('button_click.mp3');
    } catch (_) {}
  }

  void _onManualRotate(double delta) {
    if (_isCompleted) return;
    setState(() {
      _manualRotation += delta;
      _currentRotation = _manualRotation;
      _checkSolution();
    });
  }

  void _checkSolution() {
    final normalizedCurrent = _currentRotation % (2 * pi);
    final normalizedTarget = _targetRotation % (2 * pi);
    final diff = (normalizedCurrent - normalizedTarget).abs();
    final normalizedDiff = min(diff, 2 * pi - diff);

    if (normalizedDiff < 0.3) {
      _completePuzzle();
    }
  }

  void _completePuzzle() {
    if (_isCompleted) return;
    setState(() => _isCompleted = true);

    try {
      _audioService.playSfx('puzzle_success.mp3');
      _audioService.playJumpscare('success.mp3');
    } catch (_) {}

    _successController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        widget.onComplete();
      }
    });
  }

  void _showHintDialog() {
    setState(() => _showHint = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  @override
  void dispose() {
    _puzzleAnimController.dispose();
    _successController.dispose();
    _gyroService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HorrorTheme.deepBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: HorrorTheme.bloodRed),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getPuzzleTitle(),
          style: const TextStyle(color: HorrorTheme.bloodRed),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isManualMode ? Icons.touch_app : Icons.screen_rotation,
              color: HorrorTheme.bloodRed,
            ),
            onPressed: _toggleManualMode,
            tooltip: _isManualMode ? '陀螺仪模式' : '手动模式',
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline, color: HorrorTheme.bloodRed),
            onPressed: _showHintDialog,
          ),
        ],
      ),
      body: HorrorBackground(
        child: Stack(
          children: [
            _buildPuzzleContent(),
            if (_showHint)
              _buildHintOverlay(),
            if (_isCompleted)
              _buildSuccessOverlay(),
          ],
        ),
      ),
    );
  }

  String _getPuzzleTitle() {
    switch (widget.puzzleType) {
      case PuzzleType.gyroscope:
        return '陀螺解谜';
      case PuzzleType.reflection:
        return '光栅解谜';
      case PuzzleType.sequence:
        return '顺序解谜';
      case PuzzleType.light:
        return '光明解谜';
      case PuzzleType.combination:
        return '组合解谜';
      case PuzzleType.sound:
        return '声音解谜';
      case PuzzleType.none:
        return '解谜';
    }
  }

  Widget _buildPuzzleContent() {
    switch (widget.puzzleType) {
      case PuzzleType.gyroscope:
        return _buildGyroscopePuzzle();
      default:
        return _buildGyroscopePuzzle();
    }
  }

  Widget _buildGyroscopePuzzle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isManualMode ? '手动旋转陀螺对齐标记' : '摇晃手机并旋转陀螺',
            style: const TextStyle(
              color: HorrorTheme.ghostWhite,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          if (!_gyroAvailable && !_isManualMode)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: HorrorTheme.bloodRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: HorrorTheme.bloodRed),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: HorrorTheme.bloodRed),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '您的设备不支持陀螺仪，请切换到手动模式',
                      style: TextStyle(color: HorrorTheme.ghostWhite),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 48),
          _buildGyroscopeVisual(),
          const SizedBox(height: 48),
          if (!_isManualMode)
            Column(
              children: [
                Text(
                  '摇晃进度: $_shakeCount / $_requiredShakes',
                  style: const TextStyle(color: HorrorTheme.paleSkin),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _shakeCount / _requiredShakes,
                      backgroundColor: HorrorTheme.darkGray,
                      valueColor: const AlwaysStoppedAnimation<Color>(HorrorTheme.bloodRed),
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
          if (_isManualMode)
            _buildManualControls(),
        ],
      ),
    );
  }

  Widget _buildGyroscopeVisual() {
    return AnimatedBuilder(
      animation: _puzzleAnimController,
      builder: (context, child) {
        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: HorrorTheme.bloodRed.withOpacity(0.5), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: HorrorTheme.bloodRed.withOpacity(0.3),
                      blurRadius: 30,
                    ),
                  ],
                ),
              ),
              CustomPaint(
                size: const Size(250, 250),
                painter: _CompassPainter(
                  rotation: _currentRotation,
                  targetRotation: _targetRotation,
                  isCompleted: _isCompleted,
                ),
              ),
              Transform.rotate(
                angle: _isCompleted ? _spinAnimation.value : _currentRotation,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        HorrorTheme.bloodRed.withOpacity(0.8),
                        HorrorTheme.darkRed.withOpacity(0.6),
                        HorrorTheme.bloodRed.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: HorrorTheme.bloodRed.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 40,
                          decoration: BoxDecoration(
                            color: HorrorTheme.ghostWhite,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: const [
                              BoxShadow(
                                color: HorrorTheme.bloodRed,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: HorrorTheme.deepBlack,
                          border: Border.fromBorderSide(
                            BorderSide(color: HorrorTheme.bloodRed, width: 2),
                          ),
                        ),
                        child: const Icon(
                          Icons.adjust,
                          color: HorrorTheme.bloodRed,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.rotate(
                angle: _targetRotation,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 4,
                    height: 30,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: HorrorTheme.bloodRed,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: HorrorTheme.bloodRed.withOpacity(0.8),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildManualControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ManualControlButton(
            icon: Icons.rotate_left,
            label: '逆时针',
            onTap: () => _onManualRotate(-0.2),
            onLongPress: () => _onManualRotate(-0.5),
          ),
          const SizedBox(width: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HorrorTheme.darkGray,
              shape: BoxShape.circle,
              border: Border.all(color: HorrorTheme.bloodRed),
            ),
            child: const Icon(
              Icons.touch_app,
              color: HorrorTheme.bloodRed,
              size: 32,
            ),
          ),
          const SizedBox(width: 24),
          _ManualControlButton(
            icon: Icons.rotate_right,
            label: '顺时针',
            onTap: () => _onManualRotate(0.2),
            onLongPress: () => _onManualRotate(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildHintOverlay() {
    return Positioned(
      top: 100,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: HorrorTheme.darkGray.withOpacity(0.95),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: HorrorTheme.bloodRed),
        ),
        child: const Row(
          children: [
            Icon(Icons.lightbulb, color: HorrorTheme.bloodRed),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '将陀螺的白色指针旋转到与红色标记重合的位置',
                style: TextStyle(color: HorrorTheme.ghostWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return FadeTransition(
      opacity: _successFade,
      child: Container(
        color: HorrorTheme.deepBlack.withOpacity(0.9),
        child: Center(
          child: ScaleTransition(
            scale: _successScale,
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: HorrorTheme.darkGray,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: HorrorTheme.bloodRed, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: HorrorTheme.bloodRed.withOpacity(0.5),
                    blurRadius: 50,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: HorrorTheme.bloodRed,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '解谜成功',
                    style: TextStyle(
                      color: HorrorTheme.bloodRed,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '衣柜后面...传来了声响...',
                    style: TextStyle(
                      color: HorrorTheme.paleSkin,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ManualControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ManualControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_ManualControlButton> createState() => _ManualControlButtonState();
}

class _ManualControlButtonState extends State<_ManualControlButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      onLongPress: widget.onLongPress,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _pressed ? HorrorTheme.bloodRed : HorrorTheme.deepBlack,
              border: Border.all(color: HorrorTheme.bloodRed, width: 2),
              boxShadow: _pressed
                  ? [
                      BoxShadow(
                        color: HorrorTheme.bloodRed.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              widget.icon,
              color: _pressed ? Colors.white : HorrorTheme.bloodRed,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.label,
            style: TextStyle(
              color: _pressed ? Colors.white : HorrorTheme.paleSkin,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double rotation;
  final double targetRotation;
  final bool isCompleted;

  _CompassPainter({
    required this.rotation,
    required this.targetRotation,
    required this.isCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final markPaint = Paint()
      ..color = HorrorTheme.bloodRed.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final tickPaint = Paint()
      ..color = HorrorTheme.paleSkin.withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 0; i < 36; i++) {
      final angle = (i * 10) * pi / 180;
      final isMajor = i % 9 == 0;
      final innerRadius = radius - (isMajor ? 20 : 10);
      final outerRadius = radius;

      canvas.drawLine(
        Offset(
          center.dx + cos(angle) * innerRadius,
          center.dy + sin(angle) * innerRadius,
        ),
        Offset(
          center.dx + cos(angle) * outerRadius,
          center.dy + sin(angle) * outerRadius,
        ),
        isMajor ? markPaint : tickPaint,
      );
    }

    final targetPaint = Paint()
      ..color = isCompleted ? Colors.green : HorrorTheme.bloodRed
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final targetPath = Path();
    final targetInnerRadius = radius - 30;
    final targetOuterRadius = radius + 10;
    for (int i = -2; i <= 2; i++) {
      final angle = targetRotation + i * 0.1;
      targetPath.moveTo(
        center.dx + cos(angle) * targetInnerRadius,
        center.dy + sin(angle) * targetInnerRadius,
      );
      targetPath.lineTo(
        center.dx + cos(angle) * targetOuterRadius,
        center.dy + sin(angle) * targetOuterRadius,
      );
    }
    canvas.drawPath(targetPath, targetPaint);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return rotation != oldDelegate.rotation ||
        targetRotation != oldDelegate.targetRotation ||
        isCompleted != oldDelegate.isCompleted;
  }
}
