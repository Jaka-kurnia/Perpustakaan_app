import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KatalogTab extends StatefulWidget {
  const KatalogTab({super.key});

  @override
  State<KatalogTab> createState() => _KatalogTabState();
}

class _KatalogTabState extends State<KatalogTab> {
  String _searchQuery = ""; // Variabel untuk menyimpan input pencarian

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

        // Search Bar (Dinamis)
        TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase(); // Update query saat mengetik
            });
          },
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

        // Tabel Katalog Buku Dinamis
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('books').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Tidak ada data buku"));
            }

            // Filter data secara lokal berdasarkan search query
            var filteredDocs = snapshot.data!.docs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              var judul = (data['judul'] ?? "").toString().toLowerCase();
              var penulis = (data['penulis'] ?? "").toString().toLowerCase();
              var kode = (data['kode_buku'] ?? "").toString().toLowerCase();
              
              return judul.contains(_searchQuery) || 
                     penulis.contains(_searchQuery) || 
                     kode.contains(_searchQuery);
            }).toList();

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
                ],
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
                  rows: filteredDocs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    int stok = data['stok'] ?? 0;
                    bool isAvailable = stok > 0;

                    return _buildDataRow(
                      data['kode_buku'] ?? "-",
                      data['judul'] ?? "-",
                      data['penulis'] ?? "-",
                      data['kategori'] ?? "Umum",
                      stok.toString(),
                      isAvailable,
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Helper untuk membuat baris data dengan Label Status sesuai desain
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