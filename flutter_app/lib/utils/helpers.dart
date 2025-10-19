// flutter_app/lib/utils/helpers.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../models/prediction_model.dart';
import 'constants.dart';

/// Helpers para manejo de imágenes
class ImageHelpers {
  /// Valida si un archivo es una imagen válida
  static bool isValidImageFile(File file) {
    final fileName = file.path.toLowerCase();
    return ImageConfig.supportedFormats.any((ext) => fileName.endsWith(ext));
  }

  /// Valida si un MIME type es de imagen válida
  static bool isValidImageMimeType(String? mimeType) {
    if (mimeType == null) return false;
    return ImageConfig.supportedMimeTypes.contains(mimeType.toLowerCase());
  }

  /// Obtiene la extensión de un archivo
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// Formatea el tamaño de archivo en formato legible
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = (log(bytes) / log(1024)).floor();
    
    if (i >= suffixes.length) i = suffixes.length - 1;
    
    double size = bytes / pow(1024, i);
    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${suffixes[i]}';
  }

  /// Redimensiona una imagen manteniendo la proporción
  static Size calculateResizedDimensions(
    Size originalSize,
    double maxWidth,
    double maxHeight,
  ) {
    double width = originalSize.width;
    double height = originalSize.height;

    if (width <= maxWidth && height <= maxHeight) {
      return originalSize;
    }

    double aspectRatio = width / height;

    if (width > height) {
      width = maxWidth;
      height = width / aspectRatio;
      
      if (height > maxHeight) {
        height = maxHeight;
        width = height * aspectRatio;
      }
    } else {
      height = maxHeight;
      width = height * aspectRatio;
      
      if (width > maxWidth) {
        width = maxWidth;
        height = width / aspectRatio;
      }
    }

    return Size(width, height);
  }

  /// Obtiene información detallada de un archivo de imagen
  static Future<Map<String, dynamic>> getImageInfo(File imageFile) async {
    try {
      final stats = await imageFile.stat();
      final bytes = await imageFile.readAsBytes();
      
      // Intentar obtener dimensiones básicas (esto sería más complejo en una implementación real)
      // Por ahora retornamos información básica del archivo
      
      return {
        'path': imageFile.path,
        'name': imageFile.path.split('/').last,
        'extension': getFileExtension(imageFile.path),
        'sizeBytes': stats.size,
        'sizeFormatted': formatFileSize(stats.size),
        'lastModified': stats.modified,
        'isValid': isValidImageFile(imageFile),
        'mimeType': _getMimeTypeFromExtension(getFileExtension(imageFile.path)),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'isValid': false,
      };
    }
  }

  /// Obtiene el MIME type basado en la extensión
  static String _getMimeTypeFromExtension(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      case 'tiff':
      case 'tif':
        return 'image/tiff';
      default:
        return 'application/octet-stream';
    }
  }

  /// Obtiene el directorio temporal para guardar imágenes
  static Future<Directory> getTempDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Obtiene el directorio de documentos
  static Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Crea un nombre único para archivo
  static String generateUniqueFileName(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return 'img_${timestamp}_$random.$extension';
  }

  /// Valida las dimensiones de la imagen
  static bool isValidImageDimensions(double width, double height) {
    return width > 0 && 
           height > 0 && 
           width <= ApiConfig.maxImageWidth && 
           height <= ApiConfig.maxImageHeight;
  }
}

/// Helpers para la interfaz de usuario
class UIHelpers {
  /// Muestra un SnackBar con mensaje de error
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: AppStrings.ok,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Muestra un SnackBar con mensaje de éxito
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Muestra un SnackBar con mensaje informativo
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Muestra un SnackBar con mensaje de advertencia
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Muestra un diálogo de confirmación
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: confirmColor ?? AppColors.primary),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Muestra un diálogo de loading
  static void showLoadingDialog(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => PopScope(
        canPop: barrierDismissible,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppDimensions.defaultPadding),
              Text(message ?? AppStrings.loadingModel),
            ],
          ),
        ),
      ),
    );
  }

  /// Oculta el diálogo actual
  static void hideDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Muestra un diálogo de información
  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = 'Cerrar',
    List<Widget>? actions,
    IconData? icon,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.info),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(title)),
          ],
        ),
        content: SingleChildScrollView(child: Text(content)),
        actions: actions ?? [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Muestra un bottom sheet con opciones
  static Future<T?> showOptionsBottomSheet<T>(
    BuildContext context, {
    required String title,
    required List<BottomSheetOption<T>> options,
  }) async {
    return await showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.largeRadius),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.defaultPadding),
            
            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.defaultPadding),
            
            // Options
            ...options.map((option) => ListTile(
              leading: option.icon != null ? Icon(option.icon) : null,
              title: Text(option.title),
              subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
              onTap: () => Navigator.pop(context, option.value),
            )),
            
            const SizedBox(height: AppDimensions.smallPadding),
          ],
        ),
      ),
    );
  }

  /// Copia texto al clipboard
  static Future<void> copyToClipboard(String text, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    showSuccessSnackBar(context, 'Texto copiado al portapapeles');
  }

  /// Vibra el dispositivo si está disponible
  static Future<void> vibrate({int duration = 100}) async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Vibración no disponible
    }
  }

  /// Oculta el teclado
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Obtiene el color de estado basado en la confianza
  static Color getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.success;
    if (confidence >= 0.6) return AppColors.warning;
    if (confidence >= 0.4) return AppColors.info;
    return AppColors.error;
  }

  /// Formatea un porcentaje de confianza
  static String formatConfidence(double confidence) {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }
}

