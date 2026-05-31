import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final autoplayProvider = StateProvider<bool>((ref) => true);
final reproduccionSinPausasProvider = StateProvider<bool>((ref) => false);
final shuffleDefaultProvider = StateProvider<bool>((ref) => false);
final repeatDefaultProvider = StateProvider<bool>((ref) => false);

class ReproduccionScreen extends ConsumerStatefulWidget {
  const ReproduccionScreen({super.key});

  @override
  ConsumerState<ReproduccionScreen> createState() => _ReproduccionScreenState();
}

class _ReproduccionScreenState extends ConsumerState<ReproduccionScreen> {
  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    ref.read(autoplayProvider.notifier).state =
        prefs.getBool('autoplay') ?? true;
    ref.read(reproduccionSinPausasProvider.notifier).state =
        prefs.getBool('sin_pausas') ?? false;
    ref.read(shuffleDefaultProvider.notifier).state =
        prefs.getBool('shuffle_default') ?? false;
    ref.read(repeatDefaultProvider.notifier).state =
        prefs.getBool('repeat_default') ?? false;
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final autoplay = ref.watch(autoplayProvider);
    final sinPausas = ref.watch(reproduccionSinPausasProvider);
    final shuffleDefault = ref.watch(shuffleDefaultProvider);
    final repeatDefault = ref.watch(repeatDefaultProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: cs.onSurface),
            onPressed: () => Navigator.pop(context)),
        title: Text('Reproducción',
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          _SectionHeader('GENERAL', cs),
          _SwitchTile(
              icon: Icons.play_circle_outline,
              title: 'Autoplay',
              subtitle:
                  'Continuar reproduciendo canciones similares al terminar la lista',
              value: autoplay,
              cs: cs,
              onChanged: (v) {
                ref.read(autoplayProvider.notifier).state = v;
                _save('autoplay', v);
              }),
          _SwitchTile(
              icon: Icons.all_inclusive,
              title: 'Reproducción sin pausas',
              subtitle: 'Elimina el silencio entre canciones',
              value: sinPausas,
              cs: cs,
              onChanged: (v) {
                ref.read(reproduccionSinPausasProvider.notifier).state = v;
                _save('sin_pausas', v);
              }),
          Divider(color: cs.onSurface.withOpacity(0.1)),
          _SectionHeader('AL INICIAR', cs),
          _SwitchTile(
              icon: Icons.shuffle,
              title: 'Shuffle por defecto',
              subtitle: 'Activar mezcla aleatoria al abrir la app',
              value: shuffleDefault,
              cs: cs,
              onChanged: (v) {
                ref.read(shuffleDefaultProvider.notifier).state = v;
                _save('shuffle_default', v);
              }),
          _SwitchTile(
              icon: Icons.repeat,
              title: 'Repetir por defecto',
              subtitle: 'Activar repetición al abrir la app',
              value: repeatDefault,
              cs: cs,
              onChanged: (v) {
                ref.read(repeatDefaultProvider.notifier).state = v;
                _save('repeat_default', v);
              }),
        ],
      ),
    );
  }
}

Widget _SectionHeader(String text, ColorScheme cs) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(text,
        style: TextStyle(
            color: cs.onSurface.withOpacity(0.4),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2)));

Widget _SwitchTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required bool value,
  required ColorScheme cs,
  required ValueChanged<bool> onChanged,
}) =>
    ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: cs.onSurface.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: cs.onSurface.withOpacity(0.7), size: 22)),
      title: Text(title, style: TextStyle(color: cs.onSurface)),
      subtitle: Text(subtitle,
          style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
      trailing:
          Switch(value: value, activeColor: cs.primary, onChanged: onChanged),
    );
