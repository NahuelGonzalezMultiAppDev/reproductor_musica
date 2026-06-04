import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/library_provider.dart';
import '../services/database_helper.dart';
import '../services/music_database.dart';

class AcercaScreen extends ConsumerWidget {
  final AsyncValue<MusicLibrary> libraryAsync;
  const AcercaScreen({super.key, required this.libraryAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final library = libraryAsync.value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: cs.onSurface),
            onPressed: () => Navigator.pop(context)),
        title: Text('Acerca de y asistencia',
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                          colors: [cs.primary, cs.surface],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)),
                  child: Icon(Icons.music_note, color: cs.onPrimary, size: 40),
                ),
                const SizedBox(height: 12),
                Text('Reproductor de Música',
                    style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text('Versión 1.0.0',
                    style: TextStyle(color: cs.onSurface.withOpacity(0.4))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('ESTADÍSTICAS DE LA BIBLIOTECA', cs),
          if (library != null) ...[
            _StatRow(
                icon: Icons.music_note,
                label: 'Total de canciones',
                value: '${library.songs.length}',
                cs: cs),
            _StatRow(
                icon: Icons.person,
                label: 'Artistas',
                value: '${library.artists.length}',
                cs: cs),
            // _StatRow(
            // icon: Icons.album,
            // label: 'Álbumes',
            //value: '${library.albums.length}',
            //cs: cs),
            _StatRow(
                icon: Icons.favorite,
                label: 'Favoritas',
                value: '${library.songs.where((s) => s.isFavorite).length}',
                cs: cs),
            _StatRow(
                icon: Icons.playlist_play,
                label: 'Playlists',
                value: '${library.playlists.where((p) => !p.isSystem).length}',
                cs: cs),
            _StatRow(
                icon: Icons.bar_chart,
                label: 'Total reproducciones',
                value: library.songs.isEmpty
                    ? '0'
                    : '${library.songs.map((s) => s.playCount).reduce((a, b) => a + b)}',
                cs: cs),
          ],
          const SizedBox(height: 24),
          _SectionTitle('TECNOLOGÍAS', cs),
          _InfoRow(
              icon: Icons.flutter_dash,
              label: 'Framework',
              value: 'Flutter',
              cs: cs),
          _InfoRow(
              icon: Icons.storage,
              label: 'Base de datos',
              value: 'SQLite · sqflite',
              cs: cs),
          _InfoRow(
              icon: Icons.volume_up,
              label: 'Motor de audio',
              value: 'just_audio',
              cs: cs),
          _InfoRow(
              icon: Icons.code, label: 'Estado', value: 'Riverpod', cs: cs),
          const SizedBox(height: 24),
          _SectionTitle('MANTENIMIENTO', cs),
          _ActionTile(
              icon: Icons.refresh,
              title: 'Recargar biblioteca',
              subtitle: 'Vuelve a leer todos los datos de la base de datos',
              iconColor: cs.primary,
              cs: cs,
              onTap: () async {
                await ref.read(libraryProvider.notifier).build();
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Biblioteca recargada'),
                      backgroundColor: cs.primary));
              }),
          _ActionTile(
              icon: Icons.delete_sweep,
              title: 'Limpiar historial',
              subtitle: 'Resetea el contador de reproducciones a 0',
              iconColor: Colors.orangeAccent,
              cs: cs,
              onTap: () => _confirm(
                  context: context,
                  cs: cs,
                  title: 'Limpiar historial',
                  message: '¿Resetear el contador de reproducciones?',
                  onConfirm: () async {
                    final db = await DatabaseHelper.instance.database;
                    await db.rawUpdate('UPDATE songs SET play_count = 0');
                    await ref.read(libraryProvider.notifier).build();
                  })),
          _ActionTile(
              icon: Icons.delete_forever,
              title: 'Eliminar toda la biblioteca',
              subtitle: 'Borra todas las canciones de la base de datos',
              iconColor: Colors.redAccent,
              cs: cs,
              onTap: () => _confirm(
                  context: context,
                  cs: cs,
                  title: 'Eliminar biblioteca',
                  message: '¿Estás seguro? Se eliminarán todas las canciones.',
                  confirmLabel: 'Eliminar todo',
                  confirmColor: Colors.redAccent,
                  onConfirm: () async {
                    final db = await DatabaseHelper.instance.database;
                    await db.delete('playlist_songs');
                    await db
                        .rawDelete("DELETE FROM playlists WHERE is_system = 0");
                    await db.delete('songs');
                    await db.delete('artists');
                    await db.delete('albums');
                    await ref.read(libraryProvider.notifier).build();
                  })),
          const SizedBox(height: 24),
          _SectionTitle('LEGAL', cs),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: cs.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12)),
            child: Text(
                'Esta aplicación es de uso personal. Toda la música reproducida pertenece a sus respectivos autores. La app no sube ni comparte ningún archivo de audio ni dato personal.',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.5),
                    fontSize: 13,
                    height: 1.5)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _confirm({
    required BuildContext context,
    required ColorScheme cs,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmLabel = 'Confirmar',
    Color? confirmColor,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceVariant,
        title: Text(title, style: TextStyle(color: cs.onSurface)),
        content: Text(message,
            style: TextStyle(color: cs.onSurface.withOpacity(0.7))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.5)))),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                onConfirm();
              },
              child: Text(confirmLabel,
                  style: TextStyle(color: confirmColor ?? cs.primary))),
        ],
      ),
    );
  }
}

Widget _SectionTitle(String text, ColorScheme cs) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text,
        style: TextStyle(
            color: cs.onSurface.withOpacity(0.4),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2)));

Widget _StatRow(
        {required IconData icon,
        required String label,
        required String value,
        required ColorScheme cs}) =>
    Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: cs.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: TextStyle(color: cs.onSurface.withOpacity(0.7)))),
          Text(value,
              style:
                  TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
        ]));

Widget _InfoRow(
        {required IconData icon,
        required String label,
        required String value,
        required ColorScheme cs}) =>
    Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: cs.onSurface.withOpacity(0.4), size: 18),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: TextStyle(color: cs.onSurface.withOpacity(0.7)))),
          Text(value,
              style: TextStyle(
                  color: cs.onSurface.withOpacity(0.5), fontSize: 13)),
        ]));

Widget _ActionTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color iconColor,
  required ColorScheme cs,
  required VoidCallback onTap,
}) =>
    ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22)),
        title: Text(title, style: TextStyle(color: cs.onSurface)),
        subtitle: Text(subtitle,
            style:
                TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
        trailing:
            Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.2)),
        onTap: onTap);
