import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/library_provider.dart';
import '../providers/theme_provider.dart';
import '../services/music_database.dart';
import 'cuenta_screen.dart';
import 'reproduccion_screen.dart';
import 'notificaciones_screen.dart';
import 'ahorro_datos_screen.dart';
import 'calidad_screen.dart';
import 'acerca_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Configuración',
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Tema rápido ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(isDark ? Icons.dark_mode : Icons.light_mode,
                        color: Colors.amberAccent, size: 20),
                    const SizedBox(width: 10),
                    Text(isDark ? 'Tema oscuro' : 'Tema claro',
                        style: TextStyle(color: cs.onSurface)),
                  ],
                ),
                Switch(
                  value: isDark,
                  activeColor: cs.primary,
                  onChanged: (v) {
                    ref.read(themeProvider.notifier).state =
                        v ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ],
            ),
          ),
          Divider(color: cs.onSurface.withOpacity(0.1)),

          // ── Secciones ────────────────────────────────────────────────────
          _SettingsItem(
            icon: Icons.person_outline,
            title: 'Cuenta',
            subtitle: 'Nombre de usuario • Perfil',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CuentaScreen())),
          ),
          _SettingsItem(
            icon: Icons.volume_up_outlined,
            title: 'Reproducción',
            subtitle: 'Autoplay • Reproducción sin pausas',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReproduccionScreen())),
          ),
          _SettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Controles en pantalla de bloqueo',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificacionesScreen())),
          ),
          _SettingsItem(
            icon: Icons.download_outlined,
            title: 'Ahorro de datos',
            subtitle: 'Modo ahorro • Reproducción offline',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AhorroDatosScreen())),
          ),
          _SettingsItem(
            icon: Icons.bar_chart,
            title: 'Calidad de los medios',
            subtitle: 'Calidad de reproducción de audio',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CalidadScreen())),
          ),
          _SettingsItem(
            icon: Icons.info_outline,
            title: 'Acerca de y asistencia',
            subtitle: 'Versión • Estadísticas • Privacidad',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AcercaScreen(libraryAsync: libraryAsync))),
          ),

          Divider(color: cs.onSurface.withOpacity(0.1)),

          // ── Biblioteca ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('BIBLIOTECA',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
          ),
          Consumer(builder: (context, ref, _) {
            final sortBy = ref.watch(songSortProvider);
            final sortOrder = ref.watch(sortOrderProvider);
            return Column(
              children: [
                _SettingsItem(
                  icon: Icons.sort_by_alpha,
                  title: 'Ordenar canciones por',
                  subtitle: _sortLabel(sortBy),
                  onTap: () => _showSortDialog(context, ref, sortBy),
                ),
                _SettingsItem(
                  icon: sortOrder == SortOrder.ascending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  title: 'Orden',
                  subtitle: sortOrder == SortOrder.ascending
                      ? 'Ascendente (A → Z)'
                      : 'Descendente (Z → A)',
                  onTap: () {
                    ref.read(sortOrderProvider.notifier).state =
                        sortOrder == SortOrder.ascending
                            ? SortOrder.descending
                            : SortOrder.ascending;
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _sortLabel(SongSortBy sort) {
    switch (sort) {
      case SongSortBy.title:
        return 'Título';
      case SongSortBy.artist:
        return 'Artista';
      case SongSortBy.album:
        return 'Álbum';
      case SongSortBy.dateAdded:
        return 'Fecha agregada';
      case SongSortBy.playCount:
        return 'Más reproducidas';
      case SongSortBy.duration:
        return 'Duración';
      case SongSortBy.year:
        return 'Año';
    }
  }

  void _showSortDialog(
      BuildContext context, WidgetRef ref, SongSortBy current) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceVariant,
        title: Text('Ordenar por', style: TextStyle(color: cs.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SongSortBy.values
              .map((sort) => RadioListTile<SongSortBy>(
                    value: sort,
                    groupValue: current,
                    activeColor: cs.primary,
                    title: Text(_sortLabel(sort),
                        style: TextStyle(color: cs.onSurface)),
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(songSortProvider.notifier).state = v;
                        Navigator.pop(ctx);
                      }
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: cs.onSurface.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: cs.onSurface.withOpacity(0.7), size: 22),
      ),
      title: Text(title,
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
      trailing: Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.2)),
      onTap: onTap,
    );
  }
}
