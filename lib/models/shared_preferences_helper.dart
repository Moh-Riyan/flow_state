import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _keyNoIdentitas = 'no_identitas';

  static Future<void> saveNoIdentitas(String noIdentitas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNoIdentitas, noIdentitas);
    print("No Identitas disimpan: $noIdentitas");
  }

  static Future<String> getNoIdentitas() async {
    final prefs = await SharedPreferences.getInstance();
    String? noIdentitas = prefs.getString(_keyNoIdentitas);
    print("No identitas yang diambil: $noIdentitas");
    return noIdentitas ?? '';
  }

  static Future<void> removeNoIdentitas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyNoIdentitas);
    print("No Identitas dihapus");
  }
}
