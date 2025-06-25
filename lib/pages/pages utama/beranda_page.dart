import 'package:flow_state/pages/booking/detail_lapangan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flow_state/pages/pages%20utama/bottom_navigation_bar.dart';
import 'package:flow_state/pages/pages%20utama/riwayat_page.dart';
import 'package:flow_state/pages/pages%20utama/profil_page.dart';

//=============== WIDGET UTAMA (KERANGKA) ===============
class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  _BerandaState createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  int _selectedIndex = 0;
  List<dynamic> _lapangans = [];
  List<dynamic> _filteredLapangans = [];
  final TextEditingController _searchController = TextEditingController();

  // Daftar halaman tidak lagi diinisialisasi di sini secara langsung
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar halaman di dalam initState agar bisa mengirim controller
    _pages = [
      // 1. Mengirim searchController ke RecommendedContent
      RecommendedContent(searchController: _searchController),
      Riwayat(),
      Profile(),
    ];
    _fetchLapanganData();
    _searchController.addListener(_filterLapangan);
  }

  @override
  void dispose() {
    // PageController tidak lagi ada di state ini, jadi hapus disposenya
    _searchController.dispose();
    super.dispose();
  }

  void _fetchLapanganData() async {
    try {
      final response = await http.get(
        Uri.parse('https://flowstate.my.id/api/lapangans'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _lapangans = json.decode(response.body);
          _filteredLapangans = _lapangans;
        });
      } else {
        print('Gagal mengambil data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan koneksi: $e');
    }
  }

  void _filterLapangan() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLapangans = _lapangans.where((lapangan) {
        return lapangan['nama_lapangan'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // 2. Body disederhanakan, tidak lagi menggunakan Column
      //    Ini akan menampilkan halaman yang dipilih (Beranda, Riwayat, atau Profil)
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

//=============== WIDGET KONTEN HALAMAN BERANDA ===============
class RecommendedContent extends StatefulWidget {
  // 3. Tambahkan variabel untuk menerima controller
  final TextEditingController searchController;

  const RecommendedContent({super.key, required this.searchController});

  @override
  _RecommendedContentState createState() => _RecommendedContentState();
}

class _RecommendedContentState extends State<RecommendedContent> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _startAutoSlider();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlider() {
    // Bungkus dengan `mounted` check untuk keamanan
    if (!mounted) return;
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && _pageController.hasClients) {
        _currentPage = (_currentPage + 1) % 3;
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(seconds: 1),
          curve: Curves.easeIn,
        );
        _startAutoSlider();
      }
    });
  }

  String formatHarga(String harga) {
    final format = NumberFormat("#,###", "id_ID");
    int hargaInt = int.tryParse(harga) ?? 0;
    return "Rp ${format.format(hargaInt)}";
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data lapangan yang sudah difilter dari state Beranda
    final _lapangans =
        (context.findAncestorStateOfType<_BerandaState>()?._filteredLapangans) ?? [];

    // 4. Widget ini sekarang menggunakan Column untuk menyusun Search Bar dan List
    return Column(
      children: [
        // == UI KOLOM PENCARIAN SEKARANG ADA DI SINI ==
        Container(
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          // Padding diatur agar lebih aman di berbagai perangkat (menggunakan SafeArea)
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 20),
          child: Center(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextField(
                // 5. Menggunakan controller yang dikirim dari widget parent
                controller: widget.searchController,
                decoration: InputDecoration(
                  hintText: 'Cari lapangan',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 14.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        // 6. Sisa konten (slider dan list) dibungkus dengan Expanded
        //    agar bisa di-scroll dan mengisi sisa ruang
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _sliderImage('assets/images/cashback.png'),
                      _sliderImage('assets/images/diskon1.png'),
                      _sliderImage('assets/images/diskon2.png'),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      height: 8.0,
                      width: 8.0,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.orange
                            : Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange, width: 1.5),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recommended',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              _lapangans.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _lapangans.length,
                      itemBuilder: (context, index) {
                        final lapangan = _lapangans[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LapanganDetailPage(
                                  lapanganId: lapangan['id'],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 8.0),
                            padding: EdgeInsets.all(8.0),
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 34, 34, 34),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    lapangan['full_gambar_url'],
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        lapangan['nama_lapangan'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      SizedBox(height: 4.0),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.orange,
                                            size: 10,
                                          ),
                                          Text(
                                            ' ${lapangan['rating']}',
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            '• ${lapangan['lokasi']}',
                                            style: TextStyle(color: Colors.white, fontSize: 10),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.0),
                                      Text(
                                        'Mulai dari',
                                        style: TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            formatHarga(lapangan['harga_lapangan']),
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '/ jam',
                                            style: TextStyle(color: Colors.white, fontSize: 15),
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
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sliderImage(String path) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}