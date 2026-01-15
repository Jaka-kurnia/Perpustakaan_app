import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data User')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Data User kosong'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return buildUserList(docs, index);
            },
          );
        },
      ),
    );
  }
}

Widget buildUserList(List<DocumentSnapshot> docs, int index) {
  User user = User.fromMap(
    docs[index].id,
    docs[index].data() as Map<String, dynamic>,
  );

  return ListTile(
    title: Text(user.nama),
    subtitle: Text(
      'Role: ${user.role} | NIM: ${user.nim ?? '-'} | NIP: ${user.nip ?? '-'}',
    ),
  );
}