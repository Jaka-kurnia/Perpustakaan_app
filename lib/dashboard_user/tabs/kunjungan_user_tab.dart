import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class KunjunganUserTab extends StatefulWidget {
  const KunjunganUserTab({super.key});

  @override
  State<KunjunganUserTab> createState() => _KunjunganUserTabState();
}

class _KunjunganUserTabState extends State<KunjunganUserTab> {
  final String nimUser = "2024001"; // Simulasi NIM User Login

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Riwayat Kunjungan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Daftar kunjungan Anda ke perpustakaan",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              )
            ],
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('kunjungan')
                .where('id_user', isEqualTo: nimUser)
                .orderBy('tanggal_kunjungan', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    "Belum ada riwayat kunjungan",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var kunjunganDoc = snapshot.data!.docs[index];
                  var kunjunganData = kunjunganDoc.data() as Map<String, dynamic>;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.history,
                          color: Colors.blue.shade800,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        kunjunganData['nama_pengunjung'] ?? 'Pengunjung',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            "NIM: ${kunjunganData['nim_nip'] ?? ''}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            "Tanggal: ${(kunjunganData['tanggal_kunjungan'] as Timestamp).toDate().toString().substring(0, 10)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (kunjunganData['keperluan'] != null)
                            Text(
                              "Keperluan: ${kunjunganData['keperluan']}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          if (kunjunganData['jam_masuk'] != null)
                            Text(
                              "Masuk: ${(kunjunganData['jam_masuk'] as Timestamp).toDate().toString().substring(11, 16)}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          if (kunjunganData['jam_keluar'] != null)
                            Text(
                              "Keluar: ${(kunjunganData['jam_keluar'] as Timestamp).toDate().toString().substring(11, 16)}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      trailing: Text(
                        DateFormat('dd MMM yyyy').format(
                          (kunjunganData['tanggal_kunjungan'] as Timestamp).toDate(),
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
