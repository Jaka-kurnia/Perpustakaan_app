import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:perpustakaan_app/dashboard_user/tabs/katalog_tab.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/pinjam_buku.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/peminjaman_saya.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/denda.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/surat_bebas.dart';
import 'package:perpustakaan_app/dashboard_user/tabs/kunjungan_user_tab.dart';
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

  // ================= STREAM STATISTIK =================
  Stream<QuerySnapshot> getStatStream(
      String collection,
      String currentId, {
        String? status,
      }) {
    final query = FirebaseFirestore.instance.collection(collection);

    if (collection == 'books') {
      return query.snapshots();
    }

    Query filtered = query.where('id_user', isEqualTo: currentId);

    if (status != null) {
      filtered = filtered.where('status', isEqualTo: status);
    }

    return filtered.snapshots();
  }

  // ================= CARD STATISTIK =================
  Widget _buildStatItem(
      String title,
      String coll,
      Color color,
      IconData icon,
      String sub,
      String currentId, {
        String? status,
        bool isCurrency = false,
      }) {
    return StreamBuilder<QuerySnapshot>(
      stream: getStatStream(coll, currentId, status: status),
      builder: (_, snapshot) {
        String displayValue = "0";

        if (snapshot.hasData) {
          if (isCurrency) {
            double total = 0;
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              total += (data['jumlah'] ?? 0).toDouble();
            }
            displayValue = "Rp ${total.toInt()}";
          } else {
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
      case "Denda": return const DendaTab();
      case "Surat Bebas": return const SuratBebasTab();
      case "Pinjam Buku": return PinjamBukuTab(nimUser: idUser); // idUser dikirim sebagai NIM
      case "Kunjungan": return KunjunganUserTab();
      case "Katalog": return const KatalogTab();
      default: return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ================= AMBIL DATA LOGIN =================
    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String idUser = args?['id_user'] ?? "";
    final String namaUser = args?['nama'] ?? "User";

    // ================= SWITCH MENU =================
    Widget getActiveTabContent() {
      switch (activeMenu) {
        case "Katalog":
          return const KatalogTab();
        case "Pinjam Buku":
          return PinjamBukuTab(
            nimUser: idUser,
            namaUser: namaUser,
          );
        case "Peminjaman Saya":
          return const PeminjamanSayaTab();
        case "Perpanjangan":
          return PerpanjanganUserTab(nimUser: idUser);
        case "Denda":
          return const DendaTab();
        case "Surat Bebas":
          return const SuratBebasTab();
        default:
          return const SizedBox();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, idUser, namaUser),
              const SizedBox(height: 30),

              const Text(
                "Statistik Saya",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  _buildStatItem(
                    "Total Koleksi",
                    'books',
                    const Color(0xFF4CAF50),
                    Icons.auto_stories,
                    "Buku tersedia",
                    idUser,
                  ),
                  _buildStatItem(
                    "Denda Aktif",
                    'denda',
                    const Color(0xFFF44336),
                    Icons.priority_high,
                    "Total tagihan",
                    idUser,
                    status: 'belum lunas',
                    isCurrency: true,
                  ),
                  _buildStatItem(
                    "Pending",
                    'peminjaman',
                    const Color(0xFFFFB300),
                    Icons.hourglass_top,
                    "Menunggu admin",
                    idUser,
                    status: 'pending',
                  ),
                  _buildStatItem(
                    "Pinjaman Aktif",
                    'peminjaman',
                    const Color(0xFF2196F3),
                    Icons.check_circle_outline,
                    "Buku di tangan",
                    idUser,
                    status: 'dipinjam',
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _buildMenuNav(),
              const SizedBox(height: 25),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(activeMenu),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
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

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context, String id, String nama) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PI-BOOK LP3I",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "$nama - $id",
                  style: const TextStyle(
                      fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
                (route) => false,
          ),
          icon: const Icon(Icons.logout_rounded,
              color: Colors.redAccent),
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.shade50,
          ),
        ),
      ],
    );
  }

  // ================= MENU NAV =================
  Widget _buildMenuNav() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: ["Katalog", "Pinjam Buku", "Peminjaman Saya", "Denda", "Kunjungan", "Surat Bebas"]
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
}
