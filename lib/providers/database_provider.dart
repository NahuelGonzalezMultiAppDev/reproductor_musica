import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_helper.dart';

/// Proveedor global del DatabaseHelper (singleton).
final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});
