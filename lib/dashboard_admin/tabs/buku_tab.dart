import 'package:flutter/material.dart';
import '../widgets/book_item.dart';

class BukuTab extends StatelessWidget {
  const BukuTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Manajemen Buku", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Kelola koleksi buku perpustakaan", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Tambah"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        const BookItem(code: "BK001", title: "Pemrograman Web", author: "Ahmad Rizki", available: "3"),
        const BookItem(code: "BK002", title: "Basis Data", author: "Siti Aminah", available: "3"),
        const BookItem(code: "BK003", title: "Sistem Informasi", author: "Budi Santoso", available: "0"),
        const BookItem(code: "BK004", title: "Jaringan Komputer", author: "Dewi Lestari", available: "5"),
      ],
    );
  }
}