import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final modoAhorroProvider = StateProvider<bool>((ref) => false);
final modoOfflineProvider = StateProvider<bool>((ref) => false);

class AhorroDatosScreen extends ConsumerStatefulWidget {
  const AhorroDatosScreen({super.key});

  @override
  ConsumerState<AhorroDatosScreen> createState() => _AhorroDatosScreenState();
}

class _AhorroDatosScreenState extends ConsumerState<AhorroDatosScreen> {
  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    ref.read(modoAhorroProvider.notifier).state =
        prefs.getBool('modo_ahorro') ?? false;
    ref.read(modoOfflineProvider.notifier).state =
        prefs.getBool('modo_offline') ?? false;
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ahorro = ref.watch(modoAhorroProvider);
    final offline = ref.watch(modoOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: cs.onSurface),
            onPressed: () => Navigator.pop(context)),
        title: Text('Ahorro de datos',
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text('DATOS MÓVILES',
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
                child: Icon(Icons.data_saver_on,
                    color: cs.onSurface.withOpacity(0.7), size: 22)),
            title: Text('Modo ahorro de datos',
                style: TextStyle(color: cs.onSurface)),
            subtitle: Text('Reduce el consumo de datos al mínimo',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
            trailing: Switch(
                value: ahorro,
                activeColor: cs.primary,
                onChanged: (v) {
                  ref.read(modoAhorroProvider.notifier).state = v;
                  _save('modo_ahorro', v);
                }),
          ),
          Divider(color: cs.onSurface.withOpacity(0.1)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text('OFFLINE',
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
                child: Icon(Icons.wifi_off,
                    color: cs.onSurface.withOpacity(0.7), size: 22)),
            title: Text('Modo offline', style: TextStyle(color: cs.onSurface)),
            subtitle: Text(
                'Reproduce solo canciones guardadas en el dispositivo',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
            trailing: Switch(
                value: offline,
                activeColor: cs.primary,
                onChanged: (v) {
                  ref.read(modoOfflineProvider.notifier).state = v;
                  _save('modo_offline', v);
                }),
          ),
          if (offline)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.primary.withOpacity(0.3))),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: cs.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(
                          'Modo offline activo. Solo se reproducen archivos locales.',
                          style: TextStyle(color: cs.primary, fontSize: 13))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
