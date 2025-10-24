import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_stats_service.dart';
import '../language_selection_screen.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginEmail = TextEditingController();
  final _loginPwd = TextEditingController();
  final _regName = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPwd = TextEditingController();
  final _regPwd2 = TextEditingController();
  bool _loading = false;
  bool _showLoginPwd = false;
  bool _showRegPwd = false;
  bool _showRegPwd2 = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    AuthService().seedUserSamuel();
    AuthService().seedAdditionalUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmail.dispose();
    _loginPwd.dispose();
    _regName.dispose();
    _regEmail.dispose();
    _regPwd.dispose();
    _regPwd2.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final email = _loginEmail.text.trim();
    final pwd = _loginPwd.text;
    if (email.isEmpty || pwd.length < 4) {
      _toast('Ingresa email y contraseña válida');
      return;
    }
    setState(() => _loading = true);
    final ok = await AuthService().signIn(email: email, password: pwd);
    setState(() => _loading = false);
    if (!mounted) return;
    if (!ok) {
      _toast('Credenciales inválidas');
      return;
    }
    final user = await AuthService().currentUser();
    if (user != null) {
      await UserStatsService().getStats(user['email']!);
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
      (route) => false,
    );
  }

  Future<void> _onRegister() async {
    final name = _regName.text.trim();
    final email = _regEmail.text.trim();
    final pwd = _regPwd.text;
    final pwd2 = _regPwd2.text;
    if (name.isEmpty || !email.contains('@') || pwd.length < 6 || pwd != pwd2) {
      _toast('Verifica nombre, email y contraseñas');
      return;
    }
    setState(() => _loading = true);
    final ok = await AuthService().register(name: name, email: email, password: pwd);
    setState(() => _loading = false);
    if (!mounted) return;
    if (!ok) {
      _toast('El usuario ya existe');
      return;
    }
    await UserStatsService().getStats(email);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
      (route) => false,
    );
  }

  void _toast(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo con degradado azul-verde
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF00C853)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Contenido
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo y título
                  const SizedBox(height: 40),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo_lexia.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'LexIA',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Aprendizaje de idiomas impulsado por IA',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Tarjeta de login/registro
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 20,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // TabBar
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1E88E5), Color(0xFF00C853)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                indicator: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                indicatorSize: TabBarIndicatorSize.tab,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.white70,
                                labelStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                tabs: const [
                                  Tab(text: 'Iniciar sesión'),
                                  Tab(text: 'Crear cuenta'),
                                ],
                              ),
                            ),
                            // TabBarView
                            SizedBox(
                              height: 320,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildLogin(),
                                  _buildRegister(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogin() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            // Email field
            TextField(
              controller: _loginEmail,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1E88E5)),
                labelText: 'Correo electrónico',
                labelStyle: const TextStyle(color: Color(0xFF1E88E5)),
                hintText: 'tu@email.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FF),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            // Password field
            TextField(
              controller: _loginPwd,
              obscureText: !_showLoginPwd,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1E88E5)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showLoginPwd ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF1E88E5),
                  ),
                  onPressed: () => setState(() => _showLoginPwd = !_showLoginPwd),
                ),
                labelText: 'Contraseña',
                labelStyle: const TextStyle(color: Color(0xFF1E88E5)),
                hintText: 'Mínimo 4 caracteres',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FF),
              ),
            ),
            const SizedBox(height: 24),
            // Login button
            ElevatedButton(
              onPressed: _loading ? null : _onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded),
                        SizedBox(width: 8),
                        Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegister() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            // Name field
            TextField(
              controller: _regName,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF1E88E5)),
                labelText: 'Nombre completo',
                labelStyle: const TextStyle(color: Color(0xFF1E88E5)),
                hintText: 'Tu nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FF),
              ),
            ),
            const SizedBox(height: 12),
            // Email field
            TextField(
              controller: _regEmail,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1E88E5)),
                labelText: 'Correo electrónico',
                labelStyle: const TextStyle(color: Color(0xFF1E88E5)),
                hintText: 'tu@email.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FF),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            // Password field
            TextField(
              controller: _regPwd,
              obscureText: !_showRegPwd,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1E88E5)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showRegPwd ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF1E88E5),
                  ),
                  onPressed: () => setState(() => _showRegPwd = !_showRegPwd),
                ),
                labelText: 'Contraseña',
                labelStyle: const TextStyle(color: Color(0xFF1E88E5)),
                hintText: 'Mínimo 6 caracteres',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FF),
              ),
            ),
            const SizedBox(height: 12),
            // Confirm password field
            TextField(
              controller: _regPwd2,
              obscureText: !_showRegPwd2,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1E88E5)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showRegPwd2 ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF1E88E5),
                  ),
                  onPressed: () => setState(() => _showRegPwd2 = !_showRegPwd2),
                ),
                labelText: 'Confirmar contraseña',
                labelStyle: const TextStyle(color: Color(0xFF1E88E5)),
                hintText: 'Repite tu contraseña',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FF),
              ),
            ),
            const SizedBox(height: 20),
            // Register button
            ElevatedButton(
              onPressed: _loading ? null : _onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_alt_1_rounded),
                        SizedBox(width: 8),
                        Text('Crear cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
