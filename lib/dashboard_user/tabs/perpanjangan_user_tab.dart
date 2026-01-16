import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PerpanjanganUserTab extends StatefulWidget {
  const PerpanjanganUserTab({super.key});

  @override
  State<PerpanjanganUserTab> createState() => _PerpanjanganUserTabState();
}

class _PerpanjanganUserTabState extends State<PerpanjanganUserTab> {
  final String nimUser = "2024001";

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('peminjaman')
          .where('id_user', isEqualTo: nimUser)
          .where('status', isEqualTo: 'dipinjam')
          .snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.data!.docs.isEmpty) {
          return const Center(child: Text("Tidak ada buku dipinjam"));
        }

        return ListView(
          children: snap.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final pinjam = data['tanggal_pinjam'] is Timestamp 
                ? (data['tanggal_pinjam'] as Timestamp).toDate()
                : DateTime.parse(data['tanggal_pinjam'].toString());
            final tempo = data['tanggal_jatuh_tempo'] is Timestamp 
                ? (data['tanggal_jatuh_tempo'] as Timestamp).toDate()
                : DateTime.parse(data['tanggal_jatuh_tempo'].toString());

            return Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('books')
                          .where('kode_buku',
                              isEqualTo: data['kode_buku'])
                          .limit(1)
                          .get()
                          .then((v) => v.docs.first),
                      builder: (_, b) => Text(
                        b.hasData ? b.data!['judul'] : "...",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text("Kode: ${data['kode_buku']}"),
                    Text(
                        "Pinjam: ${DateFormat('dd-MM-yyyy').format(pinjam)}"),
                    Text(
                        "Jatuh Tempo: ${DateFormat('dd-MM-yyyy').format(tempo)}"),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('perpanjangan')
                          .where('id_peminjaman', isEqualTo: doc.id)
                          .snapshots(),
                      builder: (_, p) {
                        final pending = p.hasData &&
                            p.data!.docs.any((d) =>
                                d['status'] == 'pending');

                        return pending
                            ? const Text("Sedang diajukan",
                                style:
                                    TextStyle(color: Colors.orange))
                            : ElevatedButton(
                                onPressed: () =>
                                    _ajukan(doc.id),
                                child: const Text("Ajukan Perpanjangan"),
                              );
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _ajukan(String peminjamanId) async {
    await FirebaseFirestore.instance.collection('perpanjangan').add({
      'id_user': nimUser,
      'id_peminjaman': peminjamanId,
      'tanggal_ajukan': Timestamp.now(),
      'status': 'pending',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pengajuan berhasil"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
