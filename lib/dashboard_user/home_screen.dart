import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/katalog_tab.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/pinjam_buku.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/peminjaman_saya.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/denda.dart'; // Pastikan path benar
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
    
    // Koleksi 'books' bersifat umum (semua koleksi perpustakaan)
    if (collection == 'books') {
      return query.snapshots();
    }
    
    // Koleksi denda/peminjaman difilter berdasarkan id_user (NIM)
    var filteredQuery = query.where('id_user', isEqualTo: currentNim);
    if (status != null) {
      filteredQuery = filteredQuery.where('status', isEqualTo: status);
    }
    return filteredQuery.snapshots();
  }

  // Fungsi helper untuk merender Card secara dinamis dari Firebase
  Widget _buildStatItem(String title, String coll, Color color, IconData icon, String sub, {String? status, bool isCurrency = false}) {
    return StreamBuilder<QuerySnapshot>(
      stream: getStatStream(coll, status: status),
      builder: (context, snapshot) {
        String displayValue = "0";
        
        if (snapshot.hasData) {
          if (isCurrency) {
            // Logika SUM (Menjumlahkan nominal denda)
            double totalNominal = 0;
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              totalNominal += (data['jumlah'] ?? 0).toDouble();
            }
            displayValue = "Rp ${totalNominal.toInt()}";
          } else {
            // Logika COUNT (Menghitung jumlah dokumen)
            displayValue = snapshot.data!.docs.length.toString();
          }
        }

        return StatCard(
          title: title,
          value: displayValue,
          subtitle: sub,
          color: color,
          icon: icon,
        );
      },
    );
  }

  Widget getActiveTabContent() {
    switch (activeMenu) {
      case "Peminjaman Saya": return const PeminjamanSayaTab();
      case "Denda": return const DendaTab(); // Gunakan tab denda user Anda
      case "Surat Bebas": return const SuratBebasTab();
      case "Pinjam Buku": return PinjamBukuTab(nimUser: nimUser);;
      case "Katalog": return const KatalogTab();
      default: return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
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
              
              // GRID STATISTIK DINAMIS
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  _buildStatItem("Total Koleksi", 'books', const Color(0xFF4CAF50), Icons.auto_stories, "Buku tersedia"),
                  _buildStatItem("Denda Aktif", 'denda', const Color(0xFFF44336), Icons.priority_high, "Total tagihan", status: 'belum lunas', isCurrency: true),
                  _buildStatItem("Pending", 'peminjaman', const Color(0xFFFFB300), Icons.hourglass_top, "Menunggu admin", status: 'pending'),
                  _buildStatItem("Pinjaman Aktif", 'peminjaman', const Color(0xFF2196F3), Icons.check_circle_outline, "Buku di tangan", status: 'dipinjam'),
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
                    String displayName = "Memuat...";
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                      displayName = data['nama'] ?? "User";
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

  Widget _buildMenuNav() {
    return SingleChildScrollView(
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