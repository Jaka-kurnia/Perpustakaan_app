import 'package:flutter/material.dart';

class KunjunganTab extends StatefulWidget {
  const KunjunganTab({super.key});

  @override
  State<KunjunganTab> createState() => _KunjunganTabState();
}

class _KunjunganTabState extends State<KunjunganTab> {
  bool isModeKunjungan = false; // State untuk switch

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header dengan Switch
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Daftar Kunjungan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Kelola kunjungan mahasiswa ke perpustakaan",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            // Widget Switch sesuai gambar
            // Row(
            //   children: [
            //     const Text("Mode Kunjungan", style: TextStyle(fontSize: 12)),
            //     Switch(
            //       value: isModeKunjungan,
            //       onChanged: (value) {
            //         setState(() {
            //           isModeKunjungan = value;
            //         });
            //       },
            //       activeColor: Colors.black,
            //     ),
            //   ],
            // ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Container Tabel Kunjungan
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
                  columnSpacing: 40,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: Colors.black,
                  ),
                  columns: const [
                    DataColumn(label: Text("NIM")),
                    DataColumn(label: Text("Nama")),
                    DataColumn(label: Text("Keperluan")),
                    DataColumn(label: Text("Tanggal & Waktu")),
                  ],
                  rows: const [], // Data masih kosong
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  "Belum ada kunjungan",
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