import 'package:flutter/material.dart';

class KatalogTab extends StatelessWidget {
  const KatalogTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          "Katalog Buku",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Jelajahi koleksi buku perpustakaan",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 20),

        // Search Bar (Sesuai Gambar)
        TextField(
          decoration: InputDecoration(
            hintText: "Cari judul, penulis, atau kode buku...",
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Tabel Katalog Buku
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 35,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              columns: const [
                DataColumn(label: Text("Kode")),
                DataColumn(label: Text("Judul")),
                DataColumn(label: Text("Penulis")),
                DataColumn(label: Text("Kategori")),
                DataColumn(label: Text("Tersedia")),
                DataColumn(label: Text("Status")),
              ],
              rows: [
                _buildDataRow("BK001", "Pemrograman Web", "Ahmad Rizki", "Teknologi", "3", true),
                _buildDataRow("BK002", "Basis Data", "Siti Aminah", "Teknologi", "3", true),
                _buildDataRow("BK003", "Sistem Informasi", "Budi Santoso", "Teknologi", "0", false),
                _buildDataRow("BK004", "Jaringan Komputer", "Dewi Lestari", "Teknologi", "5", true),
                _buildDataRow("BK005", "Algoritma & Pemrograman", "Eko Wijaya", "Teknologi", "2", true),
                _buildDataRow("BK006", "Manajemen Proyek", "Fitri Handayani", "Manajemen", "5", true),
                _buildDataRow("BK007", "Akuntansi Dasar", "Hendra Gunawan", "Ekonomi", "3", true),
                _buildDataRow("BK008", "Pemasaran Digital", "Indah Permata", "Bisnis", "1", true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper untuk membuat baris data dengan Label Status
  DataRow _buildDataRow(String kode, String judul, String penulis, String kategori, String stok, bool isAvailable) {
    return DataRow(cells: [
      DataCell(Text(kode, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(judul)),
      DataCell(Text(penulis)),
      DataCell(Text(kategori)),
      DataCell(Text(stok)),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isAvailable ? Colors.black : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isAvailable ? "Tersedia" : "Habis",
            style: TextStyle(
              color: isAvailable ? Colors.white : Colors.grey.shade600,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ]);
  }
}