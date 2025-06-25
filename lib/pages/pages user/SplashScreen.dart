import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow_state/pages/pages%20utama/beranda_page.dart';
import 'package:flow_state/pages/pages%20user/homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// [MODIFIKASI] Menggunakan SingleTickerProviderStateMixin untuk animasi yang lebih kompleks di masa depan (praktik yang baik)
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  
  // [TAMBAHAN] Variabel untuk mengontrol state animasi
  double _logoScale = 0.5;
  double _logoOpacity = 0.0;
  double _textOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Memulai seluruh proses, termasuk animasi dan navigasi
    _startAnimationAndNavigate();
  }

  Future<void> _startAnimationAndNavigate() async {
    // 1. Mulai animasi logo setelah jeda singkat
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _logoScale = 1.0;
      _logoOpacity = 1.0;
    });

    // 2. Mulai animasi teks sedikit lebih lambat untuk efek berurutan
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _textOpacity = 1.0;
    });
    
    // 3. Setelah animasi selesai, tunggu sebentar lalu navigasi
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    _checkLoginStatusAndNavigate();
  }

  Future<void> _checkLoginStatusAndNavigate() async {
    // Pastikan widget masih ada di tree sebelum navigasi
    if (!mounted) return;

    // Cek apakah pengguna sudah login
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final bool isLoggedIn = token != null && token.isNotEmpty;

    // Arahkan ke halaman yang sesuai
    if (isLoggedIn) {
      // Jika sudah login, langsung ke halaman utama (Beranda)
      Navigator.pushReplacementNamed(context, '/beranda');
    } else {
      // Jika belum login, ke halaman selamat datang (HomePage)
      Navigator.pushReplacement(
        context,
        // [MODIFIKASI] Menambahkan transisi fade yang halus antar halaman
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // [MODIFIKASI] Bungkus logo dengan widget animasi
            AnimatedScale(
              scale: _logoScale,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: _logoOpacity,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                child: Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(20),
                  child: Image.asset('assets/logo.png'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // [MODIFIKASI] Bungkus teks dengan widget animasi
            AnimatedOpacity(
              opacity: _textOpacity,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              child: const Text(
                'Flow State',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Kadwa',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}