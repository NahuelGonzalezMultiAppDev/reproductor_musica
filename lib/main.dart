import 'package:audio_service/audio_service.dart' as bg;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/main_navigation_screen.dart';
import 'services/audio_handler.dart';
import 'services/audio_service.dart';
import 'services/database_helper.dart';
import 'providers/player_provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AudioPlayerHandler handler;
  try {
    handler = await bg.AudioService.init<AudioPlayerHandler>(
      builder: () => AudioPlayerHandler(),
      config: const bg.AudioServiceConfig(
        androidNotificationChannelId:
            'com.example.reproductor_musica.channel.audio',
        androidNotificationChannelName: 'Reproducción de música',
        androidNotificationOngoing: true,
        androidShowNotificationBadge: true,
      ),
    );
  } catch (_) {
    // Si el servicio de background falla, la app igual funciona sin notificación
    handler = AudioPlayerHandler();
  }

  final playerService = PlayerAudioService(handler);

  await DatabaseHelper.instance.database;

  runApp(ProviderScope(
    overrides: [
      audioHandlerProvider.overrideWithValue(handler),
      audioServiceProvider.overrideWith((ref) {
        ref.onDispose(() => playerService.dispose());
        return playerService;
      }),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reproductor',
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F5F5),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFF5F5F5),
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.black45,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.tealAccent,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0B0B1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0B0B1A),
          selectedItemColor: Colors.purpleAccent,
          unselectedItemColor: Colors.white70,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
