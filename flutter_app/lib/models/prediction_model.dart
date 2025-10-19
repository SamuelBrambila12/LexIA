// lib/models/prediction_model.dart

class PredictionResult {
  final int classId;
  final String className;
  final double confidence; // en porcentaje (0.0 - 100.0)
  final String confidencePercent; // representación como "85.00%"

  PredictionResult({
    required this.classId,
    required this.className,
    required this.confidence,
    required this.confidencePercent,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    // Keys posibles para id y nombre
    final dynamic rawId = json['class_id'] ?? json['classId'] ?? json['id'];
    final int parsedId = (() {
      if (rawId == null) return 0;
      if (rawId is int) return rawId;
      final s = rawId.toString();
      return int.tryParse(s) ?? 0;
    })();

    final String name = (json['class_name'] ??
            json['className'] ??
            json['label'] ??
            json['name'] ??
            'Unknown')
        .toString();

    // Confianza: admitir double, int, string ("85%", "0.85", "0.85%")
    final dynamic rawConf =
        json['confidence'] ?? json['score'] ?? json['confidence_percent'] ?? json['confidencePercent'] ?? 0;
    final double parsedConfidence = _parseConfidenceToPercent(rawConf);

    final String percentStr = '${parsedConfidence.toStringAsFixed(2)}%';

    return PredictionResult(
      classId: parsedId,
      className: name,
      confidence: parsedConfidence,
      confidencePercent: percentStr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'class_name': className,
      'confidence': confidence,
      'confidence_percent': confidencePercent,
    };
  }

  @override
  String toString() {
    return 'PredictionResult(classId: $classId, className: $className, confidence: $confidencePercent)';
  }

  // Helper privado
  static double _parseConfidenceToPercent(dynamic raw) {
    try {
      if (raw == null) return 0.0;
      if (raw is num) {
        final v = raw.toDouble();
        // Si viene entre 0 y 1 asumimos fracción -> multiplicar por 100
        return (v <= 1.0) ? (v * 100.0) : v;
      }
      final s = raw.toString().trim();
      if (s.endsWith('%')) {
        final numStr = s.substring(0, s.length - 1).trim();
        return double.tryParse(numStr) ?? 0.0;
      }
      // Si es decimal "0.85" -> multiplicar por 100
      final d = double.tryParse(s) ?? 0.0;
      return (d <= 1.0) ? (d * 100.0) : d;
    } catch (_) {
      return 0.0;
    }
  }
}

class TopPrediction {
  final String className;
  final double confidence; // en porcentaje (0.0 - 100.0)

  TopPrediction({
    required this.className,
    required this.confidence,
  });

  factory TopPrediction.fromJson(dynamic json) {
    // Aceptar Map o String u otros formatos
    if (json == null) {
      return TopPrediction(className: 'Unknown', confidence: 0.0);
    }

    if (json is Map<String, dynamic>) {
      final name = (json['class'] ?? json['class_name'] ?? json['className'] ?? json['label'] ?? json['name'] ?? 'Unknown').toString();
      final dynamic rawConf = json['confidence'] ?? json['score'] ?? json['confidence_percent'] ?? json['confidencePercent'];
      final double parsed = PredictionResult._parseConfidenceToPercent(rawConf);
      return TopPrediction(className: name, confidence: parsed);
    }

    // Si llega una String simple (ej. "cat" o "cat: 85%")
    final s = json.toString();
    // intentar extraer patrón "name: X%"
    final colonIndex = s.indexOf(':');
    if (colonIndex > 0) {
      final maybeName = s.substring(0, colonIndex).trim();
      final maybeConf = s.substring(colonIndex + 1).trim();
      return TopPrediction(className: maybeName, confidence: PredictionResult._parseConfidenceToPercent(maybeConf));
    }

    // fallback: usar el string como nombre, confianza 0
    return TopPrediction(className: s, confidence: 0.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'class_name': className,
      'confidence': confidence,
    };
  }

  @override
  String toString() => 'TopPrediction(className: $className, confidence: ${confidence.toStringAsFixed(2)}%)';
}

class ApiResponse {
  final bool success;
  final String? filename;
  final double? fileSizeKb;
  final String? imageDimensions;
  final List<int>? processedShape;
  final List<PredictionResult> predictions;
  final TopPrediction? topPrediction;
  final String? error;
  final String? info; // nuevo campo opcional para mensajes/infos generales

