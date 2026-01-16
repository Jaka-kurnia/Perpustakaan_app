import 'package:flutter/material.dart';

class PeminjamanTab extends StatelessWidget {
  const PeminjamanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul dan Deskripsi sesuai gambar
        const Text(
          "Persetujuan Peminjaman",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Kelola pengajuan peminjaman buku",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 20),

        // Container Tabel
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
              )
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Agar tabel bisa digeser ke kanan-kiri
            child: DataTable(
              columnSpacing: 25,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              columns: const [
                DataColumn(label: Text("NIM")),
                DataColumn(label: Text("Nama")),
                DataColumn(label: Text("Kode Buku")),
                DataColumn(label: Text("Judul")),
                DataColumn(label: Text("Tanggal")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Aksi")),
              ],
              rows: const [], // Kosong karena belum ada data
            ),
          ),
        ),
        
        // Pesan "Belum ada pengajuan" jika data kosong
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              "Belum ada pengajuan peminjaman",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}