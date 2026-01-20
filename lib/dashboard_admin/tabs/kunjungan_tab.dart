import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class KunjunganTab extends StatefulWidget {
  const KunjunganTab({super.key});

  @override
  State<KunjunganTab> createState() => _KunjunganTabState();
}

class _KunjunganTabState extends State<KunjunganTab> {
  bool isModeKunjungan = false;

  @override
  void initState() {
    super.initState();
    _loadKunjunganMode();
  }

  void _loadKunjunganMode() {
    // Baca state dari Firestore
    FirebaseFirestore.instance
        .collection('settings')
        .doc('kunjungan')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          isModeKunjungan = data['is_active'] ?? false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= HEADER =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Daftar Kunjungan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Kelola kunjungan mahasiswa ke perpustakaan",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              // SWITCH
              Row(
                children: [
                  const Text(
                    "Mode Kunjungan",
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: isModeKunjungan,
                    onChanged: (value) async {
                      setState(() {
                        isModeKunjungan = value;
                      });
                      
                      // Simpan state ke Firestore
                      await FirebaseFirestore.instance
                          .collection('settings')
                          .doc('kunjungan')
                          .set({
                            'is_active': value,
                            'updated_at': Timestamp.now(),
                          });
                    },
                    activeColor: Colors.black,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ================= CONTAINER TABLE =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: isModeKunjungan
                ? _buildKunjunganTable()
                : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  // ================= EMPTY MODE =================
  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.toggle_off,
            size: 50,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            "Mode Kunjungan Dinonaktifkan",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Aktifkan switch untuk melihat data kunjungan",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ================= FIREBASE TABLE =================
  Widget _buildKunjunganTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('kunjungan')
          .orderBy('tanggal_kunjungan', descending: true)
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                "Belum ada kunjungan",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return Column(
          children: [

            // ================= STATISTIK =================
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    "Total Kunjungan",
                    docs.length.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    "Hari Ini",
                    _getTodayVisits(docs),
                    Icons.today,
                    Colors.green,
                  ),
                ],
              ),
            ),

            // ================= TABLE =================
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                columnSpacing: 40,
                columns: const [
                  DataColumn(label: Text("NIM")),
                  DataColumn(label: Text("Nama")),
                  DataColumn(label: Text("Keperluan")),
                  DataColumn(label: Text("Tanggal & Waktu")),
                ],
                rows: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  DateTime tanggal =
                      (data['tanggal_kunjungan'] as Timestamp).toDate();

                  return DataRow(
                    cells: [
                      DataCell(Text(data['id_user'] ?? "-")),
                      DataCell(Text(data['nama'] ?? "-")),
                      DataCell(Text(data['tujuan'] ?? "-")),
                      DataCell(
                        Text(
                          DateFormat('dd-MM-yyyy HH:mm')
                              .format(tanggal),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= STAT CARD =================
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ================= HITUNG HARI INI =================
  String _getTodayVisits(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    final start =
        DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    int count = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final tanggal =
          (data['tanggal_kunjungan'] as Timestamp).toDate();

      if (tanggal.isAfter(start) &&
          tanggal.isBefore(end)) {
        count++;
      }
    }

    return count.toString();
  }
}
