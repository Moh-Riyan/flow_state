import 'package:flow_state/pages/pages%20user/homepage.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo di dalam lingkaran putih
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(20),
              child: Image.asset('assets/logo.png'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Flow State',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Kadwa',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
