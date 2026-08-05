import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../utils/theme.dart';

enum PuzzleType { gyro, manual, raster }

class GyroPuzzleWidget extends StatefulWidget {
  final Function(bool) onComplete;
  final PuzzleType puzzleType;

  const GyroPuzzleWidget({
    super.key,
    required this.onComplete,
    this.puzzleType = PuzzleType.gyro,
  });

  @override
  State<GyroPuzzleWidget> createState() => _GyroPuzzleWidgetState();
}

class _GyroPuzzleWidgetState extends State<GyroPuzzleWidget> with TickerProviderStateMixin {
  bool _hasGyroscope = true;
  bool _isManualMode = false;
  double _gyroX = 0;
  double _gyroY = 0;
  double _gyroZ = 0;
  
  double _topRotation = 0;
  double _topAngle = 0;
  double _manualAngle = 0;
  bool _isSpinning = false;
  bool _puzzleSolved = false;
  
  late AnimationController _spinController;
  StreamSubscription? _gyroSubscription;
  Timer? _stabilizeTimer;
  int _stableFrames = 0;

  static const double targetAngle = 0;
  static const double tolerance = 0.15;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _initGyroscope();
  }

  void _initGyroscope() {
    try {
      _gyroSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
        if (!_isManualMode && mounted) {
          setState(() {
            _gyroX = event.x;
            _gyroY = event.y;
            _gyroZ = event.z;
            _updateGyroTop(event);
          });
        }
      });
    } catch (e) {
      setState(() {
        _hasGyroscope = false;
        _isManualMode = true;
      });
    }
  }

  void _updateGyroTop(GyroscopeEvent event) {
    if (_puzzleSolved) return;

    _topAngle += event.z * 0.05;
    _topAngle = _topAngle % (pi * 2);

    final absX = event.x.abs();
    final absY = event.y.abs();
    final absZ = event.z.abs();

    if (absX < 0.2 && absY < 0.2 && absZ < 0.2) {
      _stableFrames++;
      if (_stableFrames > 30) {
        _checkWinCondition();
      }
    } else {
      _stableFrames = 0;
      if (absZ > 1.0) {
        _isSpinning = true;
      }
    }
  }

  void _manualRotate(double delta) {
    if (_puzzleSolved) return;
    setState(() {
      _manualAngle += delta;
      _manualAngle = _manualAngle % (pi * 2);
      _topAngle = _manualAngle;
    });
  }

  void _checkWinCondition() {
    final normalizedAngle = _topAngle % (pi * 2);
    final diff = (normalizedAngle - targetAngle).abs();
    final wrappedDiff = min(diff, (pi * 2) - diff);
    
    if (wrappedDiff < tolerance) {
      _solvePuzzle();
    }
  }

  void _solvePuzzle() {
    if (_puzzleSolved) return;
    setState(() {
      _puzzleSolved = true;
    });
    
    _spinController.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        widget.onComplete(true);
      });
    });
  }

  void _toggleManualMode() {
    setState(() {
      _isManualMode = !_isManualMode;
    });
  }

  @override
  void dispose() {
    _gyroSubscription?.cancel();
    _stabilizeTimer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: _buildPuzzleContent(),
              ),
            ),
            if (_isManualMode || !_hasGyroscope)
              _buildManualControls(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: HorrorTheme.inkBlack,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: HorrorTheme.ghostWhite),
            onPressed: () => widget.onComplete(false),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '陀螺谜题',
              style: TextStyle(
                color: HorrorTheme.ghostWhite,
                fontSize: 20,
                fontFamily: 'ChineseBrush',
                letterSpacing: 2,
              ),
            ),
          ),
          if (_hasGyroscope)
            TextButton.icon(
              onPressed: _toggleManualMode,
              icon: Icon(
                _isManualMode ? Icons.screen_rotation : Icons.touch_app,
                color: HorrorTheme.paperYellow,
                size: 18,
              ),
              label: Text(
                _isManualMode ? '体感模式' : '手动模式',
                style: const TextStyle(color: HorrorTheme.paperYellow),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPuzzleContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '摇晃手机让陀螺停止转动',
          style: TextStyle(
            color: HorrorTheme.paperYellow,
            fontSize: 18,
          ),
        ),
        if (_isManualMode || !_hasGyroscope)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '点击按钮旋转陀螺，使红色标记朝上',
              style: TextStyle(
                color: HorrorTheme.ghostWhite,
                fontSize: 14,
              ),
            ),
          ),
        const SizedBox(height: 40),
        _buildTop(),
        const SizedBox(height: 40),
        if (_puzzleSolved)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: HorrorTheme.eerieGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '谜题解开了！',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTop() {
    return AnimatedBuilder(
      animation: _spinController,
      builder: (context, child) {
        double rotation = _puzzleSolved
            ? _spinController.value * pi * 8
            : _topAngle;
        
        return Transform.rotate(
          angle: rotation,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  HorrorTheme.bloodRed.withOpacity(0.8),
                  HorrorTheme.darkRed,
                  HorrorTheme.corpseBlack,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _puzzleSolved 
                      ? HorrorTheme.eerieGreen.withOpacity(0.6)
                      : HorrorTheme.bloodRed.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
              border: Border.all(
                color: _puzzleSolved ? HorrorTheme.eerieGreen : HorrorTheme.bloodRed,
                width: 3,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(200, 200),
                  painter: _TopPainter(),
                ),
                Positioned(
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.8),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: HorrorTheme.paperYellow,
                      boxShadow: [
                        BoxShadow(
                          color: HorrorTheme.candleOrange.withOpacity(0.6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildManualControls() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.rotate_left,
            label: '逆时针',
            onTap: () => _manualRotate(-0.3),
            onLongPress: () => _manualRotate(-0.1),
          ),
          _buildControlButton(
            icon: Icons.rotate_right,
            label: '顺时针',
            onTap: () => _manualRotate(0.3),
            onLongPress: () => _manualRotate(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(
          color: HorrorTheme.shadowGray,
          border: Border.all(color: HorrorTheme.bloodRed),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: HorrorTheme.paperYellow, size: 40),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: HorrorTheme.ghostWhite,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!_hasGyroscope)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: HorrorTheme.darkRed.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: HorrorTheme.candleOrange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '您的设备不支持陀螺仪，请使用手动模式',
                      style: TextStyle(color: HorrorTheme.ghostWhite),
                    ),
                  ),
                ],
              ),
            ),
          Text(
            '提示：让陀螺上的红色标记对准上方即可解开谜题',
            style: TextStyle(
              color: HorrorTheme.ghostWhite.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final framePaint = Paint()
      ..color = HorrorTheme.paperYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * pi * 2;
      canvas.drawLine(
        center,
        Offset(
          center.dx + cos(angle) * radius * 0.8,
          center.dy + sin(angle) * radius * 0.8,
        ),
        framePaint,
      );
    }

    final circlePaint = Paint()
      ..color = HorrorTheme.shadowGray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius * 0.6, circlePaint);
    canvas.drawCircle(center, radius * 0.4, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RasterPuzzleWidget extends StatefulWidget {
  final Function(bool) onComplete;

  const RasterPuzzleWidget({super.key, required this.onComplete});

  @override
  State<RasterPuzzleWidget> createState() => _RasterPuzzleWidgetState();
}

class _RasterPuzzleWidgetState extends State<RasterPuzzleWidget> {
  double _brightness = 0.5;
  double _angle = 0;
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: HorrorTheme.inkBlack,
              title: const Text('光栅解谜'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => widget.onComplete(false),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '调整屏幕亮度和角度，利用反光查看隐藏文字',
                      style: TextStyle(color: HorrorTheme.paperYellow),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          Colors.black,
                          Colors.white,
                          _brightness * _angle.abs() * 2,
                        ),
                        border: Border.all(color: HorrorTheme.bloodRed),
                      ),
                      child: _revealed
                          ? const Center(
                              child: Text(
                                '祠堂地下',
                                style: TextStyle(
                                  color: HorrorTheme.bloodRed,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : CustomPaint(painter: _RasterPainter()),
                    ),
                    const SizedBox(height: 30),
                    Slider(
                      value: _brightness,
                      onChanged: (v) {
                        setState(() => _brightness = v);
                        _checkReveal();
                      },
                      activeColor: HorrorTheme.bloodRed,
                    ),
                    Slider(
                      value: _angle,
                      min: -1,
                      max: 1,
                      onChanged: (v) {
                        setState(() => _angle = v);
                        _checkReveal();
                      },
                      activeColor: HorrorTheme.candleOrange,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkReveal() {
    if (_brightness > 0.7 && _angle.abs() > 0.4) {
      setState(() => _revealed = true);
      Future.delayed(const Duration(seconds: 2), () {
        widget.onComplete(true);
      });
    }
  }
}

class _RasterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final stripeWidth = 4.0;
    for (double x = 0; x < size.width; x += stripeWidth * 2) {
      canvas.drawRect(Rect.fromLTWH(x, 0, stripeWidth, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
