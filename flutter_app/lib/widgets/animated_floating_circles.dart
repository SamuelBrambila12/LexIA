import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedFloatingCircles extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;

  const AnimatedFloatingCircles({
    super.key,
    this.primaryColor = const Color(0xFF1976D2),
    this.secondaryColor = const Color(0xFF42A5F5),
  });

  @override
  State<AnimatedFloatingCircles> createState() => _AnimatedFloatingCirclesState();
}

class _AnimatedFloatingCirclesState extends State<AnimatedFloatingCircles>
    with TickerProviderStateMixin {
  late AnimationController _controller1; // Círculo grande - muy lento
  late AnimationController _controller2; // Círculo mediano - variado
  late AnimationController _controller3; // Círculo pequeño - variado
  late AnimationController _controller4; // Círculo adicional - variado

  @override
  void initState() {
    super.initState();
    
    // Círculo grande - MUY LENTO (30 segundos)
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Círculo mediano - Movimiento variado
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    // Círculo pequeño - Movimiento variado
    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    // Círculo adicional - Movimiento variado
    _controller4 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
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
            // CÍRCULO GRANDE - Fijo abajo a la derecha con menos intensidad
            AnimatedBuilder(
              animation: _controller1,
              builder: (context, child) {
                final t = _controller1.value;
                // Posición fija abajo a la derecha
                final x = screenWidth - 100;
                final y = screenHeight - 60;
                
                // Escala respiratoria muy sutil
                final scale = 0.7 + 0.1 * math.sin(t * math.pi * 2);
                
                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.primaryColor.withOpacity(0.08),
                        boxShadow: [
                          BoxShadow(
                            color: widget.primaryColor.withOpacity(0.04 * scale),
                            blurRadius: 15 * scale,
                            spreadRadius: 3 * scale,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // CÍRCULO MEDIANO - Movimiento variado (diagonal + vertical)
            AnimatedBuilder(
              animation: _controller2,
              builder: (context, child) {
                final t = _controller2.value;
                
                // Movimiento complejo: diagonal + vertical + horizontal
                final phase1 = t * 4; // 4 ciclos completos
                
                // Movimiento principal diagonal
                final x = (t - 0.5) * (screenWidth + 200) + 
                         50 * math.sin(phase1 * math.pi);
                
                // Movimiento vertical con variación
                final y = 100 * math.sin(t * math.pi * 2) + 
                         80 * math.cos(t * math.pi * 3.5) +
                         screenHeight * 0.25;
                
                final scale = 0.7 + 0.35 * math.sin(t * math.pi * 2.5);
                
                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.secondaryColor.withOpacity(0.12),
                        boxShadow: [
                          BoxShadow(
                            color: widget.secondaryColor.withOpacity(0.08 * scale),
                            blurRadius: 15 * scale,
                            spreadRadius: 3 * scale,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // CÍRCULO PEQUEÑO - Movimiento variado (arriba-abajo + izq-derecha)
            AnimatedBuilder(
              animation: _controller3,
              builder: (context, child) {
                final t = _controller3.value;
                
                // Movimiento vertical principal
                final y = (t - 0.5) * (screenHeight + 250) +
                         60 * math.sin(t * math.pi * 2.8);
                
                // Movimiento horizontal variado
                final x = 90 * math.sin(t * math.pi * 3.5) + 
                         70 * math.cos(t * math.pi * 2.2) +
                         screenWidth * 0.3;
                
                final scale = 0.6 + 0.4 * math.sin(t * math.pi * 3);
                
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
                        color: Colors.white.withOpacity(0.08),
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

            // CÍRCULO ADICIONAL - Movimiento variado (izq-derecha + diagonal)
            AnimatedBuilder(
              animation: _controller4,
              builder: (context, child) {
                final t = _controller4.value;
                
                // Movimiento horizontal principal
                final x = (t - 0.5) * (screenWidth + 250) +
                         80 * math.sin(t * math.pi * 2.3);
                
                // Movimiento diagonal + vertical
                final y = (t - 0.5) * (screenHeight * 0.6) +
                         100 * math.sin(t * math.pi * 3.8) +
                         screenHeight * 0.4;
                
                final scale = 0.65 + 0.35 * math.cos(t * math.pi * 2);
                
                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.primaryColor.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: widget.primaryColor.withOpacity(0.06 * scale),
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

            // CÍRCULO EXTRA - Movimiento variado (arriba-abajo + izq-derecha)
            AnimatedBuilder(
              animation: _controller4,
              builder: (context, child) {
                final t = _controller4.value;
                
                // Movimiento diagonal variado
                final x = 120 * math.sin(t * math.pi * 2.7) + 
                         100 * math.cos(t * math.pi * 1.9) +
                         screenWidth * 0.15;
                
                // Movimiento vertical variado
                final y = (t - 0.5) * (screenHeight + 200) +
                         80 * math.sin(t * math.pi * 3.3);
                
                final scale = 0.55 + 0.35 * math.sin(t * math.pi * 2.2);
                
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
                        color: widget.secondaryColor.withOpacity(0.09),
                        boxShadow: [
                          BoxShadow(
                            color: widget.secondaryColor.withOpacity(0.05 * scale),
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

            // Gradiente sutil de fondo
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.primaryColor.withOpacity(0.08),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
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
