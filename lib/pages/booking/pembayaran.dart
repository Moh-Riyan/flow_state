import 'package:flow_state/models/lapangan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'detail_pembayaran_qr.dart';
import 'detail_pembayaran_fsmoney.dart';

class PembayaranPage extends StatefulWidget {
  // --- Terima data lapangan, total harga, dan ID Pemesanan ---
  final Lapangan lapangan;
  final int totalPrice;
  final String idPemesanan; // <-- ID Pemesanan dari halaman sebelumnya
  final DateTime selectedDate;
  final List<TimeOfDay> selectedTimes;

  const PembayaranPage({
    super.key,
    required this.lapangan,
    required this.totalPrice,
    required this.idPemesanan, // <-- Wajib ada
    required this.selectedDate,
    required this.selectedTimes,
  });

  @override
  _PembayaranPageState createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  String? _selectedPaymentMethod = 'QRIS';
  // State _isPaying tidak lagi diperlukan di sini karena tidak ada operasi async
  // bool _isPaying = false;

  String formatCurrency(int amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  // --- [DIUBAH] Fungsi ini sekarang hanya menangani navigasi ---
  void _handleNavigation() {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih metode pembayaran.'), backgroundColor: Colors.orange),
      );
      return;
    }

    // Panggilan API telah dipindahkan. Fungsi ini sekarang hanya untuk navigasi.
    if (_selectedPaymentMethod == 'FS Money') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPembayaranFsmoney(
            // [PENTING] Kirim semua data yang diperlukan ke halaman detail
            lapangan: widget.lapangan,
            idPemesanan: widget.idPemesanan,
            metodePembayaran: _selectedPaymentMethod!,
            totalPembayaran: widget.totalPrice,
          ),
        ),
      );
    } else if (_selectedPaymentMethod == 'QRIS') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PembayaranDetailPage(
            // Pastikan halaman PembayaranDetailPage juga siap menerima data ini jika perlu
            // idPemesanan: widget.idPemesanan,
            // totalPembayaran: widget.totalPrice,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String checkInTime = formatTimeToIndonesiaWIB(widget.selectedTimes.first);
    String checkOutTime = widget.selectedTimes.length > 1 ? formatTimeToIndonesiaWIB(widget.selectedTimes.last) : '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      widget.lapangan.fullGambarUrl,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 140,
                          height: 140,
                          color: Colors.grey[800],
                          child: const Icon(Icons.image_not_supported, color: Colors.white, size: 50),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.lapangan.namaLapangan,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.lapangan.lokasi} • ${DateFormat('EEEE, dd MMMM yy', 'id_ID').format(widget.selectedDate)}',
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Check-in',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  checkInTime,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 40),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Check-out',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  checkOutTime,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1, color: Colors.white),
              const Text('Metode Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Image.asset('assets/icons/qris.png', width: 40, height: 40),
                        const SizedBox(width: 10),
                        const Text('QRIS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    value: 'QRIS',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                    activeColor: Colors.orange,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Image.asset('assets/icons/fs_money.png', width: 40, height: 40),
                        const SizedBox(width: 10),
                        const Text('FS Money', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    value: 'FS Money',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                    activeColor: Colors.orange,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                ],
              ),
              const Divider(thickness: 1, color: Colors.white),
              const SizedBox(height: 20),
              const Text('Rincian Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Booking Lapangan', style: TextStyle(color: Colors.white70)),
                  Text(formatCurrency(widget.totalPrice), style: const TextStyle(color: Colors.white70)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(formatCurrency(widget.totalPrice), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleNavigation, // [DIUBAH] Memanggil fungsi navigasi
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        disabledBackgroundColor: Colors.orange.withOpacity(0.5)),
                    child: const Text(
                      'Lanjutkan ke Pembayaran', // [DIUBAH] Teks tombol lebih jelas
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatTimeToIndonesiaWIB(TimeOfDay time) {
    final DateTime now = DateTime.now();
    final DateTime dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat('HH:mm').format(dateTime);
  }
}
