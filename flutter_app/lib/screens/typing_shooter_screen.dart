import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TypingShooterScreen extends StatefulWidget {
  const TypingShooterScreen({super.key});

  @override
  State<TypingShooterScreen> createState() => _TypingShooterScreenState();
}

class _Enemy {
  Offset pos;
  String word;
  int hit; // letras acertadas
  double speed;
  bool isBoss;
  bool flash = false;
  DateTime? flashUntil;
  _Enemy({required this.pos, required this.word, this.hit = 0, required this.speed, this.isBoss = false});
}

class _Bullet {
  Offset pos;
  Offset target;
  _Enemy? enemy;
  double speed;
  _Bullet({required this.pos, required this.target, this.enemy, this.speed = 8});
}

class _TypingShooterScreenState extends State<TypingShooterScreen> with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  final List<_Enemy> _enemies = [];
  final List<_Bullet> _bullets = [];
  final math.Random _rnd = math.Random();
  Timer? _timer;
  double _w = 360;
  double _h = 640;
  int _wave = 1;
  bool _completed = false;
  bool _gameOver = false;
  int _lives = 3;
  bool _showIntro = true;
  Timer? _introTimer;
  List<Map<String, dynamic>> _spawnQueue = [];
  Timer? _spawnTimer;

  // Helpers para geometría de enemigos y jugador
  Size _wordBoxSize(_Enemy e) {
    final isBoss = e.isBoss;
    final ts = TextStyle(
      fontSize: isBoss ? 20 : 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    );
    final tp = TextPainter(
      text: TextSpan(text: e.word, style: ts),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    tp.layout();
    final width = tp.width + 20; // padding horizontal 10 * 2
    final height = tp.height + 12; // padding vertical 6 * 2
    return Size(width, height);
  }

  double _enemyColumnWidth(_Enemy e) {
    final shipSize = e.isBoss ? 48.0 : 36.0;
    final wordW = _wordBoxSize(e).width;
    return wordW > shipSize ? wordW : shipSize;
  }

  Offset _enemyShipCenter(_Enemy e) {
    final colW = _enemyColumnWidth(e);
    final shipSize = e.isBoss ? 48.0 : 36.0;
    final wordH = _wordBoxSize(e).height;
    final centerX = e.pos.dx + colW / 2;
    final centerY = e.pos.dy + wordH + 6 + shipSize / 2; // 6 es SizedBox entre palabra y nave
    return Offset(centerX, centerY);
  }

  Offset _playerCenter() {
    // Nave del jugador: Positioned(left: _w/2 - 30, bottom: 16), tamaño 40x40
    final left = _w / 2 - 30;
    final bottom = 16.0;
    final size = 40.0;
    final centerX = left + size / 2;
    final centerY = _h - bottom - size / 2;
    return Offset(centerX, centerY);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
      setState(() {
        _showIntro = true;
      });
      _introTimer?.cancel();
      _introTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {
          _showIntro = false;
        });
        _startRound();
      });
    });
  }

  void _startRound() {
    _enemies.clear();
    _bullets.clear();
    _lives = 3;
    _gameOver = false;

    // preparar cola de spawn progresivo
    _spawnQueue = [];
    final words = _generateWords(6 + _wave * 2, false);
    for (final w in words) {
      _spawnQueue.add({'word': w, 'isBoss': false});
    }
    // boss al final de la cola
    final bossW = _generateWords(1, true).first;
    _spawnQueue.add({'word': bossW, 'isBoss': true});

    // temporizador de spawn progresivo
    _spawnTimer?.cancel();
    final int intervalMs = math.max(250, 700 - 70 * (_wave - 1));
    _spawnTimer = Timer.periodic(Duration(milliseconds: intervalMs), (st) {
      if (!mounted) { st.cancel(); return; }
      if (_spawnQueue.isEmpty) { st.cancel(); return; }
      final item = _spawnQueue.removeAt(0);
      final bool isBoss = (item['isBoss'] as bool);
      final String word = (item['word'] as String);
      final double x = 40 + _rnd.nextDouble() * (_w - 80);
      final double y = -50.0 - _rnd.nextDouble() * 200;
      final double base = 0.25 + 0.08 * (_wave - 1);
      final double baseClamped = base < 0.25 ? 0.25 : (base > 1.2 ? 1.2 : base);
      final double speed = isBoss ? (baseClamped * 0.9) : (baseClamped + _rnd.nextDouble() * 0.12);
      setState(() {
        _enemies.add(_Enemy(pos: Offset(x, y), word: word, speed: speed, isBoss: isBoss));
      });
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (!mounted) return;
      setState(() {
        for (final e in _enemies) {
          e.pos = Offset(e.pos.dx, e.pos.dy + e.speed);
        }
        // colisi��n con base (fallo)
        _enemies.removeWhere((e) {
          if (e.pos.dy > _h - 80) {
            _lives -= 1;
            return true;
          }
          return false;
        });

        // actualizar parpadeo de impacto
        final now = DateTime.now();
        for (final e in _enemies) {
          if (e.flash && (e.flashUntil == null || now.isAfter(e.flashUntil!))) {
            e.flash = false;
          }
        }

        // actualizar balas
        for (final b in List<_Bullet>.from(_bullets)) {
          // seguir a la nave enemiga si sigue viva
          if (b.enemy != null && _enemies.contains(b.enemy)) {
            b.target = _enemyShipCenter(b.enemy!);
          }
          final dir = b.target - b.pos;
          final dist = dir.distance;
          if (dist <= b.speed) {
            // impacto
            if (b.enemy != null && _enemies.contains(b.enemy)) {
              b.enemy!.flash = true;
              b.enemy!.flashUntil = now.add(const Duration(milliseconds: 150));
            }
            _bullets.remove(b);
          } else {
            final step = Offset(dir.dx / dist * b.speed, dir.dy / dist * b.speed);
            b.pos = b.pos + step;
          }
        }

        if (_lives <= 0) {
          _gameOver = true;
          t.cancel();
        }
        if (_enemies.isEmpty && _spawnQueue.isEmpty) {
          _completed = true;
          t.cancel();
        }
      });
    });
  }

  List<String> _generateWords(int n, bool boss) {
    const pool = [
      'apple','banana','orange','grapes','strawberry','pineapple','mango','watermelon','blueberry','peach',
      'because','beautiful','tomorrow','yesterday','grammar','vocabulary','sentence','pronunciation','adjective','preposition',
      'teacher','student','listen','speak','through','thought','rhythm','awkward','queue','subtle',
    ];
    const bossPool = [
      'PRONUNCIATION','ACKNOWLEDGMENT','MISCOMMUNICATION','RESPONSIBILITY','CHARACTERIZATION','UNCONSTITUTIONAL','HYPERBOLIC',
    ];
    List<String> out = [];
    for (int i = 0; i < n; i++) {
      if (boss) {
        out.add(bossPool[_rnd.nextInt(bossPool.length)]);
      } else {
        final w = pool[_rnd.nextInt(pool.length)];
        out.add(_rnd.nextBool() ? w : w.toUpperCase());
      }
    }
    return out;
  }

  String _mask(_Enemy e) {
    final w = e.word;
    final hit = e.hit.clamp(0, w.length);
    final typed = w.substring(0, hit);
    final rest = w.substring(hit).replaceAll(RegExp(r'.'), '_');
    return '$typed$rest';
  }

  void _handleChar(String ch) {
    if (_completed || _gameOver) return;
    if (ch.isEmpty) return;
    // priorizar enemigo más cercano a la base
    _enemies.sort((a, b) => b.pos.dy.compareTo(a.pos.dy));
    for (final e in List<_Enemy>.from(_enemies)) {
      if (e.hit >= e.word.length) continue;
      final expected = e.word[e.hit];
      if (expected.toLowerCase() == ch.toLowerCase()) {
        final start = _playerCenter();
        final target = _enemyShipCenter(e);
        setState(() {
          _bullets.add(_Bullet(pos: start, target: target, enemy: e));
          e.hit += 1;
          if (e.hit >= e.word.length) {
            _enemies.remove(e);
          }
        });
        break;
      }
    }
  }

  void _onKey(RawKeyEvent ev) {
    if (_completed || _gameOver) return;
    if (ev is! RawKeyDownEvent) return;
    final keyLabel = ev.logicalKey.keyLabel;
    if (keyLabel.isEmpty || keyLabel.length != 1) return;
    _handleChar(keyLabel);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _introTimer?.cancel();
    _spawnTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: _onKey,
        child: LayoutBuilder(
          builder: (context, c) {
            _w = c.maxWidth;
            _h = c.maxHeight;
            return Stack(
              children: [
                // HUD
                Positioned(
                  left: 16, top: 16,
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      Text('x$_lives', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                Positioned(
                  right: 16, top: 16,
                  child: Text('Ronda $_wave', style: const TextStyle(color: Colors.white)),
                ),

                // Enemigos
                ..._enemies.map((e) {
                  final isBoss = e.isBoss;
                  final color = isBoss ? Colors.amberAccent : Colors.lightBlueAccent;
                  final border = isBoss ? Colors.orangeAccent : Colors.blueAccent;
                  return Positioned(
                    left: e.pos.dx,
                    top: e.pos.dy,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            border: Border.all(color: border),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: e.word.substring(0, e.hit.clamp(0, e.word.length)),
                                  style: TextStyle(
                                    color: Colors.transparent,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    fontSize: isBoss ? 20 : 16,
                                  ),
                                ),
                                TextSpan(
                                  text: e.word.substring(e.hit.clamp(0, e.word.length)),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    fontSize: isBoss ? 20 : 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Image.asset(
                          'assets/images/nave.png',
                          width: isBoss ? 48 : 36,
                          height: isBoss ? 48 : 36,
                          color: e.flash ? Colors.redAccent.withOpacity(0.6) : null,
                          colorBlendMode: e.flash ? BlendMode.modulate : null,
                        ),
                      ],
                    ),
                  );
                }).toList(),

                // Balas
                ..._bullets.map((b) {
                  return Positioned(
                    left: b.pos.dx - 2,
                    top: b.pos.dy - 8,
                    child: Container(
                      width: 4,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.yellowAccent,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(color: Colors.yellowAccent.withOpacity(0.6), blurRadius: 6),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                // Base
                Positioned(
                  left: _w / 2 - 30,
                  bottom: 16,
                  child: Column(
                    children: [
                      Image.asset('assets/images/player.png', width: 40, height: 40),
                      const SizedBox(height: 4),
                      const Text('Escribe para disparar', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),

                // Teclado en pantalla (similar a Hangman)
                if (!_completed && !_gameOver && !_showIntro)
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 72,
                    child: Opacity(
                      opacity: 0.85,
                      child: SizedBox(
                        height: 160,
                        child: Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 6,
                          runSpacing: 6,
                          children: List.generate(26, (i) {
                            final l = String.fromCharCode('A'.codeUnitAt(0) + i);
                            return SizedBox(
                              width: 36,
                              height: 36,
                              child: ElevatedButton(
                                onPressed: () => _handleChar(l),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                ),
                                child: Text(l, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    ),
                  ),

                if (_showIntro)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black87.withOpacity(0.6),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.keyboard, color: Colors.white, size: 48),
                            SizedBox(height: 12),
                            Text(
                              'Escribe para derrotar a los enemigos',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'La partida iniciará en 3 segundos...',
                              style: TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (_completed)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Ronda superada', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop('NEXT');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent.shade400,
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('Siguiente'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (_gameOver)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('GAME OVER', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop('NEXT');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent.shade400,
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('Siguiente'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
