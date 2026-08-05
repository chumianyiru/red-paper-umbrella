import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/horror_theme.dart';
import '../models/scene.dart';

class ProceduralScene extends StatelessWidget {
  final String sceneId;
  final Widget? child;

  const ProceduralScene({
    super.key,
    required this.sceneId,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _ScenePainter(sceneId: sceneId),
          size: Size.infinite,
        ),
        CustomPaint(
          painter: _FogPainter(),
          size: Size.infinite,
        ),
        CustomPaint(
          painter: _VignettePainter(),
          size: Size.infinite,
        ),
        if (child != null) child!,
      ],
    );
  }
}

class _ScenePainter extends CustomPainter {
  final String sceneId;
  final Random _random = Random(42);

  _ScenePainter({required this.sceneId});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    switch (sceneId) {
      case 'main_gate':
        _paintMainGate(canvas, size, rect);
        break;
      case 'courtyard':
        _paintCourtyard(canvas, size, rect);
        break;
      case 'main_hall':
        _paintMainHall(canvas, size, rect);
        break;
      case 'bridal_room':
        _paintBridalRoom(canvas, size, rect);
        break;
      case 'study':
        _paintStudy(canvas, size, rect);
        break;
      case 'secret_room':
        _paintSecretRoom(canvas, size, rect);
        break;
      default:
        _paintGenericHorror(canvas, size, rect);
    }
  }

  void _paintMainGate(Canvas canvas, Size size, Rect rect) {
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0D0D1A),
          const Color(0xFF1A0A0A),
          HorrorTheme.darkGray,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final moonPaint = Paint()..color = const Color(0xFFFFFACD).withOpacity(0.3);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.15),
      40,
      moonPaint,
    );

    final gatePaint = Paint()..color = const Color(0xFF1A0A00);
    final gateLeft = Rect.fromLTWH(size.width * 0.15, size.height * 0.3, size.width * 0.15, size.height * 0.6);
    final gateRight = Rect.fromLTWH(size.width * 0.7, size.height * 0.3, size.width * 0.15, size.height * 0.6);
    final gateTop = Rect.fromLTWH(size.width * 0.1, size.height * 0.25, size.width * 0.8, size.height * 0.08);
    canvas.drawRect(gateLeft, gatePaint);
    canvas.drawRect(gateRight, gatePaint);
    canvas.drawRect(gateTop, gatePaint);

    final redLanternPaint = Paint()..color = HorrorTheme.bloodRed.withOpacity(0.8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.3, size.height * 0.35),
        width: 30,
        height: 40,
      ),
      redLanternPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.7, size.height * 0.35),
        width: 30,
        height: 40,
      ),
      redLanternPaint,
    );

    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30)
      ..color = HorrorTheme.bloodRed.withOpacity(0.3);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.35), 50, glowPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.35), 50, glowPaint);
  }

  void _paintCourtyard(Canvas canvas, Size size, Rect rect) {
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0A0A15),
          const Color(0xFF15100A),
          HorrorTheme.darkGray,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final groundPaint = Paint()..color = const Color(0xFF1A1510);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4),
      groundPaint,
    );

    final wellPaint = Paint()..color = const Color(0xFF0A0A0A);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.75),
      50,
      wellPaint,
    );

    final wellRimPaint = Paint()
      ..color = const Color(0xFF2A2520)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.75),
      55,
      wellRimPaint,
    );

    final deadTreePaint = Paint()
      ..color = const Color(0xFF0A0500)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.9),
      Offset(size.width * 0.15, size.height * 0.4),
      deadTreePaint,
    );
    for (int i = 0; i < 5; i++) {
      final startY = size.height * (0.5 + i * 0.08);
      canvas.drawLine(
        Offset(size.width * 0.13, startY),
        Offset(size.width * (0.05 + _random.nextDouble() * 0.1), startY - 20),
        Paint()..color = const Color(0xFF0A0500)..strokeWidth = 3,
      );
    }
  }

  void _paintMainHall(Canvas canvas, Size size, Rect rect) {
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0F0A0A),
          const Color(0xFF1A0F0A),
          HorrorTheme.darkGray,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final candleGlow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80)
      ..color = HorrorTheme.paperYellow.withOpacity(0.2);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.5), 60, candleGlow);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.5), 60, candleGlow);

    final tabletPaint = Paint()..color = const Color(0xFF2A1510);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.35),
        width: 120,
        height: 80,
      ),
      tabletPaint,
    );

    final tabletBorder = Paint()
      ..color = HorrorTheme.bloodRed.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.35),
        width: 120,
        height: 80,
      ),
      tabletBorder,
    );

    final tablePaint = Paint()..color = const Color(0xFF1A0F05);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.6),
        width: 200,
        height: 30,
      ),
      tablePaint,
    );
  }

  void _paintBridalRoom(Canvas canvas, Size size, Rect rect) {
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1A0510),
          const Color(0xFF2A0A15),
          const Color(0xFF1A0A10),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final bedPaint = Paint()..color = const Color(0xFF2A1520);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.55, size.height * 0.45, size.width * 0.35, size.height * 0.4),
      bedPaint,
    );

    final redCurtainPaint = Paint()..color = HorrorTheme.darkRed.withOpacity(0.8);
    final curtainPath = Path();
    curtainPath.moveTo(size.width * 0.1, 0);
    curtainPath.lineTo(size.width * 0.2, size.height);
    curtainPath.lineTo(0, size.height);
    curtainPath.close();
    canvas.drawPath(curtainPath, redCurtainPaint);

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.3, size.height * 0.5),
        width: 80,
        height: 100,
      ),
      Paint()..color = const Color(0xFF0A0A10),
    );

    final mirrorGlow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40)
      ..color = Colors.white.withOpacity(0.1);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.5), 70, mirrorGlow);
  }

  void _paintStudy(Canvas canvas, Size size, Rect rect) {
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0A0F0A),
          const Color(0xFF101A15),
          HorrorTheme.darkGray,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final bookshelfPaint = Paint()..color = const Color(0xFF1A1005);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.05, size.height * 0.2, size.width * 0.25, size.height * 0.6),
      bookshelfPaint,
    );

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 8; j++) {
        final bookColor = [
          const Color(0xFF3A1510),
          const Color(0xFF1A2530),
          const Color(0xFF2A2010),
          const Color(0xFF1A1525),
        ][_random.nextInt(4)];
        canvas.drawRect(
          Rect.fromLTWH(
            size.width * 0.07 + j * 12,
            size.height * 0.25 + i * 50,
            10,
            40,
          ),
          Paint()..color = bookColor,
        );
      }
    }

    final deskPaint = Paint()..color = const Color(0xFF151008);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.6, size.height * 0.65),
        width: 180,
        height: 25,
      ),
      deskPaint,
    );

    final candlePaint = Paint()..color = HorrorTheme.paperYellow;
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.5), 8, candlePaint);
    final candleGlow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60)
      ..color = HorrorTheme.paperYellow.withOpacity(0.3);
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.5), 50, candleGlow);
  }

  void _paintSecretRoom(Canvas canvas, Size size, Rect rect) {
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF050505),
          const Color(0xFF0A0505),
          const Color(0xFF05050A),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final altarPaint = Paint()..color = const Color(0xFF0F0A0A);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.5),
        width: 200,
        height: 120,
      ),
      altarPaint,
    );

    final altarGlow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100)
      ..color = HorrorTheme.bloodRed.withOpacity(0.4);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 150, altarGlow);

    final pentagramPath = Path();
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = 60.0;
    for (int i = 0; i < 5; i++) {
      final angle = -pi / 2 + (i * 2 * pi / 5);
      final nextAngle = -pi / 2 + ((i + 2) * 2 * pi / 5);
      if (i == 0) {
        pentagramPath.moveTo(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        );
      }
      pentagramPath.lineTo(
        center.dx + radius * cos(nextAngle),
        center.dy + radius * sin(nextAngle),
      );
    }
    pentagramPath.close();

    canvas.drawPath(
      pentagramPath,
      Paint()
        ..color = HorrorTheme.bloodRed.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final circlePaint = Paint()
      ..color = HorrorTheme.bloodRed.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, 70, circlePaint);
    canvas.drawCircle(center, 80, circlePaint);
  }

  void _paintGenericHorror(Canvas canvas, Size size, Rect rect) {
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          HorrorTheme.deepBlack,
          HorrorTheme.darkGray,
          HorrorTheme.darkRed.withOpacity(0.2),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FogPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(12345);
    final fogPaint = Paint()..color = HorrorTheme.ghostWhite.withOpacity(0.03);
    
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 50 + random.nextDouble() * 150;
      canvas.drawCircle(Offset(x, y), radius, fogPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VignettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.4),
          Colors.black.withOpacity(0.8),
        ],
        stops: const [0.5, 0.8, 1.0],
      ).createShader(Offset.zero & size);
    
    canvas.drawRect(Offset.zero & size, vignettePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProceduralJumpscare extends StatelessWidget {
  final String characterId;
  final Animation<double> animation;

  const ProceduralJumpscare({
    super.key,
    required this.characterId,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _JumpscarePainter(
            characterId: characterId,
            animationValue: animation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _JumpscarePainter extends CustomPainter {
  final String characterId;
  final double animationValue;
  final Random _random = Random();

  _JumpscarePainter({required this.characterId, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (animationValue < 0.1) return;

    final flashOpacity = (animationValue < 0.3) ? (1 - animationValue * 3) * 0.8 : 0.0;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.white.withOpacity(flashOpacity),
    );

    final center = Offset(size.width / 2, size.height / 2);
    final scale = 0.3 + Curves.elasticOut.transform(animationValue.clamp(0.1, 1.0)) * 0.8;
    final shakeX = sin(animationValue * 50) * (1 - animationValue) * 20;
    final shakeY = cos(animationValue * 45) * (1 - animationValue) * 15;

    canvas.save();
    canvas.translate(center.dx + shakeX, center.dy + shakeY);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);

    _drawCharacter(canvas, size, center);

    canvas.restore();
  }

  void _drawCharacter(Canvas canvas, Size size, Offset center) {
    final faceRadius = size.width * 0.25;
    
    final facePaint = Paint();
    switch (characterId) {
      case 'red_bride':
        facePaint.color = const Color(0xFFE8D0D0);
        _drawFace(canvas, center, faceRadius, facePaint, HorrorTheme.bloodRed, true);
        break;
      case 'white_ghost':
        facePaint.color = const Color(0xFFE0E0E8);
        _drawGhost(canvas, center, faceRadius);
        break;
      case 'child_ghost':
        facePaint.color = const Color(0xFFD8D0C0);
        _drawChildFace(canvas, center, faceRadius * 0.7);
        break;
      case 'paper_grandma':
        facePaint.color = const Color(0xFFD4C4A8);
        _drawOldFace(canvas, center, faceRadius * 0.9);
        break;
      case 'jiangshi':
        facePaint.color = const Color(0xFF5A8A5A);
        _drawJiangshi(canvas, center, faceRadius);
        break;
      case 'groom':
        facePaint.color = const Color(0xFFC8B8B0);
        _drawGroom(canvas, center, faceRadius);
        break;
      case 'shadow':
        _drawShadow(canvas, center, faceRadius);
        break;
      default:
        _drawGenericGhost(canvas, center, faceRadius);
    }
  }

  void _drawFace(Canvas canvas, Offset center, double radius, Paint facePaint, Color accentColor, bool isBride) {
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 1.2, height: radius * 1.5),
      facePaint,
    );

    final eyePaint = Paint()..color = Colors.black;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx - radius * 0.3, center.dy - radius * 0.2), width: radius * 0.25, height: radius * 0.15),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx + radius * 0.3, center.dy - radius * 0.2), width: radius * 0.25, height: radius * 0.15),
      eyePaint,
    );

    final bloodPaint = Paint()..color = accentColor;
    final bloodPath = Path();
    bloodPath.moveTo(center.dx - radius * 0.2, center.dy - radius * 0.1);
    bloodPath.lineTo(center.dx - radius * 0.25, center.dy + radius * 0.5);
    bloodPath.lineTo(center.dx - radius * 0.15, center.dy + radius * 0.5);
    bloodPath.close();
    canvas.drawPath(bloodPath, bloodPaint);

    final mouthPaint = Paint()..color = accentColor;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + radius * 0.3), width: radius * 0.4, height: radius * 0.3),
      mouthPaint,
    );

    if (isBride) {
      final veilPaint = Paint()..color = Colors.red.withOpacity(0.6);
      final veilPath = Path();
      veilPath.moveTo(center.dx - radius * 0.8, center.dy - radius * 0.8);
      veilPath.lineTo(center.dx, center.dy - radius * 1.2);
      veilPath.lineTo(center.dx + radius * 0.8, center.dy - radius * 0.8);
      veilPath.lineTo(center.dx + radius, center.dy + radius);
      veilPath.lineTo(center.dx - radius, center.dy + radius);
      veilPath.close();
      canvas.drawPath(veilPath, veilPaint);
    }
  }

  void _drawGhost(Canvas canvas, Offset center, double radius) {
    final ghostPaint = Paint()..color = const Color(0xFFE8E8F0).withOpacity(0.8);
    final ghostPath = Path();
    ghostPath.addOval(Rect.fromCenter(center: center, width: radius * 1.5, height: radius * 2));
    canvas.drawPath(ghostPath, ghostPaint);

    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(center.dx - radius * 0.25, center.dy - radius * 0.1), radius * 0.1, eyePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.25, center.dy - radius * 0.1), radius * 0.1, eyePaint);

    final mouthPath = Path();
    mouthPath.addOval(Rect.fromCenter(center: Offset(center.dx, center.dy + radius * 0.3), width: radius * 0.2, height: radius * 0.4));
    canvas.drawPath(mouthPath, Paint()..color = const Color(0xFF1A0A0A));
  }

  void _drawChildFace(Canvas canvas, Offset center, double radius) {
    final facePaint = Paint()..color = const Color(0xFFD8D0C0);
    canvas.drawCircle(center, radius, facePaint);

    final eyePaint = Paint()..color = HorrorTheme.bloodRed;
    canvas.drawCircle(Offset(center.dx - radius * 0.3, center.dy - radius * 0.1), radius * 0.12, eyePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.3, center.dy - radius * 0.1), radius * 0.12, eyePaint);

    canvas.drawCircle(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.1),
      radius * 0.05,
      Paint()..color = Colors.black,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.3, center.dy - radius * 0.1),
      radius * 0.05,
      Paint()..color = Colors.black,
    );
  }

  void _drawOldFace(Canvas canvas, Offset center, double radius) {
    final facePaint = Paint()..color = const Color(0xFFC4B498);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 1.1, height: radius * 1.3),
      facePaint,
    );

    final wrinklePaint = Paint()
      ..color = const Color(0xFF8A7A60)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx - radius * 0.4, center.dy - radius * 0.3),
      Offset(center.dx - radius * 0.1, center.dy - radius * 0.2),
      wrinklePaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.1, center.dy - radius * 0.2),
      Offset(center.dx + radius * 0.4, center.dy - radius * 0.3),
      wrinklePaint,
    );

    final eyePaint = Paint()..color = const Color(0xFFFFFF00);
    canvas.drawCircle(Offset(center.dx - radius * 0.25, center.dy - radius * 0.1), radius * 0.08, eyePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.25, center.dy - radius * 0.1), radius * 0.08, eyePaint);
  }

  void _drawJiangshi(Canvas canvas, Offset center, double radius) {
    final skinPaint = Paint()..color = const Color(0xFF5A7A5A);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 1.2, height: radius * 1.4),
      skinPaint,
    );

    final talismanPaint = Paint()..color = HorrorTheme.paperYellow;
    final talismanRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - radius * 0.8),
      width: radius * 0.3,
      height: radius * 0.5,
    );
    canvas.drawRect(talismanRect, talismanPaint);

    final textPaint = Paint()
      ..color = HorrorTheme.bloodRed
      ..strokeWidth = 3;
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(talismanRect.left + 5, talismanRect.top + 10 + i * 15),
        Offset(talismanRect.right - 5, talismanRect.top + 10 + i * 15),
        textPaint,
      );
    }

    final eyePaint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(center.dx - radius * 0.2, center.dy - radius * 0.1), radius * 0.1, eyePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.2, center.dy - radius * 0.1), radius * 0.1, eyePaint);
  }

  void _drawGroom(Canvas canvas, Offset center, double radius) {
    final facePaint = Paint()..color = const Color(0xFFB8A8A0);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 1.1, height: radius * 1.3),
      facePaint,
    );

    final hatPaint = Paint()..color = Colors.black;
    final hatPath = Path();
    hatPath.addOval(Rect.fromCenter(
      center: Offset(center.dx, center.dy - radius * 0.9),
      width: radius * 1.2,
      height: radius * 0.4,
    ));
    canvas.drawPath(hatPath, hatPaint);

    final ropePaint = Paint()
      ..color = HorrorTheme.bloodRed
      ..strokeWidth = 5;
    canvas.drawCircle(center, radius, ropePaint);
    canvas.drawLine(
      Offset(center.dx - radius * 0.5, center.dy - radius * 0.5),
      Offset(center.dx, center.dy - radius * 1.5),
      ropePaint,
    );

    final eyePaint = Paint()..color = HorrorTheme.bloodRed;
    canvas.drawCircle(Offset(center.dx - radius * 0.25, center.dy - radius * 0.15), radius * 0.08, eyePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.25, center.dy - radius * 0.15), radius * 0.08, eyePaint);
  }

  void _drawShadow(Canvas canvas, Offset center, double radius) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    
    final shadowPath = Path();
    shadowPath.addOval(Rect.fromCenter(center: center, width: radius * 2, height: radius * 2.5));
    canvas.drawPath(shadowPath, shadowPaint);

    final eyePaint = Paint()..color = HorrorTheme.bloodRed;
    canvas.drawCircle(Offset(center.dx - radius * 0.3, center.dy - radius * 0.2), radius * 0.1, eyePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.3, center.dy - radius * 0.2), radius * 0.1, eyePaint);
  }

  void _drawGenericGhost(Canvas canvas, Offset center, double radius) {
    final ghostPaint = Paint()
      ..color = const Color(0x80000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius, ghostPaint);

    final eyePaint = Paint()..color = HorrorTheme.bloodRed;
    canvas.drawCircle(Offset(center.dx - radius * 0.3, center.dy - radius * 0.1), radius * 0.15, eyePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.3, center.dy - radius * 0.1), radius * 0.15, eyePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
