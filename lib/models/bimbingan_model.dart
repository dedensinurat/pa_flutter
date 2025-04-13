class Bimbingan {
  final int bimbinganId;
  final String keperluan;
  final String deskripsi;
  final DateTime rencanaBimbingan;
  final String status;

  Bimbingan({
    required this.bimbinganId,
    required this.keperluan,
    required this.deskripsi,
    required this.rencanaBimbingan,
    required this.status,
  });

  factory Bimbingan.fromJson(Map<String, dynamic> json) {
    return Bimbingan(
      bimbinganId: json['bimbingan_id'],
      keperluan: json['keperluan'],
      deskripsi: json['deskripsi'],
      rencanaBimbingan: DateTime.parse(json['rencana_bimbingan']),
      status: json['status'],
    );
  }
}
