import 'package:flutter/material.dart';

class PeminjamanSayaTab extends StatelessWidget {
  const PeminjamanSayaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Judul & Deskripsi
        const Text(
          "Peminjaman Saya",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Riwayat dan status peminjaman buku",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        
        // Container Card untuk Tabel
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              )
            ],
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Agar bisa scroll horizontal
                child: DataTable(
                  columnSpacing: 30,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: Colors.black,
                  ),
                  columns: const [
                    DataColumn(label: Text("Kode")),
                    DataColumn(label: Text("Judul")),
                    DataColumn(label: Text("Tanggal Pinjam")),
                    DataColumn(label: Text("Jatuh Tempo")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Aksi")),
                  ],
                  rows: const [], // Data masih kosong sesuai gambar
                ),
              ),
              // Pesan Empty State
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  "Belum ada peminjaman",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}