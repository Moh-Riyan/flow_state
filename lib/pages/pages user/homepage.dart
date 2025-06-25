import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Logo
            Container(
              margin: EdgeInsets.only(bottom: 45),
              child: Image.asset('assets/logo.png', width: 70),
            ),

            // Image
            Container(
              margin: EdgeInsets.only(bottom: 50),
              child: Image.asset(
                'assets/images/lapangan bola.png',
                height: 210,
              ),
            ),

            // Welcome Text
            Text(
              'Selamat datang di Flow State!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Text(
              'Kami hadir untuk mempermudah Anda\nmelakukan pemesanan lapangan futsal\n'
              'dengan cepat dan praktis. Nikmati\n'
              'pengalaman olahraga terbaik dengan layanan\n'
              'yang kami tawarkan. Mari mulai perjalanan\n'
              'Anda bersama Flow State!',
              style: TextStyle(fontSize: 12, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Register Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup'); // Navigasi ke halaman Sign Up
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.white, width: 3),
                    ),
                  ),
                  child: Text('Daftar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 35),
                
                // Login Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login'); // Navigasi ke halaman Login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Masuk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
