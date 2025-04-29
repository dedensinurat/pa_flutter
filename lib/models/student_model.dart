class Student {
  final int dimId;
  final int userId;
  final String userName;
  final String nim;
  final String nama;
  final String email;
  final int prodiId;
  final String prodiName;
  final String fakultas;
  final int angkatan;
  final String status;
  final String asrama;

  Student({
    required this.dimId,
    required this.userId,
    required this.userName,
    required this.nim,
    required this.nama,
    required this.email,
    required this.prodiId,
    required this.prodiName,
    required this.fakultas,
    required this.angkatan,
    required this.status,
    required this.asrama,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      dimId: json['dim_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      nim: json['nim'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      prodiId: json['prodi_id'] ?? 0,
      prodiName: json['prodi_name'] ?? '',
      fakultas: json['fakultas'] ?? '',
      angkatan: json['angkatan'] ?? 0,
      status: json['status'] ?? '',
      asrama: json['asrama'] ?? '',
    );
  }
}