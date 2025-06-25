// file: profile.dart

import 'dart:convert';
import 'package:flow_state/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flow_state/pages/topup/fsmoney.dart';
import 'package:flow_state/pages/pages user/homepage.dart' as userpage;


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, String> userProfile = {
    'name': 'Loading...',
    'email': 'Loading...',
    'phone': 'Loading...',
    'balance': '0.0',
  };

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    // ... (Fungsi ini tidak ada perubahan)
    final String? accessToken = await getAccessToken();

    if (accessToken == null) {
      print('Token tidak ditemukan, pastikan user sudah login!');
      // Jika token tidak ada, langsung arahkan ke halaman awal
      if (mounted) {
         Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => userpage.HomePage()),
          (Route<dynamic> route) => false,
        );
      }
      return;
    }

    final response = await http.get(
      Uri.parse('https://flowstate.my.id/api/profile'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Data dari API: $data');

      if (data['status'] == 'success') {
        setState(() {
          userProfile = {
            'name': data['data']['nama'],
            'email': data['data']['email'],
            'phone': data['data']['no_telepon'],
            'balance': data['data']['saldo'],
          };
          isLoading = false;
        });
      } else {
        print('Gagal mengambil data profil: ${data['message']}');
        setState(() { isLoading = false; });
      }
    } else {
      print('Gagal mengambil data profil');
       setState(() { isLoading = false; });
    }
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // == FUNGSI BARU UNTUK LOGOUT ==
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      print("Token tidak ditemukan, tidak perlu logout dari API.");
    } else {
      // 1. Panggil API untuk logout (opsional, tapi sangat direkomendasikan)
      try {
        await http.post(
          Uri.parse('https://flowstate.my.id/api/logout'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );
        print("Berhasil logout dari API server.");
      } catch (e) {
        print("Gagal menghubungi API logout: $e");
      }
    }

    // 2. Hapus token dari penyimpanan lokal
    await prefs.remove('access_token');

    // Pastikan widget masih ada sebelum navigasi
    if (!mounted) return;

    // 3. Arahkan ke HomePage dan hapus semua halaman sebelumnya
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage()),
      (Route<dynamic> route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    String formattedBalance = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(double.tryParse(userProfile['balance']!) ?? 0.0);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: null,
      body: ListView(
        children: [
          // ... (Kode UI bagian atas tidak ada perubahan)
          Container(
            padding: EdgeInsets.all(35.0),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40.0),
                bottomRight: Radius.circular(40.0),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40.0,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/person_b.png'),
                ),
                SizedBox(width: 25.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfile['name']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userProfile['email']!,
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      userProfile['phone']!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 35.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/icons/fs_money.png',
                  height: 100,
                  width: 100,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 70.0),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    formattedBalance,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.0),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 20.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                shadowColor: Colors.black54,
                elevation: 5,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => fsmoney()),
                );
              },
              child: Text(
                '+ TopUp',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(height: 35.0),
          ListTile(
            leading: Icon(Icons.info_outline, size: 30, color: Colors.white),
            title: Text(
              'Tentang Kami',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
            ),
            onTap: () {},
          ),
          SizedBox(height: 50.0),
          // == TOMBOL KELUAR YANG SUDAH DIPERBAIKI ==
          Padding(
            padding: EdgeInsets.all(40.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 2.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              // Panggil fungsi _handleLogout saat ditekan
              onPressed: _handleLogout,
              child: Text(
                'Keluar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}