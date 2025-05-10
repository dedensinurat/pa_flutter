class Ruangan {
  final int id;
  final String ruangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ruangan({
    required this.id,
    required this.ruangan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ruangan.fromJson(Map<String, dynamic> json) {
    return Ruangan(
      id: json['id'] ?? 0,
      ruangan: json['ruangan'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return ruangan;
  }
}
