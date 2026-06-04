import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioService {
  final AndroidEqualizer equalizer = AndroidEqualizer();

  late final AudioPlayer player = AudioPlayer(
    audioPipeline: AudioPipeline(
      androidAudioEffects: [equalizer],
    ),
  );

  Map<int, int>? _freqToBandIndex;

  // ─── Reproducción ─────────────────────────────────────────────────────────

  Future<void> play(String path, {String? title, String? artist}) async {
    final source = path.startsWith('http')
        ? AudioSource.uri(
            Uri.parse(path),
            tag: MediaItem(
              id: path,
              title: title ?? 'Canción',
              artist: artist ?? 'Desconocido',
            ),
          )
        : AudioSource.file(
            path,
            tag: MediaItem(
              id: path,
              title: title ?? 'Canción local',
              artist: artist ?? 'Local',
            ),
          );

    await player.setAudioSource(source);
    await player.play();

    await Future.delayed(const Duration(milliseconds: 300));
    await equalizer.setEnabled(true);
    await _buildFreqMap();
  }

  Future<void> pause() async => await player.pause();
  Future<void> stop() async => await player.stop();

  void dispose() {
    player.dispose();
  }

  // ─── Streams ──────────────────────────────────────────────────────────────

  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;

  // ─── Ecualizador ──────────────────────────────────────────────────────────

  Future<void> _buildFreqMap() async {
    if (_freqToBandIndex != null) return;
    final parameters = await equalizer.parameters;
    _freqToBandIndex = {};
    for (final band in parameters.bands) {
      final freqHz = band.centerFrequency.round();
      _freqToBandIndex![freqHz] = band.index;
    }
  }

  Future<void> setEqualizerEnabled(bool enabled) async {
    await equalizer.setEnabled(enabled);
  }

  /// Aplica un gain en dB a una banda por índice.
  /// just_audio espera el valor directamente en dB (no en miliBels).
  Future<void> setBandGain({
    required int bandIndex,
    required double valueDb,
  }) async {
    final parameters = await equalizer.parameters;
    final bands = parameters.bands;
    if (bandIndex < 0 || bandIndex >= bands.length) return;

    // Clamp al rango real del dispositivo
    final minDb = parameters.minDecibels;
    final maxDb = parameters.maxDecibels;
    final clamped = valueDb.clamp(minDb, maxDb);

    await bands[bandIndex].setGain(clamped);
  }

  /// Aplica un mapa de { "60Hz": 4.0, "1kHz": -2.0, ... } al EQ.
  /// Busca la banda más cercana a cada frecuencia pedida.
  Future<void> applyEqualizerValues(Map<String, double> values) async {
    await _buildFreqMap();
    if (_freqToBandIndex == null || _freqToBandIndex!.isEmpty) return;

    final parameters = await equalizer.parameters;
    final bands = parameters.bands;
    final minDb = parameters.minDecibels;
    final maxDb = parameters.maxDecibels;

    for (final entry in values.entries) {
      final targetHz = _parseFreqLabel(entry.key);
      if (targetHz == null) continue;

      // Buscar la banda más cercana en frecuencia
      int? closestBandIndex;
      int minDiff = 999999;
      for (final freqEntry in _freqToBandIndex!.entries) {
        final diff = (freqEntry.key - targetHz).abs();
        if (diff < minDiff) {
          minDiff = diff;
          closestBandIndex = freqEntry.value;
        }
      }

      if (closestBandIndex == null || closestBandIndex >= bands.length)
        continue;

      final clamped = entry.value.clamp(minDb, maxDb);
      await bands[closestBandIndex].setGain(clamped);
    }
  }

  /// Devuelve las bandas reales del dispositivo con su etiqueta y gain actual.
  Future<List<MapEntry<String, double>>> getRealBands() async {
    await _buildFreqMap();
    final parameters = await equalizer.parameters;
    return parameters.bands.map((band) {
      final label = _formatFreqLabel(band.centerFrequency.round());
      return MapEntry(label, band.gain); // gain ya viene en dB
    }).toList();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  int? _parseFreqLabel(String label) {
    final lower = label.toLowerCase().trim();
    if (lower.endsWith('khz')) {
      final num = double.tryParse(lower.replaceAll('khz', ''));
      return num != null ? (num * 1000).round() : null;
    } else if (lower.endsWith('hz')) {
      return int.tryParse(lower.replaceAll('hz', ''));
    }
    return null;
  }

  String _formatFreqLabel(int hz) {
    if (hz >= 1000) {
      final k = hz / 1000.0;
      return k == k.roundToDouble()
          ? '${k.round()}kHz'
          : '${k.toStringAsFixed(1)}kHz';
    }
    return '${hz}Hz';
  }
}
