import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CalidadAudio { baja, normal, alta, muyAlta }

final calidadProvider = StateProvider<CalidadAudio>((ref) => CalidadAudio.alta);

class CalidadScreen extends ConsumerStatefulWidget {
  const CalidadScreen({super.key});

  @override
  ConsumerState<CalidadScreen> createState() => _CalidadScreenState();
}

class _CalidadScreenState extends ConsumerState<CalidadScreen> {
  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('calidad_audio') ?? 2;
    ref.read(calidadProvider.notifier).state =
        CalidadAudio.values[index.clamp(0, 3)];
  }

  Future<void> _save(CalidadAudio calidad) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calidad_audio', calidad.index);
  }

  String _label(CalidadAudio c) {
    switch (c) {
      case CalidadAudio.baja:
        return 'Baja';
      case CalidadAudio.normal:
        return 'Normal';
      case CalidadAudio.alta:
        return 'Alta';
      case CalidadAudio.muyAlta:
        return 'Muy alta';
    }
  }

  String _desc(CalidadAudio c) {
    switch (c) {
      case CalidadAudio.baja:
        return '~96 kbps · Ahorra más batería y datos';
      case CalidadAudio.normal:
        return '~160 kbps · Equilibrio entre calidad y consumo';
      case CalidadAudio.alta:
        return '~320 kbps · Recomendado';
      case CalidadAudio.muyAlta:
        return 'Sin compresión · Mayor calidad posible';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final calidad = ref.watch(calidadProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: cs.onSurface),
            onPressed: () => Navigator.pop(context)),
        title: Text('Calidad de los medios',
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('CALIDAD DE REPRODUCCIÓN',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
          ),
          ...CalidadAudio.values.map((c) {
            final selected = calidad == c;
            return GestureDetector(
              onTap: () {
                ref.read(calidadProvider.notifier).state = c;
                _save(c);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: selected
                        ? cs.primary.withOpacity(0.15)
                        : cs.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: selected
                            ? cs.primary
                            : cs.onSurface.withOpacity(0.1),
                        width: selected ? 1.5 : 1)),
                child: Row(
                  children: [
                    Icon(Icons.graphic_eq,
                        color: selected
                            ? cs.primary
                            : cs.onSurface.withOpacity(0.4)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_label(c),
                              style: TextStyle(
                                  color: selected ? cs.primary : cs.onSurface,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(_desc(c),
                              style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.4),
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    if (selected) Icon(Icons.check_circle, color: cs.primary),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: cs.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12)),
            child: Text(
                'La calidad seleccionada se aplica a la reproducción de archivos de audio locales.',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
