import 'package:flutter/material.dart';

class PinjamBukuTab extends StatelessWidget {
  const PinjamBukuTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pinjam Buku",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Ajukan peminjaman buku baru",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 20),

        // Menggunakan Wrap agar layout responsif (Kiri & Kanan)
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            // --- BAGIAN KIRI: INPUT KODE BUKU ---
            Container(
              width: 350, // Sesuaikan lebar box kiri
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Input Kode Buku", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text("Masukkan kode buku yang tertera di sampul buku", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 20),
                  
                  const Text("Kode Buku", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Contoh: BK001",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.shopping_cart_outlined, size: 18, color: Colors.white),
                        label: const Text("Tambah", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Box Catatan
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Catatan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(height: 4),
                        Text(
                          "Pengambilan buku fisik tetap dilakukan langsung di Perpustakaan LP3I. Jangan lupa mengisi daftar kunjungan saat datang ke perpustakaan.",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- BAGIAN KANAN: KERANJANG ---
            Container(
              width: 350, // Sesuaikan lebar box kanan
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Keranjang Peminjaman (0)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text("Buku yang akan dipinjam", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 50),
                  
                  const Center(
                    child: Text(
                      "Keranjang kosong. Tambahkan buku untuk meminjam.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}