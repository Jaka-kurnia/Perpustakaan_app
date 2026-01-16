import 'package:flutter/material.dart';

class BookItem extends StatelessWidget {
  final String code;
  final String title;
  final String author;
  final String available;

  const BookItem({
    super.key,
    required this.code,
    required this.title,
    required this.author,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(author, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ],
            ),
          ),
          Column(
            children: [
              const Text("Tersedia", style: TextStyle(fontSize: 10)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: available == "0" ? Colors.red : Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  available,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}