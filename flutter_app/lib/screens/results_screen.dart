// lib/screens/results_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/prediction_model.dart';
import '../widgets/prediction_card.dart';
import '../utils/constants.dart';
import '../utils/tts_helper.dart';
import '../services/api_service.dart';

class ResultsScreen extends StatefulWidget {
  final ApiResponse response;
  final String? imagePath;

  const ResultsScreen({
    super.key,
    required this.response,
    this.imagePath,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  // Estado para la confirmación
  List<_ParsedPrediction> _sortedPredictions = <_ParsedPrediction>[];
  _ParsedPrediction? _confirmedPrediction;
  bool _asked = false; // Para no disparar múltiples diálogos

  // Traducciones EN -> ES para mostrar en la confirmación
  static const Map<String, String> _esTranslations = {
    'person': 'persona',
    'bicycle': 'bicicleta',
    'car': 'coche',
    'motorcycle': 'motocicleta',
    'airplane': 'avión',
    'bus': 'autobús',
    'train': 'tren',
    'truck': 'camión',
    'boat': 'barco',
    'traffic light': 'semáforo',
    'fire hydrant': 'hidrante',
    'stop sign': 'señal de alto',
    'parking meter': 'parquímetro',
    'bench': 'banca',
    'bird': 'pájaro',
    'cat': 'gato',
    'dog': 'perro',
    'horse': 'caballo',
    'sheep': 'oveja',
    'cow': 'vaca',
    'elephant': 'elefante',
    'bear': 'oso',
    'zebra': 'cebra',
    'giraffe': 'jirafa',
    'backpack': 'mochila',
    'umbrella': 'paraguas',
    'handbag': 'bolso',
    'tie': 'corbata',
    'suitcase': 'maleta',
    'frisbee': 'frisbee',
    'skis': 'esquíes',
    'snowboard': 'tabla de snowboard',
    'sports ball': 'balón',
    'kite': 'cometa',
    'baseball bat': 'bate de béisbol',
    'baseball glove': 'guante de béisbol',
    'skateboard': 'patineta',
    'surfboard': 'tabla de surf',
    'tennis racket': 'raqueta de tenis',
    'bottle': 'botella',
    'wine glass': 'copa de vino',
    'cup': 'taza',
    'fork': 'tenedor',
    'knife': 'cuchillo',
    'spoon': 'cuchara',
    'bowl': 'tazón',
    'banana': 'banana',
    'apple': 'manzana',
    'sandwich': 'sándwich',
    'orange': 'naranja',
    'broccoli': 'brócoli',
    'carrot': 'zanahoria',
    'hot dog': 'perro caliente',
    'pizza': 'pizza',
    'donut': 'dónut',
    'cake': 'pastel',
    'chair': 'silla',
    'couch': 'sofá',
    'sofa': 'sofá',
    'potted plant': 'planta en maceta',
    'bed': 'cama',
    'dining table': 'mesa de comedor',
    'toilet': 'inodoro',
    'tv': 'televisor',
    'tv monitor': 'monitor',
    'laptop': 'computadora portátil',
    'mouse': 'ratón',
    'remote': 'control remoto',
    'keyboard': 'teclado',
    'cell phone': 'teléfono celular',
    'mobile phone': 'teléfono móvil',
    'microwave': 'microondas',
    'oven': 'horno',
    'toaster': 'tostadora',
    'sink': 'fregadero',
    'refrigerator': 'refrigerador',
    'book': 'libro',
    'clock': 'reloj',
    'vase': 'jarrón',
    'scissors': 'tijeras',
    'teddy bear': 'oso de peluche',
    'hair drier': 'secador de cabello',
    'toothbrush': 'cepillo de dientes',
    'bottle cap': 'tapa de botella',
    'whistle': 'silbato',
  };

  
  
  
  String _normalizeKey(String s) => s.trim().toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ');

  String _toSpanishName(String english) {
    final key = _normalizeKey(english);
    if (_esTranslations.containsKey(key)) return _esTranslations[key]!;
    // Intenta coincidencia suelta quitando espacios duplicados
    final keyComp = key.replaceAll(RegExp(r"\s+"), ' ');
    if (_esTranslations.containsKey(keyComp)) return _esTranslations[keyComp]!;
    // Fallback: devolver key tal cual (puede estar en inglés si no está mapeado)
    return keyComp;
  }

  // Eliminado: colores por confianza ya no se usan visualmente
  Color _confidenceColor(double confidence) {
    return AppColors.info;
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) {
      return double.tryParse(v.replaceAll('%', '')) ?? 0.0;
    }
    return 0.0;
  }

  // -----------------------
  // Helper para normalizar una predicción
  // -----------------------
  _ParsedPrediction _parsePrediction(dynamic p, int fallbackIndex) {
    String className = 'Desconocido';
    int classId = fallbackIndex;
    double confidence = 0.0;

    if (p == null) {
      return _ParsedPrediction(className, classId, confidence);
    }

    // Si es Map -> leer por claves
    if (p is Map) {
      className = (p['className'] ?? p['label'] ?? p['name'] ?? 'Desconocido').toString();
      classId = int.tryParse((p['classId'] ?? p['id'] ?? fallbackIndex).toString()) ?? fallbackIndex;
      confidence = _toDouble(p['confidence'] ?? p['confidencePercent'] ?? p['score'] ?? 0);
      return _ParsedPrediction(className, classId, confidence);
    }

    // Si es un objeto (TopPrediction, Prediction, etc.) lo tratamos como dynamic y probamos varios nombres de campo
    final dyn = p as dynamic;
    try {
      className = (dyn.className ?? dyn.label ?? dyn.name ?? 'Desconocido').toString();
    } catch (_) {
      // seguir con default si falla
    }
    try {
      classId = int.tryParse((dyn.classId ?? dyn.id ?? fallbackIndex).toString()) ?? fallbackIndex;
    } catch (_) {
      classId = fallbackIndex;
    }
    try {
      confidence = _toDouble(dyn.confidence ?? dyn.confidencePercent ?? dyn.score ?? 0);
    } catch (_) {
      confidence = 0.0;
    }

    return _ParsedPrediction(className, classId, confidence);
  }

  List<String> _complexExamples(String w) {
    final word = (w.trim().isEmpty ? 'object' : w.trim()).toLowerCase();
    final art = _indefiniteArticle(word);

    final templates = <String>[
      'After ' + art + ' ' + word + ' was positioned near the center of the frame, it subtly anchored the entire composition.',
      'Because ' + art + ' ' + word + ' had been meticulously maintained, it performed reliably even under demanding circumstances.',
      'Although some regarded ' + art + ' ' + word + ' as ordinary, its nuanced details suggested a far more deliberate design.',
      'If ' + art + ' ' + word + ' were removed from the scene, the narrative conveyed by the image would shift in a meaningful way.',
      'The ' + word + ', which had initially gone unnoticed, eventually guided our interpretation of the surrounding context.',
      'By placing ' + art + ' ' + word + ' closer to the primary light source, the photographer emphasized its texture and contour.',
      'Whenever ' + art + ' ' + word + ' appears in technical documentation, it is often associated with consistency, safety, and repeatability.',
      'Given that ' + art + ' ' + word + ' is central to the task at hand, overlooking it would introduce unnecessary complexity.',
      'Since ' + art + ' ' + word + ' occupies a space between form and function, it frequently becomes the subject of closer scrutiny.',
      'If one were to compare ' + art + ' ' + word + ' with its predecessors, subtle but consequential improvements would quickly emerge.',
      'Placed adjacent to complementary elements, the ' + word + ' helps establish rhythm, balance, and visual coherence throughout the scene.',
      'Because the narrative hinges on the ' + word + ', the viewer’s attention is naturally drawn toward its edges, textures, and proportions.',
    ];

    // Devolver 6 ejemplos distintos y relacionados
    return templates.take(6).toList();
  }

  String _indefiniteArticle(String w) {
    if (w.isEmpty) return 'a';
    final lc = w.toLowerCase();
    // Excepciones comunes donde suena con vocal inicial
    const exceptionsAn = ['honest', 'hour', 'honor', 'heir', 'herb']; // en-US: herb
    for (final e in exceptionsAn) {
      if (lc.startsWith(e)) return 'an';
    }
    // Casos que empiezan con vocal pero suenan como consonante (e.g., "university", "european")
    if (lc.startsWith('uni') || lc.startsWith('use') || lc.startsWith('user') || lc.startsWith('euro') || lc.startsWith('one')) {
      return 'a';
    }
    const vowels = ['a', 'e', 'i', 'o', 'u'];
    return vowels.contains(lc[0]) ? 'an' : 'a';
  }

  @override
  void initState() {
    super.initState();
    _preparePredictions();
    // Lanzar el flujo de confirmación después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_asked) {
        _asked = true;
        _startConfirmationFlow(context);
      }
    });
  }

  void _preparePredictions() {
    final resp = widget.response;

    // Verificar que predictions sea una lista válida
    final List<dynamic> predictionsList = (() {
      final p = resp.predictions;
      if (p == null) return <dynamic>[];
      if (p is List) return List<dynamic>.from(p);
      return <dynamic>[p];
    })();

    final parsed = <_ParsedPrediction>[];
    if (predictionsList.isNotEmpty) {
      for (int i = 0; i < predictionsList.length; i++) {
        parsed.add(_parsePrediction(predictionsList[i], i));
      }
    } else if (resp.topPrediction != null) {
      // Fallback: usar topPrediction si no hay lista
      final top = resp.topPrediction!;
      parsed.add(_parsePrediction(top, 0));
    }

    // Ordenar por mayor confianza (asumimos "confidence" ya viene en porcentaje)
    parsed.sort((a, b) => b.confidence.compareTo(a.confidence));

    setState(() {
      _sortedPredictions = parsed;
    });
  }

  Future<void> _startConfirmationFlow(BuildContext context) async {
    if (_sortedPredictions.isEmpty) {
      // No hay nada que confirmar
      return;
    }

    // Moderación deshabilitada: no bloquear por contenido

    int idx = 0;
    while (idx < _sortedPredictions.length && mounted) {
      final cand = _sortedPredictions[idx];
      final accepted = await _askConfirmation(context, cand);
      if (!mounted) return;
      if (accepted == true) {
        setState(() {
          _confirmedPrediction = cand;
        });
        return;
      }
      idx += 1;
    }

    // Si el usuario dijo "No" a todas, seleccionar la de mayor confianza por defecto
    if (mounted && _sortedPredictions.isNotEmpty) {
      final fallback = _sortedPredictions.first;
      setState(() {
        _confirmedPrediction = fallback;
      });
    }
  }

  Future<bool?> _askConfirmation(BuildContext context, _ParsedPrediction cand) async {
    // Traducir dinámicamente con fallback al mapa local
    String spanish = _toTitleCase(_toSpanishName(cand.className));
    try {
      final t = await ApiService.translateToSpanish(cand.className);
      if (t.trim().isNotEmpty) spanish = _toTitleCase(t.trim());
    } catch (_) {}

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: AppDimensions.dialogElevation,
          child: TweenAnimationBuilder<double>(
            duration: AppAnimations.mediumDuration,
            curve: AppAnimations.fastOutSlowIn,
            tween: Tween(begin: 0.92, end: 1.0),
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con gradiente
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.secondaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(10),
                        child: const Icon(Icons.search_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Confirmación de detección',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cuerpo
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Se detectó:',
                        style: TextStyle(fontSize: 16, color: AppColors.textSecondary.withOpacity(0.9)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        spanish,
                        textAlign: TextAlign.start,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '¿Es correcto?',
                        style: TextStyle(fontSize: 16, color: AppColors.textSecondary.withOpacity(0.9)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              icon: const Icon(Icons.close_rounded),
                              label: const Text('No'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.errorDark,
                                side: const BorderSide(color: AppColors.errorDark, width: 1.4),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              icon: const Icon(Icons.check_circle_rounded),
                              label: const Text('Sí'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.successDark,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _toTitleCase(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + (s.length > 1 ? s.substring(1) : '');
  }

  @override
  Widget build(BuildContext context) {
    final resp = widget.response;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados del Análisis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareResults(context),
            tooltip: 'Compartir resultados',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen analizada (si está disponible)
            if (widget.imagePath != null && widget.imagePath!.isNotEmpty) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Imagen Analizada:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(widget.imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[100],
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text('No se pudo cargar la imagen'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.defaultPadding),
            ],

            // Estado general (mensaje)
            Card(
              elevation: 2,
              color: resp.success ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          resp.success ? Icons.check_circle : Icons.error,
                          color: resp.success ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            resp.success ? AppStrings.analysisComplete : AppStrings.errorInPrediction,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: resp.success ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (resp.error != null && resp.error!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        resp.error!,
                        style: TextStyle(color: AppColors.error),
                      ),
                    ],
                    if (resp.info != null && resp.info!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(resp.info!),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.defaultPadding),

            // Sección de confirmación pendiente o contenido confirmado
            if (_confirmedPrediction == null) ...[
              Card(
                elevation: AppDimensions.cardElevation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Confirmación pendiente',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Se te preguntará para confirmar lo detectado. Si no es correcto, se probará con la siguiente opción.',
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              // Palabra grande centrada + icono de bocina + ejemplos complejos
              Builder(builder: (_) {
                final sel = _confirmedPrediction!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              (_toTitleCase(sel.className)),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.volume_up_rounded),
                              color: AppColors.primary,
                              tooltip: 'Pronunciar',
                              onPressed: () => TtsHelper.speak(sel.className),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Text('🐢', style: TextStyle(fontSize: 18)),
                              color: AppColors.primary,
                              tooltip: 'Pronunciar lento',
                              onPressed: () => TtsHelper.speakSlow(sel.className),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: AppDimensions.cardElevation,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Examples',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<List<String>>(
                              future: ApiService.getExamples(sel.className, count: 6),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState != ConnectionState.done) {
                                  return const Center(child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  ));
                                }
                                if (snapshot.hasError) {
                                  return const Text('Error generando ejemplos', style: TextStyle(color: Colors.red));
                                }
                                final items = snapshot.data ?? const <String>[];
                                if (items.isEmpty) {
                                  return const Text('No examples available');
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: items.map((e) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Text('• ' + e),
                                  )).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],

            const SizedBox(height: AppDimensions.largePadding),

            // Botón para nueva predicción
            if (resp.success)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Hacer nuevo análisis'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _shareResults(BuildContext context) {
    try {
      String shareText = 'Vision AI - Resultados del análisis:\n\n';

      // Obtener predicciones para compartir (usar el mismo parser para robustez)
      if (widget.response.predictions != null && widget.response.predictions is List) {
        final predictions = widget.response.predictions as List;
        if (predictions.isNotEmpty) {
          for (int i = 0; i < predictions.length; i++) {
            final p = predictions[i];
            final parsed = _parsePrediction(p, i);
            shareText += '${i + 1}. ${parsed.className}: ${parsed.confidence.toStringAsFixed(1)}%\n';
          }
        }
      } else if (widget.response.topPrediction != null) {
        final top = widget.response.topPrediction!;
        final parsed = _parsePrediction(top, 0);
        shareText += 'Predicción principal: ${parsed.className} (${parsed.confidence.toStringAsFixed(1)}%)';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resultados listos para compartir'),
          duration: Duration(seconds: 3),
        ),
      );

      // Para compartir realmente, descomenta la siguiente línea e instala share_plus
      // Share.share(shareText);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al preparar resultados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Clase privada para retorno del parser
class _ParsedPrediction {
  final String className;
  final int classId;
  final double confidence;

  _ParsedPrediction(this.className, this.classId, this.confidence);
}
