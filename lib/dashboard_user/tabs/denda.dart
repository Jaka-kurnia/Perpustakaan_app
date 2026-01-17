import 'package:flutter/material.dart';

class DendaTab extends StatelessWidget {
  const DendaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          "Denda Keterlambatan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Informasi denda peminjaman",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 20),

        // Kartu Total Denda (Pink Box)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0), // Warna background pink muda
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Denda",
                    style: TextStyle(
                      color: Color(0xFFB71C1C), 
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rp 1.000 per hari keterlambatan",
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ],
              ),
              const Text(
                "Rp 0",
                style: TextStyle(
                  color: Colors.red, 
                  fontSize: 28, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Tabel Denda
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 40,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: Colors.black,
                  ),
                  columns: const [
                    DataColumn(label: Text("Buku")),
                    DataColumn(label: Text("Jatuh Tempo")),
                    DataColumn(label: Text("Hari Terlambat")),
                    DataColumn(label: Text("Denda")),
                  ],
                  rows: const [], // Data masih kosong sesuai gambar
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  "Tidak ada denda",
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