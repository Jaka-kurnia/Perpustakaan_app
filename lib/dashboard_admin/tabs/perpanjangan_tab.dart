import 'package:flutter/material.dart';

class PerpanjanganTab extends StatelessWidget {
  const PerpanjanganTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Perpanjangan Peminjaman",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Kelola pengajuan perpanjangan",
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
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 30,
                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  columns: const [
                    DataColumn(label: Text("NIM")),
                    DataColumn(label: Text("Nama")),
                    DataColumn(label: Text("Buku")),
                    DataColumn(label: Text("Jatuh Tempo Saat Ini")),
                    DataColumn(label: Text("Jatuh Tempo Baru")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Aksi")),
                  ],
                  rows: const [], // Data kosong
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  "Belum ada pengajuan perpanjangan",
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