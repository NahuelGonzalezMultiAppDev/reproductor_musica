import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:flutter_riverpod/legacy.dart';

import '../models/album.dart';
import '../models/artist.dart';
import '../models/genre.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/database_helper.dart';
import '../services/music_database.dart';

class LibraryNotifier extends AsyncNotifier<MusicLibrary> {
  DatabaseHelper get _db => DatabaseHelper.instance;

  @override
  Future<MusicLibrary> build() => MusicDatabase.loadAll();

  MusicLibrary? get _current => state.value;

  Future<void> addSong(Song song) async {
    await _db.insertSong(song);
    final lib = _current;
    if (lib == null) return;
    state = AsyncData(lib.copyWith(songs: [...lib.songs, song]));
  }

  Future<void> removeSong(String songId) async {
    await _db.deleteSong(songId);
    final lib = _current;
    if (lib == null) return;
    state = AsyncData(lib.copyWith(
      songs: lib.songs.where((s) => s.id != songId).toList(),
      playlists: [
        for (final p in lib.playlists)
          p.copyWith(songIds: p.songIds.where((id) => id != songId).toList()),
      ],
    ));
  }

  Future<void> toggleFavorite(String songId) async {
    final lib = _current;
    if (lib == null) return;
    final song = lib.songs.where((s) => s.id == songId).firstOrNull;
    if (song == null) return;
    final newValue = !song.isFavorite;
    await _db.setSongFavorite(songId, newValue);

    final updatedSongs = [
      for (final s in lib.songs)
        if (s.id == songId) s.copyWith(isFavorite: newValue) else s,
    ];
    state = AsyncData(lib.copyWith(
      songs: updatedSongs,
      playlists: _refreshFavorites(lib.playlists, updatedSongs),
    ));
  }

  Future<void> incrementPlayCount(String songId) async {
    await _db.incrementSongPlayCount(songId);
    final lib = _current;
    if (lib == null) return;
    state = AsyncData(lib.copyWith(
      songs: [
        for (final s in lib.songs)
          if (s.id == songId) s.copyWith(playCount: s.playCount + 1) else s,
      ],
    ));
  }

  Future<void> createPlaylist(String name, {String? description}) async {
    final playlist = Playlist(
      id: 'p_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      description: description,
      songIds: const [],
      createdAt: DateTime.now(),
    );
    await _db.insertPlaylist(playlist);
    final lib = _current;
    if (lib == null) return;
    state = AsyncData(lib.copyWith(playlists: [...lib.playlists, playlist]));
  }

  Future<void> deletePlaylist(String playlistId) async {
    final lib = _current;
    if (lib == null) return;
    final target = lib.playlists.where((p) => p.id == playlistId).firstOrNull;
    if (target == null || target.isSystem) return;
    await _db.deletePlaylist(playlistId);
    state = AsyncData(lib.copyWith(
      playlists: lib.playlists.where((p) => p.id != playlistId).toList(),
    ));
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    await _db.addSongToPlaylist(playlistId, songId);
    final lib = _current;
    if (lib == null) return;
    state = AsyncData(lib.copyWith(
      playlists: [
        for (final p in lib.playlists)
          if (p.id == playlistId && !p.songIds.contains(songId))
            p.copyWith(songIds: [...p.songIds, songId])
          else
            p,
      ],
    ));
  }

  Future<void> removeSongFromPlaylist(
    String playlistId,
    String songId,
  ) async {
    await _db.removeSongFromPlaylist(playlistId, songId);
    final lib = _current;
    if (lib == null) return;
    state = AsyncData(lib.copyWith(
      playlists: [
        for (final p in lib.playlists)
          if (p.id == playlistId)
            p.copyWith(songIds: p.songIds.where((id) => id != songId).toList())
          else
            p,
      ],
    ));
  }

  List<Playlist> _refreshFavorites(
    List<Playlist> playlists,
    List<Song> songs,
  ) {
    final favIds = songs.where((s) => s.isFavorite).map((s) => s.id).toList();
    return [
      for (final p in playlists)
        if (p.id == 'p_favorites') p.copyWith(songIds: favIds) else p,
    ];
  }
}

final libraryProvider =
    AsyncNotifierProvider<LibraryNotifier, MusicLibrary>(LibraryNotifier.new);

MusicLibrary _libOrEmpty(Ref ref) =>
    ref.watch(libraryProvider).value ?? MusicLibrary.empty;

final allSongsProvider = Provider<List<Song>>((ref) => _libOrEmpty(ref).songs);

final allArtistsProvider =
    Provider<List<Artist>>((ref) => _libOrEmpty(ref).artists);

final allAlbumsProvider =
    Provider<List<Album>>((ref) => _libOrEmpty(ref).albums);

final allPlaylistsProvider =
    Provider<List<Playlist>>((ref) => _libOrEmpty(ref).playlists);

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<List<Song>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final songs = ref.watch(allSongsProvider);
  return MusicDatabase.searchSongs(songs, query);
});

final selectedGenreProvider = StateProvider<Genre?>((ref) => null);

final selectedYearProvider = StateProvider<int?>((ref) => null);

final songSortProvider = StateProvider<SongSortBy>((ref) => SongSortBy.title);

final sortOrderProvider =
    StateProvider<SortOrder>((ref) => SortOrder.ascending);

final filteredSongsProvider = Provider<List<Song>>((ref) {
  var songs = ref.watch(allSongsProvider);
  final query = ref.watch(searchQueryProvider);
  final genre = ref.watch(selectedGenreProvider);
  final year = ref.watch(selectedYearProvider);
  final sortBy = ref.watch(songSortProvider);
  final order = ref.watch(sortOrderProvider);

  if (query.isNotEmpty) songs = MusicDatabase.searchSongs(songs, query);
  if (genre != null) songs = MusicDatabase.songsByGenre(songs, genre);
  if (year != null) songs = MusicDatabase.songsByYear(songs, year);
  return MusicDatabase.sort(songs, sortBy, order: order);
});

final favoritesProvider = Provider<List<Song>>(
  (ref) => MusicDatabase.favorites(ref.watch(allSongsProvider)),
);

final recentlyAddedProvider = Provider<List<Song>>(
  (ref) => MusicDatabase.recentlyAdded(ref.watch(allSongsProvider)),
);

final mostPlayedProvider = Provider<List<Song>>(
  (ref) => MusicDatabase.mostPlayed(ref.watch(allSongsProvider)),
);

final songsByArtistProvider =
    Provider.family<List<Song>, String>((ref, artistName) {
  return MusicDatabase.songsByArtist(ref.watch(allSongsProvider), artistName);
});

final songsByAlbumProvider =
    Provider.family<List<Song>, String>((ref, albumTitle) {
  return MusicDatabase.songsByAlbum(ref.watch(allSongsProvider), albumTitle);
});

final songsByGenreProvider = Provider.family<List<Song>, Genre>((ref, genre) {
  return MusicDatabase.songsByGenre(ref.watch(allSongsProvider), genre);
});

final songsInPlaylistProvider =
    Provider.family<List<Song>, String>((ref, playlistId) {
  final playlist = ref
      .watch(allPlaylistsProvider)
      .where((p) => p.id == playlistId)
      .firstOrNull;
  if (playlist == null) return const [];
  return MusicDatabase.songsInPlaylist(ref.watch(allSongsProvider), playlist);
});

final availableGenresProvider = Provider<Set<Genre>>(
  (ref) => MusicDatabase.availableGenres(ref.watch(allSongsProvider)),
);

final availableYearsProvider = Provider<Set<int>>(
  (ref) => MusicDatabase.availableYears(ref.watch(allSongsProvider)),
);
