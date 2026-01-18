import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class KunjunganUserTab extends StatefulWidget {
  const KunjunganUserTab({super.key});

  @override
  State<KunjunganUserTab> createState() => _KunjunganUserTabState();
}

class _KunjunganUserTabState extends State<KunjunganUserTab> {
  String? idUser;
  String? namaUser;

  bool isLoading = true;
  bool isSubmitting = false;

  String selectedTujuan = "berkunjung";

  final List<String> tujuanList = [
    "berkunjung",
    "pinjam buku",
    "mengembalikan buku",
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _ambilUser();
  }

  /// =======================
  /// AMBIL DATA USER
  /// =======================
  Future<void> _ambilUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      idUser = doc['id_user'];
      namaUser = doc['nama'];
    }

    setState(() => isLoading = false);
  }

  /// =======================
  /// SIMPAN KUNJUNGAN
  /// =======================
  Future<void> _submit() async {
    if (idUser == null || namaUser == null) return;

    setState(() => isSubmitting = true);

    // Cegah 2x kunjungan dalam 1 hari
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final dup = await FirebaseFirestore.instance
        .collection('kunjungan')
        .where('id_user', isEqualTo: idUser)
        .where(
          'tanggal_kunjungan',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where(
          'tanggal_kunjungan',
          isLessThan: Timestamp.fromDate(end),
        )
        .get();

    if (dup.docs.isNotEmpty) {
      _snack("Anda sudah mengisi kunjungan hari ini", Colors.orange);
      setState(() => isSubmitting = false);
      return;
    }

    await FirebaseFirestore.instance.collection('kunjungan').add({
      'id_user': idUser,
      'nama': namaUser,
      'tujuan': selectedTujuan,
      'tanggal_kunjungan': FieldValue.serverTimestamp(),
    });

    _snack("Kunjungan berhasil disimpan", Colors.green);
    setState(() => isSubmitting = false);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  /// =======================
  /// UI
  /// =======================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (idUser == null || namaUser == null) {
      return const Center(child: Text("Gagal memuat data user"));
    }

    final tanggal =
        DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Daftar Kunjungan",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _form(tanggal),

          const SizedBox(height: 24),
          _riwayat(),
        ],
      ),
    );
  }

  /// =======================
  /// FORM
  /// =======================
  Widget _form(String tanggal) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _readonly("ID User", idUser!),
            _readonly("Nama", namaUser!),
            _readonly("Tanggal", tanggal),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedTujuan,
              items: tujuanList
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedTujuan = v!),
              decoration: const InputDecoration(labelText: "Tujuan Kunjungan"),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submit,
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("SIMPAN KUNJUNGAN"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _readonly(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  /// =======================
  /// RIWAYAT KUNJUNGAN
  /// =======================
  Widget _riwayat() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('kunjungan')
          .where('id_user', isEqualTo: idUser)
          .orderBy('tanggal_kunjungan', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("Belum ada kunjungan");
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final tgl = (doc['tanggal_kunjungan'] as Timestamp?)?.toDate();
            return ListTile(
              leading: const Icon(Icons.library_books),
              title: Text(doc['tujuan']),
              subtitle: Text(
                tgl == null
                    ? "-"
                    : DateFormat('dd MMM yyyy HH:mm').format(tgl),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
NEXT