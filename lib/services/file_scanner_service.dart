import 'dart:io';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/audio_file.dart';

//Es un servicio: cuya responsabilidad es escanear el dispositivo en
//busca de archivos de música y devolverlos como una lista.
class FileScannerService{
  //Se crea una instancia privada. Este objeto es el que
  //realmente hace las consultas al SO para obtener las canciones.
  //Se declara como "final" porque no se va a reasignar.
  final OnAudioQuery _audioQuery = OnAudioQuery();

//Se define un metodo de tipo booleano para pedir los permisos.
  Future<bool> requestPermissions() async{
//Comprueba si la app está corriendo en Android.
    if(Platform.isAndroid){
      PermissionStatus status; //Declara una variable para guardar el resultado del permiso (puede ser: granted, denied, permanentlyDenied, etc.).
      
      //Solicita al usuario el permiso de audio (necesario en Android 13+ para acceder a archivos de música). 
      //El await pausa la ejecución hasta que el usuario responda el diálogo.
      status = await Permission.audio.request();
      if(status.isGranted) return true;
//Si el permiso de audio fue denegado (posiblemente Android 12 o anterior), 
//intenta pedir el permiso de almacenamiento como alternativa y devuelve si fue concedido o no.
      status = await Permission.storage.request();
      return status.isGranted;
    }
    //Si la app no está en Android, devuelve false.
    return false; 
  }
//Se define el metodo principal del servicio.
//devuelve una lista una lista de objetos AudioFile.
//Se dedica a casi todo: pide permisos, consulta las canciones
//y las convierte añ formato interno.
  Future<List<AudioFile>> scanSongs() async{
    //Llama al método anterior para obtener los permisos antes 
    //de intentar acceder al sistema de archivos.
    bool hasPermission = await requestPermissions();
//Si no se obtuvieron permisos, imprime un mensaje en consola y 
//devuelve una canción falsa (mock) en lugar de fallar con un error.
    if(!hasPermission){
      print("Permisos denegados. Devolviendo mock...");
      return _getMockSong(); 
    }

    try{
      //Llama al paquete on_audio_query para obtener todas las canciones del dispositivo.
      //SongModel es el tipo de datos que devuelve ese paquete.
      List<SongModel> songs = await _audioQuery.querySongs(
        sortType: null,  //No aplica ningún orden especial al resultado (usa el orden por defecto del sistema).
        orderType: OrderType.ASC_OR_SMALLER,  //Ordena los resultados de forma ascendente.
        uriType: UriType.EXTERNAL,  //Busca canciones en el almacenamiento externo (tarjeta SD o almacenamiento interno).
        ignoreCase: true,
      );

//Si la consulta no encontró ninguna canción 
//(dispositivo vacío o emulador), devuelve el mock en lugar de una lista vacía.
      if(songs.isEmpty){
        print("No se encontraron canciones reales. Devolviendo mock...");
        return _getMockSong();
      }
//Convierte cada SongModel (formato del paquete externo) a un AudioFile (formato interno de la app). 
      return songs.map((song) => AudioFile(
        title: song.title,
        path: song.data, 
        artist: song.artist ?? "<Desconocido>",
      )).toList();

    } catch (e){
      print("Error escaneando música: $e");
      return _getMockSong();
    }
  }
//Este metodo lo que hace es devolver una lista con una
//canción ficticia hardcodeada.
  List<AudioFile> _getMockSong(){
    return[
      //Crea un AudioFile con datos inventados.
      AudioFile(
        title: "Canción de Prueba (Mock)",
        path: "/ruta/falsa/cancion_mock.mp3",
        artist: "Artista Desconocido"
      )
    ];
  }
}