  ApiResponse({
    required this.success,
    this.filename,
    this.fileSizeKb,
    this.imageDimensions,
    this.processedShape,
    required this.predictions,
    this.topPrediction,
    this.error,
    this.info,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    // predictions
    List<PredictionResult> predictionsList = [];
    if (json['predictions'] != null) {
      try {
        predictionsList = (json['predictions'] as List)
            .map((p) => PredictionResult.fromJson(p is Map ? p as Map<String, dynamic> : {'class_name': p.toString()}))
            .toList();
      } catch (_) {
        predictionsList = [];
      }
    }

    // topPrediction: varias claves y formatos
    TopPrediction? topPred;
    if (json['top_prediction'] != null) {
      topPred = TopPrediction.fromJson(json['top_prediction']);
    } else if (json['topPrediction'] != null) {
      topPred = TopPrediction.fromJson(json['topPrediction']);
    } else if (json['top'] != null) {
      topPred = TopPrediction.fromJson(json['top']);
    }

    // info: buscar en varios campos comunes
    String? infoFromJson;
    if (json['info'] != null) {
      infoFromJson = json['info']?.toString();
    } else if (json['message'] != null) {
      infoFromJson = json['message']?.toString();
    } else if (json['detail'] != null) {
      infoFromJson = json['detail']?.toString();
    }

    return ApiResponse(
      success: json['success'] == true || json['success'] == 1 || json['status'] == 'ok',
      filename: json['filename']?.toString(),
      fileSizeKb: (json['file_size_kb'] is num) ? (json['file_size_kb'] as num).toDouble() : (json['fileSizeKb'] is num ? (json['fileSizeKb'] as num).toDouble() : null),
      imageDimensions: json['image_dimensions']?.toString() ?? json['imageDimensions']?.toString(),
      processedShape: (json['processed_shape'] is List) ? (json['processed_shape'] as List).cast<int>() : (json['processedShape'] is List ? (json['processedShape'] as List).cast<int>() : null),
      predictions: predictionsList,
      topPrediction: topPred,
      error: json['error']?.toString() ?? json['detail']?.toString(),
      info: infoFromJson,
    );
  }

  // Factory para crear respuesta de error
  factory ApiResponse.error(String errorMessage) {
    return ApiResponse(
      success: false,
      predictions: [],
      error: errorMessage,
      info: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'filename': filename,
      'file_size_kb': fileSizeKb,
      'image_dimensions': imageDimensions,
      'processed_shape': processedShape,
      'predictions': predictions.map((p) => p.toJson()).toList(),
      'top_prediction': topPrediction?.toJson(),
      'error': error,
      'info': info,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, predictions: ${predictions.length}, error: $error, info: $info)';
  }
}

class BatchResult {
  final String filename;
  final bool success;
  final List<PredictionResult> predictions;
  final TopPrediction? topPrediction;
  final String? error;

  BatchResult({
    required this.filename,
    required this.success,
    required this.predictions,
    this.topPrediction,
    this.error,
  });

  factory BatchResult.fromJson(Map<String, dynamic> json) {
    List<PredictionResult> predictionsList = [];
    if (json['predictions'] != null) {
      try {
        predictionsList = (json['predictions'] as List)
            .map((p) => PredictionResult.fromJson(p is Map ? p as Map<String, dynamic> : {'class_name': p.toString()}))
            .toList();
      } catch (_) {
        predictionsList = [];
      }
    }

    TopPrediction? topPred;
    if (json['top_prediction'] != null) {
      topPred = TopPrediction.fromJson(json['top_prediction']);
    } else if (json['topPrediction'] != null) {
      topPred = TopPrediction.fromJson(json['topPrediction']);
    } else if (json['top'] != null) {
      topPred = TopPrediction.fromJson(json['top']);
    }

    return BatchResult(
      filename: json['filename']?.toString() ?? 'Unknown',
      success: json['success'] == true || json['success'] == 1,
      predictions: predictionsList,
      topPrediction: topPred,
      error: json['error']?.toString(),
    );
  }
}

class BatchResponse {
  final bool success;
  final int batchSize;
  final int successfulPredictions;
  final int failedPredictions;
  final List<BatchResult> results;

  BatchResponse({
    required this.success,
    required this.batchSize,
    required this.successfulPredictions,
    required this.failedPredictions,
    required this.results,
  });

  factory BatchResponse.fromJson(Map<String, dynamic> json) {
    List<BatchResult> resultsList = [];
    if (json['results'] != null) {
      try {
        resultsList = (json['results'] as List).map((r) => BatchResult.fromJson(r as Map<String, dynamic>)).toList();
      } catch (_) {
        resultsList = [];
      }
    }

    return BatchResponse(
      success: json['success'] == true || json['success'] == 1,
      batchSize: json['batch_size'] ?? json['batchSize'] ?? 0,
      successfulPredictions: json['successful_predictions'] ?? json['successfulPredictions'] ?? 0,
      failedPredictions: json['failed_predictions'] ?? json['failedPredictions'] ?? 0,
      results: resultsList,
    );
  }
}
