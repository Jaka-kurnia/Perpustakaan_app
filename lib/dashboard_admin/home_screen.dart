import 'package:flutter/material.dart';

import '../screens/book/book_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LibraryDashboard();
  }
}

class LibraryDashboard extends StatelessWidget {
  const LibraryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      // ================= APP BAR =================
      appBar: AppBar(
        title: const Text(
          "Admin Perpustakaan PI-BOOK",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              // TODO: logout logic
            },
          ),
        ],
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== STATISTIK =====
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

            // ===== TAB MENU =====
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["Buku", "Peminjaman", "Perpanjangan", "Denda", "Kunjungan"]
                    .map((menu) => MenuChip(
                          title: menu,
                          isActive: menu == "Buku",
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ===== HEADER LIST BUKU =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Manajemen Buku",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Kelola koleksi buku perpustakaan",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: tambah buku
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Tambah"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 16),

            // ===== LIST BUKU =====
            const BookItem(
              code: "BK001",
              title: "Pemrograman Web",
              author: "Ahmad Rizki",
              available: "3",
            ),
            const BookItem(
              code: "BK002",
              title: "Basis Data",
              author: "Siti Aminah",
              available: "3",
            ),
            const BookItem(
              code: "BK003",
              title: "Sistem Informasi",
              author: "Budi Santoso",
              available: "0",
            ),
            const BookItem(
              code: "BK004",
              title: "Jaringan Komputer",
              author: "Dewi Lestari",
              available: "5",
            ),
          ],
        ),
      ),
    );
  }
}

//
// ================= COMPONENT =================
//

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class MenuChip extends StatelessWidget {
  final String title;
  final bool isActive;

  const MenuChip({
    super.key,
    required this.title,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class BookItem extends StatelessWidget {
  final String code;
  final String title;
  final String author;
  final String available;

  const BookItem({
    super.key,
    required this.code,
    required this.title,
    required this.author,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(author, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ],
            ),
          ),
          Column(
            children: [
              const Text("Tersedia", style: TextStyle(fontSize: 10)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: available == "0" ? Colors.red : Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  available,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
