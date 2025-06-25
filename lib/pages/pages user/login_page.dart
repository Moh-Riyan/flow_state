import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow_state/pages/pages%20user/homepage.dart'; // Impor HomePage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _clearPaymentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pesananAktif');
    print("Riwayat pembayaran lokal telah dihapus untuk login baru.");
  }

  void _submitLogin() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email dan Password tidak boleh kosong'), backgroundColor: Colors.red),
      );
      return;
    }

    final String apiUrl = 'https://flowstate.my.id/api/konsumen/login';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> responseBody = json.decode(response.body);
      final String status = (responseBody['status'] ?? '').toString().toLowerCase().trim();

      if (status == 'success') {
        final accessToken = responseBody['access_token'];
        await _clearPaymentHistory();
        await _saveAccessToken(accessToken);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login berhasil!'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacementNamed(context, '/beranda');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal: ${responseBody['message'] ?? 'Terjadi kesalahan'}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _saveAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        // [MODIFIKASI] Aksi tombol kembali diubah
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            // Gunakan Navigator.pushReplacement untuk memastikan kembali ke HomePage
            // Ini akan mengganti halaman login dengan HomePage, memberikan alur yang bersih
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Masuk',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            // Email Field
            TextField(
              controller: _emailController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            // Password Field
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock, color: Colors.white),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 150),
            // Login Button
            ElevatedButton(
              onPressed: _submitLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 90, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Masuk', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 170),
            // Link to Sign Up
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Belum punya akun? ',
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text('Daftar', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}