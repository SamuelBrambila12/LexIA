import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/constants.dart';

class ImagePickerWidget extends StatelessWidget {
  final Function(File) onImageSelected;
  final VoidCallback? onError;
  
  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.onError,
  });

  Future<void> _selectImage(BuildContext context, ImageSource source) async {
    try {
      // Solicitar permisos
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (cameraStatus.isDenied) {
          _showPermissionDialog(context, 'cámara');
          return;
        }
      } else {
        final storageStatus = await Permission.photos.request();
        if (storageStatus.isDenied) {
          _showPermissionDialog(context, 'galería');
          return;
        }
      }

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        
        // Verificar que el archivo existe y tiene tamaño válido
        if (await imageFile.exists()) {
          final fileSize = await imageFile.length();
          if (fileSize > 10 * 1024 * 1024) { // 10MB
            _showErrorDialog(context, 'El archivo es muy grande (máximo 10MB)');
            return;
          }
          
          onImageSelected(imageFile);
        } else {
          _showErrorDialog(context, 'Error: el archivo no se pudo acceder');
        }
      }
    } catch (e) {
      _showErrorDialog(context, 'Error seleccionando imagen: $e');
      if (onError != null) onError!();
    }
  }

  void _showPermissionDialog(BuildContext context, String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso requerido'),
        content: Text(
          'Para usar la $permissionType, necesitas conceder los permisos correspondientes en la configuración de la aplicación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Configuración'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _selectImage(context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text(AppStrings.selectFromCamera),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.defaultPadding),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _selectImage(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text(AppStrings.selectFromGallery),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}