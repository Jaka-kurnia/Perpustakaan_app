import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/book.dart';

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Buku')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Data buku kosong'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return buildBookList(docs, index);
            },
          );
        },
      ),
    );
  }
}
Widget buildBookList(List<DocumentSnapshot> docs, int index) {
Book book = Book.fromMap(
  docs[index].id,
  docs[index].data() as Map<String, dynamic>,
);

return ListTile(
  title: Text(book.judul),
  subtitle: Text(
    'Kode: ${book.kodeBuku} | Stok: ${book.stok}',
  ),
  trailing: Text(book.status),
);
}
