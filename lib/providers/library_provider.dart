import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/album.dart';
import '../models/artist.dart';
import '../models/genre.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/music_database.dart';

class LibraryNotifier extends Notifier<MusicLibrary> {
  @override
  MusicLibrary build() => MusicDatabase.seed();

  void toggleFavorite(String songId) {
    final updated = [
      for (final s in state.songs)
        if (s.id == songId) s.copyWith(isFavorite: !s.isFavorite) else s,
    ];
    state = state.copyWith(songs: updated, playlists: _refreshFavorites(updated));
  }

  void incrementPlayCount(String songId) {
    final updated = [
      for (final s in state.songs)
        if (s.id == songId) s.copyWith(playCount: s.playCount + 1) else s,
    ];
    state = state.copyWith(songs: updated);
  }

  void createPlaylist(String name, {String? description}) {
    final playlist = Playlist(
      id: 'p_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      description: description,
      songIds: const [],
      createdAt: DateTime.now(),
    );
    state = state.copyWith(playlists: [...state.playlists, playlist]);
  }

  void deletePlaylist(String playlistId) {
    state = state.copyWith(
      playlists: state.playlists
          .where((p) => p.id != playlistId && !p.isSystem)
          .toList(),
    );
  }

  void addSongToPlaylist(String playlistId, String songId) {
    final updated = [
      for (final p in state.playlists)
        if (p.id == playlistId && !p.songIds.contains(songId))
          p.copyWith(songIds: [...p.songIds, songId])
        else
          p,
    ];
    state = state.copyWith(playlists: updated);
  }

  void removeSongFromPlaylist(String playlistId, String songId) {
    final updated = [
      for (final p in state.playlists)
        if (p.id == playlistId)
          p.copyWith(songIds: p.songIds.where((id) => id != songId).toList())
        else
          p,
    ];
    state = state.copyWith(playlists: updated);
  }

  List<Playlist> _refreshFavorites(List<Song> songs) {
    final favIds = songs.where((s) => s.isFavorite).map((s) => s.id).toList();
    return [
      for (final p in state.playlists)
        if (p.id == 'p_favorites') p.copyWith(songIds: favIds) else p,
    ];
  }
}

final libraryProvider =
    NotifierProvider<LibraryNotifier, MusicLibrary>(LibraryNotifier.new);

final allSongsProvider = Provider<List<Song>>(
  (ref) => ref.watch(libraryProvider).songs,
);

final allArtistsProvider = Provider<List<Artist>>(
  (ref) => ref.watch(libraryProvider).artists,
);

final allAlbumsProvider = Provider<List<Album>>(
  (ref) => ref.watch(libraryProvider).albums,
);

final allPlaylistsProvider = Provider<List<Playlist>>(
  (ref) => ref.watch(libraryProvider).playlists,
);

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<List<Song>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final songs = ref.watch(allSongsProvider);
  return MusicDatabase.searchSongs(songs, query);
});

final selectedGenreProvider = StateProvider<Genre?>((ref) => null);

final selectedYearProvider = StateProvider<int?>((ref) => null);

final songSortProvider =
    StateProvider<SongSortBy>((ref) => SongSortBy.title);

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
