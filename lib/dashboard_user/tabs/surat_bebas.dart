import 'package:flutter/material.dart';

class SuratBebasTab extends StatelessWidget {
  const SuratBebasTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Judul dan Deskripsi
        const Text(
          "Surat Keterangan Bebas Perpustakaan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Surat ini diperlukan untuk pengambilan ijazah",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // Kotak Notifikasi "Anda Memenuhi Syarat" (Warna Hijau)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FFF4), // Background hijau sangat muda
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.assignment_turned_in_outlined, color: Colors.green, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Anda Memenuhi Syarat",
                      style: TextStyle(
                        color: Color(0xFF22543D), // Hijau tua
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Selamat! Anda dapat mengunduh surat keterangan bebas perpustakaan.",
                      style: TextStyle(color: Color(0xFF2F855A), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Bagian Persyaratan
        const Text(
          "Persyaratan:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildRequirementItem("Semua buku sudah dikembalikan"),
        _buildRequirementItem("Tidak ada denda yang belum dibayar"),
        const SizedBox(height: 32),

        // Tombol Unduh (Warna Hitam)
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              // Aksi unduh PDF
            },
            icon: const Icon(Icons.description_outlined, color: Colors.white, size: 20),
            label: const Text(
              "Unduh Surat Keterangan (PDF)",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget Helper untuk baris persyaratan dengan ikon centang
  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Color(0xFF2F855A), fontSize: 13),
          ),
        ],
      ),
    );
  }
}