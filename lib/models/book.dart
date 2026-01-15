class Book {
  String id;
  String judul;
  String kodeBuku;
  String penulis;
  String status;
  int stok;

  Book({
    required this.id,
    required this.judul,
    required this.kodeBuku,
    required this.penulis,
    required this.status,
    required this.stok,
  });
  
  factory Book.fromMap(String id, Map<String, dynamic> data) {
    return Book(
      id: id,
      judul: data['judul'],
      kodeBuku: data['kode_buku'],
      penulis: data['penulis'],
      status: data['status'],
      stok: data['stok'],
    );
  }

  Map<String, dynamic>toMap(){
    return{
      'judul' : judul,
      'kode_buku' :kodeBuku,
      'penulis':penulis,
      'status' :status,
      'stok':stok,
    };
  }
}
