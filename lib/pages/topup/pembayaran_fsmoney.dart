import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fsmoney.dart';
import 'topup_berhasil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailPembayaranFsmoney extends StatefulWidget {
  final int nominal;

  const DetailPembayaranFsmoney({super.key, required this.nominal});

  @override
  State<DetailPembayaranFsmoney> createState() => _DetailPembayaranFsmoneyState();
}

class _DetailPembayaranFsmoneyState extends State<DetailPembayaranFsmoney> {
  late Timer _timer;
  Duration _remaining = const Duration(minutes: 15);
  late int totalPembayaran;
  String _token = ''; // Tambahkan deklarasi untuk _token

  @override
  void initState() {
    super.initState();
    totalPembayaran = widget.nominal;
    _startTimer();
    _loadToken(); // Ganti dengan load token
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds > 0) {
        setState(() {
          _remaining -= const Duration(seconds: 1);
        });
      } else {
        _timer.cancel();
      }
    });
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token'); // Ambil token dari SharedPreferences
    
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan.')),
      );
      return;
    }

    setState(() {
      _token = token; // Simpan token ke dalam state
    });
  }

  Future<void> _kirimTopup() async {
    if (_token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan.')),
      );
      return;
    }

    final url = Uri.parse('https://flowstate.my.id/api/topup');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Kirim token sebagai Bearer token
        },
        body: jsonEncode({
          "nominal": totalPembayaran,
        }),
      );

      if (response.statusCode == 200) {
        // Request to check if the admin has confirmed the topup
        final confirmResponse = await http.get(
          Uri.parse('https://flowstate.my.id/api/topup/confirm'),
          headers: {
            'Authorization': 'Bearer $_token',
          },
        );

        if (confirmResponse.statusCode == 200) {
          // If the top-up is confirmed by the admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TopupBerhasil(nominal: totalPembayaran)),
          );
        } else {
          // Handle if the admin has not confirmed yet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran sedang menunggu konfirmasi admin.')),
          );
        }
      } else {
        // Handle failure
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => fsmoney()),
        );
      }
    } catch (e) {
      // Handle error without showing SnackBar
      print('Terjadi kesalahan: $e');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get formattedTime {
    String minutes = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Detail Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => fsmoney()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icons/fs_money.png',
                              height: 28,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'FS Money',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Waktu Tersisa', style: TextStyle(fontSize: 12, color: Colors.white)),
                          Text(formattedTime, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Pastikan nomor telepon yang Anda masukkan adalah nomor yang aktif dan dapat dihubungi.',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(color: Colors.white, fontSize: 15)),
                      Text(currencyFormat.format(totalPembayaran),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _kirimTopup,
                child: const Text(
                  'BAYAR',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
