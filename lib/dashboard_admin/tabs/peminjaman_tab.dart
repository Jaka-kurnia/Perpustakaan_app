import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PeminjamanTab extends StatelessWidget {
  const PeminjamanTab({super.key});

  Future<String> _getRelasiData(String collection, String fieldCari, String value, String fieldAmbil) async {
    var query = await FirebaseFirestore.instance.collection(collection).where(fieldCari, isEqualTo: value).limit(1).get();
    return query.docs.isNotEmpty ? query.docs.first.data()[fieldAmbil] : "-";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Persetujuan Peminjaman", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("Kelola pengajuan peminjaman buku", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 20),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('peminjaman').orderBy('tanggal_pinjam', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("NIM")),
                    DataColumn(label: Text("Nama")),
                    DataColumn(label: Text("Judul Buku")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Aksi")),
                  ],
                  rows: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return DataRow(cells: [
                      DataCell(Text(data['id_user'])),
                      DataCell(FutureBuilder(future: _getRelasiData('users', 'nim', data['id_user'], 'nama'), builder: (context, s) => Text(s.data ?? "..."))),
                      DataCell(FutureBuilder(future: _getRelasiData('books', 'kode_buku', data['kode_buku'], 'judul'), builder: (context, s) => Text(s.data ?? "..."))),
                      DataCell(_statusBadge(data['status'])),
                      DataCell(Row(
                        children: [
                          IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => _prosesStatus(doc.id, "dipinjam")),
                          IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => _prosesStatus(doc.id, "ditolak")),
                        ],
                      )),
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

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: status == "pending" ? Colors.grey : Colors.blue, borderRadius: BorderRadius.circular(5)),
      child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }

  Future<void> _prosesStatus(String id, String status) async {
    await FirebaseFirestore.instance.collection('peminjaman').doc(id).update({'status': status});
  }
}