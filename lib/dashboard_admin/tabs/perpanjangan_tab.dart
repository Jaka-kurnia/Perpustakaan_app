import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PerpanjanganTab extends StatelessWidget {
  const PerpanjanganTab({super.key});

  // ================= GET NAMA USER =================
  Future<String> _getNamaUser(String nim) async {
    if (nim.isEmpty) return "-";

    final q = await FirebaseFirestore.instance
        .collection('users')
        .where('nim', isEqualTo: nim)
        .limit(1)
        .get();

    return q.docs.isNotEmpty
        ? q.docs.first.data()['nama']?.toString() ?? "-"
        : "-";
  }

  // ================= GET JUDUL BUKU =================
  Future<String> _getJudulBuku(String idPinjam) async {
    if (idPinjam.isEmpty) return "-";

    // 1️⃣ cari peminjaman
    final pinjamQ = await FirebaseFirestore.instance
        .collection('peminjaman')
        .where('id_pinjam', isEqualTo: idPinjam)
        .limit(1)
        .get();

    if (pinjamQ.docs.isEmpty) return "-";

    final kodeBuku = pinjamQ.docs.first.data()['kode_buku'];
    if (kodeBuku == null) return "-";

    // 2️⃣ cari buku
    final bukuQ = await FirebaseFirestore.instance
        .collection('books')
        .where('kode_buku', isEqualTo: kodeBuku)
        .limit(1)
        .get();

    return bukuQ.docs.isNotEmpty
        ? bukuQ.docs.first.data()['judul']?.toString() ?? "-"
        : "-";
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('perpanjangan')
          .orderBy('tanggal_ajukan', descending: true)
          .snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.data!.docs.isEmpty) {
          return const Center(child: Text("Tidak ada pengajuan"));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text("NIM")),
              DataColumn(label: Text("Nama")),
              DataColumn(label: Text("Judul Buku")),
              DataColumn(label: Text("Tanggal Ajukan")),
              DataColumn(label: Text("Status")),
            ],
            rows: snap.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final nim = data['id_user']?.toString() ?? "-";
              final idPinjam = data['id_pinjam']?.toString() ?? "";
              final status = data['status']?.toString() ?? "-";

              DateTime tanggalAjukan = DateTime.now();
              if (data['tanggal_ajukan'] is Timestamp) {
                tanggalAjukan =
                    (data['tanggal_ajukan'] as Timestamp).toDate();
              }

              return DataRow(cells: [
                DataCell(Text(nim)),

                DataCell(
                  FutureBuilder<String>(
                    future: _getNamaUser(nim),
                    builder: (_, s) => Text(s.data ?? "..."),
                  ),
                ),

                DataCell(
                  FutureBuilder<String>(
                    future: _getJudulBuku(idPinjam),
                    builder: (_, s) => Text(s.data ?? "..."),
                  ),
                ),

                DataCell(
                  Text(DateFormat('dd-MM-yyyy').format(tanggalAjukan)),
                ),

                DataCell(_badge(status)),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }

  // ================= BADGE =================
  Widget _badge(String status) {
    final color = status == 'pending'
        ? Colors.orange
        : status == 'disetujui'
        ? Colors.green
        : Colors.red;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration:
      BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
