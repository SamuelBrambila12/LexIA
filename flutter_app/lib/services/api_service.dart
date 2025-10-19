import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction_model.dart';
import '../utils/constants.dart';
import '../utils/translation_helper.dart';

class ApiService {
  // IP configurada para tu red
  //static const String _baseUrl = 'http://192.168.100.31:8000'; // ✅ IP actualizada
  // static const String _baseUrl = 'https://fastapi-production-0a51.up.railway.app:8080';
  static const String _baseUrl = 'https://fastapi-production-e7bf.up.railway.app';
  static const Duration _timeout = Duration(seconds: 30);
  static const Duration _shortTimeout = Duration(seconds: 10);
  
  // URL personalizada para testing
  static String _customBaseUrl = '';
  
  // Headers comunes
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Getter para obtener la URL actual (usa custom si está definida)
  static String get currentBaseUrl {
    final base = _customBaseUrl.isEmpty ? _baseUrl : _customBaseUrl;
    return base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  }

  /// Configura una URL base personalizada
  static void setCustomBaseUrl(String url) {
    String u = url.trim();
    if (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    if (isValidUrl(u)) {
      _customBaseUrl = u;
      print('🔧 URL personalizada configurada: $u');
    } else {
      print('❌ URL inválida: $url');
    }
  }
  
  /// Resetea a la URL base por defecto
  static void resetBaseUrl() {
    _customBaseUrl = '';
    print('🔄 URL reseteada a: $_baseUrl');
  }

  /// Test de conectividad básica
  static Future<bool> testConnection() async {
    try {
      print('🔍 Probando conexión a: $currentBaseUrl');
      
      final response = await http
          .get(Uri.parse(currentBaseUrl))
          .timeout(const Duration(seconds: 10));
          
      print('📡 Respuesta: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error de conexión: $e');
      return false;
    }
  }

  /// Verifica el estado de salud de la API con logs detallados
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final url = '$currentBaseUrl/health';
      print('🏥 Verificando salud en: $url');
      
      final response = await http
          .get(
            Uri.parse(url),
            headers: _jsonHeaders,
          )
          .timeout(_timeout);

      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = {
          'isHealthy': data['status'] == 'healthy',
          'modelLoaded': data['model_loaded'] ?? false,
          'modelType': data['model_type'] ?? 'Unknown',
          'tensorflowVersion': data['tensorflow_version'] ?? 'Unknown',
          'inputSize': data['input_size']?.toString() ?? 'Unknown',
        };
        print('✅ API saludable: $result');
        return result;
      } else {
        final error = {
          'isHealthy': false,
          'error': 'Server returned ${response.statusCode}',
        };
        print('⚠️ API no saludable: $error');
        return error;
      }
    } on SocketException catch (e) {
      final error = {
        'isHealthy': false,
        'error': 'No se puede conectar al servidor: ${e.message}',
      };
      print('🔌 Error de conexión: $error');
      return error;
    } on http.ClientException catch (e) {
      final error = {
        'isHealthy': false,
        'error': 'Error del cliente HTTP: ${e.message}',
      };
      print('🚫 Error del cliente: $error');
      return error;
    } on Exception catch (e) {
      final error = {
        'isHealthy': false,
        'error': 'Error inesperado: $e',
      };
      print('💥 Error inesperado: $error');
      return error;
    }
  }

  /// Predice el contenido de una imagen con logs detallados
  static Future<ApiResponse> predictImage(File imageFile) async {
    try {
      print('🖼️ Iniciando predicción de imagen...');
      print('📁 Archivo: ${imageFile.path}');
      print('📋 Extensión: ${imageFile.path.split('.').last}');
      
      // Verificar que el archivo existe
      if (!await imageFile.exists()) {
        print('❌ El archivo no existe: ${imageFile.path}');
        return ApiResponse.error('El archivo de imagen no existe');
      }

      // Verificar tamaño del archivo (máximo 10MB)
      final fileSize = await imageFile.length();
      print('📏 Tamaño del archivo: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      
      if (fileSize > 10 * 1024 * 1024) {
        print('📦 Archivo muy grande: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB');
        return ApiResponse.error('El archivo es muy grande (máximo 10MB)');
      }

      final url = '$currentBaseUrl/predict';
      print('🚀 Enviando a: $url');
      
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Agregar el archivo
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      // Agregar headers
      request.headers.addAll({
        'Accept': 'application/json',
      });

      print('📤 Enviando imagen: ${imageFile.path}');
      
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Respuesta del servidor: ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Predicción exitosa');
        return ApiResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        final errorMsg = 'Error de validación: ${errorData['detail'] ?? 'Datos inválidos'}';
        print('⚠️ $errorMsg');
        return ApiResponse.error(errorMsg);
      } else if (response.statusCode == 500) {
        final errorData = json.decode(response.body);
        final errorMsg = 'Error del servidor: ${errorData['detail'] ?? 'Error interno'}';
        print('🔥 $errorMsg');
        return ApiResponse.error(errorMsg);
      } else {
        final errorMsg = 'Error HTTP ${response.statusCode}: ${response.reasonPhrase}';
        print('❌ $errorMsg');
        return ApiResponse.error(errorMsg);
      }
    } on SocketException catch (e) {
      final errorMsg = 'Sin conexión al servidor: ${e.message}';
      print('🔌 $errorMsg');
      return ApiResponse.error(errorMsg);
    } on http.ClientException catch (e) {
      final errorMsg = 'Error de conexión: ${e.message}';
      print('🚫 $errorMsg');
      return ApiResponse.error(errorMsg);
    } on Exception catch (e) {
      final errorMsg = 'Error inesperado: $e';
      print('💥 $errorMsg');
      return ApiResponse.error(errorMsg);
    }
  }
  
  /// Traduce texto de inglés a español en el dispositivo (ML Kit). Si falla, devuelve el texto original.
  static Future<String> translateToSpanish(String text) async {
    final t = (text).toString().trim();
    if (t.isEmpty) return t;
    try {
      return await TranslationHelper().translateToSpanish(t);
    } catch (_) {
      return t;
    }
  }
  
  /// Obtiene ejemplos contextuales de la API local
  static Future<List<String>> getExamples(String word, {int count = 6}) async {
    final url = '$currentBaseUrl/examples';
    final body = json.encode({'word': word, 'count': count});
    final response = await http
        .post(Uri.parse(url), headers: _jsonHeaders, body: body)
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final ex = (data['examples'] as List).map((e) => e.toString()).toList();
      return ex;
    } else {
      throw Exception('Error obteniendo ejemplos: ${response.statusCode}');
    }
  }

  /// Predice múltiples imágenes en batch
  static Future<BatchResponse> predictBatch(List<File> imageFiles) async {
    try {
      if (imageFiles.isEmpty) {
        throw Exception('No se proporcionaron archivos');
      }

      if (imageFiles.length > 10) {
        throw Exception('Máximo 10 imágenes por batch');
      }

      print('📦 Iniciando batch de ${imageFiles.length} imágenes');

      // Verificar que todos los archivos existen
      for (final file in imageFiles) {
        if (!await file.exists()) {
          throw Exception('El archivo ${file.path} no existe');
        }
      }

      final url = '$currentBaseUrl/predict/batch';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Agregar todos los archivos
      for (final imageFile in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            imageFile.path,
          ),
        );
      }

      request.headers.addAll({
        'Accept': 'application/json',
      });

      print('🚀 Enviando batch a: $url');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60), // Timeout más largo para batch
      );
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Respuesta batch: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Batch exitoso');
        return BatchResponse.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Error del servidor: ${errorData['detail'] ?? response.reasonPhrase}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('Sin conexión al servidor: ${e.message}');
    } on http.ClientException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Timeout: El servidor tardó demasiado en responder');
      }
      rethrow;
    }
  }

  /// Obtiene información básica de la API
  static Future<Map<String, dynamic>> getApiInfo() async {
    try {
      final response = await http
          .get(
            Uri.parse(currentBaseUrl),
            headers: _jsonHeaders,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error obteniendo información de la API: $e');
    }
  }

  /// Valida si una URL es válida
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Método de debug para probar diferentes IPs
  static Future<String?> findWorkingIP() async {
    final baseIPs = [
      '192.168.1.',
      '192.168.0.',
      '10.0.2.', // Para emulador Android
      '172.20.10.', // Para hotspot iOS
    ];

    print('🔍 Buscando IP que funcione...');

    for (final baseIP in baseIPs) {
      for (int i = 1; i <= 255; i++) {
        final testIP = '$baseIP$i:8000';
        try {
          final response = await http
              .get(Uri.parse('http://$testIP'))
              .timeout(const Duration(seconds: 2));
          
          if (response.statusCode == 200) {
            print('✅ IP encontrada: $testIP');
            return testIP;
          }
        } catch (e) {
          // Continuar con la siguiente IP
        }
      }
    }
    
    print('❌ No se encontró ninguna IP que funcione');
    return null;
  }

  static Future<Map<String, dynamic>> evaluatePronunciation(String target, String recognized) async {
    final url = '$currentBaseUrl/pronunciation/evaluate';
    try {
      final body = json.encode({'target': target, 'recognized': recognized});
      final response = await http
          .post(Uri.parse(url), headers: _jsonHeaders, body: body)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final double rawScore = (data['score'] is num) ? (data['score'] as num).toDouble() : 0.0;
        final double scorePercent = (rawScore * 100).clamp(0, 100);

        final List<dynamic> fbList = (data['feedback'] as List?) ?? [];

        String _posLabel(int idx, int total) {
          if (idx <= 0) return 'al inicio';
          if (idx >= total - 1) return 'al final';
          return 'en la posición ${idx + 1}';
        }

        String _mapPhone(String? p) {
          final s = (p ?? '').toUpperCase().trim();
          if (s.isEmpty || s == '∅') return '';
          const map = {
            'AA': 'a', 'AE': 'a corta', 'AH': 'a suave', 'AO': 'o abierta',
            'AW': 'au', 'AY': 'ai', 'EH': 'e', 'ER': 'er', 'EY': 'ei',
            'IH': 'i corta', 'IY': 'i', 'OW': 'ou', 'OY': 'oi', 'UH': 'u', 'UW': 'u larga',
            'B': 'b', 'CH': 'ch', 'D': 'd', 'DH': 'th sonora', 'F': 'f', 'G': 'g', 'HH': 'h',
            'JH': 'y', 'K': 'k', 'L': 'l', 'M': 'm', 'N': 'n', 'NG': 'ng', 'P': 'p', 'R': 'r',
            'S': 's', 'SH': 'sh', 'T': 't', 'TH': 'th', 'V': 'v', 'W': 'w', 'Y': 'y', 'Z': 'z', 'ZH': 'zh',
          };
          return map[s] ?? s.toLowerCase();
        }

        final int total = ((data['target_phonemes'] as List?)?.length ?? 0).clamp(1, 1000);

        final List<String> friendly = [];
        final Set<String> tips = {};
        for (final item in fbList) {
          final m = item as Map<String, dynamic>;
          final int idx = (m['index'] is num) ? (m['index'] as num).toInt() : 0;
          final String pos = _posLabel(idx, total);
          final String t = _mapPhone(m['target_phoneme']?.toString());
          final String h = _mapPhone(m['heard_phoneme']?.toString());
          String msg;
          if ((m['target_phoneme'] == null || (m['target_phoneme']?.toString().isEmpty ?? true)) && h.isNotEmpty) {
            msg = 'Evita añadir el sonido "$h" $pos';
          } else if ((m['heard_phoneme'] == null || (m['heard_phoneme']?.toString().isEmpty ?? true)) && t.isNotEmpty) {
            msg = 'Asegúrate de incluir el sonido de "$t" $pos';
          } else if (t.isNotEmpty && h.isNotEmpty) {
            msg = 'Pronuncia $pos con el sonido de "$t" en lugar de "$h"';
          } else {
            msg = 'Ajusta tu pronunciación $pos';
          }
          friendly.add(msg);

          if (t.isNotEmpty) {
            tips.add('Escucha la palabra y enfatiza el sonido de "$t" $pos');
          }
        }

        final String general = friendly.isEmpty
            ? 'Pronunciación correcta. ¡Buen trabajo!'
            : 'Se detectaron ${friendly.length} ajustes de sonido.';

        return {
          'success': true,
          'scorePercent': scorePercent,
          'general': general,
          'issues': friendly,
          'tips': tips.toList(),
          'raw': data,
        };
      } else {
        final err = 'Error HTTP ${response.statusCode}: ${response.reasonPhrase}';
        return {'success': false, 'error': err};
      }
    } on SocketException catch (e) {
      return {'success': false, 'error': 'Sin conexión al servidor: ${e.message}'};
    } on http.ClientException catch (e) {
      return {'success': false, 'error': 'Error de conexión: ${e.message}'};
    } on Exception catch (e) {
      return {'success': false, 'error': 'Error inesperado: $e'};
    }
  }
}