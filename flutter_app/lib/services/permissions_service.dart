import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionsService {
  static const _kCameraKey = 'permisos.camera.status';
  static const _kMicKey = 'permisos.microphone.status';
  static const _kGalleryKey = 'permisos.gallery.status';

  // values: granted | denied | permanentlyDenied
  static Future<void> _save(String key, String value) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(key, value);
  }

  static Future<String?> _read(String key) async {
    final p = await SharedPreferences.getInstance();
    return p.getString(key);
  }

  static Future<bool> checkAndRequestCameraOnce() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    // Estado real actual
    final status = await Permission.camera.status;
    if (status.isGranted) {
      await _save(_kCameraKey, 'granted');
      return true;
    }

    // ¿estado recordado como permanentemente denegado?
    final remembered = await _read(_kCameraKey);
    if (remembered == 'permanentlyDenied') {
      return false;
    }

    // Pedir solo si no se había marcado como permanentemente denegado
    final res = await Permission.camera.request();
    if (res.isGranted) {
      await _save(_kCameraKey, 'granted');
      return true;
    }
    if (res.isPermanentlyDenied) {
      await _save(_kCameraKey, 'permanentlyDenied');
      return false;
    }
    await _save(_kCameraKey, 'denied');
    return false;
  }

  static Future<bool> checkAndRequestMicrophoneOnce() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    final status = await Permission.microphone.status;
    if (status.isGranted) {
      await _save(_kMicKey, 'granted');
      return true;
    }

    final remembered = await _read(_kMicKey);
    if (remembered == 'permanentlyDenied') {
      return false;
    }

    final res = await Permission.microphone.request();
    if (res.isGranted) {
      await _save(_kMicKey, 'granted');
      return true;
    }
    if (res.isPermanentlyDenied) {
      await _save(_kMicKey, 'permanentlyDenied');
      return false;
    }
    await _save(_kMicKey, 'denied');
    return false;
  }

  static Future<bool> checkAndRequestGalleryOnce() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    // En iOS permission.photos, en Android variar por API; permission_handler hace el mapeo.
    // Para Android 13+ usa READ_MEDIA_IMAGES; para <= 32 usa READ_EXTERNAL_STORAGE.
    // Preferimos Permission.photos si existe soporte; en Android se puede usar Permission.storage.

    Permission permissionToRequest;
    if (Platform.isAndroid) {
      // A partir de permission_handler 10+, Permission.photos mapea a READ_MEDIA_IMAGES (API 33+)
      // y Permission.storage a READ_EXTERNAL_STORAGE (<=32). Intentamos primero photos,
      // y si no está implemented, caemos a storage.
      permissionToRequest = Permission.photos;
      // Algunas versiones de Android/permission_handler pueden reportar .isRestricted para photos;
      // en ese caso, caer a storage.
      final photosStatus = await Permission.photos.status;
      if (photosStatus.isDenied || photosStatus.isPermanentlyDenied || photosStatus.isRestricted) {
        // No asumimos concedido; dejamos que el request decida.
      }
    } else {
      permissionToRequest = Permission.photos;
    }

    var status = await permissionToRequest.status;
    if (status.isGranted) {
      await _save(_kGalleryKey, 'granted');
      return true;
    }

    final remembered = await _read(_kGalleryKey);
    if (remembered == 'permanentlyDenied') {
      return false;
    }

    // Solicitar una vez
    var res = await permissionToRequest.request();

    // Fallback para Android <= 32 si photos no procede
    if (!res.isGranted && Platform.isAndroid) {
      final storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        final storageRes = await Permission.storage.request();
        res = storageRes;
      } else {
        res = storageStatus;
      }
    }

    if (res.isGranted) {
      await _save(_kGalleryKey, 'granted');
      return true;
    }
    if (res.isPermanentlyDenied) {
      await _save(_kGalleryKey, 'permanentlyDenied');
      return false;
    }
    await _save(_kGalleryKey, 'denied');
    return false;
  }

  static Future<bool> openAppSettingsIfNeeded(String key) async {
    // Utilidad opcional por si se quiere llevar al usuario a Ajustes externamente.
    final remembered = await _read(key);
    if (remembered == 'permanentlyDenied') {
      return openAppSettings();
    }
    return Future.value(false);
  }
}
