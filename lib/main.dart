import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flow_state/pages/pages user/login_page.dart'; 
import 'package:flow_state/pages/pages user/signup_page.dart';
import 'package:flow_state/pages/pages utama/beranda_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // wajib untuk async init
  await initializeDateFormatting('id_ID', null); // inisialisasi lokal Indonesia
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flow State',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/signup': (context) => SignUpPage(),
        '/login': (context) => LoginPage(),
        '/beranda': (context) => Beranda(),
      },
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!) {
          return LoginPage(); // Jika belum login, tampilkan halaman login
        } else {
          return Beranda(); // Jika sudah login, tampilkan halaman beranda
        }
      },
    );
  }

  Future<bool> _isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token'); // Ambil token yang disimpan
    return token != null && token.isNotEmpty; // Periksa apakah token ada
  }
}






// import 'package:flow_state/pages/pages%20user/SplashScreen.dart';
// // Splash Screen
// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SplashScreen(), // Menampilkan PembayaranBerhasil saat aplikasi dijalankan
//     );
//   }
// }