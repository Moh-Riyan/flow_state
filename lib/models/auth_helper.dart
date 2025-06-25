import 'package:shared_preferences/shared_preferences.dart';

// Fungsi untuk menyimpan token setelah login
Future<void> saveAccessToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('access_token', token);
}

// Fungsi untuk mengambil token yang disimpan
Future<String?> getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
}

// Fungsi untuk menghapus token (misalnya untuk logout)
Future<void> removeAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('access_token');
}

Future<String?> getNoIdentitas() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('no_identitas');
}
