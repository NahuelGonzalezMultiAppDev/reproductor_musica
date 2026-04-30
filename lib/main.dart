import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/main_navigation_screen.dart';
import 'services/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa la base de datos antes de arrancar la UI
  await DatabaseHelper.instance.database;

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reproductor',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.tealAccent,
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}
