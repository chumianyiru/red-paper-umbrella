import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/horror_theme.dart';
import '../models/game_state.dart';
import '../models/character.dart';
import '../services/audio_service.dart';
import '../services/jumpscare_service.dart';
import '../widgets/procedural_scene.dart';

class JumpscareOverlay extends StatefulWidget {
  const JumpscareOverlay({super.key});

  @override
  State<JumpscareOverlay> createState() => _JumpscareOverlayState();
}

class _JumpscareOverlayState extends State<JumpscareOverlay> with TickerProviderStateMixin {
  final _jumpscareService = JumpscareService();
  final _audioService = AudioService();
  final _random = Random();

  late AnimationController _appearController;
  late AnimationController _shakeController;
  late AnimationController _flashController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _flashAnimation;

  bool _isActive = false;
  Character? _currentCharacter;
  CharacterSprite? _currentSprite;
  String _jumpscareType = 'shadow';
  int _flashCount = 0;

  @override
  void initState() {
    super.initState();

    _appearController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat(reverse: true);
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.easeOut),
    );
    _shakeAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
    _flashAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
    );

    _jumpscareService.jumpscareStream.listen(_onJumpscareEvent);
  }

  void _onJumpscareEvent(JumpscareEvent event) {
    if (event.type == JumpscareType.appear || event.type == JumpscareType.flash) {
      setState(() {
        _isActive = true;
        _currentCharacter = event.character;
        _currentSprite = event.sprite;
        _flashCount = 0;
      });
      _appearController.forward();
      _startFlashing();
    } else if (event.type == JumpscareType.disappear) {
      _appearController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isActive = false;
            _currentCharacter = null;
            _currentSprite = null;
          });
        }
      });
    }
  }

  void _startFlashing() {
    Future.doWhile(() async {
      if (!_isActive || !mounted) return false;
      _flashCount++;
      _flashController.forward().then((_) {
        _flashController.reverse();
      });
      await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));
      return _isActive && _flashCount < 5;
    });
  }

  @override
  void dispose() {
    _appearController.dispose();
    _shakeController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isActive) return const SizedBox.shrink();

    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([_appearController, _shakeController, _flashController]),
            builder: (context, child) {
              return Stack(
                children: [
                  _buildFlashOverlay(),
                  _buildBloodDrip(),
                  _buildJumpscareContent(),
                  _buildScreamEffect(),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFlashOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: _flashAnimation.value * 0.8,
          child: Container(
            color: _flashCount % 2 == 0 ? Colors.white : HorrorTheme.bloodRed,
          ),
        ),
      ),
    );
  }

  Widget _buildBloodDrip() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _BloodJumpscarePainter(
            progress: _appearController.value,
          ),
        ),
      ),
    );
  }

  Widget _buildJumpscareContent() {
    final characterId = _currentCharacter?.id ?? _jumpscareType;
    return Transform.translate(
      offset: Offset(_shakeAnimation.value, _shakeAnimation.value * 0.5),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ProceduralJumpscare(
              characterId: characterId,
              animation: _appearController,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJumpscareFace() {
    IconData faceIcon;
    Color faceColor;
    double faceSize;

    switch (_jumpscareType) {
      case 'bride':
        faceIcon = Icons.person;
        faceColor = HorrorTheme.bloodRed;
        faceSize = 300;
        break;
      case 'ghost':
        faceIcon = Icons.face;
        faceColor = HorrorTheme.ghostWhite;
        faceSize = 280;
        break;
      case 'zombie':
        faceIcon = Icons.sentiment_very_dissatisfied;
        faceColor = Colors.green.shade800;
        faceSize = 280;
        break;
      case 'child':
        faceIcon = Icons.child_care;
        faceColor = HorrorTheme.paleSkin;
        faceSize = 200;
        break;
      case 'paper':
        faceIcon = Icons.face_retouching_off;
        faceColor = Colors.white;
        faceSize = 250;
        break;
      case 'shadow':
        faceIcon = Icons.person_outline;
        faceColor = Colors.black;
        faceSize = 350;
        break;
      case 'face':
        faceIcon = Icons.face;
        faceColor = HorrorTheme.bloodRed;
        faceSize = 400;
        break;
      case 'hand':
        faceIcon = Icons.back_hand;
        faceColor = HorrorTheme.paleSkin;
        faceSize = 200;
        break;
      default:
        faceIcon = Icons.warning;
        faceColor = HorrorTheme.bloodRed;
        faceSize = 300;
    }

    return Container(
      width: faceSize,
      height: faceSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: faceColor.withOpacity(0.8),
            blurRadius: 50,
            spreadRadius: 20,
          ),
          BoxShadow(
            color: HorrorTheme.bloodRed.withOpacity(0.5),
            blurRadius: 100,
            spreadRadius: 30,
          ),
        ],
      ),
      child: Icon(
        faceIcon,
        size: faceSize,
        color: faceColor,
      ),
    );
  }

  Widget _buildScreamEffect() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Transform.scale(
            scale: 1.0 + _shakeAnimation.value * 0.02,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: HorrorTheme.bloodRed.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: HorrorTheme.bloodRed.withOpacity(0.8),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Text(
                '啊！！！',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BloodJumpscarePainter extends CustomPainter {
  final double progress;

  _BloodJumpscarePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HorrorTheme.bloodRed.withOpacity(progress * 0.7)
      ..style = PaintingStyle.fill;

    final bloodPaint = Paint()
      ..color = HorrorTheme.bloodRed.withOpacity(progress * 0.9)
      ..style = PaintingStyle.fill
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 15; i++) {
      final x = size.width * (i / 15) + (i.isOdd ? 20 : -10);
      final dripHeight = size.height * (0.1 + (i % 5) * 0.08) * progress;
      final dripWidth = 8.0 + (i % 3) * 4;

      final path = Path();
      path.moveTo(x, 0);
      path.quadraticBezierTo(
        x + dripWidth / 2,
        dripHeight * 0.5,
        x,
        dripHeight,
      );
      path.quadraticBezierTo(
        x - dripWidth / 2,
        dripHeight * 0.5,
        x,
        0,
      );
      canvas.drawPath(path, bloodPaint);

      canvas.drawCircle(
        Offset(x, dripHeight - 5),
        dripWidth * 0.8,
        bloodPaint,
      );
    }

    final eyeLeftPath = Path();
    eyeLeftPath.moveTo(size.width * 0.2, size.height * 0.3);
    eyeLeftPath.lineTo(size.width * 0.35, size.height * 0.35);
    eyeLeftPath.lineTo(size.width * 0.25, size.height * 0.45);
    eyeLeftPath.close();

    final eyeRightPath = Path();
    eyeRightPath.moveTo(size.width * 0.8, size.height * 0.3);
    eyeRightPath.lineTo(size.width * 0.65, size.height * 0.35);
    eyeRightPath.lineTo(size.width * 0.75, size.height * 0.45);
    eyeRightPath.close();

    canvas.drawPath(eyeLeftPath, paint);
    canvas.drawPath(eyeRightPath, paint);
  }

  @override
  bool shouldRepaint(covariant _BloodJumpscarePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
