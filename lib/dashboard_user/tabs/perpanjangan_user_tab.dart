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

  /// ===============================
  /// CONVERTER TANGGAL ANTI ERROR
  /// ===============================
  DateTime _parseTanggal(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

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

            final String idPinjam = (data['id_pinjam'] ?? doc.id).toString();
            final String kodeBuku = (data['kode_buku'] ?? '-').toString();

            final DateTime tanggalPinjam =
            _parseTanggal(data['tanggal_pinjam']);
            final DateTime jatuhTempo =
            _parseTanggal(data['tanggal_jatuh_tempo']);

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

                    /// ===============================
                    /// JUDUL BUKU (AMAN)
                    /// ===============================
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
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }

                        return Text(
                          (bookSnap.data!.docs.first['judul'] ?? 'Tanpa Judul')
                              .toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),
                    Text("Kode Buku : $kodeBuku"),
                    Text(
                      "Tanggal Pinjam : ${DateFormat('dd-MM-yyyy').format(tanggalPinjam)}",
                    ),
                    Text(
                      "Jatuh Tempo : ${DateFormat('dd-MM-yyyy').format(jatuhTempo)}",
                    ),

                    const SizedBox(height: 12),

                    /// ===============================
                    /// STATUS PERPANJANGAN
                    /// ===============================
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('perpanjangan')
                          .where('id_pinjam', isEqualTo: idPinjam)
                          .snapshots(),
                      builder: (_, perpanjanganSnap) {
                        if (perpanjanganSnap.hasData &&
                            perpanjanganSnap.data!.docs.isNotEmpty) {

                          final status = perpanjanganSnap
                              .data!.docs.first['status']
                              .toString();

                          Color color = Colors.orange;
                          if (status == 'disetujui') color = Colors.green;
                          if (status == 'ditolak') color = Colors.red;

                          return Text(
                            "Status Perpanjangan : $status",
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }

                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                _ajukanPerpanjangan(idPinjam),
                            child: const Text("Ajukan Perpanjangan"),
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

  /// ===============================
  /// SUBMIT PERPANJANGAN (AMAN)
  /// ===============================
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
