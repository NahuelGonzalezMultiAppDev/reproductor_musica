import '../models/album.dart';
import '../models/artist.dart';
import '../models/genre.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import 'database_helper.dart';

enum SongSortBy { title, artist, album, dateAdded, playCount, duration, year }

enum SortOrder { ascending, descending }

class MusicLibrary {
  final List<Song> songs;
  final List<Artist> artists;
  final List<Album> albums;
  final List<Playlist> playlists;

  const MusicLibrary({
    required this.songs,
    required this.artists,
    required this.albums,
    required this.playlists,
  });

  static const empty = MusicLibrary(
    songs: [],
    artists: [],
    albums: [],
    playlists: [],
  );

  MusicLibrary copyWith({
    List<Song>? songs,
    List<Artist>? artists,
    List<Album>? albums,
    List<Playlist>? playlists,
  }) {
    return MusicLibrary(
      songs: songs ?? this.songs,
      artists: artists ?? this.artists,
      albums: albums ?? this.albums,
      playlists: playlists ?? this.playlists,
    );
  }
}

class MusicDatabase {
  static Future<MusicLibrary> loadAll() async {
    final db = DatabaseHelper.instance;
    final results = await Future.wait([
      db.getSongs(),
      db.getArtists(),
      db.getAlbums(),
      db.getPlaylists(),
    ]);
    return MusicLibrary(
      songs: results[0] as List<Song>,
      artists: results[1] as List<Artist>,
      albums: results[2] as List<Album>,
      playlists: results[3] as List<Playlist>,
    );
  }

  static List<Song> searchSongs(List<Song> songs, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return songs;
    return songs.where((s) {
      return s.title.toLowerCase().contains(q) ||
          (s.artist?.toLowerCase().contains(q) ?? false) ||
          (s.album?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  static List<Song> songsByArtist(List<Song> songs, String artist) {
    return songs.where((s) => s.artist == artist).toList();
  }

  static List<Song> songsByAlbum(List<Song> songs, String album) {
    final list = songs.where((s) => s.album == album).toList()
      ..sort(
        (a, b) => (a.trackNumber ?? 0).compareTo(b.trackNumber ?? 0),
      );
    return list;
  }

  static List<Song> songsByGenre(List<Song> songs, Genre genre) {
    return songs.where((s) => s.genre == genre).toList();
  }

  static List<Song> songsByYear(List<Song> songs, int year) {
    return songs.where((s) => s.year == year).toList();
  }

  static List<Song> favorites(List<Song> songs) {
    return songs.where((s) => s.isFavorite).toList();
  }

  static List<Song> recentlyAdded(List<Song> songs, {int limit = 20}) {
    final list = [...songs]
      ..sort((a, b) {
        final da = a.dateAdded ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = b.dateAdded ?? DateTime.fromMillisecondsSinceEpoch(0);
        return db.compareTo(da);
      });
    return list.take(limit).toList();
  }

  static List<Song> mostPlayed(List<Song> songs, {int limit = 20}) {
    final list = [...songs]..sort((a, b) => b.playCount.compareTo(a.playCount));
    return list.take(limit).toList();
  }

  static List<Song> sort(
    List<Song> songs,
    SongSortBy by, {
    SortOrder order = SortOrder.ascending,
  }) {
    final list = [...songs];
    int cmp(Song a, Song b) {
      switch (by) {
        case SongSortBy.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SongSortBy.artist:
          return (a.artist ?? '').toLowerCase().compareTo(
                (b.artist ?? '').toLowerCase(),
              );
        case SongSortBy.album:
          return (a.album ?? '').toLowerCase().compareTo(
                (b.album ?? '').toLowerCase(),
              );
        case SongSortBy.dateAdded:
          final da = a.dateAdded ?? DateTime.fromMillisecondsSinceEpoch(0);
          final db = b.dateAdded ?? DateTime.fromMillisecondsSinceEpoch(0);
          return da.compareTo(db);
        case SongSortBy.playCount:
          return a.playCount.compareTo(b.playCount);
        case SongSortBy.duration:
          final da = a.duration?.inSeconds ?? 0;
          final db = b.duration?.inSeconds ?? 0;
          return da.compareTo(db);
        case SongSortBy.year:
          return (a.year ?? 0).compareTo(b.year ?? 0);
      }
    }

    list.sort(cmp);
    if (order == SortOrder.descending) {
      return list.reversed.toList();
    }
    return list;
  }

  static List<Song> songsInPlaylist(List<Song> songs, Playlist playlist) {
    final byId = {for (final s in songs) s.id: s};
    return [
      for (final id in playlist.songIds)
        if (byId[id] != null) byId[id]!,
    ];
  }

  static Set<Genre> availableGenres(List<Song> songs) {
    return {for (final s in songs) if (s.genre != null) s.genre!};
  }

  static Set<int> availableYears(List<Song> songs) {
    return {for (final s in songs) if (s.year != null) s.year!};
  }
}
