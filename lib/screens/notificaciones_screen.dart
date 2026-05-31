import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notifControlesProvider = StateProvider<bool>((ref) => true);
final notifCancionProvider = StateProvider<bool>((ref) => true);

class NotificacionesScreen extends ConsumerStatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  ConsumerState<NotificacionesScreen> createState() =>
      _NotificacionesScreenState();
}

class _NotificacionesScreenState extends ConsumerState<NotificacionesScreen> {
  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    ref.read(notifControlesProvider.notifier).state =
        prefs.getBool('notif_controles') ?? true;
    ref.read(notifCancionProvider.notifier).state =
        prefs.getBool('notif_cancion') ?? true;
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final controles = ref.watch(notifControlesProvider);
    final cancion = ref.watch(notifCancionProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: cs.onSurface),
            onPressed: () => Navigator.pop(context)),
        title: Text('Notificaciones',
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text('PANTALLA DE BLOQUEO',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
          ),
          ListTile(
            leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: cs.onSurface.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.lock_outline,
                    color: cs.onSurface.withOpacity(0.7), size: 22)),
            title: Text('Controles de reproducción',
                style: TextStyle(color: cs.onSurface)),
            subtitle: Text(
                'Mostrar play, pausa y skip en la pantalla de bloqueo',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
            trailing: Switch(
                value: controles,
                activeColor: cs.primary,
                onChanged: (v) {
                  ref.read(notifControlesProvider.notifier).state = v;
                  _save('notif_controles', v);
                }),
          ),
          ListTile(
            leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: cs.onSurface.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.music_note,
                    color: cs.onSurface.withOpacity(0.7), size: 22)),
            title: Text('Nombre de la canción',
                style: TextStyle(color: cs.onSurface)),
            subtitle: Text('Mostrar título y artista en la notificación',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
            trailing: Switch(
                value: cancion,
                activeColor: cs.primary,
                onChanged: (v) {
                  ref.read(notifCancionProvider.notifier).state = v;
                  _save('notif_cancion', v);
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
                'Los controles de reproducción aparecen en la barra de notificaciones mientras hay una canción activa.',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
