import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SuratBebasUserTab extends StatefulWidget {
  const SuratBebasUserTab({super.key});

  @override
  State<SuratBebasUserTab> createState() => _SuratBebasUserTabState();
}

class _SuratBebasUserTabState extends State<SuratBebasUserTab> {
  // SIMULASI USER LOGIN
  final String nimUser = "2024001";

  bool _isLoading = false;
  bool? _isBebas;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  // ================= INIT =================
  Future<void> _initData() async {
    await _loadUserData();
    _isBebas = await _checkBebasPinjaman();
    setState(() {});
  }

  // ================= LOAD USER =================
  Future<void> _loadUserData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('nim', isEqualTo: nimUser)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      _userData = snapshot.docs.first.data();
    }
  }

  // ================= CEK BEBAS PINJAMAN =================
  Future<bool> _checkBebasPinjaman() async {
    // Cek buku yang masih dipinjam
    final pinjamanAktif = await FirebaseFirestore.instance
        .collection('peminjaman')
        .where('id_user', isEqualTo: nimUser)
        .where('status', whereIn: ['dipinjam', 'terlambat'])
        .get();

    if (pinjamanAktif.docs.isNotEmpty) return false;

    // Cek denda
    final dendaAktif = await FirebaseFirestore.instance
        .collection('peminjaman')
        .where('id_user', isEqualTo: nimUser)
        .where('total_denda', isGreaterThan: 0)
        .get();

    if (dendaAktif.docs.isNotEmpty) return false;

    return true;
  }

  // ================= GENERATE SURAT =================
  Future<void> _generateSurat() async {
    if (_isBebas != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Anda belum bebas pinjaman atau denda"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final tanggal = DateFormat('dd MMMM yyyy').format(now);

      final suratContent = """
SURAT KETERANGAN BEBAS PINJAMAN DAN DENDA

Nama  : ${_userData!['nama']}
NIM   : ${_userData!['nim']}

Berdasarkan hasil pemeriksaan sistem perpustakaan pada tanggal $tanggal,
mahasiswa tersebut dinyatakan:

✓ Tidak memiliki buku yang sedang dipinjam
✓ Tidak memiliki denda aktif

Dengan demikian mahasiswa tersebut DINYATAKAN BEBAS
dari kewajiban perpustakaan.

Surat ini digunakan sebagai persyaratan pengambilan ijazah.

Perpustakaan LP3I
$tanggal
""";

      await FirebaseFirestore.instance.collection('surat_bebas').add({
        'id_user': nimUser,
        'nama': _userData!['nama'],
        'nim': _userData!['nim'],
        'tanggal_terbit': Timestamp.now(),
        'status': 'berlaku',
        'konten': suratContent,
      });

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Surat bebas berhasil dibuat"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal membuat surat: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (_userData == null || _isBebas == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Surat Bebas Pinjaman",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // USER CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, size: 30),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData!['nama'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("NIM: ${_userData!['nim']}"),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // STATUS
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isBebas! ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _isBebas! ? Icons.check_circle : Icons.error,
                  color: _isBebas! ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isBebas!
                        ? "ANDA SUDAH BEBAS PINJAMAN & DENDA"
                        : "ANDA MASIH MEMILIKI KEWAJIBAN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          _isBebas! ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateSurat,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.description),
              label: Text(_isLoading ? "Memproses..." : "Generate Surat"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
