import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/hotspot.dart';

class ScenePainter extends CustomPainter {
  final String sceneId;
  final double animationValue;
  final int sanity;
  final bool isJumpscare;

  ScenePainter({
    required this.sceneId,
    this.animationValue = 0,
    this.sanity = 100,
    this.isJumpscare = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (sceneId) {
      case 'ch1_entrance':
        _paintEntranceScene(canvas, size);
        break;
      case 'ch1_well':
        _paintWellScene(canvas, size);
        break;
      case 'ch1_house':
        _paintHouseScene(canvas, size);
        break;
      case 'ch1_wedding':
        _paintWeddingScene(canvas, size);
        break;
      case 'ch1_secret':
        _paintSecretScene(canvas, size);
        break;
      default:
        _paintDefaultScene(canvas, size);
    }

    if (sanity < 50) {
      _paintSanityEffect(canvas, size);
    }
  }

  void _paintEntranceScene(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1a1a2e),
          const Color(0xFF16213e),
          const Color(0xFF0f0f1a),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    _paintVignette(canvas, size, 0.75);

    final moonPaint = Paint()..color = const Color(0xFFeeeeff);
    final moonGlow = Paint()
      ..color = const Color(0x336688ff)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);
    canvas.drawCircle(Offset(w * 0.85, h * 0.12), 55, moonGlow);
    canvas.drawCircle(Offset(w * 0.85, h * 0.12), 38, moonPaint);

    final archPaint = Paint()..color = const Color(0xFF2d2d44);
    final pillarLeft = Path()
      ..moveTo(w * 0.2, h)
      ..lineTo(w * 0.25, h * 0.25)
      ..lineTo(w * 0.3, h * 0.25)
      ..lineTo(w * 0.3, h)
      ..close();
    canvas.drawPath(pillarLeft, archPaint);

    final pillarRight = Path()
      ..moveTo(w * 0.7, h)
      ..lineTo(w * 0.7, h * 0.25)
      ..lineTo(w * 0.75, h * 0.25)
      ..lineTo(w * 0.8, h)
      ..close();
    canvas.drawPath(pillarRight, archPaint);

    final topBeam = Path()
      ..moveTo(w * 0.22, h * 0.28)
      ..lineTo(w * 0.25, h * 0.22)
      ..lineTo(w * 0.75, h * 0.22)
      ..lineTo(w * 0.78, h * 0.28)
      ..close();
    canvas.drawPath(topBeam, archPaint);

    _paintStoneTablet(canvas, Offset(w * 0.15, h * 0.55), w * 0.1, h * 0.3);

    _paintRedUmbrella(canvas, Offset(w * 0.45, h * 0.45), 80, 120);

    _paintDeadTree(canvas, Offset(w * 0.9, h * 0.85), 50, 120);

