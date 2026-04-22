import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';

final audioProvider = Provider<AudioService>((ref) {
  return AudioService();
});
