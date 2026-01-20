import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPerpanjanganPage extends StatelessWidget {
  const AdminPerpanjanganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('perpanjangan')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada pengajuan'));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final String idPeminjaman = data['id_peminjaman'] ?? '-';
            final Timestamp? tanggalAjuan = data['tanggal_ajuan'];

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text('ID Peminjaman: $idPeminjaman'),
                subtitle: Text(
                  tanggalAjuan == null
                      ? 'Tanggal pengajuan tidak tersedia'
                      : 'Diajukan: ${DateFormat('dd-MM-yyyy').format(
                    tanggalAjuan.toDate(),
                  )}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: idPeminjaman == '-'
                          ? null
                          : () => _approve(doc.id, idPeminjaman),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('perpanjangan')
                            .doc(doc.id)
                            .update({'status': 'ditolak'});
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

  Future<void> _approve(
      String perpanjanganId,
      String peminjamanId,
      ) async {

    final peminjamanRef = FirebaseFirestore.instance
        .collection('peminjaman')
        .doc(peminjamanId);

    final peminjamanSnap = await peminjamanRef.get();

    if (!peminjamanSnap.exists) return;

    final data = peminjamanSnap.data() as Map<String, dynamic>;
    final Timestamp? tempoTimestamp = data['tanggal_jatuh_tempo'];

    if (tempoTimestamp == null) return;

    final DateTime tempoLama = tempoTimestamp.toDate();

    await peminjamanRef.update({
      'tanggal_jatuh_tempo':
      Timestamp.fromDate(tempoLama.add(const Duration(days: 7))),
    });

    await FirebaseFirestore.instance
        .collection('perpanjangan')
        .doc(perpanjanganId)
        .update({
      'status': 'disetujui',
      'tanggal_disetujui': Timestamp.now(),
    });
  }
}
