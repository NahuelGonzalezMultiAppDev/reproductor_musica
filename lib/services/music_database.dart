import '../models/album.dart';
import '../models/artist.dart';
import '../models/genre.dart';
import '../models/playlist.dart';
import '../models/song.dart';

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
  static MusicLibrary seed() {
    final now = DateTime(2026, 4, 20);

    final artists = <Artist>[
      const Artist(id: 'a1', name: 'The Weeknd'),
      const Artist(id: 'a2', name: 'Bad Bunny'),
      const Artist(id: 'a3', name: 'Taylor Swift'),
      const Artist(id: 'a4', name: 'Arctic Monkeys'),
      const Artist(id: 'a5', name: 'Daft Punk'),
      const Artist(id: 'a6', name: 'Kendrick Lamar'),
    ];

    final albums = <Album>[
      const Album(
        id: 'al1',
        title: 'After Hours',
        artist: 'The Weeknd',
        year: 2020,
        genre: Genre.rnb,
      ),
      const Album(
        id: 'al2',
        title: 'Un Verano Sin Ti',
        artist: 'Bad Bunny',
        year: 2022,
        genre: Genre.reggaeton,
      ),
      const Album(
        id: 'al3',
        title: 'Midnights',
        artist: 'Taylor Swift',
        year: 2022,
        genre: Genre.pop,
      ),
      const Album(
        id: 'al4',
        title: 'AM',
        artist: 'Arctic Monkeys',
        year: 2013,
        genre: Genre.rock,
      ),
      const Album(
        id: 'al5',
        title: 'Random Access Memories',
        artist: 'Daft Punk',
        year: 2013,
        genre: Genre.electronic,
      ),
      const Album(
        id: 'al6',
        title: 'DAMN.',
        artist: 'Kendrick Lamar',
        year: 2017,
        genre: Genre.hipHop,
      ),
    ];

    final songs = <Song>[
      Song(
        id: 's1',
        title: 'Blinding Lights',
        path: '/storage/emulated/0/Music/blinding_lights.mp3',
        artist: 'The Weeknd',
        album: 'After Hours',
        genre: Genre.rnb,
        year: 2020,
        duration: const Duration(minutes: 3, seconds: 20),
        trackNumber: 9,
        dateAdded: now.subtract(const Duration(days: 3)),
        playCount: 42,
        isFavorite: true,
      ),
      Song(
        id: 's2',
        title: 'Save Your Tears',
        path: '/storage/emulated/0/Music/save_your_tears.mp3',
        artist: 'The Weeknd',
        album: 'After Hours',
        genre: Genre.rnb,
        year: 2020,
        duration: const Duration(minutes: 3, seconds: 35),
        trackNumber: 11,
        dateAdded: now.subtract(const Duration(days: 3)),
        playCount: 18,
      ),
      Song(
        id: 's3',
        title: 'Tití Me Preguntó',
        path: '/storage/emulated/0/Music/titi_me_pregunto.mp3',
        artist: 'Bad Bunny',
        album: 'Un Verano Sin Ti',
        genre: Genre.reggaeton,
        year: 2022,
        duration: const Duration(minutes: 4, seconds: 3),
        trackNumber: 6,
        dateAdded: now.subtract(const Duration(days: 10)),
        playCount: 57,
        isFavorite: true,
      ),
      Song(
        id: 's4',
        title: 'Me Porto Bonito',
        path: '/storage/emulated/0/Music/me_porto_bonito.mp3',
        artist: 'Bad Bunny',
        album: 'Un Verano Sin Ti',
        genre: Genre.reggaeton,
        year: 2022,
        duration: const Duration(minutes: 2, seconds: 58),
        trackNumber: 2,
        dateAdded: now.subtract(const Duration(days: 10)),
        playCount: 31,
      ),
      Song(
        id: 's5',
        title: 'Anti-Hero',
        path: '/storage/emulated/0/Music/anti_hero.mp3',
        artist: 'Taylor Swift',
        album: 'Midnights',
        genre: Genre.pop,
        year: 2022,
        duration: const Duration(minutes: 3, seconds: 20),
        trackNumber: 3,
        dateAdded: now.subtract(const Duration(days: 1)),
        playCount: 25,
        isFavorite: true,
      ),
      Song(
        id: 's6',
        title: 'Lavender Haze',
        path: '/storage/emulated/0/Music/lavender_haze.mp3',
        artist: 'Taylor Swift',
        album: 'Midnights',
        genre: Genre.pop,
        year: 2022,
        duration: const Duration(minutes: 3, seconds: 22),
        trackNumber: 1,
        dateAdded: now.subtract(const Duration(days: 1)),
        playCount: 12,
      ),
      Song(
        id: 's7',
        title: 'Do I Wanna Know?',
        path: '/storage/emulated/0/Music/do_i_wanna_know.mp3',
        artist: 'Arctic Monkeys',
        album: 'AM',
        genre: Genre.rock,
        year: 2013,
        duration: const Duration(minutes: 4, seconds: 32),
        trackNumber: 1,
        dateAdded: now.subtract(const Duration(days: 60)),
        playCount: 74,
        isFavorite: true,
      ),
      Song(
        id: 's8',
        title: 'R U Mine?',
        path: '/storage/emulated/0/Music/r_u_mine.mp3',
        artist: 'Arctic Monkeys',
        album: 'AM',
        genre: Genre.rock,
        year: 2013,
        duration: const Duration(minutes: 3, seconds: 21),
        trackNumber: 3,
        dateAdded: now.subtract(const Duration(days: 60)),
        playCount: 22,
      ),
      Song(
        id: 's9',
        title: 'Get Lucky',
        path: '/storage/emulated/0/Music/get_lucky.mp3',
        artist: 'Daft Punk',
        album: 'Random Access Memories',
        genre: Genre.electronic,
        year: 2013,
        duration: const Duration(minutes: 6, seconds: 8),
        trackNumber: 8,
        dateAdded: now.subtract(const Duration(days: 120)),
        playCount: 65,
        isFavorite: true,
      ),
      Song(
        id: 's10',
        title: 'Instant Crush',
        path: '/storage/emulated/0/Music/instant_crush.mp3',
        artist: 'Daft Punk',
        album: 'Random Access Memories',
        genre: Genre.electronic,
        year: 2013,
        duration: const Duration(minutes: 5, seconds: 37),
        trackNumber: 5,
        dateAdded: now.subtract(const Duration(days: 120)),
        playCount: 40,
      ),
      Song(
        id: 's11',
        title: 'HUMBLE.',
        path: '/storage/emulated/0/Music/humble.mp3',
        artist: 'Kendrick Lamar',
        album: 'DAMN.',
        genre: Genre.hipHop,
        year: 2017,
        duration: const Duration(minutes: 2, seconds: 57),
        trackNumber: 5,
        dateAdded: now.subtract(const Duration(days: 30)),
        playCount: 88,
        isFavorite: true,
      ),
      Song(
        id: 's12',
        title: 'DNA.',
        path: '/storage/emulated/0/Music/dna.mp3',
        artist: 'Kendrick Lamar',
        album: 'DAMN.',
        genre: Genre.hipHop,
        year: 2017,
        duration: const Duration(minutes: 3, seconds: 5),
        trackNumber: 2,
        dateAdded: now.subtract(const Duration(days: 30)),
        playCount: 29,
      ),
    ];

    final playlists = <Playlist>[
      Playlist(
        id: 'p_favorites',
        name: 'Me gusta',
        description: 'Tus canciones favoritas',
        songIds: songs.where((s) => s.isFavorite).map((s) => s.id).toList(),
        createdAt: now.subtract(const Duration(days: 365)),
        isSystem: true,
      ),
      Playlist(
        id: 'p1',
        name: 'Rock Clásico',
        description: 'Guitarras y potencia',
        songIds: const ['s7', 's8'],
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      Playlist(
        id: 'p2',
        name: 'Para entrenar',
        description: 'Ritmo alto, energía arriba',
        songIds: const ['s1', 's3', 's11', 's4'],
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Playlist(
        id: 'p3',
        name: 'Chill Vibes',
        songIds: const ['s5', 's6', 's10'],
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ];

    return MusicLibrary(
      songs: songs,
      artists: artists,
      albums: albums,
      playlists: playlists,
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
