import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedTopCircles extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;

  const AnimatedTopCircles({
    super.key,
    this.primaryColor = const Color(0xFF1976D2),
    this.secondaryColor = const Color(0xFF42A5F5),
  });

  @override
  State<AnimatedTopCircles> createState() => _AnimatedTopCirclesState();
}

class _AnimatedTopCirclesState extends State<AnimatedTopCircles>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late AnimationController _controller4;
  late AnimationController _controller5;
  late AnimationController _controller6;
  late AnimationController _controller7;

  @override
  void initState() {
    super.initState();
    
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();

    _controller4 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 11),
    )..repeat();

    _controller5 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _controller6 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();

    _controller7 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
    _controller6.dispose();
    _controller7.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        return Stack(
          children: [
            // CÍRCULO 1 - Movimiento horizontal rápido (izq-derecha)
            AnimatedBuilder(
              animation: _controller1,
              builder: (context, child) {
                final t = _controller1.value;
                // Movimiento horizontal de izquierda a derecha
                final x = (t - 0.5) * (screenWidth + 150);
                // Movimiento vertical suave en el área azul
                final y = 60.0 + 40.0 * math.sin(t * math.pi * 2.5);
                
                final scale = 0.7 + 0.3 * math.sin(t * math.pi * 2);
                
                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.primaryColor.withOpacity(0.12),
                        boxShadow: [
                          BoxShadow(
                            color: widget.primaryColor.withOpacity(0.08 * scale),
                            blurRadius: 12 * scale,
                            spreadRadius: 2 * scale,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // CÍRCULO 2 - Movimiento diagonal en área azul
            AnimatedBuilder(
              animation: _controller2,
              builder: (context, child) {
                final t = _controller2.value;
                // Movimiento diagonal simple
                final x = 80.0 * math.sin(t * math.pi * 2) + screenWidth * 0.2;
                final y = 40.0 * math.cos(t * math.pi * 2.3) + 80.0;
                
                final scale = 0.65 + 0.35 * math.sin(t * math.pi * 2.8);
                
                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.secondaryColor.withOpacity(0.11),
                        boxShadow: [
                          BoxShadow(
                            color: widget.secondaryColor.withOpacity(0.07 * scale),
                            blurRadius: 10 * scale,
                            spreadRadius: 2 * scale,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // CÍRCULO 3 - Movimiento en forma de 8 (lemniscata)
            AnimatedBuilder(
              animation: _controller3,
              builder: (context, child) {
                final t = _controller3.value;
                // Lemniscata simplificada
                final x = 70.0 * math.sin(t * math.pi * 2) * math.cos(t * math.pi) + screenWidth * 0.5;
                final y = 50.0 * math.sin(t * math.pi * 2) * math.sin(t * math.pi * 2) + 100.0;
                
                final scale = 0.6 + 0.4 * math.sin(t * math.pi * 3);
                
                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.09),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.05 * scale),
                            blurRadius: 10 * scale,
                            spreadRadius: 2 * scale,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // CÍRCULO 4 - Movimiento en espiral compacta
            AnimatedBuilder(
              animation: _controller4,
              builder: (context, child) {
                final t = _controller4.value;
                // Espiral compacta
                final radius = 50.0 + 30.0 * math.sin(t * math.pi * 2);
                final angle = t * math.pi * 3;
                final x = radius * math.cos(angle) + screenWidth * 0.75;
                final y = radius * math.sin(angle) * 0.6 + 90.0;
                
                final scale = 0.55 + 0.35 * math.cos(t * math.pi * 2.5);
                
                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.primaryColor.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: widget.primaryColor.withOpacity(0.06 * scale),
                            blurRadius: 9 * scale,
                            spreadRadius: 1.5 * scale,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // CÍRCULO 5 - Movimiento horizontal en área del título
            AnimatedBuilder(
              animation: _controller5,
              builder: (context, child) {
                final t = _controller5.value;
                final x = (t - 0.5) * (screenWidth + 120);
                final y = 20.0 + 25.0 * math.sin(t * math.pi * 2.2);
                
                final scale = 0.6 + 0.3 * math.sin(t * math.pi * 2);
                
                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.secondaryColor.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: widget.secondaryColor.withOpacity(0.06 * scale),
                            blurRadius: 10 * scale,
                            spreadRadius: 2 * scale,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // CÍRCULO 6 - Movimiento diagonal en área del título
            AnimatedBuilder(
              animation: _controller6,
              builder: (context, child) {
                final t = _controller6.value;
                final x = 60.0 * math.sin(t * math.pi * 2.5) + screenWidth * 0.3;
                final y = 35.0 * math.cos(t * math.pi * 2) + 15.0;
                
                final scale = 0.55 + 0.35 * math.sin(t * math.pi * 2.5);
                
                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.04 * scale),
                            blurRadius: 8 * scale,
                            spreadRadius: 1.5 * scale,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // CÍRCULO 7 - Movimiento en espiral pequeña en área del título
            AnimatedBuilder(
              animation: _controller7,
              builder: (context, child) {
                final t = _controller7.value;
                final radius = 35.0 + 20.0 * math.sin(t * math.pi * 2);
                final angle = t * math.pi * 2.5;
                final x = radius * math.cos(angle) + screenWidth * 0.7;
                final y = radius * math.sin(angle) * 0.5 + 25.0;
                
                final scale = 0.5 + 0.3 * math.cos(t * math.pi * 2);
                
                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.primaryColor.withOpacity(0.09),
                        boxShadow: [
                          BoxShadow(
                            color: widget.primaryColor.withOpacity(0.05 * scale),
                            blurRadius: 8 * scale,
                            spreadRadius: 1 * scale,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Gradiente sutil
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.primaryColor.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
