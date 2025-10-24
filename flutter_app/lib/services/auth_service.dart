import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _kCurrentEmailKey = 'auth.currentUser.email';
  static const String _kCurrentNameKey = 'auth.currentUser.name';

  // Claves por usuario
  static String _nameKey(String email) => 'auth.users.$email.name';
  static String _passwordKey(String email) => 'auth.users.$email.password';

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<void> seedUserSamuel() async {
    final p = await _prefs;
    const email = 'samuel@lexia.local';
    const name = 'Samuel Brambila';
    const password = 'samuel75';

    final exists = p.getString(_nameKey(email)) != null;
    if (!exists) {
      await p.setString(_nameKey(email), name);
      await p.setString(_passwordKey(email), password);
    }
  }

  Future<bool> register({required String name, required String email, required String password}) async {
    final p = await _prefs;
    if (p.getString(_nameKey(email)) != null) {
      // ya existe
      return false;
    }
    await p.setString(_nameKey(email), name);
    await p.setString(_passwordKey(email), password);
    // Por conveniencia, iniciar sesión después de registro
    await p.setString(_kCurrentEmailKey, email);
    await p.setString(_kCurrentNameKey, name);
    return true;
  }

  Future<bool> signIn({required String email, required String password}) async {
    final p = await _prefs;
    final storedPwd = p.getString(_passwordKey(email));
    final name = p.getString(_nameKey(email));
    if (storedPwd == null || name == null) return false;
    if (storedPwd != password) return false;
    await p.setString(_kCurrentEmailKey, email);
    await p.setString(_kCurrentNameKey, name);
    return true;
  }

  Future<void> signOut() async {
    final p = await _prefs;
    await p.remove(_kCurrentEmailKey);
    await p.remove(_kCurrentNameKey);
  }

  Future<bool> isLoggedIn() async {
    final p = await _prefs;
    return p.getString(_kCurrentEmailKey) != null;
  }

  Future<Map<String, String>?> currentUser() async {
    final p = await _prefs;
    final email = p.getString(_kCurrentEmailKey);
    final name = p.getString(_kCurrentNameKey);
    if (email == null || name == null) return null;
    return {'email': email, 'name': name};
  }

  Future<List<Map<String, String>>> listUsers() async {
    final p = await _prefs;
    final Set<String> keys = p.getKeys();
    final users = <Map<String, String>>[];
    for (final k in keys) {
      if (k.startsWith('auth.users.') && k.endsWith('.name')) {
        final email = k.substring('auth.users.'.length, k.length - '.name'.length);
        final name = p.getString(k) ?? email;
        users.add({'email': email, 'name': name});
      }
    }
    // Orden alfabético por nombre
    users.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
    return users;
  }

  Future<bool> switchUser(String email) async {
    final p = await _prefs;
    final name = p.getString(_nameKey(email));
    if (name == null) return false;
    await p.setString(_kCurrentEmailKey, email);
    await p.setString(_kCurrentNameKey, name);
    return true;
  }

  Future<bool> deleteUser(String email) async {
    final p = await _prefs;
    final currEmail = p.getString(_kCurrentEmailKey);
    await p.remove(_nameKey(email));
    await p.remove(_passwordKey(email));
    // Borrar stats asociados
    await _deleteStatsFor(email);
    // Si es el usuario actual, cerrar sesión
    if (currEmail == email) {
      await signOut();
    }
    return true;
  }

  Future<void> _deleteStatsFor(String email) async {
    final p = await _prefs;
    await p.remove('stats.$email.progress');
    await p.remove('stats.$email.streakDays');
    await p.remove('stats.$email.lessons');
    await p.remove('stats.$email.points');
    await p.remove('stats.$email.level');
  }
}
