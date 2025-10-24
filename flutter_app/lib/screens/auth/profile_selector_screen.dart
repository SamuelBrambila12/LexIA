import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_stats_service.dart';
import '../english_menu_screen.dart';

class ProfileSelectorScreen extends StatefulWidget {
  const ProfileSelectorScreen({super.key});

  @override
  State<ProfileSelectorScreen> createState() => _ProfileSelectorScreenState();
}

class _ProfileSelectorScreenState extends State<ProfileSelectorScreen> {
  List<Map<String, String>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await AuthService().listUsers();
    setState(() {
      _users = list;
      _loading = false;
    });
  }

  Future<void> _switchTo(String email) async {
    final ok = await AuthService().switchUser(email);
    if (!ok) return;
    // Inicializa stats si falta
    await UserStatsService().getStats(email);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const GrammarExerciseScreen()), (_) => false);
  }

  Future<void> _delete(String email) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar perfil'),
        content: Text('¿Deseas eliminar el perfil "$email"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm != true) return;
    await AuthService().deleteUser(email);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar perfil'),
        actions: [
          IconButton(
            tooltip: 'Refrescar',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? _empty()
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _users.length,
                  itemBuilder: (ctx, i) {
                    final u = _users[i];
                    final name = u['name'] ?? '';
                    final email = u['email'] ?? '';
                    return _userCard(name, email);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context); // volver y permitir registrar
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Crear perfil'),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: 8),
          Text('No hay perfiles. Crea uno nuevo desde la pantalla anterior.'),
        ],
      ),
    );
  }

  Widget _userCard(String name, String email) {
    final initials = _initials(name);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFFFF3C4),
          child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(email),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              tooltip: 'Usar',
              icon: const Icon(Icons.login),
              onPressed: () => _switchTo(email),
            ),
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(email),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }
}
