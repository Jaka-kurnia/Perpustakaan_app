import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PinjamBukuTab extends StatefulWidget {
  const PinjamBukuTab({super.key, String? nimUser});

  @override
  State<PinjamBukuTab> createState() => _PinjamBukuTabState();
}

class _PinjamBukuTabState extends State<PinjamBukuTab> {
  final TextEditingController _kodeController = TextEditingController();
  List<Map<String, dynamic>> _keranjang = [];

  // 1. Fungsi Tambah ke Keranjang (Cek Firebase)
  Future<void> _tambahKeKeranjang() async {
    String kode = _kodeController.text.trim().toUpperCase();
    if (kode.isEmpty) return;

    if (_keranjang.any((item) => item['kode_buku'] == kode)) {
      _showSnackBar("Buku sudah ada di keranjang", Colors.orange);
      return;
    }

    var query = await FirebaseFirestore.instance
        .collection('books')
        .where('kode_buku', isEqualTo: kode)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      var data = query.docs.first.data();
      if (data['stok'] <= 0) {
        _showSnackBar("Stok buku habis", Colors.red);
        return;
      }

      setState(() {
        _keranjang.add({
          'kode_buku': data['kode_buku'],
          'judul': data['judul'],
        });
        _kodeController.clear();
      });
    } else {
      _showSnackBar("Kode buku tidak ditemukan", Colors.red);
    }
  }

  // 2. Fungsi Kirim Pengajuan ke Firebase
  Future<void> _kirimPengajuan() async {
    if (_keranjang.isEmpty) return;

    try {
      for (var item in _keranjang) {
        await FirebaseFirestore.instance.collection('peminjaman').add({
          'id_user': "2024001", // Simulasi NIM User Login
          'kode_buku': item['kode_buku'],
          'status': "pending",
          'tanggal_pinjam': DateTime.now().toIso8601String(),
          'tanggal_dikembalikan': "-",
        });
      }

      setState(() => _keranjang.clear());
      _showSnackBar("Pengajuan berhasil dikirim!", Colors.green);
    } catch (e) {
      _showSnackBar("Gagal mengirim pengajuan", Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pinjam Buku", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("Ajukan peminjaman buku baru", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20, runSpacing: 20,
          children: [
            _buildInputSection(),
            _buildCartSection(),
          ],
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Container(
      width: 350, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Input Kode Buku", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _kodeController,
                  decoration: InputDecoration(hintText: "Masukkan Kode Buku", filled: true, fillColor: Colors.grey.shade100, border: InputBorder.none),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _tambahKeKeranjang, style: ElevatedButton.styleFrom(backgroundColor: Colors.black), child: const Text("Tambah", style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartSection() {
    return Container(
      width: 350, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text("Keranjang (${_keranjang.length})", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (_keranjang.isEmpty) const Text("Keranjang Kosong", style: TextStyle(color: Colors.grey)),
          ..._keranjang.asMap().entries.map((e) => ListTile(
                title: Text(e.value['judul']),
                subtitle: Text(e.value['kode_buku']),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _keranjang.removeAt(e.key))),
              )),
          if (_keranjang.isNotEmpty)
            ElevatedButton(onPressed: _kirimPengajuan, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text("Ajukan Sekarang", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}