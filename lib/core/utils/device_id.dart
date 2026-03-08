import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceId {
  static const _key = 'sigetu_device_id';

  /// Devuelve el device_id persistente del dispositivo.
  /// Si no existe aún, lo genera y lo guarda.
  static Future<String> get() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) return existing;
    final newId = const Uuid().v4();
    await prefs.setString(_key, newId);
    return newId;
  }
}
