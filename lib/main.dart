import 'package:flow_state/pages/pages%20user/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flow_state/pages/pages%20user/login_page.dart'; 
import 'package:flow_state/pages/pages%20user/signup_page.dart';
import 'package:flow_state/pages/pages%20utama/beranda_page.dart';
import 'package:flow_state/pages/pages%20user/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flow State',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // [MODIFIKASI] Jadikan SplashScreen sebagai halaman awal aplikasi
      home: const SplashScreen(),
      // Definisikan semua rute untuk navigasi yang bersih
      routes: {
        '/welcome': (context) => HomePage(), // Halaman selamat datang
        '/signup': (context) => SignUpPage(),
        '/login': (context) => LoginPage(),
        '/beranda': (context) => const Beranda(),
      },
    );
  }
}

// [DIHAPUS] Kelas HomePage yang berisi FutureBuilder dihapus dari sini.
// Logikanya akan dipindahkan ke SplashScreen.