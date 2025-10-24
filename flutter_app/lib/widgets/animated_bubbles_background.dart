import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AnimatedBubblesBackground extends StatefulWidget {
  const AnimatedBubblesBackground({super.key});

  @override
  State<AnimatedBubblesBackground> createState() => _AnimatedBubblesBackgroundState();
}

class _AnimatedBubblesBackgroundState extends State<AnimatedBubblesBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _BubblesPainter(animation: _ctrl),
      ),
    );
  }
}

class _BubblesPainter extends CustomPainter {
  final Animation<double> animation;
  _BubblesPainter({required this.animation}) : super(repaint: animation);

  final List<_BubbleSpec> _specs = List.generate(7, (i) {
    final rnd = math.Random(2025 + i * 37);
    final baseR = 60.0 + rnd.nextDouble() * 100.0; // 60–160
    final amp = 6.0 + rnd.nextDouble() * 8.0; // 6–14
    final phase = rnd.nextDouble() * math.pi * 2;
    final dx = rnd.nextDouble() * 0.8 + 0.1; // 0.1–0.9 width factor
    final dy = rnd.nextDouble() * 0.8 + 0.1;
    final shadeBlend = rnd.nextDouble() * 0.6 + 0.2; // 0.2–0.8
    return _BubbleSpec(
      baseRadius: baseR,
      amplitude: amp,
      phase: phase,
      posXFactor: dx,
      posYFactor: dy,
      shadeBlend: shadeBlend,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    // Base colors suaves, con opacidades bajas
    final c1 = AppColors.primary.withOpacity(0.12);
    final c2 = AppColors.secondary.withOpacity(0.10);

    for (var i = 0; i < _specs.length; i++) {
      final s = _specs[i];
      // Radio “breathing”
      final r = s.baseRadius + s.amplitude * math.sin(t * math.pi * 2 + s.phase);

      // Leve drift en X/Y
      final driftX = s.amplitude * 0.6 * math.cos(t * math.pi * 2 + s.phase * 0.7);
      final driftY = s.amplitude * 0.6 * math.sin(t * math.pi * 2 + s.phase * 0.9);

      final cx = (s.posXFactor * size.width).clamp(r, size.width - r) + driftX;
      final cy = (s.posYFactor * size.height).clamp(r, size.height - r) + driftY;

      // Mezcla entre dos tonos para variedad
      final color = Color.lerp(c1, c2, s.shadeBlend)!;

      final paint = Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12); // glow sutil

      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblesPainter oldDelegate) => true;
}

class _BubbleSpec {
  final double baseRadius;
  final double amplitude;
  final double phase;
  final double posXFactor;
  final double posYFactor;
  final double shadeBlend;

  _BubbleSpec({
    required this.baseRadius,
    required this.amplitude,
    required this.phase,
    required this.posXFactor,
    required this.posYFactor,
    required this.shadeBlend,
  });
}
