// (Salin semua import Anda di sini)
import 'package:flow_state/models/lapangan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'detail_pembayaran_qr.dart';
import 'detail_pembayaran_fsmoney.dart';

class PembayaranPage extends StatefulWidget {
  final Lapangan lapangan;
  final int totalPrice;
  final String idPemesanan;
  final DateTime selectedDate;
  final List<TimeOfDay> selectedTimes;

  const PembayaranPage({
    super.key,
    required this.lapangan,
    required this.totalPrice,
    required this.idPemesanan,
    required this.selectedDate,
    required this.selectedTimes,
  });

  @override
  _PembayaranPageState createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  String? _selectedPaymentMethod = 'QRIS';

  String formatCurrency(int amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  // [MODIFIKASI UTAMA] di fungsi _handleNavigation
  void _handleNavigation() {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih metode pembayaran.'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_selectedPaymentMethod == 'FS Money') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPembayaranFsmoney(
            lapangan: widget.lapangan,
            idPemesanan: widget.idPemesanan,
            metodePembayaran: _selectedPaymentMethod!,
            totalPembayaran: widget.totalPrice,
            // [TAMBAHAN] Kirim data tanggal dan waktu ke halaman detail pembayaran
            selectedDate: widget.selectedDate,
            selectedTimes: widget.selectedTimes,
          ),
        ),
      );
    } else if (_selectedPaymentMethod == 'QRIS') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PembayaranDetailPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Tidak ada perubahan di build method)
    // ... (Salin seluruh build method Anda di sini)
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
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.lapangan.lokasi} • ${DateFormat('EEEE, dd MMMM yy', 'id_ID').format(widget.selectedDate)}',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  checkInTime,
                                  style: const TextStyle(
                                    fontSize: 15,
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  checkOutTime,
                                  style: const TextStyle(
                                    fontSize: 15,
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
                 RadioListTile<String>(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('assets/icons/gopay.png', width: 40, height: 40),
                        SizedBox(width: 10),
                        Text('GoPay', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    value: 'GoPay',
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('assets/icons/ovo.png', width: 40, height: 40),
                        SizedBox(width: 10),
                        Text('OVO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    value: 'OVO',
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('assets/icons/bca.png', width: 40, height: 40),
                        SizedBox(width: 10),
                        Text('BCA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    value: 'BCA',
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('assets/icons/mandiri.png', width: 40, height: 40),
                        SizedBox(width: 10),
                        Text('Mandiri', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    value: 'Mandiri',
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('assets/icons/bri.png', width: 40, height: 40),
                        SizedBox(width: 10),
                        Text('BRI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    value: 'BRI',
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
              const SizedBox(height: 40),
              Center(
                child: SizedBox(
                  width: 250,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _handleNavigation,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        disabledBackgroundColor: Colors.orange.withOpacity(0.5)),
                    child: const Text(
                      'Lanjut Pembayaran',
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