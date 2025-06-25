import 'package:flutter/material.dart';
// [PENTING] Impor file tempat widget Beranda Anda berada
// Sesuaikan path jika nama file atau lokasinya berbeda
import 'package:flow_state/pages/pages%20utama/beranda_page.dart'; 

class PembayaranGagal extends StatelessWidget {
  const PembayaranGagal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Judul disesuaikan agar lebih relevan dengan isi halaman
        title: const Text(
          'Pembayaran Gagal', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            // --- [DIUBAH] ---
            // Mengganti Navigator.pop dengan logika untuk kembali ke Beranda
            // dan menghapus semua halaman sebelumnya.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Beranda()),
              (Route<dynamic> route) => false,
            );
            // --- [SELESAI PERUBAHAN] ---
          },
        ),
        // Tambahkan ini agar tidak ada tombol kembali ganda
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/gagal.png', // Ganti dengan path gambar kamu
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Pembayaran Gagal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Saldo Anda Tidak Cukup',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}