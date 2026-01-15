import 'package:flutter/material.dart';
import 'package:perpustakaan_app/dashboard_admin/tabs/denda_tab.dart';
// Import file tab
import 'tabs/peminjaman_saya.dart';
// Aktifkan import ini jika file sudah tersedia
// import 'tabs/katalog_tab.dart'; 

// import 'tabs/surat_bebas_tab.dart';

// Import widgets
import 'widgets/stat_card.dart';
import 'widgets/menu_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Pastikan activeMenu sesuai dengan salah satu item di list menu agar tidak error
  String activeMenu = "Buku"; 

  Widget getActiveTabContent() {
    switch (activeMenu) {
      case "Peminjaman Saya":
        return const PeminjamanSayaTab();
      case "Denda":
        return const DendaTab();
      // Tambahkan case lain di sini sesuai kebutuhan
      default:
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              "Konten untuk $activeMenu sedang dikembangkan",
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER PROFIL =================
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.menu_book, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PI-BOOK LP3I", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                        Text(
                          "kurniajakaa - MHS050392", 
                          style: TextStyle(fontSize: 12, color: Colors.grey)
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.logout, size: 16, color: Colors.black),
                    label: const Text("Keluar", style: TextStyle(color: Colors.black)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              // ================= GRID STATISTIK =================
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Karena sudah ada SingleChildScrollView di atas
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

              // ================= TAB MENU HORIZONTAL =================
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["Katalog", "Pinjam Buku", "Peminjaman Saya", "Denda", "Surat Bebas"]
                      .map((menu) => MenuChip(
                            title: menu,
                            isActive: activeMenu == menu,
                            onTap: () {
                              setState(() {
                                activeMenu = menu;
                              });
                            },
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),

              // ================= KONTEN DINAMIS =================
              getActiveTabContent(),
            ],
          ),
        ),
      ),
    );
  }
}