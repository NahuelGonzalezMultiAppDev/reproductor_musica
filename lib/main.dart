import 'package:flutter/material.dart';
import 'models/audio_file.dart';
import 'services/file_scanner_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends MaterialApp {
  const MyApp({super.key}) : super(home: const PantallaPrueba(), debugShowCheckedModeBanner: false);
}

class PantallaPrueba extends StatefulWidget {
  const PantallaPrueba({super.key});

  @override
  State<PantallaPrueba> createState() => _PantallaPruebaState();
}

class _PantallaPruebaState extends State<PantallaPrueba> {
  final FileScannerService _scanner = FileScannerService();
  List<AudioFile> _canciones = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _probarEscaner();
  }

  Future<void> _probarEscaner() async {
    // 1. Llamamos a tu servicio
    final canciones = await _scanner.scanSongs();
    
    // 2. Actualizamos la pantalla con el resultado
    setState(() {
      _canciones = canciones;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi prueba de Archivos')),
      body: _cargando 
        ? const Center(child: CircularProgressIndicator()) // Muestra un circulito mientras escanea
        : ListView.builder(
            itemCount: _canciones.length,
            itemBuilder: (context, index) {
              final cancion = _canciones[index];
              return ListTile(
                leading: const Icon(Icons.audio_file, color: Colors.purple),
                title: Text(cancion.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Ruta: ${cancion.path}"),
              );
            },
          ),
    );
  }
}