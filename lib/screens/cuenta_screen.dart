import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final usernameProvider = StateProvider<String>((ref) => 'Usuario');

class CuentaScreen extends ConsumerStatefulWidget {
  const CuentaScreen({super.key});

  @override
  ConsumerState<CuentaScreen> createState() => _CuentaScreenState();
}

class _CuentaScreenState extends ConsumerState<CuentaScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(usernameProvider));
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('username') ?? 'Usuario';
    ref.read(usernameProvider.notifier).state = saved;
    _controller.text = saved;
  }

  Future<void> _saveUsername(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', value);
    ref.read(usernameProvider.notifier).state = value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final username = ref.watch(usernameProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Cuenta',
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: cs.primary.withOpacity(0.2),
              child: Text(username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: TextStyle(
                      color: cs.primary,
                      fontSize: 40,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
          Text('Nombre de usuario',
              style: TextStyle(
                  color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              filled: true,
              fillColor: cs.surfaceVariant.withOpacity(0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.check, color: cs.primary),
                onPressed: () async {
                  await _saveUsername(_controller.text.trim());
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Nombre guardado'),
                      backgroundColor: cs.primary,
                      duration: const Duration(seconds: 2),
                    ));
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: cs.onSurface.withOpacity(0.4), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                      'Tu nombre se guarda localmente en el dispositivo.',
                      style: TextStyle(
                          color: cs.onSurface.withOpacity(0.5), fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
