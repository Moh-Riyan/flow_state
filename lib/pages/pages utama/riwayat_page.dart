import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flow_state/models/pesanan.dart';

class Riwayat extends StatefulWidget {
  @override
  _RiwayatState createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<Pesanan> _pesananAktif = [];
  List<Pesanan> _daftarRiwayatPesanan = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAndCategorizeOrders();
  }

  Future<void> _loadAndCategorizeOrders() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final allOrders = await Pesanan.muatPesananAktif();
    final now = DateTime.now();

    final active = <Pesanan>[];
    final history = <Pesanan>[];

    for (final pesanan in allOrders) {
      try {
        final timeParts = pesanan.jamSelesai.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        final checkOutDateTime = DateTime(
          pesanan.tanggalPemesanan.year,
          pesanan.tanggalPemesanan.month,
          pesanan.tanggalPemesanan.day,
          hour,
          minute,
        );

        if (now.isBefore(checkOutDateTime)) {
          active.add(pesanan);
        } else {
          history.add(pesanan);
        }
      } catch (e) {
        print('Error parsing waktu untuk pesanan ${pesanan.idPemesanan}: $e');
        history.add(pesanan);
      }
    }
    
    active.sort((a, b) => b.tanggalPemesanan.compareTo(a.tanggalPemesanan));
    history.sort((a, b) => b.tanggalPemesanan.compareTo(a.tanggalPemesanan));

    if (!mounted) return;
    setState(() {
      _pesananAktif = active;
      _daftarRiwayatPesanan = history;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // [MODIFIKASI UTAMA] Perubahan struktur UI pada method build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // AppBar dihapus untuk menaikkan posisi TabBar
      body: SafeArea(
        // SafeArea memastikan konten tidak terhalang oleh status bar atau notch
        child: Column(
          children: [
            // TabBar sekarang menjadi bagian dari body
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.orange,
                labelColor: Colors.orange,
                unselectedLabelColor: Colors.white,
                indicatorWeight: 3.0,
                tabs: const [
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
            // Divider untuk memberikan garis pemisah visual (opsional)
            Divider(color: Colors.grey[850], height: 1),
            // TabBarView harus dibungkus dengan Expanded agar mengisi sisa ruang
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPesananListView(_pesananAktif, 'Belum ada pesanan aktif.'),
                  _buildPesananListView(_daftarRiwayatPesanan, 'Belum ada riwayat pesanan.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPesananListView(List<Pesanan> daftarPesanan, String emptyMessage) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    if (daftarPesanan.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: daftarPesanan.length,
      itemBuilder: (context, index) {
        final pesanan = daftarPesanan[index];
        return _buildPesananCard(pesanan);
      },
    );
  }

  Widget _buildPesananCard(Pesanan pesanan) {
    final hargaFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final String hargaTampil = hargaFormat.format(pesanan.totalPembayaran);

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
                height: 120,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 100,
                    height: 120,
                    color: Colors.grey[800],
                    child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 120,
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(pesanan.tanggalPemesanan),
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTimeInfo('Check-in', pesanan.jamMulai),
                      SizedBox(width: 24),
                      _buildTimeInfo('Check-out', pesanan.jamSelesai),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Total Pembayaran',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  SizedBox(height: 2),
                  Text(
                    hargaTampil,
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 2),
        Text(
          time,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}