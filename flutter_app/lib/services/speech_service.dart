import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'permissions_service.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final FlutterTts flutterTts = FlutterTts();
  final SpeechToText speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  double _confidence = 0.0;
  Timer? _autoStopTimer;
  String? _localeId;
  String _lastNonEmpty = '';

  Future<bool> initSpeech() async {
    try {
      _speechEnabled = await speechToText.initialize(
        onError: (error) => print('Error de inicialización: $error'),
        debugLogging: true,
      );

      if (_speechEnabled) {
        try {
          final locales = await speechToText.locales();
          final systemLocale = await speechToText.systemLocale();

          // Selección robusta de inglés: en_US / en-US, luego cualquier en-*, y por último fallback
          LocaleName? selected;
          for (final l in locales) {
            final id = l.localeId.toLowerCase();
            if (id == 'en_us' || id == 'en-us') {
              selected = l;
              break;
            }
          }
          if (selected == null) {
            for (final l in locales) {
              final id = l.localeId.toLowerCase();
              if (id.startsWith('en')) {
                selected = l;
                break;
              }
            }
          }

          final LocaleName fallback = systemLocale ?? (locales.isNotEmpty ? locales.first : LocaleName('en_US', 'English (US)'));
          final LocaleName chosen = selected ?? fallback;
          _localeId = chosen.localeId;
          print('SpeechService: Locale seleccionado -> ' + (_localeId ?? 'default'));
        } catch (e) {
          print('SpeechService: No se pudo obtener locales, usando default. Error: $e');
          _localeId = null;
        }
      }

      return _speechEnabled;
    } catch (e) {
      _speechEnabled = false;
      return false;
    }
  }

  Future<void> speak(String text) async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.speak(text);
    } catch (e) {
      print('Error al reproducir audio: $e');
    }
  }

  Future<bool> startListening(Function(String) onResult, {Function(double)? onLevel}) async {
    if (!_speechEnabled) {
      final initialized = await initSpeech();
      if (!initialized) {
        return false;
      }
    }

    // Verificar/solicitar micrófono una sola vez
    final micOk = await PermissionsService.checkAndRequestMicrophoneOnce();
    if (!micOk) {
      return false;
    }

    try {
      _lastWords = '';
      _lastNonEmpty = '';
      _confidence = 0.0;

      await speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          _lastWords = result.recognizedWords;
          if (_lastWords.trim().isNotEmpty) {
            _lastNonEmpty = _lastWords;
          }
          _confidence = result.confidence;
          onResult(_lastWords);
          print('SpeechService onResult -> "' + _lastWords + '" (conf: ' + _confidence.toStringAsFixed(2) + ')');
        },
        onSoundLevelChange: (level) {
          if (onLevel != null) onLevel(level);
        },
        localeId: _localeId, // usa en_US si disponible, si no el del sistema
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
        listenFor: const Duration(seconds: 12),
        pauseFor: const Duration(seconds: 3),
        onDevice: false,
      );
      return true;
    } catch (e) {
      print('Error al iniciar la grabación: $e');
      // Fallback: intentar sin forzar locale ni reconocimiento en dispositivo
      try {
        await speechToText.listen(
          onResult: (SpeechRecognitionResult result) {
            _lastWords = result.recognizedWords;
            if (_lastWords.trim().isNotEmpty) {
              _lastNonEmpty = _lastWords;
            }
            _confidence = result.confidence;
            onResult(_lastWords);
            print('SpeechService onResult (fallback) -> "' + _lastWords + '" (conf: ' + _confidence.toStringAsFixed(2) + ')');
          },
          onSoundLevelChange: (level) {
            if (onLevel != null) onLevel(level);
          },
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
          listenFor: const Duration(seconds: 12),
          pauseFor: const Duration(seconds: 3),
          onDevice: false,
        );
        return true;
      } catch (e2) {
        print('Fallback listen también falló: $e2');
        return false;
      }
    }
  }

  Future<Map<String, dynamic>> stopListening() async {
    _autoStopTimer?.cancel();
    await speechToText.stop();
    // Espera breve a que llegue el resultado final si aún no llegó
    for (int i = 0; i < 10; i++) {
      if (_lastWords.trim().isNotEmpty || _lastNonEmpty.trim().isNotEmpty) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    final String finalText = _lastWords.trim().isNotEmpty ? _lastWords : _lastNonEmpty;
    final confidence = _confidence;
    return {
      'text': finalText,
      'confidence': confidence,
      'timestamp': DateTime.now().toIso8601String(),
      'language': 'en-US',
    };
  }

  bool get isListening => speechToText.isListening;

  Future<void> cancelListening() async {
    _autoStopTimer?.cancel();
    await speechToText.cancel();
    _lastWords = '';
    _confidence = 0.0;
  }
}