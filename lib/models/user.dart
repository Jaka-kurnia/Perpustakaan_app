class User {
  final String id;
  final String nama;
  final String role;
  final String? nim;
  final String? nip;

  User({
    required this.id,
    required this.nama,
    required this.role,
    this.nim,
    this.nip,
  });


  factory User.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return User(
      id: id,
      nama: data['nama'] ?? '',
      role: data['role'] ?? '',
      nim: data['nim'],
      nip: data['nip'],
    );
  }

  /// 🔽 Dari Object ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'role': role,
      'nim': nim,
      'nip': nip,
    };
  }
}
