import 'dart:io';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/audio_file.dart';

class FileScannerService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      PermissionStatus status;
      status = await Permission.audio.request();
      if (status.isGranted) return true;

      status = await Permission.storage.request();
      return status.isGranted;
    }
    return false; 
  }

  Future<List<AudioFile>> scanSongs() async {
    bool hasPermission = await requestPermissions();

    if (!hasPermission) {
      print("Permisos denegados. Devolviendo mock...");
      return _getMockSong(); 
    }

    try {
      List<SongModel> songs = await _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      if (songs.isEmpty) {
        print("No se encontraron canciones reales. Devolviendo mock...");
        return _getMockSong();
      }

      return songs.map((song) => AudioFile(
        title: song.title,
        path: song.data, 
        artist: song.artist ?? "<Desconocido>",
      )).toList();

    } catch (e) {
      print("Error escaneando música: $e");
      return _getMockSong();
    }
  }

  List<AudioFile> _getMockSong() {
    return [
      AudioFile(
        title: "Canción de Prueba (Mock)",
        path: "/ruta/falsa/cancion_mock.mp3",
        artist: "Artista Desconocido"
      )
    ];
  }
}