import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      backgroundColor: const Color.fromARGB(255, 34, 34, 34), // Latar belakang hitam
      selectedItemColor: Colors.orange, // Ikon aktif oranye
      unselectedItemColor: Colors.white, // Ikon tidak aktif putih
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/beranda.png',
            width: 24,
            height: 24,
          ),
          label: 'Beranda',
          activeIcon: Image.asset(
            'assets/icons/beranda.png',
            width: 24,
            height: 24,
            color: Colors.orange, // Ikon aktif berwarna oranye
          ),
        ),

        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/riwayat.png',
            width: 24,
            height: 24,
          ),
          label: 'Riwayat',
          activeIcon: Image.asset(
            'assets/icons/riwayat.png',
            width: 24,
            height: 24,
            color: Colors.orange, // Ikon aktif berwarna oranye
          ),
        ),
        
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/profile.png',
            width: 24,
            height: 24,
          ),
          label: 'Profil',
          activeIcon: Image.asset(
            'assets/icons/profile.png',
            width: 24,
            height: 24,
            color: Colors.orange, // Ikon aktif berwarna oranye
          ),
        ),
      ],
    );
  }
}
