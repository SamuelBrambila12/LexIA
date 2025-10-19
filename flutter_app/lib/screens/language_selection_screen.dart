import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'english_menu_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  void _showLockedDialog(BuildContext context, String language) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$language - En construcción'),
        content: const Text('Este idioma está en desarrollo y pronto estará disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con gradiente y decoraciones
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -60,
            child: _Blob(color: Colors.white.withOpacity(0.08), size: 220),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: _Blob(color: Colors.white.withOpacity(0.06), size: 180),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Image.asset(
                            'assets/images/logo_lexia.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LexIA',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Aprendizaje de idiomas impulsado por IA',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 24,
                      left: 16,
                      right: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 18,
                          offset: Offset(0, -4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.flag_rounded, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Selecciona un idioma',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Expanded(
                          child: ListView(
                            children: [
                              _LanguageTile(
                                leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                                title: 'Inglés',
                                subtitle: 'Disponible',
                                enabled: true,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const EnglishMenuScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              _LanguageTile(
                                leading: const Text('🇫🇷', style: TextStyle(fontSize: 24)),
                                title: 'Francés',
                                subtitle: 'En construcción',
                                enabled: false,
                                onTap: () => _showLockedDialog(context, 'Francés'),
                              ),
                              const SizedBox(height: 8),
                              _LanguageTile(
                                leading: const Text('🇩🇪', style: TextStyle(fontSize: 24)),
                                title: 'Alemán',
                                subtitle: 'En construcción',
                                enabled: false,
                                onTap: () => _showLockedDialog(context, 'Alemán'),
                              ),
                              const SizedBox(height: 8),
                              _LanguageTile(
                                leading: const Text('🇮🇹', style: TextStyle(fontSize: 24)),
                                title: 'Italiano',
                                subtitle: 'En construcción',
                                enabled: false,
                                onTap: () => _showLockedDialog(context, 'Italiano'),
                              ),
                              const SizedBox(height: 8),
                              _LanguageTile(
                                leading: const Text('🇵🇹', style: TextStyle(fontSize: 24)),
                                title: 'Portugués',
                                subtitle: 'En construcción',
                                enabled: false,
                                onTap: () => _showLockedDialog(context, 'Portugués'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            leading: leading,
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(color: enabled ? Colors.green : Colors.orange),
            ),
            trailing: Icon(
              enabled ? Icons.arrow_forward_ios_rounded : Icons.lock_outline_rounded,
              color: enabled ? AppColors.primary : Colors.grey[600],
              size: 18,
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;

  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}