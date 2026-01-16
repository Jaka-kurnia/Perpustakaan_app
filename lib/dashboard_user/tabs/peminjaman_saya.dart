import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PeminjamanSayaTab extends StatelessWidget {
  const PeminjamanSayaTab({super.key});

  // Fungsi untuk mengambil Judul Buku berdasarkan kode_buku dari koleksi 'books'
  Future<String> _getBookTitle(String kode) async {
    var bookQuery = await FirebaseFirestore.instance
        .collection('books')
        .where('kode_buku', isEqualTo: kode)
        .limit(1)
        .get();

    if (bookQuery.docs.isNotEmpty) {
      return bookQuery.docs.first.data()['judul'] ?? "Buku";
    }
    return "Judul tidak ditemukan";
  }

  // Fungsi untuk menghitung Jatuh Tempo (Misal: 7 hari setelah tanggal pinjam)
  String _calculateDueDate(String dateString) {
    try {
      DateTime pinjam = DateTime.parse(dateString);
      DateTime tempo = pinjam.add(const Duration(days: 7));
      return DateFormat('dd MMM yyyy').format(tempo);
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simulasi NIM user yang login (Pastikan ini sama dengan id_user saat input di PinjamBukuTab)
    const String nimLogin = "2024001"; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        
        StreamBuilder<QuerySnapshot>(
          // Query hanya data milik user yang sedang login
          stream: FirebaseFirestore.instance
              .collection('peminjaman')
              .where('id_user', isEqualTo: nimLogin)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            return Container(
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
                  rows: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String tanggalPinjam = data['tanggal_pinjam'] ?? "";
                    
                    return DataRow(cells: [
                      DataCell(Text(data['kode_buku'] ?? "-")),
                      // Relasi ke koleksi Books untuk ambil judul
                      DataCell(FutureBuilder<String>(
                        future: _getBookTitle(data['kode_buku']),
                        builder: (context, res) => Text(res.data ?? "Loading..."),
                      )),
                      DataCell(Text(tanggalPinjam != "" 
                          ? DateFormat('dd MMM yyyy').format(DateTime.parse(tanggalPinjam)) 
                          : "-")),
                      DataCell(Text(_calculateDueDate(tanggalPinjam))),
                      DataCell(_buildStatusBadge(data['status'] ?? "pending")),
                      DataCell(
                        data['status'] == 'pending' 
                        ? TextButton(
                            onPressed: () => _batalkanPeminjaman(doc.id),
                            child: const Text("Batalkan", style: TextStyle(color: Colors.red, fontSize: 12)),
                          )
                        : const Text("-", style: TextStyle(color: Colors.grey)),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }


  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          "Belum ada peminjaman",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'dipinjam': color = Colors.blue; break;
      case 'ditolak': color = Colors.red; break;
      case 'dikembalikan': color = Colors.green; break;
      default: color = Colors.orange; // Untuk 'pending'
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _batalkanPeminjaman(String docId) async {
    await FirebaseFirestore.instance.collection('peminjaman').doc(docId).delete();
  }
}