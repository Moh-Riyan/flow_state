import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TopupBerhasil extends StatelessWidget {
  final int nominal;

  const TopupBerhasil({super.key, required this.nominal});

  @override
  Widget build(BuildContext context) {
    final formattedNominal = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(nominal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
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
              'TopUp Berhasil',
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
              formattedNominal,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
