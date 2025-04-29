class Submit {
  final int id;
  final String judul;
  final String instruksi;
  final String file;
  final String batas;
  final int userId;
  final String status;
  final String prodi;
  final String kategoriPA;
  final String tahunAjaran;
  final String submissionStatus;
  final String submissionFile;
  final String? submissionDate;

  Submit({
    required this.id,
    required this.judul,
    required this.instruksi,
    required this.file,
    required this.batas,
    required this.userId,
    this.status = 'berlangsung',
    this.prodi = '',
    this.kategoriPA = '',
    this.tahunAjaran = '',
    this.submissionStatus = 'Belum',
    this.submissionFile = '',
    this.submissionDate,
  });

  factory Submit.fromJson(Map<String, dynamic> json) {
    return Submit(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      instruksi: json['instruksi'] ?? '',
      file: json['file'] ?? '',
      batas: json['batas'] ?? '',
      userId: json['userId'] ?? 0,
      status: json['status'] ?? 'berlangsung',
      prodi: json['prodi'] ?? '',
      kategoriPA: json['kategori_pa'] ?? '',
      tahunAjaran: json['tahun_ajaran'] ?? '',
      submissionStatus: json['submission_status'] ?? 'Belum',
      submissionFile: json['submission_file'] ?? '',
      submissionDate: json['submission_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'instruksi': instruksi,
      'file': file,
      'batas': batas,
      'userId': userId,
      'status': status,
      'prodi': prodi,
      'kategori_pa': kategoriPA,
      'tahun_ajaran': tahunAjaran,
      'submission_status': submissionStatus,
      'submission_file': submissionFile,
      'submission_date': submissionDate,
    };
  }
}