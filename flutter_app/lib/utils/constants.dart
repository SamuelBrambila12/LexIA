// flutter_app/lib/utils/constants.dart
import 'package:flutter/material.dart';

/// Colores principales de la aplicación
class AppColors {
  // Colores primarios
  static const Color primary = Colors.blue;
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color secondary = Colors.blueAccent;
  static const Color secondaryLight = Color(0xFF82B1FF);
  static const Color secondaryDark = Color(0xFF448AFF);

  // Colores de estado
  static const Color success = Colors.green;
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  
  static const Color warning = Colors.orange;
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  
  static const Color error = Colors.red;
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // Colores de fondo
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardBackground = Colors.white;
  static const Color cardBackgroundDark = Color(0xFF2D2D2D);

  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textDisabledDark = Color(0xFF616161);

  // Colores adicionales
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
  static const Color shadow = Color(0x1F000000);
  static const Color overlay = Color(0x80000000);

  // Colores para predicciones (gradiente)
  static const List<Color> predictionColors = [
    Color(0xFFFFD700), // Gold
    Color(0xFFFF8C00), // Dark Orange
    Color(0xFFFF6347), // Tomato
    Color(0xFFDC143C), // Crimson
    Color(0xFF8A2BE2), // Blue Violet
    Color(0xFF4169E1), // Royal Blue
    Color(0xFF32CD32), // Lime Green
    Color(0xFF20B2AA), // Light Sea Green
  ];
}

/// Strings utilizados en toda la aplicación
class AppStrings {
  // Título de la app
  static const String appTitle = 'LexIA';
  static const String appSubtitle = 'Clasificación de Imágenes con IA';
  
  // Pantalla principal
  static const String selectFromCamera = 'Cámara';
  static const String selectFromGallery = 'Galería';
  static const String analyzeImage = 'Analizar Imagen';
  static const String analyzing = 'Analizando...';
  static const String results = 'Resultados';
  static const String topPrediction = 'Predicción Principal';
  static const String allPredictions = 'Todas las predicciones';
  static const String imageSelected = 'Imagen seleccionada';
  static const String clearImage = 'Limpiar imagen';
  static const String viewFullScreen = 'Ver en pantalla completa';
  
  // Estado de la API
  static const String apiConnected = 'API Conectada';
  static const String apiDisconnected = 'API No Disponible';
  static const String apiHealthy = 'Sistema Saludable';
  static const String apiUnhealthy = 'Sistema No Disponible';
  static const String verify = 'Verificar';
  static const String checkingConnection = 'Verificando conexión...';
  static const String connectionStatus = 'Estado de Conexión';
  
  // Mensajes de error
  static const String errorSelectingImage = 'Error seleccionando imagen';
  static const String errorInPrediction = 'Error en predicción';
  static const String errorConnection = 'Error de conexión';
  static const String errorServer = 'Error del servidor';
  static const String errorUnknown = 'Error desconocido';
  static const String errorImageTooLarge = 'La imagen es muy grande (máximo 10MB)';
  static const String errorInvalidImage = 'Formato de imagen no válido';
  static const String errorPermissionDenied = 'Permisos denegados';
  static const String errorCameraNotAvailable = 'Cámara no disponible';
  static const String errorGalleryNotAvailable = 'Galería no disponible';
  
  // Validaciones
  static const String noImageSelected = 'No se ha seleccionado ninguna imagen';
  static const String apiNotAvailable = 'La API no está disponible';
  static const String imageProcessingFailed = 'Error procesando la imagen';
  
  // Información
  static const String appInfo = 'Información de la App';
  static const String appVersion = 'Versión 1.0.0';
  static const String appDescription = 'Aplicación de clasificación de imágenes usando inteligencia artificial';
  
  // Features
  static const String features = 'Características:';
  static const String featureAIClassification = '• Clasificación de imágenes con IA';
  static const String featureMobileNetV2 = '• Modelo: EfficientNetV2-B0 preentrenado';
  static const String featureSupportedFormats = '• Soporta: JPG, PNG, BMP, GIF, TIFF';
  static const String featureMaxSize = '• Tamaño máximo: 10MB por imagen';
  static const String featureInternetRequired = '• Requiere conexión a internet';
  static const String featureRealTime = '• Análisis en tiempo real';
  
