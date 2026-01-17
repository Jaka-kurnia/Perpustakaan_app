
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DendaTab extends StatelessWidget {
  const DendaTab({super.key});

  // ================= HITUNG DENDA =================
  int _hitungDenda(DateTime jatuhTempo) {
    final now = DateTime.now();

    if (now.isBefore(jatuhTempo)) return 0;

    final terlambat = now.difference(jatuhTempo).inDays;
    return terlambat * 1000; // Rp 1000 / hari
  }

  // ================= GET USER =================
  Future<String> _getNamaUser(String nim) async {
    if (nim.isEmpty) return "-";

    final q = await FirebaseFirestore.instance
        .collection('users')
        .where('nim', isEqualTo: nim)
        .limit(1)
        .get();

    if (q.docs.isNotEmpty) {
      return q.docs.first.data()['nama']?.toString() ?? nim;
    }
    return nim;
  }

  // ================= GET BUKU =================
  Future<String> _getJudulBuku(String kode) async {
    if (kode.isEmpty) return "-";

    final q = await FirebaseFirestore.instance
        .collection('books')
        .where('kode_buku', isEqualTo: kode)
        .limit(1)
        .get();

    if (q.docs.isNotEmpty) {
      return q.docs.first.data()['judul']?.toString() ?? kode;
    }
    return kode;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('peminjaman')
          .where('status', isEqualTo: 'dipinjam') // hanya yang belum dikembalikan
          .snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("Tidak ada data peminjaman"));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text("NIM")),
              DataColumn(label: Text("Nama")),
              DataColumn(label: Text("Buku")),
              DataColumn(label: Text("Jatuh Tempo")),
              DataColumn(label: Text("Terlambat")),
              DataColumn(label: Text("Total Denda")),
              DataColumn(label: Text("Status")),
            ],
            rows: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              if (data['tanggal_jatuh_tempo'] is! Timestamp) {
                return const DataRow(cells: []);
              }

              final jatuhTempo =
                  (data['tanggal_jatuh_tempo'] as Timestamp).toDate();

              final denda = _hitungDenda(jatuhTempo);
              if (denda == 0) {
                return const DataRow(cells: []);
              }

              return DataRow(cells: [
                DataCell(Text(data['id_user'] ?? "-")),

                DataCell(FutureBuilder<String>(
                  future: _getNamaUser(data['id_user'] ?? ""),
                  builder: (_, s) => Text(s.data ?? "..."),
                )),

                DataCell(FutureBuilder<String>(
                  future: _getJudulBuku(data['kode_buku'] ?? ""),
                  builder: (_, s) => Text(s.data ?? "..."),
                )),

                DataCell(Text(
                    DateFormat('dd-MM-yyyy').format(jatuhTempo))),

                DataCell(Text(
                  "${DateTime.now().difference(jatuhTempo).inDays} hari",
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                )),

                DataCell(Text(
                  "Rp $denda",
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                )),

                DataCell(Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "Belum Lunas",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                )),
              ]);
            }).where((row) => row.cells.isNotEmpty).toList(),
          ),
        );
      },
    );
  }
}
