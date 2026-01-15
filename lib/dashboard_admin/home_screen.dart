import 'package:flutter/material.dart';

void main() {
  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const LibraryDashboard(),
    );
  }
}

class LibraryDashboard extends StatelessWidget {
  const LibraryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Admin Perpustakaan LP3I", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.logout, color: Colors.black)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row untuk Statistik Atas
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard("Total Buku", "8", Colors.black),
                _buildStatCard("Pending Pinjam", "0", Colors.orange),
                _buildStatCard("Pending Perpanjang", "0", Colors.blue),
                _buildStatCard("Total Denda", "Rp 0", Colors.red),
              ],
            ),
            const SizedBox(height: 20),

            // Menu Tab Bar Sederhana
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["Buku", "Peminjaman", "Perpanjangan", "Denda", "Kunjungan"].map((tab) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: tab == "Buku" ? Colors.white : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(tab, style: TextStyle(fontWeight: tab == "Buku" ? FontWeight.bold : FontWeight.normal)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Bagian Manajemen Buku
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Manajemen Buku", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Kelola koleksi buku perpustakaan", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Tambah"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                )
              ],
            ),
            const SizedBox(height: 15),

            // List Buku (Versi Mobile Card agar lebih rapi)
            _buildBookItem("BK001", "Pemrograman Web", "Ahmad Rizki", "5", "3"),
            _buildBookItem("BK002", "Basis Data", "Siti Aminah", "4", "3"),
            _buildBookItem("BK003", "Sistem Informasi", "Budi Santoso", "3", "0"),
            _buildBookItem("BK004", "Jaringan Komputer", "Dewi Lestari", "6", "5"),
          ],
        ),
      ),
    );
  }

  // Widget untuk Card Statistik
  Widget _buildStatCard(String title, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  // Widget untuk List Buku
  Widget _buildBookItem(String code, String title, String author, String stock, String available) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(author, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ],
            ),
          ),
          Column(
            children: [
              const Text("Tersedia", style: TextStyle(fontSize: 10)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: available == "0" ? Colors.red : Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Text(available, style: const TextStyle(color: Colors.white, fontSize: 12)),
              )
            ],
          )
        ],
      ),
    );
  }
}