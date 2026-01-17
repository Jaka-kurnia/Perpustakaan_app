import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PerpanjanganUserTab extends StatefulWidget {
  final String nimUser;

  const PerpanjanganUserTab({
    super.key,
    required this.nimUser,
  });

  @override
  State<PerpanjanganUserTab> createState() => _PerpanjanganUserTabState();
}

class _PerpanjanganUserTabState extends State<PerpanjanganUserTab> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('peminjaman')
          .where('id_user', isEqualTo: widget.nimUser)
          .where('status', isEqualTo: 'dipinjam')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Tidak ada buku dipinjam"));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final String idPinjam = data['id_pinjam'];
            final String kodeBuku = data['kode_buku'];

            final DateTime tanggalPinjam =
            (data['tanggal_pinjam'] as Timestamp).toDate();
            final DateTime jatuhTempo =
            (data['tanggal_jatuh_tempo'] as Timestamp).toDate();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// JUDUL BUKU
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('books')
                          .where('kode_buku', isEqualTo: kodeBuku)
                          .limit(1)
                          .get(),
                      builder: (_, bookSnap) {
                        if (!bookSnap.hasData ||
                            bookSnap.data!.docs.isEmpty) {
                          return const Text(
                            "Judul tidak ditemukan",
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          );
                        }

                        return Text(
                          bookSnap.data!.docs.first['judul'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        );
                      },
                    ),

                    const SizedBox(height: 6),
                    Text("Kode Buku : $kodeBuku"),
                    Text(
                        "Tanggal Pinjam : ${DateFormat('dd-MM-yyyy').format(tanggalPinjam)}"),
                    Text(
                        "Jatuh Tempo : ${DateFormat('dd-MM-yyyy').format(jatuhTempo)}"),

                    const SizedBox(height: 12),

                    /// CEK STATUS PERPANJANGAN
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('perpanjangan')
                          .where('id_pinjam', isEqualTo: idPinjam)
                          .where('status', isEqualTo: 'pending')
                          .snapshots(),
                      builder: (_, perpanjanganSnap) {
                        final bool sedangDiajukan =
                            perpanjanganSnap.hasData &&
                                perpanjanganSnap
                                    .data!.docs.isNotEmpty;

                        if (sedangDiajukan) {
                          return const Text(
                            "Sedang diajukan",
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600),
                          );
                        }

                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                _ajukanPerpanjangan(idPinjam),
                            child:
                            const Text("Ajukan Perpanjangan"),
                          ),
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

  /// SUBMIT PERPANJANGAN
  Future<void> _ajukanPerpanjangan(String idPinjam) async {
    await FirebaseFirestore.instance.collection('perpanjangan').add({
      'id_user': widget.nimUser,
      'id_pinjam': idPinjam,
      'tanggal_ajukan': Timestamp.now(),
      'status': 'pending',
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pengajuan perpanjangan berhasil"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
