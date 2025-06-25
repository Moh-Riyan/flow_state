import 'package:flutter/material.dart';

class TentangKamiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tentang Kami',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kelompok 1
              Text(
                'APLIKASI BERBASIS WEB',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/anggota1.jpg'), // Ganti dengan gambar anggota 1
                      ),
                      SizedBox(height: 8),
                      Text('Nama Anggota 1', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/anggota2.jpg'), // Ganti dengan gambar anggota 2
                      ),
                      SizedBox(height: 8),
                      Text('Nama Anggota 2', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/anggota3.jpg'), // Ganti dengan gambar anggota 3
                      ),
                      SizedBox(height: 8),
                      Text('Nama Anggota 3', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Kelompok 2
              Text(
                'Kelompok 2',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/anggota4.jpg'), // Ganti dengan gambar anggota 4
                      ),
                      SizedBox(height: 8),
                      Text('Nama Anggota 4', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/anggota5.jpg'), // Ganti dengan gambar anggota 5
                      ),
                      SizedBox(height: 8),
                      Text('Nama Anggota 5', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/anggota6.jpg'), // Ganti dengan gambar anggota 6
                      ),
                      SizedBox(height: 8),
                      Text('Nama Anggota 6', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