  // Botones
  static const String close = 'Cerrar';
  static const String cancel = 'Cancelar';
  static const String confirm = 'Confirmar';
  static const String ok = 'OK';
  static const String retry = 'Reintentar';
  static const String settings = 'Configuración';
  static const String share = 'Compartir';
  static const String save = 'Guardar';
  static const String delete = 'Eliminar';
  static const String edit = 'Editar';
  
  // Permisos
  static const String permissionRequired = 'Permiso requerido';
  static const String cameraPermissionMessage = 'Para usar la cámara, necesitas conceder los permisos correspondientes en la configuración de la aplicación.';
  static const String galleryPermissionMessage = 'Para acceder a la galería, necesitas conceder los permisos correspondientes en la configuración de la aplicación.';
  static const String goToSettings = 'Ir a Configuración';
  
  // Información técnica
  static const String fileInfo = 'Información del archivo:';
  static const String filename = 'Archivo:';
  static const String fileSize = 'Tamaño:';
  static const String dimensions = 'Dimensiones:';
  static const String modelType = 'Modelo:';
  static const String tensorflowVersion = 'TensorFlow:';
  static const String inputSize = 'Tamaño de entrada:';
  static const String processingTime = 'Tiempo de procesamiento:';
  static const String confidence = 'Confianza:';
  
  // Resultados
  static const String predictionResults = 'Resultados del Análisis';
  static const String analysisComplete = 'Análisis completado exitosamente';
  static const String classId = 'ID de clase:';
  static const String className = 'Clase:';
  static const String confidenceLevel = 'Nivel de confianza:';
  
  // Mensajes de éxito
  static const String imageAnalyzedSuccessfully = 'Imagen analizada exitosamente';
  static const String connectionEstablished = 'Conexión establecida correctamente';
  static const String imageSelectedSuccessfully = 'Imagen seleccionada correctamente';
  
  // Loading states
  static const String loadingModel = 'Cargando modelo...';
  static const String processingImage = 'Procesando imagen...';
  static const String connectingToServer = 'Conectando al servidor...';
  static const String preparingResults = 'Preparando resultados...';
  
  // Empty states
  static const String noResultsFound = 'No se encontraron resultados';
  static const String selectImageToStart = 'Selecciona una imagen para comenzar';
  static const String noImagesInGallery = 'No hay imágenes en la galería';
  
  // Time units
  static const String seconds = 'segundos';
  static const String milliseconds = 'ms';
  
  // File size units
  static const String bytes = 'bytes';
  static const String kb = 'KB';
  static const String mb = 'MB';
  
  // Image formats
  static const String supportedFormats = 'Formatos soportados: JPG, PNG, BMP, GIF, TIFF';
  
  // API information
  static const String serverUrl = 'URL del servidor:';
  static const String serverStatus = 'Estado del servidor:';
  static const String modelStatus = 'Estado del modelo:';
  static const String lastUpdated = 'Última actualización:';
}

/// Dimensiones y espaciados utilizados en la UI
class AppDimensions {
  // Padding y margin
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  static const double tinyPadding = 4.0;
  
  // Tamaños de elementos
  static const double buttonHeight = 48.0;
  static const double smallButtonHeight = 36.0;
  static const double largeButtonHeight = 56.0;
  static const double imageHeight = 300.0;
  static const double thumbnailSize = 80.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 48.0;
  static const double smallIconSize = 16.0;
  
  // Elevaciones
  static const double cardElevation = 4.0;
  static const double buttonElevation = 2.0;
  static const double dialogElevation = 24.0;
  static const double appBarElevation = 4.0;
  
  // Border radius
  static const double defaultRadius = 8.0;
  static const double smallRadius = 4.0;
  static const double largeRadius = 16.0;
  static const double circularRadius = 50.0;
  
  // Tamaños de texto
  static const double titleFontSize = 24.0;
  static const double subtitleFontSize = 18.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 12.0;
  static const double smallFontSize = 10.0;
  
  // Anchos y alturas específicas
  static const double maxImageWidth = 1024.0;
  static const double maxImageHeight = 1024.0;
  static const double minButtonWidth = 120.0;
  static const double dialogWidth = 280.0;
  
  // Espaciados entre elementos
  static const double elementSpacing = 12.0;
  static const double sectionSpacing = 20.0;
  static const double listItemSpacing = 8.0;
  
