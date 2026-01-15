import 'package:flutter/material.dart';
import 'package:perpustakaan_app/dashboard_admin/tabs/denda_tab.dart';
import 'package:perpustakaan_app/dashboard_admin/tabs/kunjungan_tab.dart';
import 'package:perpustakaan_app/dashboard_admin/tabs/perpanjangan_tab.dart';
import 'widgets/stat_card.dart';
import 'widgets/menu_chip.dart';
import 'tabs/buku_tab.dart';
import 'tabs/peminjaman_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Simpan menu yang sedang aktif di state
  String activeMenu = "Buku";

  // Fungsi untuk mengganti konten secara dinamis
  Widget getActiveTabContent() {
    switch (activeMenu) {
      case "Buku":
        return const BukuTab();
      case "Peminjaman":
        return const PeminjamanTab();
        case "Perpanjangan":
        return const PerpanjanganTab();
        case "Denda":
        return const DendaTab();
      case "Kunjungan":
        return const KunjunganTab();
      default:
        return Center(
          child: Text("Konten untuk $activeMenu sedang dikembangkan"),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          "Admin Perpustakaan PI-BOOK",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row Statistik
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: const [
                StatCard(title: "Total Buku", value: "8", color: Colors.black),
                StatCard(title: "Pending Pinjam", value: "0", color: Colors.orange),
                StatCard(title: "Perpanjangan", value: "0", color: Colors.blue),
                StatCard(title: "Total Denda", value: "Rp 0", color: Colors.red),
              ],
            ),
            const SizedBox(height: 24),

            // Tab Menu Dinamis
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["Buku", "Peminjaman", "Perpanjangan", "Denda", "Kunjungan"]
                    .map((menu) => MenuChip(
                          title: menu,
                          isActive: activeMenu == menu,
                          onTap: () {
                            setState(() {
                              activeMenu = menu; // Update menu saat diklik
                            });
                          },
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Bagian Konten Dinamis yang berubah-ubah
            getActiveTabContent(),
          ],
        ),
      ),
    );
  }
}