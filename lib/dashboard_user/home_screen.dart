import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpustakaan_app/dashboard_admin/tabs/denda_tab.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/katalog_tab.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/pinjam_buku.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/surat_bebas.dart';
import 'package:perpustakaan_app/routes/app_routes.dart';
import 'tabs/peminjaman_saya.dart';
import 'widgets/stat_card.dart';
import 'widgets/menu_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String activeMenu = "Katalog";
  final String nimUser = "2024001"; // Simulasi NIM User Login

  // Fungsi helper untuk Stream statistik
  Stream<QuerySnapshot> getStatStream(String collection, {String? status}) {
    if (status != null) {
      return FirebaseFirestore.instance
          .collection(collection)
          .where('id_user', isEqualTo: nimUser)
          .where('status', isEqualTo: status)
          .snapshots();
    }
    return FirebaseFirestore.instance.collection(collection).snapshots();
  }

  Widget getActiveTabContent() {
    switch (activeMenu) {
      case "Peminjaman Saya":
        return const PeminjamanSayaTab();
      case "Denda":
        return const DendaTab();
      case "Surat Bebas":
        return const SuratBebasTab();
      case "Pinjam Buku":
        return const PinjamBukuTab();
      case "Katalog":
        return const KatalogTab();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              _buildHeader(context),
              const SizedBox(height: 30),

              // --- DYNAMIC STATISTIC GRID ---
              const Text("Ikhtisar Pustaka", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.4, // Sedikit lebih tinggi untuk menampung ikon
                children: [
                  // Stat Total Buku - Indigo (Info Umum)
                  StreamBuilder<QuerySnapshot>(
                    stream: getStatStream('books'),
                    builder: (context, snapshot) {
                      int total = snapshot.hasData ? snapshot.data!.docs.length : 0;
                      return StatCard(
                        title: "Koleksi Buku", 
                        value: total.toString(), 
                        color: Colors.indigo,
                        icon: Icons.book_rounded,
                      );
                    },
                  ),
                  // Stat Pending Pinjam - Orange (Perlu Perhatian)
                  StreamBuilder<QuerySnapshot>(
                    stream: getStatStream('peminjaman', status: 'pending'),
                    builder: (context, snapshot) {
                      int total = snapshot.hasData ? snapshot.data!.docs.length : 0;
                      return StatCard(
                        title: "Menunggu Acc", 
                        value: total.toString(), 
                        color: Colors.orange.shade700,
                        icon: Icons.pending_actions_rounded,
                      );
                    },
                  ),
                  // Stat Aktif Pinjam - Blue (Proses Berjalan)
                  StreamBuilder<QuerySnapshot>(
                    stream: getStatStream('peminjaman', status: 'dipinjam'),
                    builder: (context, snapshot) {
                      int total = snapshot.hasData ? snapshot.data!.docs.length : 0;
                      return StatCard(
                        title: "Buku Dipinjam", 
                        value: total.toString(), 
                        color: Colors.blue.shade700,
                        icon: Icons.bookmark_added_rounded,
                      );
                    },
                  ),
                  // Stat Total Denda - Red (Kritis/Penting)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('denda')
                        .where('id_user', isEqualTo: nimUser)
                        .where('status', isEqualTo: 'belum lunas')
                        .snapshots(),
                    builder: (context, snapshot) {
                      double totalDenda = 0;
                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs) {
                          totalDenda += (doc.data() as Map<String, dynamic>)['jumlah'] ?? 0;
                        }
                      }
                      return StatCard(
                        title: "Total Denda", 
                        value: "Rp ${totalDenda.toInt()}", 
                        color: Colors.redAccent.shade700,
                        icon: Icons.warning_amber_rounded,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- TAB NAVIGATION MENU ---
              const Text("Menu Navigasi", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ["Katalog", "Pinjam Buku", "Peminjaman Saya", "Denda", "Surat Bebas"]
                      .map((menu) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: MenuChip(
                              title: menu,
                              isActive: activeMenu == menu,
                              onTap: () => setState(() => activeMenu = menu),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 25),

              // --- TAB CONTENT AREA ---
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(activeMenu),
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: getActiveTabContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 15),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PI-BOOK LP3I",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("kurniajakaa - MHS050392",
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false),
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          style: IconButton.styleFrom(backgroundColor: Colors.red.shade50),
        ),
      ],
    );
  }
}