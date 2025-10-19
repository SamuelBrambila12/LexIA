import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/word_exercise.dart';
import '../services/speech_service.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/pronunciation_feedback.dart';

class PronunciationExerciseScreen extends StatefulWidget {
  const PronunciationExerciseScreen({super.key});

  @override
  State<PronunciationExerciseScreen> createState() => _PronunciationExerciseScreenState();
}

class _PronunciationExerciseScreenState extends State<PronunciationExerciseScreen> with SingleTickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  late WordExercise _currentWord;
  String _userRecording = '';
  bool _isRecording = false;
  bool _evaluated = false;
  double _evaluationScore = 0.0;
  String _evaluationFeedback = '';
  List<String> _issues = [];
  List<String> _tips = [];
  late AnimationController _recordingController;
  
  @override
  void initState() {
    super.initState();
    _currentWord = WordExercise.getRandomWord();
    _recordingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  void _showPermissionSettings() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permiso Requerido'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mic_off_rounded,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'El permiso del micrófono es necesario para esta función. Por favor, habilítalo en la configuración de la aplicación.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text('Abrir Configuración'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permiso de micrófono'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mic_rounded,
                size: 64,
                color: AppColors.primary,
              ),
              SizedBox(height: 16),
              Text(
                'Para poder evaluar tu pronunciación, necesitamos acceso al micrófono. Por favor, intenta nuevamente.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                final result = await Permission.microphone.request();
                if (!result.isGranted && mounted) {
                  _showPermissionSettings();
                }
              },
              child: const Text('Reintentar'),
            ),
          ],
        );
      },
    );
  }

  void _nextWord() {
    setState(() {
      _recordingController.stop();
      _speechService.cancelListening();

      // Elegir palabra distinta
      final current = _currentWord.word;
      final candidates = WordExercise.exercises.where((w) => w.word != current).toList();
      if (candidates.isNotEmpty) {
        candidates.shuffle();
        _currentWord = candidates.first;
      } else {
        _currentWord = WordExercise.getRandomWord();
      }

      // Reset estado
      _userRecording = '';
      _isRecording = false;
      _evaluated = false;
      _evaluationScore = 0.0;
      _evaluationFeedback = '';
      _issues = [];
      _tips = [];
    });
  }

  Future<void> _toggleRecording() async {
    final result = await Permission.microphone.request();

    if (result.isGranted) {
      if (!_isRecording) {
        // Iniciar grabación
        setState(() {
          _isRecording = true;
          _evaluated = false;
          _userRecording = '';
          _evaluationScore = 0.0;
          _evaluationFeedback = '';
          _issues = [];
          _tips = [];
        });

        _recordingController.repeat(reverse: true);

        final bool started = await _speechService.startListening((text) {
          setState(() {
            _userRecording = text;
          });
        });

        if (!started) {
          _recordingController.stop();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo iniciar la grabación. Por favor, intenta nuevamente.'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isRecording = false;
            });
          }
          return;
        }
      } else {
        // Detener grabación INMEDIATA y mostrar loader de evaluación
        _recordingController.stop();
        setState(() {
          _isRecording = false; // detener visualmente de inmediato
          _evaluated = false;
          _evaluationFeedback = 'Evaluando pronunciación...';
          _issues = [];
          _tips = [];
        });

        final result = await _speechService.stopListening();
        String recognizedText = (result['text'] ?? '').toString();
        // Si el motor no alcanzó a producir texto final, usar la última parcial
        if (recognizedText.trim().isEmpty && _userRecording.trim().isNotEmpty) {
          recognizedText = _userRecording;
        }

        if (recognizedText.trim().isEmpty) {
          if (mounted) {
            setState(() {
              _evaluated = true;
              _evaluationScore = 0.0;
              _evaluationFeedback = 'No se reconoció tu pronunciación. Intenta hablar más claro o acércate al micrófono.';
              _issues = [];
              _tips = [];
            });
          }
          return;
        }

        try {
          final eval = await ApiService.evaluatePronunciation(
            _currentWord.word,
            recognizedText,
          );

          if (mounted) {
            if (eval['success'] == true) {
              setState(() {
                _evaluationScore = (eval['scorePercent'] as num?)?.toDouble() ?? 0.0;
                _evaluationFeedback = (eval['general'] ?? '').toString();
                _issues = List<String>.from(eval['issues'] ?? const <String>[]);
                _tips = List<String>.from(eval['tips'] ?? const <String>[]);
                _evaluated = true;
              });
            } else {
              setState(() {
                _evaluated = true;
                _evaluationScore = 0.0;
                _evaluationFeedback = (eval['error'] ?? 'Error en la evaluación').toString();
              });
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _evaluated = true;
              _evaluationScore = 0.0;
              _evaluationFeedback = 'Error al evaluar la pronunciación: $e';
            });
          }
        }
      }

      if (!mounted) return;
    } else if (result.isDenied) {
      if (mounted) {
        _showPermissionDialog();
      }
    } else if (result.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios de Pronunciación'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F5F5)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.defaultPadding),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta principal con la palabra
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _currentWord.word,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _currentWord.phonetics.first,
                              style: GoogleFonts.notoSans(
                                textStyle: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Botones de control
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón de audio
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () => _speechService.speak(_currentWord.word),
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Icon(
                                Icons.volume_up_rounded,
                                size: 32,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Botón de micrófono
                      Container(
                        decoration: BoxDecoration(
                          color: _isRecording ? Colors.red : AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording ? Colors.red : AppColors.primary).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _toggleRecording,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Icon(
                                _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Nota de ayuda para evitar errores
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Para evitar errores de evaluación, al terminar de pronunciar la palabra, espere 1 segundo adicional antes de detener la grabación',
                              style: TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Área de retroalimentación (aparece tras evaluación o mientras evalúa)
                  if (!_evaluated && _evaluationFeedback.isEmpty) ...[
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Example',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentWord.example.isNotEmpty ? _currentWord.example : 'Try saying: ' + _currentWord.word,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (!_evaluated && !_isRecording && _evaluationFeedback.isNotEmpty) ...[
                  // Loader mientras evalúa
                  Center(
                  child: Column(
                  children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                  _evaluationFeedback,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  ],
                  ),
                  ),
                  ] else if (_evaluated) ...[
                  PronunciationFeedback(
                  score: _evaluationScore,
                  feedback: _evaluationFeedback,
                  issues: _issues,
                  tips: _tips,
                  ),
                  const SizedBox(height: 24),
                  Align(
                  alignment: Alignment.center,
                  child: FilledButton.icon(
                  onPressed: _nextWord,
                  style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                  ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text(
                  'Siguiente Palabra',
                  style: TextStyle(fontSize: 16),
                  ),
                  ),
                  ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}