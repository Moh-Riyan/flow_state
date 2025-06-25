import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow_state/models/lapangan.dart';

class Pesanan {
  final Lapangan lapangan;
  final int totalPembayaran;
  final String idPemesanan;
  final DateTime tanggalPemesanan;

  Pesanan({
    required this.lapangan,
    required this.totalPembayaran,
    required this.idPemesanan,
    required this.tanggalPemesanan,
  });

  factory Pesanan.fromJson(Map<String, dynamic> json) {
    return Pesanan(
      lapangan: Lapangan.fromJson(json['lapangan']),
      totalPembayaran: json['totalPembayaran'],
      idPemesanan: json['idPemesanan'],
      tanggalPemesanan: DateTime.parse(json['tanggalPemesanan']),
    );
  }

  // Menambahkan metode toJson
  Map<String, dynamic> toJson() {
    return {
      'lapangan': lapangan.toJson(),
      'totalPembayaran': totalPembayaran,
      'idPemesanan': idPemesanan,
      'tanggalPemesanan': tanggalPemesanan.toIso8601String(),
    };
  }

  // Menyimpan daftar pesanan ke SharedPreferences
  static Future<void> simpanPesananAktif(Pesanan pesananBaru) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonPesanan = prefs.getString('pesananAktif');
    List<Pesanan> daftarPesanan = [];

    // Jika sudah ada pesanan sebelumnya, muat pesanan tersebut
    if (jsonPesanan != null) {
      List<dynamic> listPesanan = json.decode(jsonPesanan);
      daftarPesanan = listPesanan.map((item) => Pesanan.fromJson(item)).toList();
    }

    // Tambahkan pesanan baru ke dalam daftar pesanan
    daftarPesanan.add(pesananBaru);

    // Simpan kembali daftar pesanan ke SharedPreferences
    String jsonDaftarPesanan = json.encode(daftarPesanan.map((item) => item.toJson()).toList());
    await prefs.setString('pesananAktif', jsonDaftarPesanan);

    // Debugging output untuk memeriksa apakah data disimpan dengan benar
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
