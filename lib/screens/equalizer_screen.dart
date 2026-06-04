import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  bool enabled = false;
  String currentProfile = 'Normal';

  List<double> bands = [0, 0, 0, 0, 0];

  final List<String> labels = ['60Hz', '230Hz', '910Hz', '3.6kHz', '14kHz'];

  // 8 perfiles de ecualización
  final Map<String, List<double>> profiles = {
    'Normal': [0, 0, 0, 0, 0],
    'Rock': [4, 2, 0, 2, 4],
    'Pop': [0, 2, 4, 2, 0],
    'Jazz': [3, 1, 0, 1, 3],
    'Clásica': [4, 3, 0, 2, 4],
    'Bass': [6, 4, 0, -2, -4],
    'Vocal': [-2, 0, 4, 4, 2],
    'Dance': [5, 3, -1, 2, 4],
  };

  void _applyProfile(String name) {
    setState(() {
      currentProfile = name;
      bands = List<double>.from(profiles[name]!);
    });
  }

  void _resetBands() {
    setState(() {
      for (int i = 0; i < bands.length; i++) {
        bands[i] = 0;
      }
      currentProfile = 'Normal';
    });
  }

  Future<void> _openSystemEqualizer() async {
    try {
      const intent = AndroidIntent(
        action: 'android.media.action.DISPLAY_AUDIO_EFFECT_CONTROL_PANEL',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'No se pudo abrir el ecualizador del sistema. '
              'Tu dispositivo puede no tenerlo disponible.',
            ),
            backgroundColor: const Color(0xFF07373B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  String get _displayProfile {
    final current = profiles[currentProfile];
    if (current == null) return 'Personalizado';
    for (int i = 0; i < bands.length; i++) {
      if ((bands[i] - current[i]).abs() > 0.01) return 'Personalizado';
    }
    return currentProfile;
  }

  @override
  Widget build(BuildContext context) {
    final profileNames = profiles.keys.toList();
    // Ancho de cada chip: 4 visibles a la vez con padding
    final double chipWidth = (MediaQuery.of(context).size.width - 32 - 30) / 4;

    return Scaffold(
      backgroundColor: const Color(0xFF031F21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF031F21),
        elevation: 0,
        title: const Text('Ecualizador'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Ajustes de sonido',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),

            // Toggle habilitar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF07373B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Habilitar ecualizador',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          enabled
                              ? 'Ecualizador activado'
                              : 'Ecualizador desactivado',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: enabled,
                    activeColor: const Color(0xFF63D8BE),
                    onChanged: (value) => setState(() => enabled = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Botón ecualizador del sistema
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _openSystemEqualizer,
                icon: const Icon(Icons.graphic_eq),
                label: const Text(
                  'Abrir ecualizador del sistema',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF63D8BE),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Accedé al ecualizador nativo de tu dispositivo para ajustes adicionales.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),

            // Perfil actual
            Text(
              'Perfil actual: $_displayProfile',
              style: const TextStyle(
                color: Color(0xFF63D8BE),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Sliders de bandas
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF07373B),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  bands.length,
                  (index) => Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${bands[index] >= 0 ? '+' : ''}${bands[index].toStringAsFixed(0)} dB',
                          style: TextStyle(
                            fontSize: 11,
                            color: bands[index] != 0
                                ? const Color(0xFF63D8BE)
                                : Colors.white54,
                            fontWeight: bands[index] != 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: enabled
                                    ? const Color(0xFF63D8BE)
                                    : Colors.white24,
                                inactiveTrackColor:
                                    Colors.white.withOpacity(0.1),
                                thumbColor: enabled
                                    ? const Color(0xFF63D8BE)
                                    : Colors.white30,
                                overlayColor:
                                    const Color(0xFF63D8BE).withOpacity(0.2),
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8),
                              ),
                              child: Slider(
                                value: bands[index],
                                min: -12,
                                max: 12,
                                onChanged: enabled
                                    ? (value) {
                                        setState(() {
                                          bands[index] = double.parse(
                                              value.toStringAsFixed(0));
                                        });
                                      }
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          labels[index],
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Perfiles: scroll horizontal, 4 visibles a la vez, solo nombre
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: profileNames.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final name = profileNames[index];
                  final isSelected = currentProfile == name &&
                      _displayProfile != 'Personalizado';
                  return GestureDetector(
                    onTap: enabled ? () => _applyProfile(name) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: chipWidth,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF63D8BE).withOpacity(0.2)
                            : const Color(0xFF07373B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF63D8BE)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF63D8BE)
                              : enabled
                                  ? Colors.white
                                  : Colors.white38,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Botón resetear
            Center(
              child: TextButton.icon(
                onPressed: _resetBands,
                icon: const Icon(Icons.refresh, color: Color(0xFF63D8BE)),
                label: const Text(
                  'Resetear bandas',
                  style: TextStyle(color: Color(0xFF63D8BE)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
