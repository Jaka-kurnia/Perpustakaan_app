import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PerpanjanganTab extends StatelessWidget {
  const PerpanjanganTab({super.key});

  Future<String> _getField(
    String collection,
    String fieldCari,
    String value,
    String fieldAmbil,
  ) async {
    try {
      final q = await FirebaseFirestore.instance
          .collection(collection)
          .where(fieldCari, isEqualTo: value)
          .limit(1)
          .get();

      if (q.docs.isNotEmpty) {
        final data = q.docs.first.data() as Map<String, dynamic>?;
        return data?[fieldAmbil]?.toString() ?? "-";
      }
      return "-";
    } catch (e) {
      return "-";
    }
  }

  Future<void> _proses(
    BuildContext context,
    String docId,
    String status, {
    String? catatan,
  }) async {
    try {
      final perpanjanganRef =
          FirebaseFirestore.instance.collection('perpanjangan').doc(docId);

      await perpanjanganRef.update({
        'status': status,
        'tanggal_proses': Timestamp.now(),
        if (catatan != null) 'catatan': catatan,
      });

      if (status == 'disetujui') {
        final perpanjanganData = (await perpanjanganRef.get()).data()!;
        final peminjamanId = perpanjanganData['id_peminjaman'];

        final peminjamanRef = FirebaseFirestore.instance
            .collection('peminjaman')
            .doc(peminjamanId);

        final peminjamanDoc = await peminjamanRef.get();
        final peminjamanData = peminjamanDoc.data() as Map<String, dynamic>;
        final oldDate = peminjamanData['tanggal_jatuh_tempo'] as Timestamp;

        await peminjamanRef.update({
          'tanggal_jatuh_tempo':
              oldDate.toDate().add(const Duration(days: 7)),
          'status': 'dipinjam', // Kembalikan status dari 'diperpanjang' ke 'dipinjam'
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Perpanjangan $status"),
          backgroundColor:
              status == 'disetujui' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

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
              DataColumn(label: Text("Aksi")),
            ],
            rows: snap.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final tanggal =
                  (data['tanggal_ajukan'] as Timestamp).toDate();

              return DataRow(cells: [
                DataCell(Text(data['id_user'])),

                DataCell(FutureBuilder<String>(
                  future: _getField(
                      'users', 'nim', data['id_user'], 'nama'),
                  builder: (_, s) => Text(s.data ?? "..."),
                )),

                DataCell(FutureBuilder<String>(
                  future: _getField(
                      'peminjaman', 'id', data['id_peminjaman'], 'kode_buku'),
                  builder: (_, kode) {
                    if (!kode.hasData) return const Text("...");
                    return FutureBuilder<String>(
                      future: _getField(
                          'books', 'kode_buku', kode.data!, 'judul'),
                      builder: (_, j) => Text(j.data ?? "..."),
                    );
                  },
                )),

                DataCell(Text(DateFormat('dd-MM-yyyy').format(tanggal))),
                DataCell(_badge(data['status'])),

                DataCell(Row(
                  children: [
                    if (data['status'] == 'pending') ...[
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () =>
                            _dialog(context, doc.id, 'disetujui'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () =>
                            _dialog(context, doc.id, 'ditolak'),
                      ),
                    ],
                    if (data['status'] != 'pending')
                      const Icon(Icons.check_circle, color: Colors.grey),
                  ],
                )),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }

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
      child: Text(status.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }

  void _dialog(BuildContext context, String id, String status) {
    final c = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(status == 'disetujui'
            ? "Setujui Perpanjangan"
            : "Tolak Perpanjangan"),
        content: status == 'ditolak'
            ? TextField(controller: c, decoration: const InputDecoration(labelText: "Catatan"))
            : null,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _proses(context, id, status,
                  catatan: status == 'ditolak' ? c.text : null);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}
