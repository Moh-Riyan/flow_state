import 'package:flow_state/pages/pages%20utama/beranda_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PembayaranBerhasil extends StatelessWidget {
  final int totalPembayaran;

  const PembayaranBerhasil({
    super.key,
    required this.totalPembayaran,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id', 
      symbol: 'Rp. ', 
      decimalDigits: 0
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Berhasil', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        // Tombol ini akan mengarahkan pengguna kembali ke halaman paling awal (root)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            // Menutup semua halaman di atas Beranda dan kembali ke Beranda.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Beranda()),
              (Route<dynamic> route) => false, // 'false' berarti hapus semua route
            );
          },
        ),
        // Menonaktifkan tombol kembali default agar tidak bentrok dengan yang kita buat.
        automaticallyImplyLeading: false, 
      ),

      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/berhasil.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Pembayaran Berhasil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Total Pembayaran',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Text(
                currencyFormat.format(totalPembayaran),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}