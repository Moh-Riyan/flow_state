import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Impor model yang diperlukan
import 'package:flow_state/models/manajemen_pesanan.dart';
import 'package:flow_state/models/lapangan.dart'; 
import 'package:flow_state/models/pesanan.dart';
import 'pembayaran_berhasil.dart';
import 'pembayaran_gagal.dart';

class DetailPembayaranFsmoney extends StatefulWidget {
  final String idPemesanan;
  final String metodePembayaran;
  final int totalPembayaran;
  final Lapangan lapangan;

  const DetailPembayaranFsmoney({
    super.key,
    required this.idPemesanan,
    required this.metodePembayaran,
    required this.totalPembayaran,
    required this.lapangan,
  });

  @override
  State<DetailPembayaranFsmoney> createState() => _DetailPembayaranPageState();
}

class _DetailPembayaranPageState extends State<DetailPembayaranFsmoney> {
  late Timer _timer;
  Duration _remaining = const Duration(minutes: 15);
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds > 0) {
        setState(() {
          _remaining -= const Duration(seconds: 1);
        });
      } else {
        _timer.cancel();
      }
    });
  }

  String get formattedTime {
    String minutes =
        _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // =======================================================================
  // === GANTI SELURUH FUNGSI _processPayment ANDA DENGAN VERSI INI ===
  // =======================================================================
  Future<void> _processPayment() async {
    if (!mounted) return;
    setState(() {
      _isProcessingPayment = true;
    });

    // --- [DEBUG] Mulai proses
    print('=============================================');
    print('[DEBUG] Memulai proses pembayaran...');

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');
      if (accessToken == null) {
        // --- [DEBUG] Error karena token tidak ada
        print('[DEBUG] GAGAL: Token tidak ditemukan.');
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }
      
      // --- [DEBUG] Token berhasil ditemukan
      print('[DEBUG] Token ditemukan: Bearer $accessToken');

      final Map<String, dynamic> dataPembayaran = {
        'metode_pembayaran': 'FSMoney',
      };

      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      };

      // --- [DEBUG] Mengirim request ke server
      final url = 'https://flowstate.my.id/api/pembayaran/${widget.idPemesanan}';
      print('[DEBUG] Mengirim request ke: $url');
      print('[DEBUG] Dengan body: ${json.encode(dataPembayaran)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(dataPembayaran),
      );

      // --- [DEBUG] Menerima respons dari server
      print('[DEBUG] API Response Status Code: ${response.statusCode}');
      print('[DEBUG] API Response Body: ${response.body}');

      dynamic responseBody;
      try {
        responseBody = json.decode(response.body);
      } catch (e) {
        throw Exception('Terjadi kesalahan pada server. Respons tidak valid.');
      }

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody['status'] == 'success') {
          _timer.cancel();

          // --- [DEBUG] Pembayaran SUKSES
          print('[DEBUG] PEMBAYARAN SUKSES! Menambahkan lapangan ke riwayat...');
          // Konversi Lapangan ke Pesanan sebelum menambah ke pesananAktif
          ManajemenPesanan.pesananAktif.add(
            Pesanan(
              lapangan: widget.lapangan,
              idPemesanan: widget.idPemesanan,
              totalPembayaran: widget.totalPembayaran,
              tanggalPemesanan: DateTime.now(), // Ganti jika ada tanggal lain yang sesuai
              // Tambahkan properti lain yang diperlukan sesuai konstruktor Pesanan
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => PembayaranBerhasil(
                totalPembayaran: widget.totalPembayaran,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          // --- [DEBUG] Pembayaran Gagal menurut server
          print('[DEBUG] GAGAL: Server merespons "gagal". Pesan: ${responseBody['message']}');
          throw Exception(responseBody['message'] ?? 'Pembayaran Gagal');
        }
      } else {
        // --- [DEBUG] Error HTTP dari server
        print('[DEBUG] GAGAL: HTTP Status Code bukan 200/201.');
        final String serverMessage =
            responseBody['message'] ?? 'Status code: ${response.statusCode}';
        throw Exception('Error dari server: $serverMessage');
      }
    } catch (e) {
      // --- [DEBUG] Terjadi error di dalam blok try
      print('[DEBUG] EXCEPTION DITANGKAP: ${e.toString()}');
      if (mounted) {
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('saldo')) {
          _timer.cancel();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PembayaranGagal()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}'))
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }
  // =======================================================================
  // === BATAS AKHIR FUNGSI _processPayment ===
  // =======================================================================

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Detail Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ... (Sisa UI build method tidak perlu diubah) ...
            // ... (Salin sisa UI build method Anda yang sudah ada ke sini) ...
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
                            Image.asset('assets/icons/fs_money.png', height: 28),
                            const SizedBox(width: 8),
                            Text(
                              widget.metodePembayaran,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Waktu Tersisa', style: TextStyle(fontSize: 12, color: Colors.white)),
                          Text(
                            formattedTime,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      )
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
                      'Pastikan saldo FS Money Anda mencukupi untuk menyelesaikan transaksi ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(color: Colors.white, fontSize: 15)),
                      Text(
                        currencyFormat.format(widget.totalPembayaran),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  disabledBackgroundColor: Colors.orange.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isProcessingPayment ? null : _processPayment,
                child: _isProcessingPayment
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                      )
                    : const Text(
                        'BAYAR SEKARANG',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}