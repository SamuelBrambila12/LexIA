// lib/screens/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/prediction_model.dart';
import '../widgets/api_status_widget.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/prediction_card.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/tts_helper.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  File? _selectedImage;
  bool _isLoading = false;
  bool _isApiHealthy = false;
  ApiResponse? _lastResponse;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkApiHealth();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _checkApiHealth() async {
    try {
      final healthData = await ApiService.checkHealth();
      if (mounted) {
        setState(() {
          _isApiHealthy = healthData['isHealthy'] ?? false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isApiHealthy = false;
        });
        debugPrint('Error checking API health: $e');
      }
    }
  }

  void _onImageSelected(File imageFile) {
    if (mounted) {
      setState(() {
        _selectedImage = imageFile;
        _lastResponse = null;
      });
      _animationController.forward();
    }
  }

  void _onImageSelectionError() {
    if (mounted) {
      UIHelpers.showErrorSnackBar(context, AppStrings.errorSelectingImage);
    }
  }

  Future<void> _predictImage() async {
    if (_selectedImage == null) {
      UIHelpers.showErrorSnackBar(context, AppStrings.noImageSelected);
      return;
    }

    if (!_isApiHealthy) {
      UIHelpers.showErrorSnackBar(context, 'La API no está disponible. Verifica tu conexión.');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.predictImage(_selectedImage!);
      
      if (!mounted) return;

      setState(() {
        _lastResponse = response;
        _isLoading = false;
      });

      if (response.success) {
        // Navegar a pantalla de resultados
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              response: response,
              imagePath: _selectedImage?.path,
            ),
          ),
        );
        // Manejo de moderación: limpiar imagen si corresponde
        if (mounted && result is Map && result['clearImage'] == true) {
          setState(() {
            _selectedImage = null;
            _lastResponse = null;
          });
        }
      } else {
        UIHelpers.showErrorSnackBar(
          context,
          response.error ?? 'Error desconocido en la predicción',
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      final errorResponse = ApiResponse.error('Error de conexión: $e');
      setState(() {
        _lastResponse = errorResponse;
        _isLoading = false;
      });
      UIHelpers.showErrorSnackBar(context, 'Error en predicción: $e');
    }
  }

  void _clearImage() {
    if (mounted) {
      setState(() {
        _selectedImage = null;
        _lastResponse = null;
      });
      _animationController.reverse();
    }
  }

  void _showImageFullScreen() {
    if (_selectedImage == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageView(imageFile: _selectedImage!),
        fullscreenDialog: true,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Traductor de objetos con IA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isApiHealthy ? Icons.cloud_done : Icons.cloud_off,
              color: _isApiHealthy ? AppColors.success : AppColors.error,
            ),
            onPressed: _checkApiHealth,
            tooltip: 'Estado de la API',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
            tooltip: 'Información',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _checkApiHealth();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Estado de la API oculto
              const SizedBox.shrink(),

              // Botones de selección de imagen
              ImagePickerWidget(
                onImageSelected: _onImageSelected,
                onError: _onImageSelectionError,
              ),

              const SizedBox(height: AppDimensions.largePadding),

              // Imagen seleccionada
              if (_selectedImage != null) ...[
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildImageSection(),
                ),
                const SizedBox(height: AppDimensions.defaultPadding),
              ],

              // Mostrar la palabra detectada cuando se vuelve desde resultados
              if (_lastResponse != null && _lastResponse!.topPrediction != null && !_isLoading) ...[
                const SizedBox(height: AppDimensions.defaultPadding),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _toTitleCase(_lastResponse!.topPrediction!.className),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
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
                          onPressed: () => TtsHelper.speak(_lastResponse!.topPrediction!.className),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: AppDimensions.cardElevation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header con botones
          Padding(
            padding: const EdgeInsets.all(AppDimensions.defaultPadding),
            child: Row(
              children: [
                const Icon(
                  Icons.image,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Imagen seleccionada',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: _showImageFullScreen,
                  tooltip: 'Ver en pantalla completa',
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearImage,
                  tooltip: 'Limpiar imagen',
                ),
              ],
            ),
          ),

          // Imagen
          GestureDetector(
            onTap: _showImageFullScreen,
            child: Container(
              height: AppDimensions.imageHeight,
              margin: const EdgeInsets.symmetric(
                horizontal: AppDimensions.defaultPadding,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.error,
                            ),
                            SizedBox(height: 8),
                            Text('Error cargando imagen'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.defaultPadding),

          // Botón de análisis (oculto si ya hay resultado)
          if (_lastResponse == null) 
            Padding(
              padding: const EdgeInsets.all(AppDimensions.defaultPadding),
              child: ElevatedButton.icon(
                onPressed: _isApiHealthy && !_isLoading ? _predictImage : null,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.psychology),
                label: Text(
                  _isLoading ? AppStrings.analyzing : AppStrings.analyzeImage,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Eliminado: preview anterior. Ahora se muestra palabra al volver desde resultados.

  // Eliminado preview con probabilidades; ahora solo mostramos la palabra principal.

  List<String> _buildExampleSentences(String word) {
    final w = word.toLowerCase();
    // Ejemplos simples; en el futuro esto podría venir de una API o base de datos
    switch (w) {
      case 'cat':
        return [
          'The cat is sleeping on the sofa.',
          'A black cat crossed the street.',
          'She adopted a stray cat last week.',
        ];
      case 'dog':
        return [
          'The dog is barking loudly.',
          'I take my dog for a walk every morning.',
          'Her dog loves to play fetch.',
        ];
      case 'bottle':
        return [
          'Please pass me the water bottle.',
          'He recycled the plastic bottle.',
          'The baby drank from the bottle.',
        ];
      default:
        return [
          'This is a $word.',
          'I can see a $word in the image.',
          'The $word is on the table.',
        ];
    }
  }

  String _toTitleCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de la App'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Clasificación de imágenes con IA'),
            SizedBox(height: 8),
            Text('• Modelo: EfficientNetV2-L preentrenado'),
            SizedBox(height: 8),
            Text('• Soporta: JPG, PNG, BMP, GIF, TIFF'),
            SizedBox(height: 8),
            Text('• Tamaño máximo: 10MB por imagen'),
            SizedBox(height: 8),
            Text('• Requiere conexión a internet'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

// Pantalla para mostrar imagen en pantalla completa
class _FullScreenImageView extends StatelessWidget {
  final File imageFile;

  const _FullScreenImageView({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Imagen completa',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              // Mostrar información de la imagen
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Información de la imagen'),
                  content: FutureBuilder<FileStat>(
                    future: imageFile.stat(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final stat = snapshot.data!;
                        final sizeInMB = (stat.size / (1024 * 1024)).toStringAsFixed(2);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ruta: ${imageFile.path}'),
                            const SizedBox(height: 8),
                            Text('Tamaño: ${sizeInMB} MB'),
                            const SizedBox(height: 8),
                            Text('Modificado: ${stat.modified}'),
                          ],
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            imageFile,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Error cargando imagen',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}