import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpustakaan_app/dashboard_admin/tabs/denda_tab.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/katalog_tab.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/pinjam_buku.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/peminjaman_saya.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/denda.dart' hide DendaTab;
import 'package:perpustakaan_app/dashboard_user/tabs/surat_bebas.dart';
import 'package:perpustakaan_app/routes/app_routes.dart';
import 'widgets/stat_card.dart';
import 'widgets/menu_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String activeMenu = "Katalog";
  String? nimUser;

  // Stream data statistik yang terfilter berdasarkan NIM yang sedang login
  Stream<QuerySnapshot> getStatStream(String collection, {String? status}) {
    String currentNim = nimUser ?? "";
    var query = FirebaseFirestore.instance.collection(collection);
    
    if (collection == 'books') {
      return query.snapshots();
    }
    
    var filteredQuery = query.where('id_user', isEqualTo: currentNim);
    if (status != null) {
      filteredQuery = filteredQuery.where('status', isEqualTo: status);
    }
    return filteredQuery.snapshots();
  }

  Widget getActiveTabContent() {
    switch (activeMenu) {
      case "Peminjaman Saya": return const PeminjamanSayaTab();
      case "Denda": return const DendaTab();
      case "Surat Bebas": return const SuratBebasTab();
      case "Pinjam Buku": return const PinjamBukuTab();
      case "Katalog": return const KatalogTab();
      default: return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menangkap NIM yang dikirim dari LoginScreen
    nimUser = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 30),
              const Text("Statistik Saya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  _buildStatItem("Total Koleksi", 'books', const Color(0xFF4CAF50), Icons.auto_stories, "Semua kategori"),
                  _buildStatItem("Denda Aktif", 'denda', const Color(0xFFF44336), Icons.priority_high, "Segera lunasi", status: 'belum lunas'),
                  _buildStatItem("Pending", 'peminjaman', const Color(0xFFFFB300), Icons.hourglass_top, "Verifikasi admin", status: 'pending'),
                  _buildStatItem("Pinjaman Aktif", 'peminjaman', const Color(0xFF2196F3), Icons.check_circle_outline, "Sedang dipinjam", status: 'dipinjam'),
                ],
              ),
              const SizedBox(height: 32),
              _buildMenuNav(),
              const SizedBox(height: 25),
              _buildTabContent(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Header yang mengambil nama User dari Firestore berdasarkan NIM
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("PI-BOOK LP3I", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').where('nim', isEqualTo: nimUser).snapshots(),
                  builder: (context, snapshot) {
                    String displayName = "Loading...";
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                      displayName = data['nama'] ?? "No Name";
                    }
                    return Text("$displayName - $nimUser", style: const TextStyle(fontSize: 12, color: Colors.blueGrey));
                  },
                ),
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

  // Widget helper untuk StatCard agar kode lebih bersih
  Widget _buildStatItem(String title, String coll, Color color, IconData icon, String sub, {String? status}) {
    return StreamBuilder<QuerySnapshot>(
      stream: getStatStream(coll, status: status),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return StatCard(title: title, value: count.toString(), subtitle: sub, color: color, icon: icon);
      },
    );
  }

  Widget _buildMenuNav() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
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
    );
  }

  Widget _buildTabContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(activeMenu),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
        ),
        child: Padding(padding: const EdgeInsets.all(20.0), child: getActiveTabContent()),
      ),
    );
  }
}