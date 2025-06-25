import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flow_state/models/lapangan.dart';
import 'package:intl/intl.dart';
import 'package:flow_state/pages/booking/pilih_jadwal.dart';

class LapanganDetailPage extends StatelessWidget {
  final String lapanganId;

  LapanganDetailPage({required this.lapanganId});

  // Fungsi untuk memformat harga
  String formatHarga(String harga) {
    final format = NumberFormat("#,###", "id_ID");
    int hargaInt = int.tryParse(harga) ?? 0;
    return "Rp ${format.format(hargaInt)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Detail Lapangan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: FutureBuilder<Lapangan>(
        future: _fetchLapanganDetail(lapanganId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan', style: TextStyle(color: Colors.white)));
          } else if (snapshot.hasData) {
            var lapangan = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar lapangan
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        lapangan.fullGambarUrl,
                        width: 300,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),
                  // Nama lapangan dan rating
                  Text(
                    lapangan.namaLapangan,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 18),
                      Text(
                        ' ${lapangan.rating}',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '• ${lapangan.lokasi}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Harga per jam dan tombol Booking
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            formatHarga(lapangan.hargaLapangan),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            '/ jam',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // --- PERUBAHAN DI SINI ---
                          // Mengirim objek 'lapangan' ke halaman SelectSchedule
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectSchedule(lapangan: lapangan),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Booking',
                          style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  // Deskripsi lapangan
                  Text(
                    lapangan.deskripsiLapangan,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  SizedBox(height: 30),
                  // Fasilitas
                  Text(
                    'Fasilitas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: lapangan.fasilitas.map((fasilitas) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Column(
                          children: [
                            Image.network(fasilitas.fullGambarUrl, width: 40, height: 40),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          } else {
            return Center(child: Text('Data tidak ditemukan', style: TextStyle(color: Colors.white)));
          }
        },
      ),
    );
  }

  Future<Lapangan> _fetchLapanganDetail(String id) async {
    try {
      final response = await http.get(
        Uri.parse('https://flowstate.my.id/api/lapangans/$id'),
      );
      if (response.statusCode == 200) {
        return Lapangan.fromJson(json.decode(response.body));
      } else {
        throw Exception('Gagal mengambil data');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}