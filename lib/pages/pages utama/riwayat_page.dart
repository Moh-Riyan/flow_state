import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flow_state/models/pesanan.dart';
import 'package:flow_state/models/lapangan.dart';

class Riwayat extends StatefulWidget {
  @override
  _RiwayatState createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Pesanan> pesananAktif = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Memuat pesanan aktif dari SharedPreferences
    Pesanan.muatPesananAktif().then((pesananList) {
      setState(() {
        pesananAktif = pesananList;
        print("Pesanan aktif dimuat: $pesananAktif");  // Output untuk debugging
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.orange,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.white,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Text(
                    'Pesanan Aktif',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Tab(
                  child: Text(
                    'Daftar Pesanan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPesananAktif(),
          _buildDaftarPesanan(),  // Tombol "Tambah Pesanan" sudah dihapus di sini
        ],
      ),
    );
  }

  Widget _buildPesananAktif() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: pesananAktif.length,
      itemBuilder: (context, index) {
        final pesanan = pesananAktif[index];
        return _buildPesananCard(pesanan);
      },
    );
  }

  // Hapus bagian yang berkaitan dengan tombol "Tambah Pesanan"
  Widget _buildDaftarPesanan() {
    return Center(
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: pesananAktif.length, // Menampilkan daftar pesanan aktif
        itemBuilder: (context, index) {
          final pesanan = pesananAktif[index];
          return _buildPesananCard(pesanan);  // Menggunakan _buildPesananCard untuk menampilkan pesanan
        },
      ),
    );
  }

  Widget _buildPesananCard(Pesanan pesanan) {
    final hargaFormat = NumberFormat("#,##0", "en_US");
    final hargaInt = int.tryParse(pesanan.lapangan.hargaLapangan) ?? 0;

    return Card(
      color: Color(0xFF1C1C1E),
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                pesanan.lapangan.fullGambarUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[800],
                    child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[800],
                    child: Icon(Icons.sports_soccer_rounded, color: Colors.white, size: 40),
                  );
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pesanan.lapangan.namaLapangan,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text(
                        pesanan.lapangan.rating,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(width: 8),
                      Text("•", style: TextStyle(color: Colors.white, fontSize: 14)),
                      SizedBox(width: 8),
                      Text(
                        pesanan.lapangan.lokasi,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mulai dari',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Rp ${hargaFormat.format(hargaInt).replaceAll(',', '.')}',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/jam',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
