import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/horror_theme.dart';

class BloodDripPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          HorrorTheme.bloodRed.withOpacity(0.8),
          HorrorTheme.darkRed.withOpacity(0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final random = Random(42);
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height * 0.1;
      final endY = startY + random.nextDouble() * size.height * 0.4 + 50;
      final width = random.nextDouble() * 8 + 3;

      final path = Path()
        ..moveTo(x, startY)
        ..quadraticBezierTo(
          x + random.nextDouble() * 10 - 5,
          startY + (endY - startY) * 0.5,
          x,
          endY,
        );

      canvas.drawPath(
        path,
        Paint()
          ..color = HorrorTheme.bloodRed.withOpacity(random.nextDouble() * 0.5 + 0.3)
          ..strokeWidth = width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FogPainter extends CustomPainter {
  final double animation;

  FogPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HorrorTheme.ghostWhite.withOpacity(0.03 + sin(animation) * 0.02);

    for (int i = 0; i < 5; i++) {
      final offset = sin(animation + i * pi / 3) * 50;
      final rect = Rect.fromLTWH(
        -100 + offset + i * size.width / 3,
        size.height * 0.5 + cos(animation + i) * 30,
        size.width * 0.8,
        size.height * 0.5,
      );
      canvas.drawOval(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FogPainter oldDelegate) => true;
}

class VignettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Colors.transparent,
          HorrorTheme.deepBlack.withOpacity(0.7),
          HorrorTheme.deepBlack,
        ],
        stops: [0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HorrorBackground extends StatelessWidget {
  final Widget child;
  final bool showBlood;
  final bool showVignette;
  final bool animated;

  const HorrorBackground({
    super.key,
    required this.child,
    this.showBlood = true,
    this.showVignette = true,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: HorrorTheme.deepBlack,
          ),
        ),
        if (showBlood)
          Positioned.fill(
            child: CustomPaint(
              painter: BloodDripPainter(),
            ),
          ),
        if (showVignette)
          Positioned.fill(
            child: CustomPaint(
              painter: VignettePainter(),
            ),
          ),
        if (animated)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 2 * pi),
            duration: const Duration(seconds: 20),
            builder: (context, value, _) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: FogPainter(value),
                ),
              );
            },
            onEnd: () {},
          ),
        Positioned.fill(child: child),
      ],
    );
  }
}
