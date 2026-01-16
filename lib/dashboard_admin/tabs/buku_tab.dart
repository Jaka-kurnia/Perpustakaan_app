import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/book_item.dart';

class BukuTab extends StatefulWidget { // Ubah ke StatefulWidget agar lebih fleksibel
  const BukuTab({super.key});

  @override
  State<BukuTab> createState() => _BukuTabState();
}

class _BukuTabState extends State<BukuTab> {
  // Controller untuk mengambil input dari modal
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _kodeController = TextEditingController();
  final TextEditingController _penulisController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  // Fungsi untuk mengirim data ke Firebase
  Future<void> _tambahBuku() async {
    if (_judulController.text.isEmpty || _kodeController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('books').add({
      'judul': _judulController.text,
      'kode_buku': _kodeController.text,
      'penulis': _penulisController.text,
      'stok': int.tryParse(_stokController.text) ?? 0,
      'status': (int.tryParse(_stokController.text) ?? 0) > 0 ? "Tersedia" : "Habis",
    });

    // Reset form dan tutup modal
    _judulController.clear();
    _kodeController.clear();
    _penulisController.clear();
    _stokController.clear();
    Navigator.pop(context);
  }

  // Fungsi untuk memunculkan Modal Bottom Sheet
  void _showAddForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar modal tidak terpotong keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Penyesuaian keyboard
          left: 20, right: 20, top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tambah Buku Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: _kodeController, decoration: const InputDecoration(labelText: "Kode Buku (Contoh: BK001)")),
              TextField(controller: _judulController, decoration: const InputDecoration(labelText: "Judul Buku")),
              TextField(controller: _penulisController, decoration: const InputDecoration(labelText: "Penulis")),
              TextField(controller: _stokController, decoration: const InputDecoration(labelText: "Jumlah Stok"), keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _tambahBuku,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Text("Simpan Koleksi", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Manajemen Buku", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Kelola koleksi buku perpustakaan", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showAddForm, // Panggil fungsi modal di sini
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Tambah"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('books').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
            if (!snapshot.hasData) return const Text("Data Kosong");
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return BookItem(
                  code: data['kode_buku'] ?? '-',
                  title: data['judul'] ?? '-',
                  author: data['penulis'] ?? '-',
                  available: data['stok']?.toString() ?? '0',
                );
              },
            );
          },
        ),
      ],
    );
  }
}