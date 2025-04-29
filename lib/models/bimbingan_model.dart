class Bimbingan {
  final int id;
  final int kelompokId;
  final int userId;
  final String keperluan;
  final DateTime rencanaMulai;
  final DateTime rencanaSelesai;
  final String lokasi;
  final String status;

  Bimbingan({
    required this.id,
    required this.kelompokId,
    required this.userId,
    required this.keperluan,
    required this.rencanaMulai,
    required this.rencanaSelesai,
    required this.lokasi,
    required this.status,
  });

  factory Bimbingan.fromJson(Map<String, dynamic> json) {
    return Bimbingan(
      id: json['id'],
      kelompokId: json['kelompok_id'],
      userId: json['user_id'],
      keperluan: json['keperluan'],
      rencanaMulai: DateTime.parse(json['rencana_mulai']),
      rencanaSelesai: DateTime.parse(json['rencana_selesai']),
      lokasi: json['lokasi'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keperluan': keperluan,
      'rencana_mulai': rencanaMulai.toIso8601String(),
      'rencana_selesai': rencanaSelesai.toIso8601String(),
      'lokasi': lokasi,
    };
  }
}
