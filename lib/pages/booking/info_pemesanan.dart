// (Salin semua import Anda di sini)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow_state/models/lapangan.dart';
import 'package:flow_state/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flow_state/pages/booking/pembayaran.dart';
// Hapus import 'package:flow_state/models/pesanan.dart'; jika tidak digunakan lagi di sini
// Namun, kita masih membutuhkannya untuk TimeOfDayExtension, jadi biarkan saja.
import 'package:flow_state/models/pesanan.dart';


class BookingInfoPage extends StatefulWidget {
  final Lapangan lapangan;
  final DateTime selectedDate;
  final List<TimeOfDay> selectedTimes;

  const BookingInfoPage({
    super.key,
    required this.lapangan,
    required this.selectedDate,
    required this.selectedTimes,
  });

  @override
  State<BookingInfoPage> createState() => _BookingInfoPageState();
}

class _BookingInfoPageState extends State<BookingInfoPage> {
  // ... (Tidak ada perubahan pada properti state)
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;
  final TextEditingController _catatanController = TextEditingController();
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }
  
  // Fungsi _fetchUserProfile tidak berubah
  Future<void> _fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('Token tidak ditemukan, pastikan user sudah login!');
      }

      final response = await http.get(
        Uri.parse('https://flowstate.my.id/api/profile'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _userProfile = UserProfile.fromJson(data);
            _isLoadingProfile = false;
          });
        } else {
          throw Exception('Gagal mengambil data profil: ${data['message']}');
        }
      } else {
        throw Exception('Gagal mengambil data profil. Status: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
        );
      }
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }


  // [MODIFIKASI UTAMA] di fungsi _kirimPemesanan
  Future<void> _kirimPemesanan() async {
    if (_userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pengguna belum siap, coba lagi.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final int basePrice = int.tryParse(widget.lapangan.hargaLapangan) ?? 0;
      final int durationInHours = widget.selectedTimes.last.hour - widget.selectedTimes.first.hour;
      final double totalPrice = (basePrice * (durationInHours > 0 ? durationInHours : 1)).toDouble();

      final String tanggal = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      final String jamMulai = '${widget.selectedTimes.first.hour.toString().padLeft(2, '0')}:${widget.selectedTimes.first.minute.toString().padLeft(2, '0')}:00';
      final String jamSelesai = '${widget.selectedTimes.last.hour.toString().padLeft(2, '0')}:${widget.selectedTimes.last.minute.toString().padLeft(2, '0')}:00';

      final Map<String, dynamic> dataPemesanan = {
        'konsumen_id': _userProfile!.noIdentitas,
        'lapangan_id': widget.lapangan.id,
        'tanggal': tanggal,
        'jam_mulai': jamMulai,
        'jam_selesai': jamSelesai,
        'harga': totalPrice,
        'catatan': _catatanController.text,
      };

      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final response = await http.post(
        Uri.parse('https://flowstate.my.id/api/pemesanan'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
        body: json.encode(dataPemesanan),
      );

      dynamic responseBody;
      try {
        responseBody = json.decode(response.body);
      } catch (e) {
        throw Exception('Terjadi kesalahan pada server. Respons tidak valid.');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (responseBody['status'] == 'success') {
          final String idPemesananDariApi = responseBody['data']?['id_pemesanan']?.toString() ?? '';

          if (idPemesananDariApi.isEmpty) {
            throw Exception('API berhasil, tetapi tidak mengembalikan ID Pemesanan.');
          }

          // [DIHAPUS] Logika penyimpanan ke SharedPreferences dihapus dari sini.

          if (mounted) {
            // Langsung navigasi ke halaman pembayaran dengan semua data yang diperlukan
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PembayaranPage(
                  lapangan: widget.lapangan,
                  selectedTimes: widget.selectedTimes,
                  selectedDate: widget.selectedDate,
                  totalPrice: totalPrice.toInt(),
                  idPemesanan: idPemesananDariApi,
                ),
              ),
            );
          }
        } else {
          throw Exception('Gagal membuat pemesanan: ${responseBody['message']}');
        }
      } else {
        String detailError = responseBody['message'] ?? 'Tidak ada pesan spesifik dari server.';
        if (responseBody['errors'] != null) {
          detailError += ' Detail: ${responseBody['errors'].values.first[0]}';
        }
        throw Exception('Gagal membuat pesanan ($detailError)');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }
  
  // ... (Sisa kode seperti build, _buildProfileInfo, dll tidak berubah)
  // ... (Salin sisa kode Anda di sini)
    String formatCurrency(int amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    int durationInHours = 0;
    if (widget.selectedTimes.length >= 2) {
      widget.selectedTimes.sort((a, b) => a.compareTo(b));
      final TimeOfDay startTime = widget.selectedTimes.first;
      final TimeOfDay endTime = widget.selectedTimes.last;
      durationInHours = endTime.hour - startTime.hour;
      if (durationInHours <= 0) {
        durationInHours = 1;
      }
    }
    final int basePrice = int.tryParse(widget.lapangan.hargaLapangan) ?? 0;
    final int totalPrice = basePrice * durationInHours;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context, true),
                    padding: const EdgeInsets.only(left: 5),
                  ),
                  const SizedBox(width: 4),
                  const Text('Informasi Pemesanan', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.lapangan.fullGambarUrl,
                          width: 300, 
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(widget.lapangan.namaLapangan, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                    
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 20),
                        const SizedBox(width: 4),
                        Text(widget.lapangan.rating, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        const Text('•', style: TextStyle(color: Colors.white70)),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(widget.lapangan.lokasi, style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1, color: Colors.white),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Jadwal Pemesanan', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('Waktu Pemesanan', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, dd MMMM yy', 'id_ID').format(widget.selectedDate),
                          style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                if (widget.selectedTimes.isNotEmpty) timeBox(formatTimeToIndonesiaWIB(widget.selectedTimes.first)),
                                if (widget.selectedTimes.length > 1)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Text('–', style: TextStyle(color: Colors.orange, fontSize: 12)),
                                  ),
                                if (widget.selectedTimes.length > 1) timeBox(formatTimeToIndonesiaWIB(widget.selectedTimes.last)),
                              ],
                            ),
                            if (durationInHours > 0) ...[
                              const SizedBox(height: 4),
                              Text('($durationInHours Jam)', style: const TextStyle(color: Colors.white70, fontSize: 12))
                            ]
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1, color: Colors.white),
                    const Text('Informasi Pemesanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    _buildProfileInfo(),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Harga Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(formatCurrency(totalPrice), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1, color: Colors.white),
                    const Text('Tambah Catatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white30)),
                      child: TextField(
                        controller: _catatanController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(hintText: 'Cth: Pastikan lapangan yang kami pesan tadi bersih dari sampah ya minn....', hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none, isCollapsed: true),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isBooking ? null : _kirimPemesanan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            disabledBackgroundColor: Colors.orange.withOpacity(0.5)
                          ),
                          child: _isBooking
                              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black))
                              : const Text('Pilih Pembayaran', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    if (_isLoadingProfile) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 2.0));
    }

    if (_userProfile == null) {
      return const Text(
        'Gagal memuat data pengguna.',
        style: TextStyle(color: Colors.redAccent),
      );
    }

    const defaultStyle = TextStyle(color: Colors.white, fontSize: 14);
    const orangeStyle = TextStyle(color: Colors.orange, fontSize: 14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: defaultStyle,
            children: [
              const TextSpan(text: '> ', style: orangeStyle),
              TextSpan(text: _userProfile!.nama),
            ],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: defaultStyle,
            children: [
              const TextSpan(text: '> ', style: orangeStyle),
              TextSpan(text: _userProfile!.phone),
            ],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: defaultStyle,
            children: [
              const TextSpan(text: '> ', style: orangeStyle),
              TextSpan(text: _userProfile!.email),
            ],
          ),
        ),
      ],
    );
  }

  String formatTimeToIndonesiaWIB(TimeOfDay time) {
    final DateTime dateTime = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dateTime);
  }

  Widget timeBox(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(border: Border.all(color: Colors.orange, width: 2), borderRadius: BorderRadius.circular(8)),
      child: Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}

extension TimeOfDayExtension on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (hour < other.hour) return -1;
    if (hour > other.hour) return 1;
    if (minute < other.minute) return -1;
    if (minute > other.minute) return 1;
    return 0;
  }
}