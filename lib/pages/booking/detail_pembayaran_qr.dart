import 'package:flutter/material.dart';
import 'dart:async'; // Untuk menggunakan Timer

class PembayaranDetailPage extends StatefulWidget {
  @override
  _PembayaranDetailPageState createState() => _PembayaranDetailPageState();
}

class _PembayaranDetailPageState extends State<PembayaranDetailPage> {
  int _start = 900; // 15 menit dalam detik
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return; // Cek jika widget masih ada di tree
      if (_start == 0) {
        _timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Mengubah background utama menjadi hitam
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Detail Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        // AppBar bisa dibuat sedikit transparan atau warna lain yang cocok
        backgroundColor: Colors.orange,
        elevation: 0, // Menghilangkan bayangan
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                // 2. Memberi warna pada container agar menonjol dari background
                decoration: BoxDecoration(
                  color: Colors.grey.shade900, // Warna container
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Asumsikan gambar qris.png memiliki background transparan
                        Image.asset('assets/icons/qris.png', width: 50, height: 50),
                        SizedBox(width: 10),
                        // 3. Mengubah warna teks menjadi putih
                        Text('QRIS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // 3. Mengubah warna teks menjadi putih
                            Text('Waktu Tersisa', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            SizedBox(height: 5),
                            Text(
                              formatTime(_start),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(8), // Padding agar ada border putih
                        color: Colors.white, // Background putih untuk QR code
                        child: Image.asset('assets/images/qr_code.png', width: 200, height: 200),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.download, color: Colors.white),
                        label: Text(
                          'Download',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // 4. Mengubah warna divider agar terlihat
                    Divider(thickness: 1, color: Colors.grey.shade700),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 3. Mengubah warna teks menjadi putih
                        Text('Booking Lapangan', style: TextStyle(fontSize: 16, color: Colors.white)),
                        Text('Rp 60.000', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(thickness: 1, color: Colors.grey.shade700),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 3. Mengubah warna teks menjadi putih
                        Text('Total Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Rp 60.000', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 3. Mengubah warna teks menjadi putih
                    Text(
                      'Instruksi Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    // 3. Mengubah warna teks menjadi putih
                    Text(
                      '• Buka aplikasi e-wallet atau bank digital yang menyediakan layanan QRIS dan pilih pemindahan QR.',
                      style: TextStyle(fontSize: 14, height: 1.5, color: Colors.white70),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '• Arahkan kamera pada Kode QR di atas hingga halaman pembayaran muncul.',
                      style: TextStyle(fontSize: 14, height: 1.5, color: Colors.white70),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '• Anda juga dapat mengunduh kode QR di atas jika layanan QRIS menyediakan fitur Unggah QR.',
                      style: TextStyle(fontSize: 14, height: 1.5, color: Colors.white70),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '• Anda akan menerima sejumlah deposit setelah dikonfirmasi.',
                      style: TextStyle(fontSize: 14, height: 1.5, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}