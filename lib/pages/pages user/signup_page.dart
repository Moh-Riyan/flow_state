import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow_state/models/user.dart'; // Pastikan untuk mengimpor model User

// Fungsi untuk menyimpan no_identitas
Future<void> saveNoIdentitas(String noIdentitas) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('no_identitas', noIdentitas);
}

// Fungsi untuk mengambil no_identitas
Future<String?> getNoIdentitas() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('no_identitas');
}

// Fungsi untuk menghapus no_identitas
Future<void> removeNoIdentitas() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('no_identitas');
}

// Fungsi untuk menangani registrasi pengguna
Future<void> registerUser(User user, BuildContext context) async {
  final String apiUrl = 'https://flowstate.my.id/api/konsumen/register';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(user.toJson()),
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);
    final String status = (responseBody['status'] ?? '').toString().toLowerCase().trim();

    if (status == 'success') {
      final String noIdentitas = responseBody['no_identitas'] ?? ''; // Ambil no_identitas dari response

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrasi berhasil. Silakan login.'),
          backgroundColor: Colors.green,
        ),
      );

      // Simpan no_identitas ke SharedPreferences setelah registrasi berhasil
      await saveNoIdentitas(noIdentitas); // Menggunakan helper

      await Future.delayed(Duration(seconds: 1));
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrasi gagal: ${responseBody['message'] ?? 'Terjadi kesalahan'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Terjadi error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Widget SignUpPage untuk registrasi pengguna
class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscureText = true;
  String? _phoneError, _emailError, _nameError, _passwordError;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Fungsi dengan validasi lengkap
  void _submitRegistration() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text;

    setState(() {
      _nameError = null;
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
    });

    if (name.isEmpty) {
      setState(() => _nameError = 'Nama tidak boleh kosong');
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError = 'Email tidak valid');
      return;
    }

    // Validasi nomor telepon (harus diisi dan maksimal 12 angka)
    if (phone.isEmpty || phone.length != 12 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      setState(() => _phoneError = 'harus 12 angka');
      return;
    }

    if (password.length < 8) {
      setState(() => _passwordError = 'Password minimal 8 karakter');
      return;
    }

    User newUser = User(
      noIdentitas: phone,
      nama: name,
      email: email,
      noTelepon: phone,
      password: password,
    );

    // Panggil fungsi registerUser yang sudah ada
    registerUser(newUser, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20),
              alignment: Alignment.centerLeft,
              child: Text(
                'Daftar',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            // Nama input field
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nama',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Colors.white),
              ),
            ),
            if (_nameError != null) 
              Text(_nameError!, style: TextStyle(color: Colors.red, fontSize: 12)),

            SizedBox(height: 20),
            // Email input field
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
            if (_emailError != null)
              Text(_emailError!, style: TextStyle(color: Colors.red, fontSize: 12)),

            SizedBox(height: 20),
            // No Telepon input field
            TextField(
              controller: _phoneController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'No.Telpon',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone, color: Colors.white),
              ),
            ),
            if (_phoneError != null) 
              Text(_phoneError!, style: TextStyle(color: Colors.red, fontSize: 12)),

            SizedBox(height: 20),
            // Password input field
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
            if (_passwordError != null) 
              Text(_passwordError!, style: TextStyle(color: Colors.red, fontSize: 12)),

            SizedBox(height: 60),
            ElevatedButton(
              onPressed: _submitRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 90, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Daftar',
                style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 120),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[ 
                Text('Sudah punya akun? ', style: TextStyle(color: Colors.white)),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    'Masuk',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
