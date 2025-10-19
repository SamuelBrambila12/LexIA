import 'dart:async';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationHelper {
  static final _instance = TranslationHelper._internal();
  factory TranslationHelper() => _instance;
  TranslationHelper._internal();

  OnDeviceTranslator? _translator;
  bool _modelReady = false;
  bool _isDownloading = false;

  Future<void> _ensureModel() async {
    if (_modelReady) return;
    if (_isDownloading) {
      // Esperar a descarga concurrente
      while (_isDownloading) {
        await Future.delayed(const Duration(milliseconds: 150));
      }
      return;
    }
    _isDownloading = true;
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      // Verificar si ya está descargado
      final enEsDownloaded = await modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode) &&
          await modelManager.isModelDownloaded(TranslateLanguage.spanish.bcpCode);

      if (!enEsDownloaded) {
        // Descargar EN y ES
        await modelManager.downloadModel(TranslateLanguage.english.bcpCode);
        await modelManager.downloadModel(TranslateLanguage.spanish.bcpCode);
      }

      _translator ??= OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: TranslateLanguage.spanish,
      );
      _modelReady = true;
    } finally {
      _isDownloading = false;
    }
  }

  Future<String> translateToSpanish(String text) async {
    final s = text.trim();
    if (s.isEmpty) return s;
    await _ensureModel();
    try {
      final translated = await _translator!.translateText(s);
      return translated.trim().isEmpty ? s : translated.trim();
    } catch (_) {
      return s; // fallback
    }
  }

  Future<void> dispose() async {
    await _translator?.close();
    _translator = null;
    _modelReady = false;
  }
}
