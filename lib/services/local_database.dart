import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_helper.dart';
import '../services/music_database.dart';

final localDatabaseProvider = FutureProvider<MusicLibrary>((ref) async {
  // Asegura que la base de datos está abierta
  await DatabaseHelper.instance.database;
  // Carga todos los datos
  return MusicDatabase.loadAll();
});