/// Helpers para manejo de permisos
class PermissionHelpers {
  /// Solicita permisos de cámara
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Solicita permisos de almacenamiento/fotos
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// Verifica si los permisos de cámara están concedidos
  static Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Verifica si los permisos de almacenamiento están concedidos
  static Future<bool> isStoragePermissionGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  /// Muestra diálogo de permisos denegados
  static Future<void> showPermissionDeniedDialog(
    BuildContext context,
    String permissionType,
  ) async {
    await UIHelpers.showInfoDialog(
      context,
      title: AppStrings.permissionRequired,
      content: permissionType == 'camera' 
          ? AppStrings.cameraPermissionMessage
          : AppStrings.galleryPermissionMessage,
      icon: Icons.security,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            openAppSettings();
          },
          child: const Text(AppStrings.goToSettings),
        ),
      ],
    );
  }

  /// Solicita todos los permisos necesarios
  static Future<Map<String, bool>> requestAllPermissions() async {
    final results = await [
      Permission.camera,
      Permission.photos,
    ].request();

    return {
      'camera': results[Permission.camera]?.isGranted ?? false,
      'photos': results[Permission.photos]?.isGranted ?? false,
    };
  }
}

/// Helpers para validaciones
class ValidationHelpers {
  /// Valida si una URL es válida
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Valida si un archivo existe y es accesible
  static Future<bool> validateFile(File file) async {
    try {
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Valida el tamaño de un archivo
  static Future<bool> validateFileSize(File file, int maxSizeBytes) async {
    try {
      final stats = await file.stat();
      return stats.size <= maxSizeBytes;
    } catch (e) {
      return false;
    }
  }

  /// Valida una respuesta de la API
  static bool validateApiResponse(Map<String, dynamic> response) {
    return response.containsKey('success') && 
           response['success'] is bool;
  }

  /// Valida que una predicción tenga datos válidos
  static bool validatePrediction(PredictionResult prediction) {
    return prediction.className.isNotEmpty &&
           prediction.confidence >= 0.0 &&
           prediction.confidence <= 1.0;
  }
}

/// Helpers para formateo de datos
class DataHelpers {
  /// Convierte bytes a base64
  static String bytesToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  /// Convierte base64 a bytes
  static Uint8List base64ToBytes(String base64String) {
    return base64Decode(base64String);
  }

  /// Formatea una fecha de manera legible
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year} '
           '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }

  /// Formatea duración en formato legible
  static String formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
  }

  /// Trunca texto si es muy largo
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitaliza la primera letra de cada palabra
  static String capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) => word.isEmpty 
            ? word 
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Convierte una lista de predicciones a JSON
  static Map<String, dynamic> predictionsToJson(List<PredictionResult> predictions) {
    return {
      'predictions': predictions.map((p) => p.toJson()).toList(),
      'count': predictions.length,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Helpers para navegación
class NavigationHelpers {
  /// Navega a una pantalla con animación personalizada
  static Future<T?> navigateWithAnimation<T>(
    BuildContext context,
    Widget destination, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: curve)),
            child: child,
          );
        },
      ),
    );
  }

  /// Navega y limpia el stack
  static Future<void> navigateAndClearStack(
    BuildContext context,
    Widget destination,
  ) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => destination),
      (route) => false,
    );
  }
}

/// Helpers para logging y debugging
class LogHelpers {
  /// Log de información
  static void info(String message, [String? tag]) {
    if (AppConfig.isDebugMode) {
      print('[INFO${tag != null ? ':$tag' : ''}] $message');
    }
  }

  /// Log de error
  static void error(String message, [dynamic error, String? tag]) {
    if (AppConfig.isDebugMode) {
      print('[ERROR${tag != null ? ':$tag' : ''}] $message');
      if (error != null) print('Details: $error');
    }
  }

  /// Log de debug
  static void debug(String message, [String? tag]) {
    if (AppConfig.isDebugMode) {
      print('[DEBUG${tag != null ? ':$tag' : ''}] $message');
    }
  }

  /// Log de performance
  static void performance(String operation, Duration duration, [String? tag]) {
    if (AppConfig.enablePerformanceLogging) {
      print('[PERF${tag != null ? ':$tag' : ''}] $operation took ${duration.inMilliseconds}ms');
    }
  }
}

/// Clase auxiliar para opciones de bottom sheet
class BottomSheetOption<T> {
  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;

  const BottomSheetOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
  });
}

/// Helpers para efectos de UI
class EffectHelpers {
  /// Crea un efecto de shimmer
  static Widget createShimmerEffect({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }

  /// Crea un efecto de pulse
  static Widget createPulseEffect({
    required Widget child,
    Duration duration = const Duration(seconds: 1),
    double minOpacity = 0.5,
    double maxOpacity = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: minOpacity, end: maxOpacity),
      duration: duration,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: child,
    );
  }
}