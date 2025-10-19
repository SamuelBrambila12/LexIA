import 'package:flutter_tts/flutter_tts.dart';

class TtsHelper {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;

  static Future<void> _init() async {
    if (_initialized) return;
    // Configuración básica
    await _tts.setLanguage('en-US');
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  static Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _init();
    await _tts.setSpeechRate(0.45);
    await _tts.stop();
    await _tts.speak(text);
  }

  static Future<void> speakSlow(String text) async {
    if (text.trim().isEmpty) return;
    await _init();
    await _tts.setSpeechRate(0.12);
    await _tts.stop();
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
  }
}