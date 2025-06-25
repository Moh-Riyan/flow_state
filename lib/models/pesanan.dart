import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow_state/models/lapangan.dart';

class Pesanan {
  final Lapangan lapangan;
  final int totalPembayaran;
  final String idPemesanan;
  final DateTime tanggalPemesanan;
  // [TAMBAHAN] Properti untuk menyimpan jam mulai dan selesai
  final String jamMulai;
  final String jamSelesai;

  Pesanan({
    required this.lapangan,
    required this.totalPembayaran,
    required this.idPemesanan,
    required this.tanggalPemesanan,
    // [TAMBAHAN] Update constructor
    required this.jamMulai,
    required this.jamSelesai,
  });

  factory Pesanan.fromJson(Map<String, dynamic> json) {
    return Pesanan(
      lapangan: Lapangan.fromJson(json['lapangan']),
      totalPembayaran: json['totalPembayaran'],
      idPemesanan: json['idPemesanan'],
      tanggalPemesanan: DateTime.parse(json['tanggalPemesanan']),
      // [TAMBAHAN] Mengambil data jam dari JSON, dengan nilai default jika null
      jamMulai: json['jam_mulai'] ?? '00:00',
      jamSelesai: json['jam_selesai'] ?? '00:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lapangan': lapangan.toJson(),
      'totalPembayaran': totalPembayaran,
      'idPemesanan': idPemesanan,
      'tanggalPemesanan': tanggalPemesanan.toIso8601String(),
      // [TAMBAHAN] Menambahkan data jam ke JSON
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
    };
  }

  // Menyimpan daftar pesanan ke SharedPreferences
  static Future<void> simpanPesananAktif(Pesanan pesananBaru) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonPesanan = prefs.getString('pesananAktif');
    List<Pesanan> daftarPesanan = [];

    if (jsonPesanan != null) {
      List<dynamic> listPesanan = json.decode(jsonPesanan);
      daftarPesanan = listPesanan.map((item) => Pesanan.fromJson(item)).toList();
    }

    daftarPesanan.add(pesananBaru);

    String jsonDaftarPesanan = json.encode(daftarPesanan.map((item) => item.toJson()).toList());
    await prefs.setString('pesananAktif', jsonDaftarPesanan);
    print("Menyimpan Pesanan Aktif: $jsonDaftarPesanan");
  }

  // Memuat daftar pesanan dari SharedPreferences
  static Future<List<Pesanan>> muatPesananAktif() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonPesanan = prefs.getString('pesananAktif');
    if (jsonPesanan != null) {
      List<dynamic> listPesanan = json.decode(jsonPesanan);
      return listPesanan.map((item) => Pesanan.fromJson(item)).toList();
    }
    return [];
  }
}