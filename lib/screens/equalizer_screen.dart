import 'package:flutter/material.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  bool enabled = false;

  final List<double> bands = [0, 0, 0, 0, 0];

  final List<String> labels = [
    "60Hz",
    "230Hz",
    "910Hz",
    "3.6kHz",
    "14kHz",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031F21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF031F21),
        elevation: 0,
        title: const Text("Ecualizador"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Ajustes de sonido",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
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
                          "Habilitar ecualizador",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          enabled
                              ? "Ecualizador activado"
                              : "Ecualizador desactivado",
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: enabled,
                    onChanged: (value) {
                      setState(() {
                        enabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.graphic_eq),
                label: const Text(
                  "Abrir ecualizador del sistema",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
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
            const SizedBox(height: 12),
            const Text(
              "También podés acceder al ecualizador del sistema de tu dispositivo para ajustes adicionales.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Perfil actual: Normal",
              style: TextStyle(
                color: Color(0xFF63D8BE),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
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
                  (index) => Column(
                    children: [
                      const Text(
                        "+0 dB",
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Slider(
                            value: bands[index],
                            min: -12,
                            max: 12,
                            onChanged: enabled
                                ? (value) {
                                    setState(() {
                                      bands[index] = value;
                                    });
                                  }
                                : null,
                          ),
                        ),
                      ),
                      Text(
                        labels[index],
                        style: const TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  for (int i = 0; i < bands.length; i++) {
                    bands[i] = 0;
                  }
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Resetear bandas"),
            ),
          ],
        ),
      ),
    );
  }
}
