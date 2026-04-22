import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/album.dart';
import '../models/artist.dart';
import '../models/playlist.dart';
import '../models/song.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'reproductor.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE artists (
        id          TEXT PRIMARY KEY,
        name        TEXT NOT NULL,
        image_path  TEXT,
        bio         TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE albums (
        id          TEXT PRIMARY KEY,
        title       TEXT NOT NULL,
        artist      TEXT NOT NULL,
        year        INTEGER,
        cover_path  TEXT,
        genre       TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE songs (
        id            TEXT PRIMARY KEY,
        title         TEXT NOT NULL,
        path          TEXT NOT NULL UNIQUE,
        artist        TEXT,
        album         TEXT,
        genre         TEXT,
        year          INTEGER,
        duration_ms   INTEGER,
        artwork       TEXT,
        track_number  INTEGER,
        date_added    INTEGER,
        play_count    INTEGER NOT NULL DEFAULT 0,
        is_favorite   INTEGER NOT NULL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE playlists (
        id           TEXT PRIMARY KEY,
        name         TEXT NOT NULL,
        description  TEXT,
        cover_path   TEXT,
        created_at   INTEGER NOT NULL,
        is_system    INTEGER NOT NULL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE playlist_songs (
        playlist_id  TEXT NOT NULL,
        song_id      TEXT NOT NULL,
        position     INTEGER NOT NULL,
        PRIMARY KEY (playlist_id, song_id),
        FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
        FOREIGN KEY (song_id)     REFERENCES songs(id)     ON DELETE CASCADE
      );
    ''');

    await db.execute(
      'CREATE INDEX idx_songs_artist ON songs(artist);',
    );
    await db.execute(
      'CREATE INDEX idx_songs_album ON songs(album);',
    );
    await db.execute(
      'CREATE INDEX idx_songs_genre ON songs(genre);',
    );
    await db.execute(
      'CREATE INDEX idx_songs_favorite ON songs(is_favorite);',
    );
    await db.execute(
      'CREATE INDEX idx_playlist_songs_position ON playlist_songs(playlist_id, position);',
    );

    await db.insert('playlists', {
      'id': 'p_favorites',
      'name': 'Me gusta',
      'description': 'Tus canciones favoritas',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'is_system': 1,
    });
  }

  Future<List<Song>> getSongs() async {
    final db = await database;
    final rows = await db.query('songs');
    return rows.map(Song.fromMap).toList();
  }

  Future<List<Artist>> getArtists() async {
    final db = await database;
    final rows = await db.query('artists');
    return rows.map(Artist.fromMap).toList();
  }

  Future<List<Album>> getAlbums() async {
    final db = await database;
    final rows = await db.query('albums');
    return rows.map(Album.fromMap).toList();
  }

  Future<List<Playlist>> getPlaylists() async {
    final db = await database;
    final playlists = await db.query('playlists');
    final junctions = await db.query(
      'playlist_songs',
      orderBy: 'playlist_id, position',
    );
    final byPlaylist = <String, List<String>>{};
    for (final row in junctions) {
      final pid = row['playlist_id'] as String;
      final sid = row['song_id'] as String;
      (byPlaylist[pid] ??= []).add(sid);
    }
    return playlists
        .map((row) => Playlist.fromMap(row, byPlaylist[row['id']] ?? const []))
        .toList();
  }

  Future<void> insertSong(Song song) async {
    final db = await database;
    await db.insert(
      'songs',
      song.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSong(String songId) async {
    final db = await database;
    await db.delete('songs', where: 'id = ?', whereArgs: [songId]);
  }

  Future<void> setSongFavorite(String songId, bool isFavorite) async {
    final db = await database;
    await db.update(
      'songs',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [songId],
    );
  }

  Future<void> incrementSongPlayCount(String songId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE songs SET play_count = play_count + 1 WHERE id = ?',
      [songId],
    );
  }

  Future<void> insertArtist(Artist artist) async {
    final db = await database;
    await db.insert(
      'artists',
      artist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertAlbum(Album album) async {
    final db = await database;
    await db.insert(
      'albums',
      album.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPlaylist(Playlist playlist) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'playlists',
        playlist.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.delete(
        'playlist_songs',
        where: 'playlist_id = ?',
        whereArgs: [playlist.id],
      );
      for (var i = 0; i < playlist.songIds.length; i++) {
        await txn.insert('playlist_songs', {
          'playlist_id': playlist.id,
          'song_id': playlist.songIds[i],
          'position': i,
        });
      }
    });
  }

  Future<void> deletePlaylist(String playlistId) async {
    final db = await database;
    await db.delete('playlists', where: 'id = ?', whereArgs: [playlistId]);
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final db = await database;
    final existing = await db.query(
      'playlist_songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
      limit: 1,
    );
    if (existing.isNotEmpty) return;
    final maxRow = await db.rawQuery(
      'SELECT COALESCE(MAX(position), -1) AS max_pos FROM playlist_songs WHERE playlist_id = ?',
      [playlistId],
    );
    final nextPos = (maxRow.first['max_pos'] as int) + 1;
    await db.insert('playlist_songs', {
      'playlist_id': playlistId,
      'song_id': songId,
      'position': nextPos,
    });
  }

  Future<void> removeSongFromPlaylist(
    String playlistId,
    String songId,
  ) async {
    final db = await database;
    await db.delete(
      'playlist_songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );
  }
}
