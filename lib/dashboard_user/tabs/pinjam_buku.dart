import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PinjamBukuTab extends StatefulWidget {
  final String? nimUser;
  final String? namaUser;
  const PinjamBukuTab({super.key, this.nimUser, this.namaUser});

  @override
  State<PinjamBukuTab> createState() => _PinjamBukuTabState();
}

class _PinjamBukuTabState extends State<PinjamBukuTab> {
  final TextEditingController _kodeBukuController = TextEditingController();
  bool _isLoading = false;

  final Color primaryColor = const Color(0xFF6366F1);

  Future<void> _kirimPengajuan() async {
    if (_kodeBukuController.text.isEmpty) {
      _showSnackBar("Masukkan kode buku terlebih dahulu!", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('peminjaman').add({
        'id_user': widget.nimUser,
        'nama': widget.namaUser,
        'kode_buku': _kodeBukuController.text.trim().toUpperCase(),
        'status': 'pending',
        'tanggal_pinjam': DateTime.now().toIso8601String(),
        'tanggal_dikembalikan': "-",
      });

      _kodeBukuController.clear();
      _showSnackBar("Peminjaman berhasil diajukan!", Colors.green);
    } catch (e) {
      _showSnackBar("Terjadi kesalahan: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section - Lebih Ramping
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Ajukan Pinjam Buku",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Masukkan kode unik yang tertera pada buku.",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          // Main Card Input - Ukuran Dioptimalkan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Icon Decorative - Lebih Kecil
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_stories_rounded, color: primaryColor, size: 28),
                ),
                const SizedBox(height: 20),
                
                // Input Field - Font & Padding disesuaikan
                TextField(
                  controller: _kodeBukuController,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintText: "CONTOH: BKU-091",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, letterSpacing: 1),
                    labelText: "KODE BUKU",
                    labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: Icon(Icons.qr_code_2_rounded, color: primaryColor, size: 20),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button - Tinggi disesuaikan (Compact)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _kirimPengajuan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: primaryColor.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded, size: 18),
                              SizedBox(width: 10),
                              Text(
                                "Kirim Pengajuan",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // Info Panel - Lebih Slim
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Peminjaman memerlukan persetujuan pustakawan. Cek status di tab Riwayat.",
                    style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}