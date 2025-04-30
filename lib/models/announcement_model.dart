class Announcement {
  final int id;
  final String judul;
  final String deskripsi;
  final DateTime tanggalPenulisan;
  final String? file;
  final String status;
  final int userId;
  final int kpaId;
  final int prodiId;
  final int tmId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Announcement({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.tanggalPenulisan,
    this.file,
    required this.status,
    required this.userId,
    required this.kpaId,
    required this.prodiId,
    required this.tmId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      tanggalPenulisan: DateTime.parse(json['tanggal_penulisan']),
      file: json['file'],
      status: json['status'],
      userId: json['user_id'],
      kpaId: json['kpa_id'],
      prodiId: json['prodi_id'],
      tmId: json['tm_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Helper method to format the date for display
  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(tanggalPenulisan);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${tanggalPenulisan.day}/${tanggalPenulisan.month}/${tanggalPenulisan.year}';
    }
  }
}