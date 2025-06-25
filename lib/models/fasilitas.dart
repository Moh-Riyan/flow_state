class Fasilitas {
  final int idFasilitas;
  final String namaFasilitas;
  final String gambarIkon;
  final String fullGambarUrl;

  Fasilitas({
    required this.idFasilitas,
    required this.namaFasilitas,
    required this.gambarIkon,
    required this.fullGambarUrl,
  });

  factory Fasilitas.fromJson(Map<String, dynamic> json) {
    return Fasilitas(
      idFasilitas: json['id_fasilitas'],
      namaFasilitas: json['nama_fasilitas'],
      gambarIkon: json['gambar_ikon'],
      fullGambarUrl: json['full_gambar_url'],
    );
  }

  // Menambahkan metode toJson
  Map<String, dynamic> toJson() {
    return {
      'id_fasilitas': idFasilitas,
      'nama_fasilitas': namaFasilitas,
      'gambar_ikon': gambarIkon,
      'full_gambar_url': fullGambarUrl,
    };
  }
}
