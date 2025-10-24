import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'pronunciation_exercise_screen.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'dart:async';
import 'typing_shooter_screen.dart';
import '../services/auth_service.dart';
import '../services/user_stats_service.dart';
import 'auth/login_register_screen.dart';

class EnglishMenuScreen extends StatelessWidget {
  const EnglishMenuScreen({super.key});

  void _showComingSoon(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title - En construcción'),
        content: const Text(
          'Esta sección está en desarrollo. Pronto podrás practicar con ejercicios interactivos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void _openUserSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _UserProfileSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inglés'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Perfil',
            onPressed: () => _openUserSheet(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(AppDimensions.defaultPadding),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.largePadding),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                                            Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Text(
                              '🇬🇧',
                              style: TextStyle(fontSize: 28),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Menú de aprendizaje',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Elige una categoría para empezar a practicar',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.defaultPadding,
              vertical: AppDimensions.smallPadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _MenuCard(
                  title: 'Ejercicios gramaticales',
                  subtitle: 'Práctica de tiempos verbales, artículos y más',
                  icon: Icons.menu_book_rounded,
                  color: Colors.deepPurple,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GrammarExerciseScreen(),
                      ),
                    );
                  },
                ),
                _MenuCard(
                  title: 'Ejercicios de pronunciación',
                  subtitle: 'Escucha y repite para mejorar tu acento',
                  icon: Icons.record_voice_over_rounded,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PronunciationExerciseScreen(),
                      ),
                    );
                  },
                ),
                _MenuCard(
                  title: 'Traducción de objetos',
                  subtitle: 'Usa la cámara para identificar y traducir objetos',
                  icon: Icons.camera_alt_rounded,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserProfileSheet extends StatefulWidget {
  const _UserProfileSheet({super.key});

  @override
  State<_UserProfileSheet> createState() => _UserProfileSheetState();
}

class _UserProfileSheetState extends State<_UserProfileSheet> {
  Map<String, String>? _user;
  double _progress = 0.0;
  int _streak = 0;
  int _lessons = 0;
  int _points = 0;
  String _level = 'A1';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final us = await AuthService().currentUser();
    if (us != null) {
      final stats = await UserStatsService().getStats(us['email']!);
      if (!mounted) return;
      setState(() {
        _user = us;
        _progress = stats.progress;
        _streak = stats.streakDays;
        _lessons = stats.lessons;
        _points = stats.points;
        _level = stats.level;
        _loading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final name = _user?['name'] ?? 'Invitado';
    final nextLevel = _level == 'A1' ? 'A2' : (_level == 'A2' ? 'B1' : (_level == 'B1' ? 'B2' : 'C1'));

    return FractionallySizedBox(
      heightFactor: 0.86,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, -8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 6)),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 34,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.person, size: 40, color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),
                                    Chip(
                                      label: Text('Nivel de inglés: $_level', style: const TextStyle(color: Colors.white)),
                                      backgroundColor: Colors.black26,
                                      side: const BorderSide(color: Colors.white24),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                              tooltip: 'Cerrar',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Progreso hacia $nextLevel', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 14,
                          backgroundColor: const Color(0xFFEAEFF3),
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(_progress * 100).toStringAsFixed(0)}% completado', style: const TextStyle(color: Colors.black54)),
                          Text('Meta: $nextLevel', style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _StatCard(icon: Icons.local_fire_department_rounded, color: Colors.deepOrange, label: 'Racha', value: '$_streak días'),
                          const SizedBox(width: 12),
                          _StatCard(icon: Icons.check_circle_rounded, color: Colors.green, label: 'Lecciones', value: '$_lessons'),
                          const SizedBox(width: 12),
                          _StatCard(icon: Icons.star_rounded, color: Colors.amber, label: 'Puntos', value: '$_points'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => _logout(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.color, required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 4)),
          ],
          border: Border.all(color: const Color(0xFFE9EDF2)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Pantalla de Ejercicios Gramaticales
// -------------------------------------------------------------

enum GrammarType { multipleChoice, trueFalse, orderWords, balloonPop, duckHunt, typingShooter, memoryPairs, hangman, dragFill }

class GrammarExercise {
  final GrammarType type;
  final String prompt;
  final List<String> options; // para multipleChoice y trueFalse (True/False)
  final dynamic answer; // String para MCQ; bool para TF; List<String> para orderWords
  final String? explanation;
  final String category; // e.g., "Tiempos Verbales", "Oraciones", etc.

  GrammarExercise({
    required this.type,
    required this.prompt,
    required this.options,
    required this.answer,
    this.explanation,
    required this.category,
  });
}

class GrammarExerciseScreen extends StatefulWidget {
  const GrammarExerciseScreen({super.key});

  @override
  State<GrammarExerciseScreen> createState() => _GrammarExerciseScreenState();
}

class _GrammarExerciseScreenState extends State<GrammarExerciseScreen> {
  final List<GrammarExercise> _exercises = [];
  int _index = 0;
  int _attempts = 0;
  bool _answered = false;
  bool _isCorrect = false;
  List<String> _currentOrder = [];
  String? _lastSelectedOption;
  bool _lastOrderWrong = false;

  // Estado para minijuego: globos
  List<bool> _balloonHidden = [];
  List<bool> _balloonExploding = []; // Para rastrear si está en proceso de explosión
  List<Offset> _balloonPositions = [];
  int _balloonExerciseIndex = -1;

  // Estado para minijuego: memorama
  List<String> _memLabels = [];
  List<int> _memPairIds = [];
  Set<int> _memMatchedCards = <int>{}; // Índices de cartas emparejadas
  List<int> _memRevealed = [];
  int _memExerciseIndex = -1;
  int _memRoundId = 0; // Para invalidar callbacks atrasados
  int _memMaxLives = 4; // Vidas para memorama

  // Estado para minijuego: ahorcado
  Set<String> _hangGuessed = <String>{};
  Set<String> _hangUsed = <String>{};
  int _hangWrongCount = 0;
  final int _hangMaxWrong = 6;
  int _hangExerciseIndex = -1;

  // Estado para minijuego: arrastrar a huecos
  List<String?> _fillPlaced = [];
  Set<int> _fillWrong = <int>{};
  int _fillExerciseIndex = -1;

  // Estado para minijuego: duck hunt
  int _duckExerciseIndex = -1;
  List<double> _duckX = [];
  List<double> _duckY = [];
  List<bool> _duckHidden = [];
  double _duckAreaWidth = 300;
  Timer? _duckTimer;
  List<double> _duckVX = [];
  List<double> _duckVY = [];

  // Estado: typing shooter
  int _typingExerciseIndex = -1;
  bool _typingLaunched = false;

  @override
  void initState() {
    super.initState();
    _generateExercises();
  }

  void _generateExercises() {
    final rnd = math.Random();

    // 1) Multiple Choice: tiempos verbales, completar huecos
    final List<GrammarExercise> mcq = [];
    final subjects = ['I', 'You', 'He', 'She', 'We', 'They'];
    final verbs = [
      {'base': 'go', 'past': 'went', 'pp': 'gone', 'ing': 'going', 's': 'goes'},
      {'base': 'eat', 'past': 'ate', 'pp': 'eaten', 'ing': 'eating', 's': 'eats'},
      {'base': 'have', 'past': 'had', 'pp': 'had', 'ing': 'having', 's': 'has'},
      {'base': 'be', 'past': 'was/were', 'pp': 'been', 'ing': 'being', 's': 'is'},
      {'base': 'see', 'past': 'saw', 'pp': 'seen', 'ing': 'seeing', 's': 'sees'},
      {'base': 'make', 'past': 'made', 'pp': 'made', 'ing': 'making', 's': 'makes'},
      {'base': 'study', 'past': 'studied', 'pp': 'studied', 'ing': 'studying', 's': 'studies'},
      {'base': 'play', 'past': 'played', 'pp': 'played', 'ing': 'playing', 's': 'plays'},
    ];

    final timeAdverbs = ['every day', 'yesterday', 'right now', 'often', 'last week', 'tomorrow', 'at the moment'];

    // Plantillas de MCQ
    for (int i = 0; i < 110; i++) {
      final subj = subjects[rnd.nextInt(subjects.length)];
      final verb = verbs[rnd.nextInt(verbs.length)];
      final adv = timeAdverbs[rnd.nextInt(timeAdverbs.length)];

      // Elegir tiempo verbal según adverbio
      String prompt = '';
      String correct = '';
      final List<String> opts = [];

      if (adv == 'yesterday' || adv == 'last week') {
        // pasado simple
        prompt = '$subj ____ to the park $adv.';
        correct = verb['past']!;
        opts.addAll({verb['base']!, verb['past']!, verb['pp']!, verb['ing']!});
      } else if (adv == 'right now' || adv == 'at the moment') {
        // presente continuo
        final be = (subj == 'He' || subj == 'She') ? 'is' : (subj == 'I' ? 'am' : 'are');
        prompt = '$subj $be ____ to the park $adv.';
        correct = verb['ing']!;
        opts.addAll({verb['ing']!, verb['past']!, verb['base']!, verb['s']!});
      } else if (adv == 'tomorrow') {
        // futuro simple
        prompt = '$subj will ____ to the park $adv.';
        correct = verb['base']!;
        opts.addAll({verb['base']!, verb['s']!, verb['past']!, verb['pp']!});
      } else {
        // presente simple
        final v = (subj == 'He' || subj == 'She') ? verb['s']! : verb['base']!;
        prompt = '$subj ____ to the park $adv.';
        correct = v;
        opts.addAll({verb['s']!, verb['base']!, verb['ing']!, verb['past']!});
      }

      final shuffled = List<String>.from(opts)..shuffle(rnd);
      mcq.add(GrammarExercise(
        type: GrammarType.multipleChoice,
        prompt: prompt,
        options: shuffled,
        answer: correct,
        explanation: 'Selecciona la forma correcta del verbo según el contexto temporal.',
        category: 'Tiempos Verbales',
      ));
    }

    // 2) True/False: afirmaciones gramaticales
    final List<GrammarExercise> tf = [];
    final tfStatements = <Map<String, dynamic>>[
      {'text': 'She go to school every day.', 'answer': false, 'fix': 'She goes to school every day.'},
      {'text': 'They was happy.', 'answer': false, 'fix': 'They were happy.'},
      {'text': 'I have been to London.', 'answer': true, 'fix': ''},
      {'text': 'He don\'t like coffee.', 'answer': false, 'fix': 'He doesn\'t like coffee.'},
      {'text': 'We are studying now.', 'answer': true, 'fix': ''},
      {'text': 'The cats is sleeping.', 'answer': false, 'fix': 'The cats are sleeping.'},
      {'text': 'It rains a lot in April.', 'answer': true, 'fix': ''},
      {'text': 'Does she plays tennis?', 'answer': false, 'fix': 'Does she play tennis?'},
      {'text': 'There is many people here.', 'answer': false, 'fix': 'There are many people here.'},
      {'text': 'He has eaten breakfast.', 'answer': true, 'fix': ''},
      {'text': 'We didn\'t went to the party.', 'answer': false, 'fix': 'We didn\'t go to the party.'},
      {'text': 'I am reading a book.', 'answer': true, 'fix': ''},
      {'text': 'She can sings very well.', 'answer': false, 'fix': 'She can sing very well.'},
      {'text': 'They have finished their homework.', 'answer': true, 'fix': ''},
      {'text': 'He is tallest than me.', 'answer': false, 'fix': 'He is taller than me.'},
      {'text': 'We were watching a movie.', 'answer': true, 'fix': ''},
      {'text': 'I doesn\'t like apples.', 'answer': false, 'fix': 'I don\'t like apples.'},
      {'text': 'She was born in 1990.', 'answer': true, 'fix': ''},
      {'text': 'He don\'t have any friends.', 'answer': false, 'fix': 'He doesn\'t have any friends.'},
      {'text': 'There are a book on the table.', 'answer': false, 'fix': 'There is a book on the table.'},
    ];

    for (int i = 0; i < 60; i++) {
      final s = tfStatements[rnd.nextInt(tfStatements.length)];
      tf.add(GrammarExercise(
        type: GrammarType.trueFalse,
        prompt: s['text'] as String,
        options: const ['True', 'False'],
        answer: s['answer'] as bool,
        explanation: (s['fix'] as String).isEmpty ? null : 'Corrección: ${s['fix']}',
        category: 'Verdadero/Falso',
      ));
    }

    // 3) Ordenar palabras (orderWords)
    final List<GrammarExercise> order = [];
    final orderTemplates = <Map<String, dynamic>>[
      {'correct': 'I am learning English now'},
      {'correct': 'She plays the piano beautifully'},
      {'correct': 'They have finished their work'},
      {'correct': 'We will go to the beach tomorrow'},
      {'correct': 'He is taller than his brother'},
      {'correct': 'There are many apples in the basket'},
      {'correct': 'The movie was very interesting'},
      {'correct': 'Please speak more slowly'},
      {'correct': 'It is raining heavily outside'},
      {'correct': 'Can you help me with this'},
    ];

    for (int i = 0; i < 60; i++) {
      final t = orderTemplates[rnd.nextInt(orderTemplates.length)]['correct'] as String;
      final tokens = t.split(' ');
      final shuffled = List<String>.from(tokens)..shuffle(rnd);
      order.add(GrammarExercise(
        type: GrammarType.orderWords,
        prompt: 'Ordena las palabras para formar la oración correcta:',
        options: shuffled,
        answer: tokens, // lista en orden
        explanation: 'Frase correcta: $t',
        category: 'Orden de Palabras',
      ));
    }

    // 4) Minijuego: Reventar globos (selecciona la opción correcta)
    final List<GrammarExercise> balloon = [];
    for (int i = 0; i < 15; i++) {
      final subj = subjects[rnd.nextInt(subjects.length)];
      final verb = verbs[rnd.nextInt(verbs.length)];
      final adv = timeAdverbs[rnd.nextInt(timeAdverbs.length)];
      String prompt = '';
      String correct = '';
      final List<String> opts = [];
      if (adv == 'yesterday' || adv == 'last week') {
        prompt = '[Globos] $subj ____ to the park $adv.';
        correct = verb['past']!;
        opts.addAll({verb['base']!, verb['past']!, verb['pp']!, verb['ing']!});
      } else if (adv == 'right now' || adv == 'at the moment') {
        final be = (subj == 'He' || subj == 'She') ? 'is' : (subj == 'I' ? 'am' : 'are');
        prompt = '[Globos] $subj $be ____ to the park $adv.';
        correct = verb['ing']!;
        opts.addAll({verb['ing']!, verb['past']!, verb['base']!, verb['s']!});
      } else if (adv == 'tomorrow') {
        prompt = '[Globos] $subj will ____ to the park $adv.';
        correct = verb['base']!;
        opts.addAll({verb['base']!, verb['s']!, verb['past']!, verb['pp']!});
      } else {
        final v = (subj == 'He' || subj == 'She') ? verb['s']! : verb['base']!;
        prompt = '[Globos] $subj ____ to the park $adv.';
        correct = v;
        opts.addAll({verb['s']!, verb['base']!, verb['ing']!, verb['past']!});
      }
      final shuffled = List<String>.from(opts)..shuffle(rnd);
      balloon.add(GrammarExercise(
        type: GrammarType.balloonPop,
        prompt: prompt,
        options: shuffled,
        answer: correct,
        explanation: 'Toca el globo con la opción correcta.',
        category: 'Minijuego: Globos',
      ));
    }

    // 4b) Minijuego: Duck Hunt (toca el pato con la opción correcta)
    final List<GrammarExercise> duckHunt = [];
    for (int i = 0; i < 15; i++) {
      final subj = subjects[rnd.nextInt(subjects.length)];
      final verb = verbs[rnd.nextInt(verbs.length)];
      final adv = timeAdverbs[rnd.nextInt(timeAdverbs.length)];
      String prompt = '';
      String correct = '';
      final List<String> opts = [];
      if (adv == 'yesterday' || adv == 'last week') {
        prompt = '[DuckHunt] $subj ____ to the park $adv.';
        correct = verb['past']!;
        opts.addAll({verb['base']!, verb['past']!, verb['pp']!, verb['ing']!});
      } else if (adv == 'right now' || adv == 'at the moment') {
        final be = (subj == 'He' || subj == 'She') ? 'is' : (subj == 'I' ? 'am' : 'are');
        prompt = '[DuckHunt] $subj $be ____ to the park $adv.';
        correct = verb['ing']!;
        opts.addAll({verb['ing']!, verb['past']!, verb['base']!, verb['s']!});
      } else if (adv == 'tomorrow') {
        prompt = '[DuckHunt] $subj will ____ to the park $adv.';
        correct = verb['base']!;
        opts.addAll({verb['base']!, verb['s']!, verb['past']!, verb['pp']!});
      } else {
        final v = (subj == 'He' || subj == 'She') ? verb['s']! : verb['base']!;
        prompt = '[DuckHunt] $subj ____ to the park $adv.';
        correct = v;
        opts.addAll({verb['s']!, verb['base']!, verb['ing']!, verb['past']!});
      }
      final shuffled = List<String>.from(opts)..shuffle(rnd);
      duckHunt.add(GrammarExercise(
        type: GrammarType.duckHunt,
        prompt: prompt,
        options: shuffled,
        answer: correct,
        explanation: 'Dispara al pato con la opción correcta.',
        category: 'Minijuego: Duck Hunt',
      ));
    }

    // 4c) Minijuego: Typing Shooter (zty.pe-like) - más frecuente (5 rondas)
    final List<GrammarExercise> typingShooter = List.generate(5, (i) => GrammarExercise(
      type: GrammarType.typingShooter,
      prompt: 'Typing Shooter: escribe las palabras para destruir las naves (Ronda ${i + 1})',
      options: const [],
      answer: 'ROUND_${i + 1}',
      explanation: 'Escribe las letras mostradas para destruir a los enemigos. Vence al jefe para completar la ronda.',
      category: 'Minijuego: Typing Shooter',
    ));

    // 5) Minijuego: Memorama (pares únicos de múltiples categorías)
    final List<GrammarExercise> memory = [];
    // Pool de categorías (pares únicos)
    final memoryPools = <Map<String, String>>[
      // País ↔ Gentilicio
      {'Mexico': 'Mexican', 'Spain': 'Spanish', 'Japan': 'Japanese', 'Brazil': 'Brazilian', 'France': 'French', 'Germany': 'German'},
      // Color ↔ Español
      {'Red': 'Rojo', 'Blue': 'Azul', 'Green': 'Verde', 'Yellow': 'Amarillo', 'Black': 'Negro', 'White': 'Blanco'},
      // Animal ↔ Español
      {'Dog': 'Perro', 'Cat': 'Gato', 'Bird': 'Pájaro', 'Fish': 'Pez', 'Horse': 'Caballo', 'Cow': 'Vaca'},
      // Profesión ↔ Español
      {'Teacher': 'Maestro', 'Doctor': 'Doctor', 'Engineer': 'Ingeniero', 'Nurse': 'Enfermero', 'Lawyer': 'Abogado'},
      // Antónimos
      {'Big': 'Small', 'Hot': 'Cold', 'Fast': 'Slow', 'Happy': 'Sad', 'Tall': 'Short', 'Early': 'Late'},
      // Verbo ↔ Pasado
      {'Go': 'Went', 'Eat': 'Ate', 'See': 'Saw', 'Make': 'Made', 'Have': 'Had', 'Write': 'Wrote'},
      // Verbo ↔ 3a persona
      {'Go': 'Goes', 'Study': 'Studies', 'Have': 'Has', 'Do': 'Does', 'Watch': 'Watches'},
      // Preposición ↔ Uso
      {'On': 'Surface', 'In': 'Inside', 'At': 'Point', 'Under': 'Below', 'Between': 'Middle'},
    ];

    // Generar muchos ejercicios de memorama mezclando categorías
    for (int i = 0; i < 30; i++) {
      // 1 de cada ~5 usa to be determinista para reforzar base
      if (i % 5 == 0) {
        final heOrShe = rnd.nextBool() ? 'He' : 'She';
        final pairs = <String, String>{'I': 'am', 'You': 'are', heOrShe: 'is'};
        memory.add(GrammarExercise(
          type: GrammarType.memoryPairs,
          prompt: 'Memorama: empareja pronombre y verbo "to be"',
          options: const [],
          answer: pairs,
          explanation: 'Voltea dos cartas para formar un par correcto.',
          category: 'Minijuego: Memorama',
        ));
        continue;
      }
      // Elegir categoría aleatoria del pool
      final pool = Map<String, String>.from(memoryPools[rnd.nextInt(memoryPools.length)]);
      final keys = pool.keys.toList()..shuffle(rnd);
      // Tomar 3 pares únicos
      final picked = <String, String>{};
      for (int k = 0; k < keys.length && picked.length < 3; k++) {
        final k0 = keys[k];
        final v0 = pool[k0]!;
        if (!picked.containsKey(k0) && !picked.containsValue(v0)) {
          picked[k0] = v0;
        }
      }
      if (picked.length == 3) {
        memory.add(GrammarExercise(
          type: GrammarType.memoryPairs,
          prompt: 'Memorama: empareja los conceptos relacionados',
          options: const [],
          answer: picked,
          explanation: 'Encuentra los 3 pares correspondientes.',
          category: 'Minijuego: Memorama',
        ));
      }
    }

    // 6) Minijuego: Ahorcado (adivina la palabra letra por letra)
    final List<GrammarExercise> hangman = [];
    final hangmanPool = <Map<String, String>>[
      {'word': 'ADJECTIVE', 'clue': 'Palabra que describe a un sustantivo (en inglés).'},
      {'word': 'VERB', 'clue': 'Palabra que expresa una acción (en inglés).'},
      {'word': 'PRONOUN', 'clue': 'Palabra que reemplaza a un sustantivo (en inglés).'},
      {'word': 'PREPOSITION', 'clue': 'Palabra que muestra relación entre palabras (en inglés).'},
      {'word': 'BECAUSE', 'clue': 'Conector causal común en inglés.'},
      {'word': 'BEAUTIFUL', 'clue': 'Antónimo de ugly.'},
      {'word': 'YESTERDAY', 'clue': 'Indica pasado (adverbio de tiempo).'},
      {'word': 'TOMORROW', 'clue': 'Indica futuro (adverbio de tiempo).'},
      {'word': 'SENTENCE', 'clue': 'Conjunto de palabras con sentido completo (en inglés).'},
      {'word': 'GRAMMAR', 'clue': 'Conjunto de reglas de una lengua (en inglés).'},
      {'word': 'VOCABULARY', 'clue': 'Conjunto de palabras conocidas (en inglés).'},
      {'word': 'TEACHER', 'clue': 'Persona que enseña (en inglés).'},
      {'word': 'STUDENT', 'clue': 'Persona que aprende (en inglés).'},
      {'word': 'LISTEN', 'clue': 'Acción de prestar atención a sonidos (en inglés).'},
      {'word': 'SPEAK', 'clue': 'Acción de hablar (en inglés).'},
      {'word': 'THOUGHT', 'clue': 'Pasado de think.'},
      {'word': 'WRITTEN', 'clue': 'Participio pasado de write.'},
      {'word': 'WERE', 'clue': 'Pasado plural de be.'},
      {'word': 'THAN', 'clue': 'Comparativo: A is taller ___ B.'},
      {'word': 'THERE', 'clue': 'Homófono de their/they’re; adverbio de lugar.'},
    ];
    for (int i = 0; i < 20; i++) {
      final e = hangmanPool[rnd.nextInt(hangmanPool.length)];
      hangman.add(GrammarExercise(
        type: GrammarType.hangman,
        prompt: 'Hangman: ${e['clue']}',
        options: const [],
        answer: e['word'],
        explanation: 'Adivina la palabra con las letras correctas.',
        category: 'Minijuego: Hangman',
      ));
    }

    // 7) Arrastrar a huecos (dragFill)
    final List<GrammarExercise> dragFill = [];
    final clozePool = <Map<String, dynamic>>[
      {
        'prompt': 'I ____ to the gym ____ day.',
        'answer': ['go', 'every'],
        'options': ['go', 'goes', 'every', 'any', 'yesterday']
      },
      {
        'prompt': 'She ____ English ____ the weekends.',
        'answer': ['studies', 'on'],
        'options': ['study', 'studies', 'in', 'on', 'at']
      },
      {
        'prompt': 'They ____ dinner ____ 7 pm.',
        'answer': ['have', 'at'],
        'options': ['has', 'have', 'in', 'on', 'at']
      },
      {
        'prompt': 'We ____ to the beach ____ summer.',
        'answer': ['go', 'in'],
        'options': ['go', 'goes', 'on', 'in', 'at']
      },
      {
        'prompt': 'He ____ coffee ____ the morning.',
        'answer': ['drinks', 'in'],
        'options': ['drink', 'drinks', 'in', 'on', 'at']
      },
      {
        'prompt': 'There ____ many people ____ the park.',
        'answer': ['are', 'in'],
        'options': ['is', 'are', 'at', 'in', 'on']
      },
      {
        'prompt': 'I ____ breakfast ____ 8 o\'clock.',
        'answer': ['have', 'at'],
        'options': ['has', 'have', 'in', 'on', 'at']
      },
      {
        'prompt': 'She ____ very fast ____ running.',
        'answer': ['is', 'at'],
        'options': ['is', 'are', 'at', 'in', 'on']
      },
      {
        'prompt': 'We ____ a new book ____ the library.',
        'answer': ['found', 'in'],
        'options': ['find', 'found', 'at', 'in', 'on']
      },
      {
        'prompt': 'He ____ soccer ____ Sundays.',
        'answer': ['plays', 'on'],
        'options': ['play', 'plays', 'in', 'at', 'on']
      },
    ];
    for (int i = 0; i < 20; i++) {
      final e = clozePool[rnd.nextInt(clozePool.length)];
      final opt = List<String>.from(e['options'] as List)..shuffle(rnd);
      dragFill.add(GrammarExercise(
        type: GrammarType.dragFill,
        prompt: e['prompt'] as String,
        options: opt,
        answer: List<String>.from(e['answer'] as List<String>),
        explanation: 'Arrastra las palabras correctas a cada hueco.',
        category: 'Completar Oraciones (Arrastre)',
      ));
    }

    // Restaurar encabezado fijo inicial y memorama fijo, luego mezclar el resto de forma balanceada
    _exercises.clear();

    // Base principal mezclada sin minijuegos fijos
    final base = <GrammarExercise>[
      ...mcq,
      ...tf,
      ...order,
      ...dragFill,
    ]..shuffle(rnd);

    // Tomar candidatos de minijuegos
    final firstBalloon = balloon.isNotEmpty ? balloon.first : GrammarExercise(
      type: GrammarType.balloonPop,
      prompt: '[Globos] I ____ to the park every day.',
      options: const ['go', 'goes', 'went', 'going'],
      answer: 'go',
      category: 'Minijuego: Globos',
    );
    final firstHangman = hangman.isNotEmpty ? hangman.first : GrammarExercise(
      type: GrammarType.hangman,
      prompt: 'Hangman: Palabra que expresa una acción (en inglés).',
      options: const [],
      answer: 'VERB',
      category: 'Minijuego: Hangman',
    );
    final firstDuck = duckHunt.isNotEmpty ? duckHunt.first : GrammarExercise(
      type: GrammarType.duckHunt,
      prompt: '[DuckHunt] She ____ English on the weekends.',
      options: const ['study', 'studies', 'studied', 'studying'],
      answer: 'studies',
      category: 'Minijuego: Duck Hunt',
    );
    final firstTyping = typingShooter.isNotEmpty ? typingShooter.first : GrammarExercise(
      type: GrammarType.typingShooter,
      prompt: 'Typing Shooter: escribe las palabras para destruir las naves (Ronda 1)',
      options: const [],
      answer: 'ROUND_1',
      category: 'Minijuego: Typing Shooter',
    );

    // Inserciones fijas al inicio según tu orden previo
    // Índice 0: primer elemento de base (si base está vacío, se completará con el resto)
    if (base.isNotEmpty) {
      _exercises.add(base.removeAt(0));
    }
    // Índice 1: Globos
    _exercises.add(firstBalloon);
    // Índice 2: Hangman
    _exercises.add(firstHangman);
    // Índice 3: Duck Hunt
    _exercises.add(firstDuck);
    // Índice 4: Typing Shooter
    _exercises.add(firstTyping);

    // Preparar memorama fijo en índice 6
    GrammarExercise? fixedMemory;
    if (memory.isNotEmpty) {
      fixedMemory = memory.first;
    }

    // Resto de ejercicios disponibles (excluyendo los ya usados como primeros)
    final used = <GrammarExercise>{firstBalloon, firstHangman, firstDuck, firstTyping};
    final remaining = <GrammarExercise>[
      ...base,
      ...balloon.where((e) => !used.contains(e)),
      ...hangman.where((e) => !used.contains(e)),
      ...duckHunt.where((e) => !used.contains(e)),
      ...typingShooter.where((e) => !used.contains(e)),
      ...memory.where((e) => e != fixedMemory),
    ];

    // Mezclar el resto
    remaining.shuffle(rnd);

    // Si hay memorama fijo, insertarlo en índice 6 (o al final si no alcanza la longitud)
    if (fixedMemory != null) {
      final insertIndex = math.min(6, _exercises.length);
      // Rellenar hasta índice 6 con elementos de remaining si hace falta
      while (_exercises.length < 6 && remaining.isNotEmpty) {
        _exercises.add(remaining.removeAt(0));
      }
      final idx = math.min(6, _exercises.length);
      _exercises.insert(idx, fixedMemory);
    }

    // Añadir los restantes
    _exercises.addAll(remaining);

    // Paso de balanceo: evitar demasiados consecutivos del mismo tipo
    for (int i = 2; i < _exercises.length - 1; i++) {
      final prev = _exercises[i - 1].type;
      final curr = _exercises[i].type;
      final next = _exercises[i + 1].type;
      // Si hay racha de 3 iguales prev-curr-next, intenta intercambiar con un siguiente distinto
      if (prev == curr && curr == next) {
        for (int j = i + 2; j < _exercises.length; j++) {
          if (_exercises[j].type != curr) {
            final tmp = _exercises[i + 1];
            _exercises[i + 1] = _exercises[j];
            _exercises[j] = tmp;
            break;
          }
        }
      }
    }

    _exercises.shuffle(rnd);
    
    // Insertar minijuegos al inicio en orden específico
    _exercises.insert(1, balloon.isNotEmpty ? balloon[0] : GrammarExercise(
      type: GrammarType.balloonPop,
      prompt: '[Globos] I ____ to the park every day.',
      options: ['go', 'goes', 'went', 'going'],
      answer: 'go',
      category: 'Minijuego: Globos',
    ));
    
    _exercises.insert(2, hangman.isNotEmpty ? hangman[0] : GrammarExercise(
      type: GrammarType.hangman,
      prompt: 'Hangman: Palabra que expresa una acción (en inglés).',
      options: const [],
      answer: 'VERB',
      category: 'Minijuego: Hangman',
    ));
    
    _exercises.insert(3, duckHunt.isNotEmpty ? duckHunt[0] : GrammarExercise(
      type: GrammarType.duckHunt,
      prompt: '[DuckHunt] She ____ English on the weekends.',
      options: ['study', 'studies', 'studied', 'studying'],
      answer: 'studies',
      category: 'Minijuego: Duck Hunt',
    ));
    
    // Agregar typing shooter después (mantener su posición)
    if (typingShooter.isNotEmpty) {
      _exercises.insert(4, typingShooter[0]);
    }
    
    // Agregar memorama 2 ejercicios después del primer typing shooter (índice 6)
    if (memory.isNotEmpty) {
      _exercises.insert(6, memory[0]);
    }
  }

  void _selectOption(String option) {
    if (_answered) return;

    setState(() {
      _lastSelectedOption = option;
      _lastOrderWrong = false;
      final ex = _exercises[_index];

      if (ex.type == GrammarType.multipleChoice) {
        _isCorrect = (option == (ex.answer as String));
      } else if (ex.type == GrammarType.trueFalse) {
        final boolAns = (ex.answer as bool);
        _isCorrect = (option == (boolAns ? 'True' : 'False'));
      }

      if (_isCorrect) {
        _answered = true;
      } else {
        _attempts += 1; // solo baja vida si fue incorrecto
        HapticFeedback.lightImpact();
        if (_attempts >= 2) {
          _answered = true; // se mostrará la correcta
        }
      }
    });
  }

  void _checkOrder() {
    if (_answered) return;
    setState(() {
      final ex = _exercises[_index];
      final correctTokens = (ex.answer as List<String>);
      _isCorrect = listEquals(_currentOrder, correctTokens);
      _lastOrderWrong = !_isCorrect;
      if (_isCorrect) {
        _answered = true;
      } else {
        _attempts += 1; // solo baja vida si fue incorrecto
        HapticFeedback.lightImpact();
        if (_attempts >= 2) {
          _answered = true;
        }
      }
    });
  }

  void _next() {
    setState(() {
      _index = (_index + 1) % _exercises.length;
      _attempts = 0;
      _answered = false;
      _isCorrect = false;
      _currentOrder = [];
      _lastSelectedOption = null;
      _lastOrderWrong = false;
      // Reset minijuegos
      _balloonHidden = [];
      _balloonPositions = [];
      _balloonExerciseIndex = -1;
      _memLabels = [];
      _memPairIds = [];
      _memMatchedCards = <int>{};
      _memRevealed = [];
      _memExerciseIndex = -1;
      // Reset ahorcado
      _hangGuessed = <String>{};
      _hangUsed = <String>{};
      _hangWrongCount = 0;
      _hangExerciseIndex = -1;
      // Reset dragFill
      _fillPlaced = [];
      _fillWrong = <int>{};
      _fillExerciseIndex = -1;
      // Reset duck hunt
      _duckTimer?.cancel();
      _duckTimer = null;
      _duckExerciseIndex = -1;
      _duckX = [];
      _duckY = [];
      _duckHidden = [];
      _duckVX = [];
      _duckVY = [];
      // Reset typing shooter
      _typingExerciseIndex = -1;
      _typingLaunched = false;
    });
  }

  List<Widget> _buildBalloonExplosion(Color color) {
    final particles = <Widget>[];
    final rnd = math.Random(42); // Seed fijo para consistencia
    
    // Generar 16 partículas en lugar de 8
    for (int i = 0; i < 16; i++) {
      final angle = (i / 16) * 2 * math.pi;
      final distance = 50.0 + rnd.nextDouble() * 20.0; // Distancia variable
      final dx = math.cos(angle) * distance;
      final dy = math.sin(angle) * distance;
      
      // Tamaño variable de partículas
      final size = 4.0 + rnd.nextDouble() * 8.0;
      
      // Rotación aleatoria
      final rotation = rnd.nextDouble() * 2 * math.pi;
      
      particles.add(
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            // Easing: comienza rápido, termina lento
            final easeValue = value < 0.5 
              ? 2 * value * value 
              : -1 + (4 - 2 * value) * value;
            
            return Transform.translate(
              offset: Offset(dx * easeValue, dy * easeValue),
              child: Transform.rotate(
                angle: rotation * easeValue,
                child: Opacity(
                  opacity: (1.0 - value).clamp(0.0, 1.0),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    // Agregar onda de choque (círculo expandible)
    particles.add(
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value * 2.5,
            child: Opacity(
              opacity: (1.0 - value) * 0.6,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: 2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    
    return particles;
  }

  @override
  void dispose() {
    _duckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ex = _exercises.isEmpty ? null : _exercises[_index];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA5D6A7), // Verde claro
        foregroundColor: Colors.white,
        title: const Text('Ejercicios gramaticales'),
      ),
      body: ex == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppDimensions.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(ex),
                  const SizedBox(height: 16),
                  Expanded(child: _buildExerciseCard(ex)),
                  const SizedBox(height: 12),
                  _buildFooter(ex),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(GrammarExercise ex) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFA5D6A7).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book_rounded, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.category,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text('Ejercicio ${_index + 1} de ${_exercises.length}', style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
            _buildAttempts(ex),
          ],
        ),
      ),
    );
  }

  Widget _buildAttempts(GrammarExercise ex) {
    if (ex.type == GrammarType.hangman) {
      return Row(
        children: [
          const Icon(Icons.accessibility_new_rounded, color: Colors.black87, size: 18),
          const SizedBox(width: 6),
          Text('Fallos: $_hangWrongCount/$_hangMaxWrong'),
          const SizedBox(width: 8),
          Row(
            children: List.generate(_hangMaxWrong, (i) {
              final active = i < _hangWrongCount;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Icon(
                  Icons.circle,
                  size: 8,
                  color: active ? Colors.redAccent : Colors.grey[400],
                ),
              );
            }),
          ),
        ],
      );
    }

    // Para memorama: mostrar 4 corazones
    if (ex.type == GrammarType.memoryPairs) {
      final remaining = (_answered && !_isCorrect) ? 0 : (_memMaxLives - _attempts).clamp(0, _memMaxLives);
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
        child: Row(
          key: ValueKey('hearts-mem-$remaining'),
          children: List.generate(_memMaxLives, (i) {
            final filled = i < remaining;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(Icons.favorite, color: filled ? Colors.redAccent : Colors.grey, size: 18),
            );
          }),
        ),
      );
    }

    final remaining = (_answered && !_isCorrect) ? 0 : (2 - _attempts).clamp(0, 2);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
      child: Row(
        key: ValueKey('hearts-$remaining'),
        children: List.generate(2, (i) {
          final filled = i < remaining;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(Icons.favorite, color: filled ? Colors.redAccent : Colors.grey, size: 18),
          );
        }),
      ),
    );
  }

  Widget _buildExerciseCard(GrammarExercise ex) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                ex.prompt,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              if (ex.type == GrammarType.multipleChoice) _buildMCQ(ex),
              if (ex.type == GrammarType.trueFalse) _buildTrueFalse(ex),
              if (ex.type == GrammarType.orderWords) _buildOrderWords(ex),
              if (ex.type == GrammarType.balloonPop) _buildBalloonPop(ex),
              if (ex.type == GrammarType.duckHunt) _buildDuckHunt(ex),
              if (ex.type == GrammarType.typingShooter) _buildTypingShooter(ex),
              if (ex.type == GrammarType.memoryPairs) _buildMemoryPairs(ex),
              if (ex.type == GrammarType.hangman) _buildHangman(ex),
              if (ex.type == GrammarType.dragFill) _buildDragFill(ex),
              const SizedBox(height: 16),
              _buildFeedback(ex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMCQ(GrammarExercise ex) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ex.options.map((o) {
        final isDisabled = _answered && !_isCorrect && _attempts >= 2;
        Color bg = Colors.white;
        Color border = Colors.grey[300]!;
        if (_answered) {
          if (o == ex.answer) {
            bg = Colors.green[50]!;
            border = Colors.green;
          } else if (_attempts >= 2) {
            bg = Colors.red[50]!;
            border = Colors.red;
          }
        } else {
          if (!_isCorrect && _lastSelectedOption == o) {
            bg = Colors.red[50]!;
            border = Colors.red;
          }
        }
        return GestureDetector(
          onTap: (_answered && !_isCorrect && _attempts >= 2) || _answered && _isCorrect ? null : () => _selectOption(o),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3)),
              ],
            ),
            child: Text(o, style: const TextStyle(fontSize: 16)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalse(GrammarExercise ex) {
    final buttons = ['True', 'False'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons.map((b) {
        final isCorrectBtn = (ex.answer as bool) ? b == 'True' : b == 'False';
        Color bg = Colors.white;
        Color border = Colors.grey[300]!;
        if (_answered) {
          if (isCorrectBtn) {
            bg = Colors.green[50]!;
            border = Colors.green;
          } else if (_attempts >= 2) {
            bg = Colors.red[50]!;
            border = Colors.red;
          }
        } else {
          if (!_isCorrect && _lastSelectedOption == b) {
            bg = Colors.red[50]!;
            border = Colors.red;
          }
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            onPressed: (_answered && !_isCorrect && _attempts >= 2) || _answered && _isCorrect ? null : () => _selectOption(b),
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: Colors.black,
              side: BorderSide(color: border),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: Text(b, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderWords(GrammarExercise ex) {
    if (_currentOrder.isEmpty) {
      _currentOrder = List<String>.from(ex.options);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _lastOrderWrong ? Colors.red : Colors.transparent, width: 1.2),
          ),
          child: ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorderStart: (_) => HapticFeedback.selectionClick(),
            itemBuilder: (context, i) {
              final token = _currentOrder[i];
              return Card(
                key: ValueKey(token + i.toString()),
                child: ReorderableDragStartListener(
                  index: i,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.drag_handle_rounded, color: Colors.grey[600], size: 26),
                        const SizedBox(width: 8),
                        Text(token, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: _currentOrder.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _currentOrder.removeAt(oldIndex);
                _currentOrder.insert(newIndex, item);
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.center,
          child: FilledButton.icon(
            onPressed: (_answered && !_isCorrect && _attempts >= 2) || _answered && _isCorrect ? null : _checkOrder,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Comprobar orden'),
          ),
        ),
      ],
    );
  }

  Widget _buildBalloonPop(GrammarExercise ex) {
    if (_balloonExerciseIndex != _index) {
      _balloonExerciseIndex = _index;
      _balloonHidden = List<bool>.filled(ex.options.length, false);
      _balloonExploding = List<bool>.filled(ex.options.length, false);
    }

    return SizedBox(
      height: 280,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          const h = 280.0;
          return Stack(
            children: List.generate(ex.options.length, (i) {
              final o = ex.options[i];
              if (_balloonHidden[i] && !_answered) {
                return const SizedBox.shrink();
              }
              const balloonSize = 84.0;
              const minSpacing = 16.0;
              final cols = math.max(2, (w / (balloonSize + minSpacing)).floor());
              final rows = (ex.options.length / cols).ceil();
              final cellW = w / cols;
              final cellH = h / rows;
              final r = i ~/ cols;
              final c = i % cols;
              final cx = c * cellW + cellW / 2;
              final cy = r * cellH + cellH / 2;
              final rnd = math.Random(_index * 97 + i * 17);
              final maxShiftX = math.max(0.0, (cellW - balloonSize) / 2 - 4);
              final maxShiftY = math.max(0.0, (cellH - balloonSize) / 2 - 4);
              final shiftX = (rnd.nextDouble() * 2 - 1) * maxShiftX;
              final shiftY = (rnd.nextDouble() * 2 - 1) * maxShiftY;
              final double left = (cx - balloonSize / 2 + shiftX).clamp(0.0, w - balloonSize).toDouble();
              final double top = (cy - balloonSize / 2 + shiftY).clamp(0.0, h - balloonSize).toDouble();
              final isCorrect = o == ex.answer;
              Color bg = Colors.lightBlue[200]!;
              Color border = Colors.blue[700]!;
              if (_answered) {
                if (isCorrect) {
                  bg = Colors.green[300]!;
                  border = Colors.green[800]!;
                } else if (_attempts >= 2) {
                  bg = Colors.red[200]!;
                  border = Colors.red[800]!;
                }
              }
              return Positioned(
                left: left,
                top: top,
                child: GestureDetector(
                  onTap: (_answered)
                      ? null
                      : () {
                          if (isCorrect) {
                            setState(() {
                              _isCorrect = true;
                              _answered = true;
                            });
                          } else {
                            setState(() {
                              _attempts += 1;
                              _balloonHidden[i] = true;
                            });
                            HapticFeedback.lightImpact();
                            if (_attempts >= 2) {
                              setState(() {
                                _answered = true;
                              });
                            }
                          }
                        },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Partículas de explosión - mostrar cuando está explotando (no cuando está oculto)
                      if (_balloonExploding[i] && !isCorrect)
                        ..._buildBalloonExplosion(border),
                      // Globo original - desaparece después de la explosión, reaparece al terminar
                      AnimatedScale(
                        scale: (_balloonHidden[i] && !_answered ? 0.0 : 1.0),
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [bg.withOpacity(0.95), Colors.white.withOpacity(0.6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(color: border, width: 2),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                                ],
                              ),
                              child: Text(o, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 4),
                            Transform.rotate(
                              angle: 0.8,
                              child: Container(width: 10, height: 10, color: border),
                            ),
                            const SizedBox(height: 2),
                            Container(width: 2, height: 24, color: Colors.grey[400]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildDuckHunt(GrammarExercise ex) {
    // Inicializar estado si cambia de ejercicio
    if (_duckExerciseIndex != _index) {
      _duckExerciseIndex = _index;
      final n = ex.options.length;
      _duckHidden = List<bool>.filled(n, false);
      _duckX = List<double>.filled(n, 0);
      _duckY = List<double>.filled(n, 0);
      _duckVX = List<double>.filled(n, 0);
      _duckVY = List<double>.filled(n, 0);
      // Spawn inicial aleatorio desde cualquier lado
      final rand = math.Random(_index * 123 + n);
      for (int i = 0; i < n; i++) {
        final side = rand.nextInt(2); // 0=left,1=right (solo horizontal para asegurar visibilidad)
        final speed = 2.0 + rand.nextDouble() * 1.8;
        double x = 0, y = 0, vx = 0, vy = 0;
        const areaH = 260.0;
        final w = _duckAreaWidth;
        const duckWidth = 96.0;
        const labelWidth = 120.0;
        const totalWidth = duckWidth + labelWidth;
        
        if (side == 0) {
          // Desde la izquierda
          x = -totalWidth - 20.0;
          y = 40 + rand.nextDouble() * (areaH - 120);
          vx = speed;
          vy = 0;
        } else {
          // Desde la derecha
          x = w + 20.0;
          y = 40 + rand.nextDouble() * (areaH - 120);
          vx = -speed;
          vy = 0;
        }
        _duckX[i] = x;
        _duckY[i] = y;
        _duckVX[i] = vx;
        _duckVY[i] = vy;
      }
      _duckTimer?.cancel();
      _duckTimer = Timer.periodic(const Duration(milliseconds: 30), (t) {
        if (!mounted || _answered) {
          _duckTimer?.cancel();
          return;
        }
        setState(() {
          for (int i = 0; i < _duckX.length; i++) {
            if (_duckHidden[i]) continue;
            final w = _duckAreaWidth;
            const h = 260.0;
            const duckWidth = 96.0;
            const labelWidth = 120.0;
            const totalWidth = duckWidth + labelWidth;
            
            _duckX[i] += _duckVX[i];
            
            // Respawn cuando sale del área visible
            if (_duckX[i] < -totalWidth - 50 || _duckX[i] > w + 50) {
              final r = math.Random(_index * 321 + i * 11);
              final side = r.nextInt(2);
              final speed = 2.0 + r.nextDouble() * 1.8;
              
              if (side == 0) {
                _duckX[i] = -totalWidth - 20.0;
                _duckY[i] = 40 + r.nextDouble() * (h - 120);
                _duckVX[i] = speed;
              } else {
                _duckX[i] = w + 20.0;
                _duckY[i] = 40 + r.nextDouble() * (h - 120);
                _duckVX[i] = -speed;
              }
            }
          }
        });
      });
    }

    const double areaHeight = 260;

    return SizedBox(
      height: areaHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _duckAreaWidth = constraints.maxWidth;
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondo_duck.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: List.generate(ex.options.length, (i) {
              final o = ex.options[i];
              final isCorrect = o == ex.answer;
              final hidden = i < _duckHidden.length && _duckHidden[i];
              if (hidden && !_answered) {
                return const SizedBox.shrink();
              }
              Color border = Colors.blueGrey;
              Color fill = Colors.lightBlueAccent.withOpacity(0.8);
              if (_answered) {
                if (isCorrect) {
                  border = Colors.green;
                  fill = Colors.greenAccent.withOpacity(0.8);
                } else if (_attempts >= 2) {
                  border = Colors.red;
                  fill = Colors.redAccent.withOpacity(0.6);
                }
              }
              final left = (i < _duckX.length) ? _duckX[i] : -100.0;
              final top = (i < _duckY.length) ? _duckY[i] : 40.0 + 40.0 * i;
              return Positioned(
                left: left,
                top: top,
                child: GestureDetector(
                  onTap: _answered
                      ? null
                      : () {
                          if (isCorrect) {
                            setState(() {
                              _isCorrect = true;
                              _answered = true;
                            });
                            _duckTimer?.cancel();
                          } else {
                            setState(() {
                              _attempts += 1;
                              if (i < _duckHidden.length) _duckHidden[i] = true;
                            });
                            if (_attempts >= 2) {
                              setState(() {
                                _answered = true;
                              });
                              _duckTimer?.cancel();
                            }
                          }
                        },
                  child: _duckWidget(o, border, fill, (_duckVX.length > i ? _duckVX[i] < 0 : false)),
                ),
              );
            }),
            ),
          );
        },
      ),
    );
  }

  Widget _duckWidget(String label, Color border, Color fill, bool flipHoriz) {
      final duckImg = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(flipHoriz ? -1.0 : 1.0, 1.0),
        child: Image.asset(
          'assets/images/duck.gif',
          width: 96,
          height: 80,
          fit: BoxFit.contain,
        ),
      );
      // Amarillo pastel con borde gris oscuro
      final Color chipBg = const Color(0xFFFFF3C4);
      final Color chipBorder = Colors.grey[700]!;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          duckImg,
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: chipBorder, width: 2),
              boxShadow: const [
                BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
        ],
      );
  }

  Widget _buildTypingShooter(GrammarExercise ex) {
    if (_typingExerciseIndex != _index && !_typingLaunched) {
      _typingExerciseIndex = _index;
      _typingLaunched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final result = await Navigator.of(context).push<dynamic>(
          MaterialPageRoute(builder: (_) => const TypingShooterScreen()),
        );
        if (!mounted) return;
        if (result == 'NEXT') {
          setState(() {
            _isCorrect = false;
            _answered = true;
            _typingLaunched = false;
          });
          _next();
        } else {
          setState(() {
            _isCorrect = (result == true);
            _answered = true;
            _typingLaunched = false;
          });
        }
      });
    }
    return const SizedBox(
      height: 280,
      child: Center(child: Text('Iniciando ronda de Typing Shooter...')),
    );
  }

  Widget _buildMemoryPairs(GrammarExercise ex) {
    if (_memExerciseIndex != _index) {
      _memExerciseIndex = _index;
      _memLabels = [];
      _memPairIds = [];
      _memMatchedCards = <int>{};
      _memRevealed = [];
      final pairs = (ex.answer as Map<String, String>);
      final entries = pairs.entries.toList();
      final items = <Map<String, dynamic>>[];
      // Crear lista de items con parId por pareja (no por carta) para emparejar por ID
      for (var i = 0; i < entries.length; i++) {
        items.add({'label': entries[i].key, 'pairId': i});     // sujeto
        items.add({'label': entries[i].value, 'pairId': i});   // to be
      }
      items.shuffle(math.Random(_index));
      for (final it in items) {
        _memLabels.add(it['label'] as String);
        _memPairIds.add(it['pairId'] as int);
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.3,
      ),
      itemCount: _memLabels.length,
      itemBuilder: (context, i) {
        final isMatched = _memMatchedCards.contains(i);
        final isRevealed = isMatched || _memRevealed.contains(i) || _answered;
        return GestureDetector(
          onTap: () {
            if (_answered) return;
            if (isMatched) return; // No se puede tocar cartas ya emparejadas
            if (_memRevealed.contains(i)) return; // No se puede tocar la misma carta dos veces
            
            setState(() {
              _memRevealed.add(i);
            });
            
            if (_memRevealed.length == 2) {
              final currentRound = ++_memRoundId; // snapshot para delayed
              final a = _memRevealed[0];
              final b = _memRevealed[1];

              // Match por parId (sujeto <-> to be) evitando ambigüedades
              if (_memPairIds[a] == _memPairIds[b] && a != b) {
                // ACIERTO: las dos cartas quedan emparejadas en verde
                setState(() {
                  _memMatchedCards.add(a);
                  _memMatchedCards.add(b);
                  _memRevealed.clear();
                  final totalCards = _memLabels.length;
                  // Si se emparejaron todas las cartas, el ejercicio es correcto
                  if (_memMatchedCards.length == totalCards) {
                    _isCorrect = true;
                    _answered = true;
                  }
                });
              } else {
                // FALLO: baja una vida, se muestran un instante y se vuelven a tapar
                _attempts += 1;
                HapticFeedback.lightImpact();
                
                // Delay para que se vean las cartas incorrectas un instante
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (!mounted) return;
                  // Protección: ignorar si cambió de round o ya se completó correctamente
                  if (currentRound != _memRoundId || _isCorrect) return;
                  
                  setState(() {
                    _memRevealed.clear();
                    // Si se gastaron las vidas, marcar como incorrecto
                    if (_attempts >= _memMaxLives) {
                      _answered = true;
                      _isCorrect = false;
                    }
                  });
                });
              }
            }
          },
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: isRevealed ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, child) {
              final angle = value * math.pi;
              final isBack = angle > math.pi / 2;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Fondo que rota
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isBack
                            ? (isMatched ? Colors.green[100] : Colors.amber[100])
                            : Colors.blueGrey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isBack
                              ? (isMatched ? Colors.green : Colors.grey[400]!)
                              : Colors.grey[400]!,
                          width: isBack && isMatched ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
                  // Texto sin rotación
                  if (isBack)
                    Text(
                      _memLabels[i],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )
                  else
                    const Text(
                      '?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Colors.grey,
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHangman(GrammarExercise ex) {
    // Inicializar estado si cambia de ejercicio
    if (_hangExerciseIndex != _index) {
      _hangExerciseIndex = _index;
      _hangGuessed = <String>{};
      _hangUsed = <String>{};
      _hangWrongCount = 0;
    }

    final word = (ex.answer as String).toUpperCase();

    String maskedWord(String w) {
      final buffer = StringBuffer();
      for (final ch in w.characters) {
        final isLetter = RegExp(r'[A-Z]').hasMatch(ch);
        if (!isLetter) {
          buffer.write('$ch ');
        } else if (_hangGuessed.contains(ch)) {
          buffer.write('$ch ');
        } else {
          buffer.write('_ ');
        }
      }
      return buffer.toString().trimRight();
    }

    void pickLetter(String l) {
      if (_answered) return;
      l = l.toUpperCase();
      if (_hangUsed.contains(l)) return;
      setState(() {
        _hangUsed.add(l);
        if (word.contains(l)) {
          _hangGuessed.add(l);
          // ¿se completó?
          final allRevealed = word
              .split('')
              .where((c) => RegExp(r'[A-Z]').hasMatch(c))
              .every((c) => _hangGuessed.contains(c));
          if (allRevealed) {
            _isCorrect = true;
            _answered = true;
          }
        } else {
          _hangWrongCount += 1;
          HapticFeedback.lightImpact();
          if (_hangWrongCount >= _hangMaxWrong) {
            _isCorrect = false;
            _answered = true;
          }
        }
      });
    }

    final letters = List<String>.generate(26, (i) => String.fromCharCode('A'.codeUnitAt(0) + i));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 160,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              return Stack(
                children: [
                  // Base
                  Positioned(
                    left: w * 0.2,
                    right: w * 0.2,
                    bottom: 10,
                    child: Container(height: 8, color: Colors.brown[400]),
                  ),
                  // Poste vertical
                  Positioned(
                    left: w * 0.2,
                    bottom: 18,
                    child: Container(width: 8, height: 120, color: Colors.brown[600]),
                  ),
                  // Viga superior
                  Positioned(
                    left: w * 0.2,
                    top: 10,
                    child: Container(width: w * 0.4, height: 6, color: Colors.brown[500]),
                  ),
                  // Cuerda
                  Positioned(
                    left: w * 0.2 + w * 0.4 - 8,
                    top: 16,
                    child: Container(width: 2, height: 18, color: Colors.brown[700]),
                  ),
                  // Cabeza
                  if (_hangWrongCount >= 1)
                    Positioned(
                      left: w * 0.2 + w * 0.4 - 8 - 11,
                      top: 34,
                      child: Container(width: 22, height: 22, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black87)),
                    ),
                  // Torso
                  if (_hangWrongCount >= 2)
                    Positioned(
                      left: w * 0.2 + w * 0.4 - 8 - 1,
                      top: 56,
                      child: Container(width: 2, height: 36, color: Colors.black87),
                    ),
                  // Brazo izq
                  if (_hangWrongCount >= 3)
                    Positioned(
                      left: w * 0.2 + w * 0.4 - 8 - 10,
                      top: 62,
                      child: Transform.rotate(
                        angle: -0.6,
                        child: Container(width: 2, height: 22, color: Colors.black87),
                      ),
                    ),
                  // Brazo der
                  if (_hangWrongCount >= 4)
                    Positioned(
                      left: w * 0.2 + w * 0.4 - 8 + 8,
                      top: 62,
                      child: Transform.rotate(
                        angle: 0.6,
                        child: Container(width: 2, height: 22, color: Colors.black87),
                      ),
                    ),
                  // Pierna izq
                  if (_hangWrongCount >= 5)
                    Positioned(
                      left: w * 0.2 + w * 0.4 - 8 - 6,
                      top: 86,
                      child: Transform.rotate(
                        angle: 0.7,
                        child: Container(width: 2, height: 26, color: Colors.black87),
                      ),
                    ),
                  // Pierna der
                  if (_hangWrongCount >= 6)
                    Positioned(
                      left: w * 0.2 + w * 0.4 - 8 + 4,
                      top: 86,
                      child: Transform.rotate(
                        angle: -0.7,
                        child: Container(width: 2, height: 26, color: Colors.black87),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            maskedWord(word),
            style: const TextStyle(fontSize: 28, letterSpacing: 2, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            ex.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.6,
          ),
          itemCount: letters.length,
          itemBuilder: (context, i) {
            final l = letters[i];
            final used = _hangUsed.contains(l);
            final inWord = (ex.answer as String).toUpperCase().contains(l);
            Color bg = Colors.white;
            Color br = Colors.grey[300]!;
            if (used) {
              bg = inWord ? Colors.green[50]! : Colors.red[50]!;
              br = inWord ? Colors.green : Colors.red;
            }
            return ElevatedButton(
              onPressed: used || _answered ? null : () => pickLetter(l),
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: Colors.black,
                side: BorderSide(color: br),
                padding: EdgeInsets.zero,
              ),
              child: Text(l, style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          },
        ),
        const SizedBox(height: 8),
        if (_answered && !_isCorrect)
          Center(
            child: Text('La palabra era: $word', style: const TextStyle(color: Colors.redAccent)),
          ),
      ],
    );
  }

  Widget _buildDragFill(GrammarExercise ex) {
    // Inicializar estado por ejercicio
    final blanks = RegExp(r'____').allMatches(ex.prompt).length;
    if (_fillExerciseIndex != _index) {
      _fillExerciseIndex = _index;
      _fillPlaced = List<String?>.filled(blanks, null);
      _fillWrong = <int>{};
    }

    List<InlineSpan> spans = [];
    final parts = ex.prompt.split('____');
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i], style: const TextStyle(fontSize: 16)));
      if (i < blanks) {
        final placed = _fillPlaced[i];
        final isWrong = _fillWrong.contains(i);
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: DragTarget<String>(
              builder: (context, c, r) {
                return Container(
                  constraints: const BoxConstraints(minWidth: 80, minHeight: 36),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: placed != null ? (isWrong ? Colors.red[50] : Colors.green[50]) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isWrong ? Colors.red : Colors.grey[400]!),
                  ),
                  child: placed == null
                      ? const Center(child: Text('____'))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(placed, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() => _fillPlaced[i] = null);
                              },
                              child: const Icon(Icons.close, size: 16),
                            ),
                          ],
                        ),
                );
              },
              onAccept: (val) {
                setState(() {
                  _fillPlaced[i] = val;
                  _fillWrong.remove(i);
                });
              },
            ),
          ),
        ));
      }
    }

    void check() {
      if (_answered) return;
      final correct = List<String>.from(ex.answer as List<String>);
      final current = _fillPlaced.map((e) => e ?? '').toList();
      final ok = listEquals(current, correct);
      setState(() {
        if (ok) {
          _isCorrect = true;
          _answered = true;
          _fillWrong.clear();
        } else {
          _isCorrect = false;
          _fillWrong.clear();
          for (int i = 0; i < blanks; i++) {
            if ((current[i]) != correct[i]) _fillWrong.add(i);
          }
          _attempts += 1; // solo baja vida si es incorrecto
          if (_attempts >= 2) {
            _answered = true;
          }
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RichText(text: TextSpan(style: const TextStyle(color: Colors.black87), children: spans)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ex.options.map((o) {
            final used = _fillPlaced.contains(o);
            return Draggable<String>(
              data: o,
              feedback: Material(
                color: Colors.transparent,
                child: Chip(label: Text(o), backgroundColor: Colors.blue[50]),
              ),
              childWhenDragging: Opacity(opacity: 0.4, child: Chip(label: Text(o))),
              child: Chip(
                label: Text(o),
                backgroundColor: used ? Colors.grey[200] : Colors.white,
                shape: StadiumBorder(side: BorderSide(color: Colors.grey[400]!)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.center,
          child: FilledButton.icon(
            onPressed: (_answered && !_isCorrect && _attempts >= 2) || _answered && _isCorrect ? null : check,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Comprobar'),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedback(GrammarExercise ex) {
    if (!_answered) {
      return const SizedBox.shrink();
    }

    String hintFor(GrammarExercise ex) {
      switch (ex.type) {
        case GrammarType.multipleChoice:
          return 'Revisa el tiempo verbal según el contexto (p. ej., adverbios como "yesterday", "right now", "tomorrow").';
        case GrammarType.trueFalse:
          return 'Verifica auxiliares y concordancia sujeto–verbo; cuida la forma negativa y preguntas.';
        case GrammarType.orderWords:
          return 'Sigue el orden Sujeto–Verbo–Complemento y la posición natural de adverbios.';
        case GrammarType.dragFill:
          return 'Fíjate en preposiciones de tiempo/lugar y la forma verbal correcta.';
        case GrammarType.balloonPop:
        case GrammarType.duckHunt:
          return 'Elige la forma verbal acorde al tiempo indicado por el contexto.';
        case GrammarType.memoryPairs:
            // RetroalimentaciÃ³n especÃ­fica segÃºn el contenido del memorama
            final answer = ex.answer as Map<String, String>;
            final firstKey = answer.keys.first;
            final firstValue = answer.values.first;
            
            // Detectar tipo de memorama por contenido
            if (firstKey == 'I' || firstKey == 'You' || firstKey == 'He' || firstKey == 'She') {
              return 'Empareja pronombres con sus formas correctas del verbo "to be".';
            } else if (firstValue.contains('Mexican') || firstValue.contains('Spanish') || firstValue.contains('Japanese')) {
              return 'Empareja paÃ­ses con sus gentilicios en inglÃ©s.';
            } else if (firstValue.contains('Rojo') || firstValue.contains('Azul') || firstValue.contains('Verde')) {
              return 'Empareja colores en inglÃ©s con sus traducciones al espaÃ±ol.';
            } else if (firstValue.contains('Perro') || firstValue.contains('Gato') || firstValue.contains('PÃ¡jaro')) {
              return 'Empareja animales en inglÃ©s con sus traducciones al espaÃ±ol.';
            } else if (firstValue.contains('Maestro') || firstValue.contains('Doctor') || firstValue.contains('Ingeniero')) {
              return 'Empareja profesiones en inglÃ©s con sus traducciones al espaÃ±ol.';
            } else if (firstValue.contains('Small') || firstValue.contains('Cold') || firstValue.contains('Slow')) {
              return 'Empareja palabras con sus antÃ³nimos en inglÃ©s.';
            } else if (firstValue.contains('Went') || firstValue.contains('Ate') || firstValue.contains('Saw')) {
              return 'Empareja verbos con sus formas en pasado simple.';
            } else if (firstValue.contains('Goes') || firstValue.contains('Studies') || firstValue.contains('Does')) {
              return 'Empareja verbos con sus formas en tercera persona del singular.';
            } else if (firstValue.contains('Surface') || firstValue.contains('Inside') || firstValue.contains('Point')) {
              return 'Empareja preposiciones con sus usos correctos.';
            }
            return 'Encuentra los pares correspondientes.';
        case GrammarType.hangman:
          return 'Usa la pista para deducir la palabra; revisa ortografía.';
        case GrammarType.typingShooter:
          return 'Escribe con precisión las letras mostradas.';
      }
    }

    final isTwoAttemptsWrong = !_isCorrect && _attempts >= 2;
    final Color bg = _isCorrect ? Colors.green[50]! : (isTwoAttemptsWrong ? Colors.red[50]! : Colors.orange[50]!);
    final Color br = _isCorrect ? Colors.green : (isTwoAttemptsWrong ? Colors.red : Colors.orange);
    final Color fg = _isCorrect ? Colors.green : (isTwoAttemptsWrong ? Colors.red : Colors.orange);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: br),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_isCorrect ? Icons.check_circle : Icons.info_outline, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¡Correcto!', style: TextStyle(fontWeight: FontWeight.bold)),
                if (!_isCorrect) ...[
                  // Si es incorrecto, sustituimos mensajes genéricos por orientación específica
                  const SizedBox(height: 2),
                  Text(hintFor(ex)),
                  if (isTwoAttemptsWrong)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        ex.type == GrammarType.orderWords
                            ? 'Respuesta: ${(ex.answer as List<String>).join(' ')}'
                            : ex.type == GrammarType.trueFalse
                                ? 'Respuesta: ${(ex.answer as bool) ? 'True' : 'False'}'
                                : 'Respuesta: ${ex.answer}',
                      ),
                    ),
                  if (ex.explanation != null && ex.explanation!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(ex.explanation!),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(GrammarExercise ex) {
    final enabledNext = _answered || (_attempts >= 2);
    
    // Para memorama: mostrar intentos sobre 4
    if (ex.type == GrammarType.memoryPairs) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _answered
                ? (_isCorrect ? '¡Bien hecho!' : 'La respuesta correcta se ha mostrado')
                : 'Intentos: $_attempts/$_memMaxLives',
            style: TextStyle(color: Colors.grey[700]),
          ),
          FilledButton.icon(
            onPressed: enabledNext ? _next : null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF66BB6A),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Siguiente'),
          ),
        ],
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _answered
              ? (_isCorrect ? '¡Bien hecho!' : 'La respuesta correcta se ha mostrado')
              : 'Intentos: $_attempts/2',
          style: TextStyle(color: Colors.grey[700]),
        ),
        FilledButton.icon(
          onPressed: enabledNext ? _next : null,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF66BB6A),
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Siguiente'),
        ),
      ],
    );
  }
}
