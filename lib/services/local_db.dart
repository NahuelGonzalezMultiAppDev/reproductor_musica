// ignore_for_file: unused_import

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SongModel {
  final int? id;
  final String title;
  final String? artist;
  final String filePath;
  final int? durationMs;
  final DateTime addedAt;

  SongModel({
    this.id,
    required this.title,
    this.artist,
    required this.filePath,
    this.durationMs,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'artist': artist,
    'filePath': filePath,
    'durationMs': durationMs,
    'addedAt': addedAt.toIso8601String(),
  };

  factory SongModel.fromMap(Map<String, Object?> m) => SongModel(
    id: m['id'] as int?,
    title: m['title'] as String,
    artist: m['artist'] as String?,
    filePath: m['filePath'] as String,
    durationMs: m['durationMs'] as int?,
    addedAt: DateTime.parse(m['addedAt'] as String),
  );
}

class LocalDb {
  static LocalDb? _instance;
  static LocalDb get instance => _instance ??= LocalDb._internal();

  LocalDb._internal();

  Database? _db;
  final StreamController<List<SongModel>> _songsController =
      StreamController.broadcast();

  Stream<List<SongModel>> get songsStream => _songsController.stream;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final docs = await getApplicationDocumentsDirectory();
    final path = join(docs.path, 'reproductor.sqlite');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
        CREATE TABLE songs(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          artist TEXT,
          filePath TEXT NOT NULL,
          durationMs INTEGER,
          addedAt TEXT NOT NULL
        )
      ''');
      },
    );
    await _emitAllSongs();
    return _db!;
  }

  Future<void> _emitAllSongs() async {
    final db = await database;
    final rows = await db.query('songs', orderBy: 'addedAt DESC');
    final list = rows.map((r) => SongModel.fromMap(r)).toList();
    _songsController.add(list);
  }

  Future<int> insertSong(SongModel song) async {
    final db = await database;
    final id = await db.insert('songs', song.toMap());
    await _emitAllSongs();
    return id;
  }

  Future<int> deleteSong(int id) async {
    final db = await database;
    final count = await db.delete('songs', where: 'id = ?', whereArgs: [id]);
    await _emitAllSongs();
    return count;
  }

  Future<List<SongModel>> getAllSongs() async {
    final db = await database;
    final rows = await db.query('songs', orderBy: 'addedAt DESC');
    return rows.map((r) => SongModel.fromMap(r)).toList();
  }

  Future<void> close() async {
    await _songsController.close();
    await _db?.close();
  }
}
