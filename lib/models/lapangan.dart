import 'package:flow_state/models/fasilitas.dart';

class Lapangan {
  final String id;
  final String namaLapangan;
  final String lokasi;
  final String hargaLapangan;
  final String rating;
  final String deskripsiLapangan;
  final String gambarLapangan;
  final String fullGambarUrl;
  final List<Fasilitas> fasilitas;
  final bool statusAktif;

  Lapangan({
    required this.id,
    required this.namaLapangan,
    required this.lokasi,
    required this.hargaLapangan,
    required this.rating,
    required this.deskripsiLapangan,
    required this.gambarLapangan,
    required this.fullGambarUrl,
    required this.fasilitas,
    required this.statusAktif,
  });

  factory Lapangan.fromJson(Map<String, dynamic> json) {
    return Lapangan(
      id: json['id'].toString(),
      namaLapangan: json['nama_lapangan'],
      lokasi: json['lokasi'],
      hargaLapangan: json['harga_lapangan'],
      rating: json['rating'],
      deskripsiLapangan: json['deskripsi_lapangan'],
      gambarLapangan: json['gambar_lapangan'],
      fullGambarUrl: json['full_gambar_url'],
      fasilitas: (json['fasilitas'] as List)
          .map((item) => Fasilitas.fromJson(item))
          .toList(),
      statusAktif: json['status_aktif'],
    );
  }

  // Menambahkan metode toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lapangan': namaLapangan,
      'lokasi': lokasi,
      'harga_lapangan': hargaLapangan,
      'rating': rating,
      'deskripsi_lapangan': deskripsiLapangan,
      'gambar_lapangan': gambarLapangan,
      'full_gambar_url': fullGambarUrl,
      'fasilitas': fasilitas.map((fasilitas) => fasilitas.toJson()).toList(),
      'status_aktif': statusAktif,
    };
  }
}