  // Tamaños de containers
  static const double statusIndicatorSize = 12.0;
  static const double progressIndicatorSize = 20.0;
  static const double avatarSize = 40.0;
  
  // Opacidades
  static const double disabledOpacity = 0.6;
  static const double overlayOpacity = 0.8;
  static const double shadowOpacity = 0.1;
}

/// Configuración de animaciones
class AppAnimations {
  // Duraciones
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 400);
  static const Duration longDuration = Duration(milliseconds: 600);
  static const Duration extraLongDuration = Duration(milliseconds: 1000);
  
  // Curvas de animación
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  
  // Valores de transición
  static const double fadeInBegin = 0.0;
  static const double fadeInEnd = 1.0;
  static const double slideOffsetBegin = 0.3;
  static const double slideOffsetEnd = 0.0;
  static const double scaleBegin = 0.8;
  static const double scaleEnd = 1.0;
}

/// Configuración de la API
class ApiConfig {
  // URLs base (cambiar por tu IP local)
  static const String baseUrl = 'http://192.168.1.100:8000';
  static const String localUrl = 'http://localhost:8000';
  
  // Endpoints
  static const String healthEndpoint = '/health';
  static const String predictEndpoint = '/predict';
  static const String predictBatchEndpoint = '/predict/batch';
  static const String infoEndpoint = '/';
  
  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);
  static const Duration healthTimeout = Duration(seconds: 5);
  
  // Límites
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxBatchSize = 10;
  static const int imageQuality = 85;
  static const double maxImageWidth = 1024;
  static const double maxImageHeight = 1024;
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

/// Configuración de imágenes
class ImageConfig {
  // Formatos soportados
  static const List<String> supportedFormats = [
    '.jpg',
    '.jpeg',
    '.png',
    '.bmp',
    '.gif',
    '.tiff',
    '.webp',
  ];
  
  // MIME types
  static const List<String> supportedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/bmp',
    'image/gif',
    'image/tiff',
    'image/webp',
  ];
  
  // Configuración de compresión
  static const int defaultQuality = 85;
  static const int thumbnailQuality = 70;
  static const double thumbnailMaxWidth = 200;
  static const double thumbnailMaxHeight = 200;
}

/// Configuración de logs y debugging
class AppConfig {
  // Flags de debug
  static const bool isDebugMode = true;
  static const bool enableApiLogging = true;
  static const bool enablePerformanceLogging = false;
  
  // Configuración de retry
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Cache
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100;
}

/// Textos de ayuda y tooltips
class AppTooltips {
  static const String cameraButton = 'Tomar foto con la cámara';
  static const String galleryButton = 'Seleccionar imagen de la galería';
  static const String analyzeButton = 'Analizar la imagen seleccionada';
  static const String refreshButton = 'Actualizar estado de la API';
  static const String clearButton = 'Limpiar imagen actual';
  static const String fullScreenButton = 'Ver imagen en pantalla completa';
  static const String infoButton = 'Información sobre la aplicación';
  static const String settingsButton = 'Configuración de la aplicación';
  static const String shareButton = 'Compartir resultados';
}

/// Temas personalizados
class AppThemes {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.cardBackground,
    dividerColor: AppColors.divider,
    
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onError: Colors.white,
    ),
    
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: AppDimensions.titleFontSize,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: AppDimensions.subtitleFontSize,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: AppDimensions.bodyFontSize,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: AppDimensions.bodyFontSize,
        color: AppColors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: AppDimensions.captionFontSize,
        color: AppColors.textSecondary,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: AppDimensions.buttonElevation,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.defaultPadding,
          vertical: AppDimensions.smallPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.defaultRadius),
        ),
        minimumSize: const Size(
          AppDimensions.minButtonWidth,
          AppDimensions.buttonHeight,
        ),
      ),
    ),
    
    // cardTheme: CardTheme(
    //   elevation: AppDimensions.cardElevation,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
    //   ),
    //   color: AppColors.cardBackground,
    // ),
    
    appBarTheme: const AppBarTheme(
      elevation: AppDimensions.appBarElevation,
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    ),
    
    useMaterial3: true,
  );
  
  static ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.cardBackgroundDark,
    dividerColor: AppColors.dividerDark,
    
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
      background: AppColors.backgroundDark,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryDark,
      onBackground: AppColors.textPrimaryDark,
      onError: Colors.white,
    ),
    
    useMaterial3: true,
  );
}