    final pathPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF252540), const Color(0xFF1a1a2e)],
      ).createShader(Rect.fromLTWH(w * 0.35, h * 0.5, w * 0.3, h * 0.5));
    final path = Path()
      ..moveTo(w * 0.35, h * 0.5)
      ..lineTo(w * 0.65, h * 0.5)
      ..lineTo(w * 0.8, h)
      ..lineTo(w * 0.2, h)
      ..close();
    canvas.drawPath(path, pathPaint);

    _paintBurntPaper(canvas, Offset(w * 0.27, h * 0.82));

    _paintFog(canvas, size, 0.35);
    _paintGrain(canvas, size, 0.1);
  }

  void _paintWellScene(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0a1515),
          const Color(0xFF0f1a1a),
          const Color(0xFF050a0a),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final moonPaint = Paint()..color = const Color(0xFFccddee);
    final moonGlow = Paint()
      ..color = const Color(0x224466aa)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawCircle(Offset(w * 0.15, h * 0.1), 45, moonGlow);
    canvas.drawCircle(Offset(w * 0.15, h * 0.1), 30, moonPaint);

    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF1a2525), const Color(0xFF0f1515)],
      ).createShader(Rect.fromLTWH(0, h * 0.5, w, h * 0.5));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.5, w, h * 0.5), groundPaint);

    final wellStonePaint = Paint()..color = const Color(0xFF3d3d45);
    final wellPath = Path()
      ..addOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.55), width: w * 0.32, height: 45));
    canvas.drawPath(wellPath, wellStonePaint);

    final wellInnerPaint = Paint()..color = const Color(0xFF000000);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.55), width: w * 0.22, height: 30), wellInnerPaint);

    final wellRedGlow = Paint()
      ..color = const Color(0x44660000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.55), width: w * 0.25, height: 35), wellRedGlow);

    final wellSidePaint = Paint()..color = const Color(0xFF454550);
    final wellSidePath = Path()
      ..moveTo(w * 0.34, h * 0.55)
      ..lineTo(w * 0.37, h * 0.88)
      ..lineTo(w * 0.63, h * 0.88)
      ..lineTo(w * 0.66, h * 0.55)
      ..close();
    canvas.drawPath(wellSidePath, wellSidePaint);

    final wellRimPaint = Paint()
      ..color = const Color(0xFF555560)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.55), width: w * 0.32, height: 45), wellRimPaint);

    final ropePaint = Paint()
      ..color = const Color(0xFF654321)
      ..strokeWidth = 4;
    canvas.drawLine(Offset(w * 0.62, h * 0.2), Offset(w * 0.58, h * 0.5), ropePaint);
    canvas.drawLine(Offset(w * 0.62, h * 0.2), Offset(w * 0.72, h * 0.22), ropePaint);
    final windlassPaint = Paint()..color = const Color(0xFF554433);
    canvas.drawRect(Rect.fromLTWH(w * 0.6, h * 0.18, w * 0.15, h * 0.04), windlassPaint);

    _paintRedShoe(canvas, Offset(w * 0.47, h * 0.68));

    _paintHouseSilhouette(canvas, Offset(w * 0.2, h * 0.4), w * 0.2, h * 0.35);

    for (int i = 0; i < 3; i++) {
      _paintDeadTree(canvas, Offset(w * (0.05 + i * 0.12), h * 0.7), 30, 80);
    }
    _paintDeadTree(canvas, Offset(w * 0.9, h * 0.65), 35, 90);

    _paintFog(canvas, size, 0.4);
    _paintVignette(canvas, size, 0.7);
    _paintGrain(canvas, size, 0.12);
  }

  void _paintHouseScene(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bgPaint = Paint()..color = const Color(0xFF0f0a08);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final candleLight = Paint()
      ..color = const Color(0x22ffaa44)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
    canvas.drawCircle(Offset(w * 0.5, h * 0.3), 120, candleLight);

    final wallPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF2a1f15), const Color(0xFF1a120c)],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.55));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.55), wallPaint);

    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF3d2815), const Color(0xFF25180c)],
      ).createShader(Rect.fromLTWH(0, h * 0.55, w, h * 0.45));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.55, w, h * 0.45), floorPaint);
    _paintFloorBoards(canvas, size, h * 0.55);

    final portraitFramePaint = Paint()..color = const Color(0xFF4a2f1a);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.5, h * 0.28), width: w * 0.28, height: h * 0.32), portraitFramePaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.5, h * 0.28), width: w * 0.24, height: h * 0.28), Paint()..color = const Color(0xFF1a0f0a));
    _paintBridePortrait(canvas, Offset(w * 0.5, h * 0.28), w * 0.2, h * 0.24, 0.4 + animationValue * 0.15);

    final dresserPaint = Paint()..color = const Color(0xFF5a3d28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.22, h * 0.72), width: w * 0.22, height: h * 0.28), const Radius.circular(5)),
      dresserPaint,
    );
    canvas.drawLine(Offset(w * 0.12, h * 0.65), Offset(w * 0.32, h * 0.65), Paint()..color = const Color(0xFF3d2815)..strokeWidth = 2);
    canvas.drawLine(Offset(w * 0.12, h * 0.78), Offset(w * 0.32, h * 0.78), Paint()..color = const Color(0xFF3d2815)..strokeWidth = 2);

    final handlePaint = Paint()..color = const Color(0xFF886633);
    canvas.drawCircle(Offset(w * 0.22, h * 0.71), 6, handlePaint);
    canvas.drawCircle(Offset(w * 0.22, h * 0.84), 6, handlePaint);

    _paintWoodenComb(canvas, Offset(w * 0.22, h * 0.58));

    final mirrorPaint = Paint()
      ..color = const Color(0xFF3d3d45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.8, h * 0.6), width: 60, height: 80), mirrorPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.8, h * 0.6), width: 52, height: 72), Paint()..color = const Color(0xFF1a1a20));

    final doorFramePaint = Paint()..color = const Color(0xFF4a2020);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.85, h * 0.45), width: w * 0.12, height: h * 0.35), const Radius.circular(3)),
      doorFramePaint,
    );
    final doorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF5a2525), const Color(0xFF3d1515)],
      ).createShader(Rect.fromCenter(center: Offset(w * 0.85, h * 0.45), width: w * 0.1, height: h * 0.32));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.85, h * 0.45), width: w * 0.1, height: h * 0.32), const Radius.circular(2)),
      doorPaint,
    );

    final chainPaint = Paint()
      ..color = const Color(0xFF444444)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(w * 0.8, h * 0.35), Offset(w * 0.9, h * 0.35), chainPaint);
    canvas.drawLine(Offset(w * 0.8, h * 0.4), Offset(w * 0.9, h * 0.4), chainPaint);
    final lockPaint = Paint()..color = const Color(0xFF666666);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.85, h * 0.38), width: 15, height: 20), lockPaint);

    _paintCobweb(canvas, Offset(0, 0), 80, Paint()..color = const Color(0x22ffffff)..strokeWidth = 1..style = PaintingStyle.stroke);
    _paintCobweb(canvas, Offset(w, 0), 70, Paint()..color = const Color(0x22ffffff)..strokeWidth = 1..style = PaintingStyle.stroke);

    _paintVignette(canvas, size, 0.6);
    _paintFlicker(canvas, size, 0.08);
    _paintGrain(canvas, size, 0.1);
  }

  void _paintWeddingScene(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2a0a0a),
          const Color(0xFF3d0f0f),
          const Color(0xFF1a0505),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final xiBgPaint = Paint()..color = const Color(0xFF8B0000);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.5, h * 0.15), width: 100, height: 120), xiBgPaint);
    _paintXiCharacter(canvas, Offset(w * 0.5, h * 0.15), 45);

    final tablePaint = Paint()..color = const Color(0xFF5d4037);
    canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.55, w * 0.6, h * 0.08), tablePaint);
    final tableClothPaint = Paint()..color = const Color(0xFF8B0000);
    canvas.drawRect(Rect.fromLTWH(w * 0.22, h * 0.53, w * 0.56, h * 0.04), tableClothPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.25, h * 0.63, 8, h * 0.25), tablePaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.72, h * 0.63, 8, h * 0.25), tablePaint);

    final candleHolderPaint = Paint()..color = const Color(0xFFB8860B);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.4, h * 0.5), width: 12, height: 20), candleHolderPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.6, h * 0.5), width: 12, height: 20), candleHolderPaint);

    final candlePaint = Paint()..color = const Color(0xFFFF4500);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.4, h * 0.45), width: 10, height: 35), candlePaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.6, h * 0.45), width: 10, height: 35), candlePaint);

    final flamePaint = Paint()..color = Color(0xFF00FF00).withOpacity(0.6 + animationValue * 0.3);
    final flameGlow = Paint()
      ..color = const Color(0x2200FF00)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(Offset(w * 0.4, h * 0.4), 20, flameGlow);
    canvas.drawCircle(Offset(w * 0.6, h * 0.4), 20, flameGlow);
    _paintFlame(canvas, Offset(w * 0.4, h * 0.4), flamePaint);
    _paintFlame(canvas, Offset(w * 0.6, h * 0.4), flamePaint);

    _paintTablet(canvas, Offset(w * 0.3, h * 0.5));

    _paintRedVeil(canvas, Offset(w * 0.68, h * 0.62));

    final chairPaint = Paint()..color = const Color(0xFF4a2020);
    canvas.drawRect(Rect.fromLTWH(w * 0.62, h * 0.5, 8, h * 0.2), chairPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.75, h * 0.5, 8, h * 0.2), chairPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.6, h * 0.7, w * 0.22, 8), chairPaint);

    final curtainPaint = Paint()..color = const Color(0xFF660000);
    final leftCurtain = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.15, 0)
      ..lineTo(w * 0.08, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(leftCurtain, curtainPaint);
    final rightCurtain = Path()
      ..moveTo(w, 0)
      ..lineTo(w * 0.85, 0)
      ..lineTo(w * 0.92, h)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(rightCurtain, curtainPaint);

    _paintVignette(canvas, size, 0.65);
    _paintFlicker(canvas, size, 0.12);
    _paintGrain(canvas, size, 0.1);
  }

  void _paintSecretScene(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0a0505),
          const Color(0xFF150808),
          const Color(0xFF050303),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final wallPaint = Paint()..color = const Color(0xFF1a0a0a);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), wallPaint);

    _paintBloodWriting(canvas, size);

    final coffinPaint = Paint()..color = const Color(0xFF8B0000);
    final coffinPath = Path()
      ..moveTo(w * 0.25, h * 0.35)
      ..lineTo(w * 0.75, h * 0.35)
      ..lineTo(w * 0.72, h * 0.72)
      ..lineTo(w * 0.28, h * 0.72)
      ..close();
    canvas.drawPath(coffinPath, coffinPaint);

    final coffinInnerPaint = Paint()..color = const Color(0xFF5a0000);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.5, h * 0.53), width: w * 0.42, height: h * 0.34), const Radius.circular(8)),
      coffinInnerPaint,
    );

    final coffinEdgePaint = Paint()
      ..color = const Color(0xFFAA4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawPath(coffinPath, coffinEdgePaint);

    final goldLinePaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawLine(Offset(w * 0.5, h * 0.35), Offset(w * 0.5, h * 0.72), goldLinePaint..strokeWidth = 3);
    canvas.drawCircle(Offset(w * 0.35, h * 0.45), 8, Paint()..color = const Color(0xFFFFD700));
    canvas.drawCircle(Offset(w * 0.65, h * 0.45), 8, Paint()..color = const Color(0xFFFFD700));
    canvas.drawCircle(Offset(w * 0.35, h * 0.62), 8, Paint()..color = const Color(0xFFFFD700));
    canvas.drawCircle(Offset(w * 0.65, h * 0.62), 8, Paint()..color = const Color(0xFFFFD700));

    _paintWatch(canvas, Offset(w * 0.17, h * 0.78));

    _paintDiary(canvas, Offset(w * 0.83, h * 0.75));

    final candleLight = Paint()
      ..color = const Color(0x11ff6644)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), 150, candleLight);

    _paintVignette(canvas, size, 0.85);
    _paintFlicker(canvas, size, 0.15);
    _paintGrain(canvas, size, 0.18);
  }

  void _paintDefaultScene(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    _paintVignette(canvas, size, 0.8);
  }

  void _paintVignette(Canvas canvas, Size size, double intensity) {
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(intensity),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignettePaint);
  }

  void _paintFog(Canvas canvas, Size size, double intensity) {
    final random = math.Random(42);
    for (int i = 0; i < 25; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height * 0.7 + size.height * 0.3;
      double r = 60 + random.nextDouble() * 120;
      final fogPaint = Paint()..color = const Color(0x33bbbbbb).withOpacity(intensity * 0.25);
      canvas.drawCircle(Offset(x, y), r, fogPaint);
    }
  }

  void _paintGrain(Canvas canvas, Size size, double intensity) {
    final random = math.Random(123);
    for (int i = 0; i < 600 * intensity; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double opacity = random.nextDouble() * intensity;
      final grainPaint = Paint()..color = Colors.white.withOpacity(opacity * 0.08);
      canvas.drawCircle(Offset(x, y), 0.5, grainPaint);
    }
  }

  void _paintFlicker(Canvas canvas, Size size, double intensity) {
    final flickerPaint = Paint()
      ..color = Colors.black.withOpacity((math.sin(animationValue * 8) + 1) * 0.08 * intensity);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flickerPaint);
  }

  void _paintSanityEffect(Canvas canvas, Size size) {
    double insanity = (100 - sanity) / 100;
    if (insanity > 0.3) {
      final warpPaint = Paint()
        ..color = const Color(0xFF880000).withOpacity(insanity * 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), warpPaint);
    }
  }

  void _paintDeadTree(Canvas canvas, Offset base, double width, double height) {
    final treePaint = Paint()
      ..color = const Color(0xFF1a1010)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(base, Offset(base.dx, base.dy - height), treePaint);
    _paintBranch(canvas, Offset(base.dx, base.dy - height * 0.65), width * 0.45, -50, treePaint);
    _paintBranch(canvas, Offset(base.dx, base.dy - height * 0.45), width * 0.35, 35, treePaint);
    _paintBranch(canvas, Offset(base.dx, base.dy - height * 0.75), width * 0.3, -70, treePaint);
  }

  void _paintBranch(Canvas canvas, Offset start, double length, double angleDeg, Paint paint) {
    double angleRad = angleDeg * math.pi / 180;
    Offset end = Offset(
      start.dx + length * math.cos(angleRad),
      start.dy + length * math.sin(angleRad),
    );
    canvas.drawLine(start, end, paint);
    if (length > 12) {
      _paintBranch(canvas, end, length * 0.55, angleDeg - 35, paint);
      _paintBranch(canvas, end, length * 0.45, angleDeg + 45, paint);
    }
  }

  void _paintStoneTablet(Canvas canvas, Offset center, double width, double height) {
    final tabletPaint = Paint()..color = const Color(0xFF4a4a55);
    final tabletPath = Path()
      ..moveTo(center.dx - width * 0.3, center.dy + height * 0.4)
      ..lineTo(center.dx - width * 0.4, center.dy - height * 0.35)
      ..lineTo(center.dx - width * 0.2, center.dy - height * 0.5)
      ..lineTo(center.dx + width * 0.2, center.dy - height * 0.5)
      ..lineTo(center.dx + width * 0.4, center.dy - height * 0.35)
      ..lineTo(center.dx + width * 0.3, center.dy + height * 0.4)
      ..close();
    canvas.drawPath(tabletPath, tabletPaint);

    final textPaint = Paint()
      ..color = const Color(0xFF222222)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 5; i++) {
      double y = center.dy - height * 0.2 + i * height * 0.12;
      canvas.drawLine(Offset(center.dx - width * 0.2, y), Offset(center.dx + width * 0.2, y), textPaint);
    }
  }

  void _paintRedUmbrella(Canvas canvas, Offset center, double width, double height) {
    final umbrellaPaint = Paint()..color = const Color(0xFF8B0000);
    final canopyPath = Path()
      ..moveTo(center.dx - width * 0.5, center.dy - height * 0.1)
      ..quadraticBezierTo(center.dx, center.dy - height * 0.6, center.dx + width * 0.5, center.dy - height * 0.1)
      ..lineTo(center.dx + width * 0.4, center.dy - height * 0.05)
      ..quadraticBezierTo(center.dx, center.dy - height * 0.45, center.dx - width * 0.4, center.dy - height * 0.05)
      ..close();
    canvas.drawPath(canopyPath, umbrellaPaint);

    final ribPaint = Paint()
      ..color = const Color(0xFF660000)
      ..strokeWidth = 2;
    for (int i = 0; i < 6; i++) {
      double angle = -math.pi + (math.pi / 5) * i;
      canvas.drawLine(
        Offset(center.dx, center.dy - height * 0.25),
        Offset(center.dx + math.cos(angle) * width * 0.45, center.dy - height * 0.1 + math.sin(angle) * height * 0.1),
        ribPaint,
      );
    }

    final handlePaint = Paint()..color = const Color(0xFF4a2818);
    canvas.drawLine(
      Offset(center.dx, center.dy - height * 0.1),
      Offset(center.dx, center.dy + height * 0.4),
      handlePaint..strokeWidth = 5,
    );
    canvas.drawCircle(Offset(center.dx, center.dy + height * 0.4), 8, handlePaint);

    final tipPaint = Paint()..color = const Color(0xFF886633);
    canvas.drawCircle(Offset(center.dx, center.dy - height * 0.5), 6, tipPaint);
  }

  void _paintBurntPaper(Canvas canvas, Offset position) {
    final paperPaint = Paint()..color = const Color(0xFF554422);
    final paperPath = Path()
      ..moveTo(position.dx - 15, position.dy - 10)
      ..lineTo(position.dx + 12, position.dy - 12)
      ..lineTo(position.dx + 15, position.dy + 8)
      ..lineTo(position.dx - 10, position.dy + 10)
      ..close();
    canvas.drawPath(paperPath, paperPaint);

    final ashPaint = Paint()..color = const Color(0xFF333333).withOpacity(0.5);
    for (int i = 0; i < 8; i++) {
      canvas.drawCircle(
        Offset(position.dx + (i - 4) * 5, position.dy + 15 + (i % 3) * 3),
        2 + (i % 2) * 1.0,
        ashPaint,
      );
    }
  }

  void _paintRedShoe(Canvas canvas, Offset position) {
    final shoePaint = Paint()..color = const Color(0xFF8B0000);
    final shoePath = Path()
      ..moveTo(position.dx - 20, position.dy)
      ..quadraticBezierTo(position.dx - 25, position.dy + 8, position.dx - 15, position.dy + 15)
      ..lineTo(position.dx + 18, position.dy + 12)
      ..quadraticBezierTo(position.dx + 25, position.dy + 5, position.dx + 20, position.dy - 5)
      ..quadraticBezierTo(position.dx - 5, position.dy - 8, position.dx - 20, position.dy)
      ..close();
    canvas.drawPath(shoePath, shoePaint);

    final threadPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawLine(Offset(position.dx - 5, position.dy - 3), Offset(position.dx + 5, position.dy - 3), threadPaint..strokeWidth = 1.5);
    canvas.drawLine(Offset(position.dx - 8, position.dy + 2), Offset(position.dx + 8, position.dy + 2), threadPaint);

    final eyePaint = Paint()..color = const Color(0xFF000000);
    canvas.drawCircle(Offset(position.dx + 8, position.dy + 2), 2, eyePaint);
  }

  void _paintHouseSilhouette(Canvas canvas, Offset position, double width, double height) {
    final housePaint = Paint()..color = const Color(0xFF0a0a12);
    final housePath = Path()
      ..moveTo(position.dx, position.dy + height)
      ..lineTo(position.dx + width * 0.1, position.dy + height * 0.3)
      ..lineTo(position.dx + width * 0.5, position.dy)
      ..lineTo(position.dx + width * 0.9, position.dy + height * 0.3)
      ..lineTo(position.dx + width, position.dy + height)
      ..close();
    canvas.drawPath(housePath, housePaint);

    final windowGlow = Paint()
      ..color = const Color(0x22ffaa44)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(position.dx + width * 0.35, position.dy + height * 0.5), width: 15, height: 20),
      windowGlow,
    );
  }

  void _paintFloorBoards(Canvas canvas, Size size, double startY) {
    final boardPaint = Paint()..color = const Color(0xFF25180c);
    for (int x = 0; x < size.width; x += 70) {
      canvas.drawLine(
        Offset(x.toDouble(), startY),
        Offset(x.toDouble() + 35, size.height),
        boardPaint..strokeWidth = 1,
      );
    }
  }

  void _paintBridePortrait(Canvas canvas, Offset center, double width, double height, double opacity) {
    final facePaint = Paint()..color = const Color(0xFFddccbb).withOpacity(opacity * 0.4);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: width * 0.5, height: height * 0.6),
      facePaint,
    );

    final veilPaint = Paint()..color = const Color(0xFF8B0000).withOpacity(opacity * 0.5);
    final veilPath = Path()
      ..moveTo(center.dx - width * 0.4, center.dy - height * 0.3)
      ..lineTo(center.dx + width * 0.4, center.dy - height * 0.3)
      ..lineTo(center.dx + width * 0.5, center.dy + height * 0.5)
      ..lineTo(center.dx - width * 0.5, center.dy + height * 0.5)
      ..close();
    canvas.drawPath(veilPath, veilPaint);

    final eyePaint = Paint()..color = const Color(0xFF000000).withOpacity(opacity * 0.7);
    canvas.drawCircle(Offset(center.dx - width * 0.1, center.dy - height * 0.05), width * 0.05, eyePaint);
    canvas.drawCircle(Offset(center.dx + width * 0.1, center.dy - height * 0.05), width * 0.05, eyePaint);

    final mouthPaint = Paint()
      ..color = const Color(0xFF8B0000).withOpacity(opacity * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final mouthPath = Path()
      ..moveTo(center.dx - width * 0.08, center.dy + height * 0.15)
      ..quadraticBezierTo(center.dx, center.dy + height * 0.08, center.dx + width * 0.08, center.dy + height * 0.15);
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _paintWoodenComb(Canvas canvas, Offset position) {
    final combPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: position, width: 40, height: 15), const Radius.circular(3)),
      combPaint,
    );

    final toothPaint = Paint()..color = const Color(0xFF654321);
    for (int i = 0; i < 8; i++) {
      double x = position.dx - 15 + i * 4.5;
      canvas.drawLine(Offset(x, position.dy + 7), Offset(x, position.dy + 18), toothPaint..strokeWidth = 2);
    }

    final hairPaint = Paint()..color = const Color(0xFF1a0a00).withOpacity(0.6);
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(position.dx - 10 + i * 10, position.dy + 5),
        Offset(position.dx - 8 + i * 10, position.dy - 8),
        hairPaint..strokeWidth = 1,
      );
    }
  }

  void _paintFlame(Canvas canvas, Offset position, Paint paint) {
    final flamePath = Path()
      ..moveTo(position.dx, position.dy - 15 - animationValue * 5)
      ..quadraticBezierTo(position.dx - 8, position.dy - 5, position.dx, position.dy + 5)
      ..quadraticBezierTo(position.dx + 8, position.dy - 5, position.dx, position.dy - 15 - animationValue * 5);
    canvas.drawPath(flamePath, paint);
  }

  void _paintXiCharacter(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(center.dx - size * 0.35, center.dy - size * 0.5), Offset(center.dx + size * 0.35, center.dy - size * 0.5), paint);
    canvas.drawLine(Offset(center.dx - size * 0.35, center.dy - size * 0.3), Offset(center.dx + size * 0.35, center.dy - size * 0.3), paint);
    canvas.drawLine(Offset(center.dx - size * 0.35, center.dy), Offset(center.dx + size * 0.35, center.dy), paint);
    canvas.drawLine(Offset(center.dx - size * 0.35, center.dy + size * 0.3), Offset(center.dx + size * 0.35, center.dy + size * 0.3), paint);
    canvas.drawLine(Offset(center.dx, center.dy - size * 0.6), Offset(center.dx, center.dy + size * 0.5), paint);
    canvas.drawLine(Offset(center.dx - size * 0.2, center.dy - size * 0.15), Offset(center.dx + size * 0.2, center.dy - size * 0.15), paint);
    canvas.drawLine(Offset(center.dx - size * 0.2, center.dy + size * 0.15), Offset(center.dx + size * 0.2, center.dy + size * 0.15), paint);
  }

  void _paintTablet(Canvas canvas, Offset position) {
    final tabletPaint = Paint()..color = const Color(0xFFB8860B);
    final tabletPath = Path()
      ..moveTo(position.dx - 18, position.dy - 5)
      ..lineTo(position.dx - 15, position.dy - 25)
      ..lineTo(position.dx + 15, position.dy - 25)
      ..lineTo(position.dx + 18, position.dy - 5)
      ..lineTo(position.dx + 15, position.dy + 25)
      ..lineTo(position.dx - 15, position.dy + 25)
      ..close();
    canvas.drawPath(tabletPath, tabletPaint);

    final namePaint = Paint()
      ..color = const Color(0xFF8B0000)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(position.dx - 8, position.dy - 15 + i * 15),
        Offset(position.dx + 8, position.dy - 15 + i * 15),
        namePaint,
      );
    }
  }

  void _paintRedVeil(Canvas canvas, Offset position) {
    final veilPaint = Paint()..color = const Color(0xFF8B0000).withOpacity(0.8);
    final veilPath = Path()
      ..moveTo(position.dx - 25, position.dy - 20)
      ..lineTo(position.dx + 25, position.dy - 20)
      ..lineTo(position.dx + 30, position.dy + 30)
      ..lineTo(position.dx - 30, position.dy + 30)
      ..close();
    canvas.drawPath(veilPath, veilPaint);

    final foldPaint = Paint()..color = const Color(0xFF660000);
    canvas.drawLine(Offset(position.dx, position.dy - 18), Offset(position.dx + 5, position.dy + 28), foldPaint..strokeWidth = 2);
    canvas.drawLine(Offset(position.dx - 10, position.dy - 15), Offset(position.dx - 5, position.dy + 25), foldPaint..strokeWidth = 1);
  }

  void _paintBloodWriting(Canvas canvas, Size size) {
    final bloodPaint = Paint()
      ..color = const Color(0xFF660000).withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final textPaint = TextPainter(
      text: TextSpan(
        text: '不要娶她',
        style: TextStyle(
          color: const Color(0xFF880000).withOpacity(0.5),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPaint.layout();

    for (int i = 0; i < 4; i++) {
      textPaint.paint(canvas, Offset(20 + (i % 2) * 30, size.height * (0.1 + i * 0.18)));
    }
  }

  void _paintWatch(Canvas canvas, Offset position) {
    final watchPaint = Paint()..color = const Color(0xFFC0C0C0);
    canvas.drawCircle(position, 20, watchPaint);
    canvas.drawCircle(position, 16, Paint()..color = const Color(0xFF222222));

    final handPaint = Paint()..color = const Color(0xFFC0C0C0)..strokeWidth = 2;
    canvas.drawLine(position, Offset(position.dx + 8, position.dy - 5), handPaint);
    canvas.drawLine(position, Offset(position.dx - 5, position.dy + 8), handPaint);

    canvas.drawCircle(position, 3, Paint()..color = const Color(0xFF880000));
  }

  void _paintDiary(Canvas canvas, Offset position) {
    final diaryPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: position, width: 50, height: 70), const Radius.circular(3)),
      diaryPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: position, width: 44, height: 64), const Radius.circular(2)),
      Paint()..color = const Color(0xFFDDCCAA),
    );

    final linePaint = Paint()..color = const Color(0xFF665533)..strokeWidth = 1;
    for (int i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(position.dx - 18, position.dy - 22 + i * 8),
        Offset(position.dx + 18, position.dy - 22 + i * 8),
        linePaint,
      );
    }
  }

  void _paintCobweb(Canvas canvas, Offset corner, double size, Paint paint) {
    for (int i = 1; i <= 4; i++) {
      double r = size * i / 4;
      canvas.drawArc(Rect.fromCircle(center: corner, radius: r), 0, math.pi / 2, false, paint);
    }
    for (int i = 0; i <= 4; i++) {
      double angle = (math.pi / 2) * i / 4;
      canvas.drawLine(
        corner,
        Offset(corner.dx + size * math.cos(angle), corner.dy + size * math.sin(angle)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScenePainter oldDelegate) {
    return oldDelegate.sceneId != sceneId ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.sanity != sanity ||
        oldDelegate.isJumpscare != isJumpscare;
  }
}

class HotspotOverlayPainter extends CustomPainter {
  final List<Hotspot> hotspots;
  final String? selectedItemId;
  final Set<String> collectedHotspotIds;
  final bool Function(Hotspot) isHotspotRevealed;

  HotspotOverlayPainter({
    required this.hotspots,
    this.selectedItemId,
    required this.collectedHotspotIds,
    required this.isHotspotRevealed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final hotspot in hotspots) {
      if (hotspot.isHidden && !isHotspotRevealed(hotspot)) continue;
      if (collectedHotspotIds.contains(hotspot.id) && hotspot.oneTime) continue;

      final rect = Rect.fromLTRB(
        hotspot.position.left * size.width,
        hotspot.position.top * size.height,
        hotspot.position.right * size.width,
        hotspot.position.bottom * size.height,
      );

      if (selectedItemId != null && hotspot.requiredItem == selectedItemId) {
        final highlightPaint = Paint()
          ..color = const Color(0x4400ff00)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
        canvas.drawRect(rect, highlightPaint);

        final borderPaint = Paint()
          ..color = const Color(0x8800ff00)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRect(rect, borderPaint);
      }

      if (hotspot.type == HotspotType.item && !collectedHotspotIds.contains(hotspot.id)) {
        final glowPaint = Paint()
          ..color = const Color(0x22ffaa44)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
        canvas.drawRect(rect.inflate(6), glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HotspotOverlayPainter oldDelegate) {
    return oldDelegate.hotspots != hotspots ||
        oldDelegate.selectedItemId != selectedItemId ||
        oldDelegate.collectedHotspotIds.length != collectedHotspotIds.length;
  }
}
