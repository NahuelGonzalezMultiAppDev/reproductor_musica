import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/local_db.dart';

final localDbProvider = Provider<LocalDb>((ref) {
  final db = LocalDb.instance;
  ref.onDispose(() => db.close());
  return db;
});

final songsStreamProvider = StreamProvider.autoDispose<List<SongModel>>((ref) {
  final db = ref.watch(localDbProvider);
  return db.songsStream;
});

class SongsNotifier extends StateNotifier<AsyncValue<List<SongModel>>> {
  SongsNotifier(this.read) : super(const AsyncValue.loading()) {
    _listen();
  }
  final Reader read;
  StreamSubscription<List<SongModel>>? _sub;

  void _listen() {
    _sub = read.songsStream.listen((list) {
      state = AsyncValue.data(list);
    }, onError: (e, st) => state = AsyncValue.error(e, st));
  }

  Future<void> addSong(SongModel song) async {
    try {
      await read.insertSong(song);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeSong(int id) async {
    await read.deleteSong(id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

class Reader {
  get songsStream => null;

  Future<void> insertSong(SongModel song) async {}

  Future<void> deleteSong(int id) async {}
}

final songsNotifierProvider =
    StateNotifierProvider.autoDispose<
      SongsNotifier,
      AsyncValue<List<SongModel>>
    >((ref) => SongsNotifier(ref.read as Reader));
