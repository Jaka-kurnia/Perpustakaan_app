import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PeminjamanTab extends StatelessWidget {
  const PeminjamanTab({super.key});

  Future<String> _getRelasiData(String collection, String fieldCari, String value, String fieldAmbil) async {
    var query = await FirebaseFirestore.instance.collection(collection).where(fieldCari, isEqualTo: value).limit(1).get();
    return query.docs.isNotEmpty ? query.docs.first.data()[fieldAmbil] : "-";
  }

  Future<void> _prosesStatus(BuildContext context, String id, String status) async {
    await FirebaseFirestore.instance.collection('peminjaman').doc(id).update({'status': status});
  }

  Future<void> _prosesPengembalian(BuildContext context, String docId, Map<String, dynamic> data) async {
    try {
      // Hitung denda keterlambatan
      DateTime tanggalJatuhTempo = (data['tanggal_jatuh_tempo'] as Timestamp).toDate();
      DateTime tanggalKembali = DateTime.now();
      int hariTerlambat = tanggalKembali.difference(tanggalJatuhTempo).inDays;
      
      if (hariTerlambat > 0) {
        int dendaPerHari = 1000; // Rp 1000 per hari
        int totalDenda = hariTerlambat * dendaPerHari;
        
        // Update status peminjaman dengan denda
        await FirebaseFirestore.instance.collection('peminjaman').doc(docId).update({
          'status': 'dikembalikan',
          'tanggal_kembalikan': tanggalKembali,
          'is_denda': true,
          'total_denda': totalDenda,
        });
      } else {
        // Update status peminjaman tanpa denda
        await FirebaseFirestore.instance.collection('peminjaman').doc(docId).update({
          'status': 'dikembalikan',
          'tanggal_kembalikan': tanggalKembali,
          'is_denda': false,
          'total_denda': 0,
        });
      }

      // Update stok buku
      var bookQuery = await FirebaseFirestore.instance
          .collection('books')
          .where('kode_buku', isEqualTo: data['kode_buku'])
          .get();
      
      if (bookQuery.docs.isNotEmpty) {
        var bookDoc = bookQuery.docs.first;
        int currentStok = bookDoc['stok'] ?? 0;
        await bookDoc.reference.update({'stok': currentStok + 1});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(hariTerlambat > 0 
              ? "Buku berhasil dikembalikan. Denda: Rp ${(hariTerlambat * 1000)}"
              : "Buku berhasil dikembalikan"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengembalikan buku: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Manajemen Peminjaman", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("Kelola persetujuan dan pengembalian buku", style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                      DataCell(FutureBuilder(future: _getRelasiData('users', 'id_user', data['id_user'], 'nama'), builder: (context, s) => Text(s.data ?? "..."))),
                      DataCell(FutureBuilder(future: _getRelasiData('books', 'kode_buku', data['kode_buku'], 'judul'), builder: (context, s) => Text(s.data ?? "..."))),
                      DataCell(_statusBadge(data['status'])),
                      DataCell(Row(
                        children: [
                          if (data['status'] == 'pending')
                            IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => _prosesStatus(context, doc.id, "dipinjam")),
                          if (data['status'] == 'pending')
                            IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => _prosesStatus(context, doc.id, "ditolak")),
                          if (data['status'] == 'dipinjam')
                            IconButton(icon: const Icon(Icons.assignment_return, color: Colors.blue), onPressed: () => _prosesPengembalian(context, doc.id, data)),
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
    Color color;
    switch (status) {
      case "pending":
        color = Colors.grey;
        break;
      case "dipinjam":
        color = Colors.blue;
        break;
      case "ditolak":
        color = Colors.red;
        break;
      case "dikembalikan":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }
}
