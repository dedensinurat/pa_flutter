class Submit {
  final int id;
  final String judul;
  final String instruksi;
  final String batas;
  final String file;
  final int userId;
  final String status;
  final String prodi;
  final String kategoriPa;
  final String tahunAjaran;

  Submit({
    required this.id,
    required this.judul,
    required this.instruksi,
    required this.batas,
    required this.file,
    required this.userId,
    required this.status,
    required this.prodi,
    required this.kategoriPa,
    required this.tahunAjaran,
  });

  factory Submit.fromJson(Map<String, dynamic> json) {
    return Submit(
      id: json['id'],
      judul: json['judul'],
      instruksi: json['instruksi'],
      batas: json['batas'],
      file: json['file'] ?? '',
      userId: json['userId'],
      status: json['status'],
      prodi: json['prodi'],
      kategoriPa: json['kategori_pa'],
      tahunAjaran: json['tahun_ajaran'],
    );
  }
}