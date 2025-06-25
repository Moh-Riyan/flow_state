import 'package:flow_state/models/pesanan.dart'; // <- Ganti import

class ManajemenPesanan {
  /// Daftar untuk menyimpan pesanan yang masih aktif.
  static final List<Pesanan> pesananAktif = []; // <- Ganti tipe list menjadi Pesanan

  /// Daftar untuk menyimpan semua riwayat pesanan.
  static final List<Pesanan> daftarPesanan = [];

  /// Fungsi untuk menambahkan pesanan baru ke daftar aktif.
  static void tambahPesananAktif(Pesanan pesanan) { // <- Ganti parameter menjadi Pesanan
    // Mencegah duplikat berdasarkan ID Pemesanan
    if (!pesananAktif.any((item) => item.idPemesanan == pesanan.idPemesanan)) {
      pesananAktif.add(pesanan);
    }
  }
}