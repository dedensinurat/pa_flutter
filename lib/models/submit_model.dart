class Submit {
  final int submitId;
  final String judul;
  final String instruksi;
  final String file;
  final String batas;
  final int userId;

  Submit({
    required this.submitId,
    required this.judul,
    required this.instruksi,
    required this.file,
    required this.batas,
    required this.userId,
  });

  factory Submit.fromJson(Map<String, dynamic> json) {
    return Submit(
      submitId: json['submit_id'],
      judul: json['judul'],
      instruksi: json['instruksi'],
      file: json['file'],
      batas: json['batas'],
      userId: json['user_id'],
    );
  }
}
