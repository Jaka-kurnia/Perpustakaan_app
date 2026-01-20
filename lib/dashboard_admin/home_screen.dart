import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpustakaan_app/dashboard_admin/tabs/denda_tab.dart';
import 'package:perpustakaan_app/dashboard_admin/tabs/kunjungan_tab.dart';
import 'package:perpustakaan_app/dashboard_admin/tabs/perpanjangan_tab.dart';
import 'widgets/stat_card.dart';
import 'widgets/menu_chip.dart';
import 'tabs/buku_tab.dart';
import 'tabs/peminjaman_tab.dart';
import '../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String activeMenu = "Buku";

  Widget getActiveTabContent() {
    switch (activeMenu) {
      case "Buku": return const BukuTab();
      case "Peminjaman": return const PeminjamanTab();
      case "Perpanjangan": return const AdminPerpanjanganPage();
      case "Denda": return const DendaTab();
      case "Kunjungan": return const KunjunganTab();
      default: return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Admin Panel", style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
            Text("PI-BOOK LP3I", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ringkasan Data", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // --- GRID STATISTIK ADMIN ---
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
              children: [
                // Total Buku - Biru (Informasi Stok)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('books').snapshots(),
                  builder: (context, snapshot) {
                    int total = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return StatCard(
                      title: "Total Buku",
                      value: total.toString(),
                      subtitle: "Koleksi tersedia",
                      color: Colors.blue.shade700,
                      icon: Icons.book,
                    );
                  },
                ),
                // Pending Pinjam - Kuning (Antrean Aksi)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('peminjaman').where('status', isEqualTo: 'pending').snapshots(),
                  builder: (context, snapshot) {
                    int total = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return StatCard(
                      title: "Pending",
                      value: total.toString(),
                      subtitle: "Perlu disetujui",
                      color: Colors.orange.shade600,
                      icon: Icons.pending_actions,
                    );
                  },
                ),
                // Perpanjangan - Hijau (Aktivitas)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('perpanjangan').where('status', isEqualTo: 'pending').snapshots(),
                  builder: (context, snapshot) {
                    int total = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return StatCard(
                      title: "Perpanjangan",
                      value: total.toString(),
                      subtitle: "Request masuk",
                      color: Colors.teal.shade600,
                      icon: Icons.history_rounded,
                    );
                  },
                ),
                // Total Denda - Merah (Urgent/Finance)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('denda').where('status', isEqualTo: 'belum lunas').snapshots(),
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
                      subtitle: "Belum terbayar",
                      color: Colors.redAccent.shade700,
                      icon: Icons.account_balance_wallet,
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            const Text("Menu Kelola", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // --- MENU NAVIGATION ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ["Buku", "Peminjaman", "Perpanjangan", "Denda", "Kunjungan"]
                    .map((menu) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: MenuChip(
                            title: menu,
                            isActive: activeMenu == menu,
                            onTap: () => setState(() => activeMenu = menu),
                          ),
                        ))
                    .toList(),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // --- TAB CONTENT ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: getActiveTabContent(),
            ),
          ],
        ),
      ),
    );
  }
}