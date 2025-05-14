class Submit {
  final int id;
  final int userId;
  final String judulTugas;
  final String deskripsiTugas;
  final int kpaId;
  final int prodiId;
  final int tmId;
  final String tanggalPengumpulan;
  final String file;
  final String status;
  final String kategoriTugas;
  final String? createdAt;
  final String? updatedAt;

  // Relasi
  final Prodi? prodi;
  final KategoriPA? kategoriPA;
  final TahunAjaran? tahunMasuk;
  final List<PengumpulanTugas>? pengumpulanTugas;
  
  // Derived fields for UI convenience
  String get submissionStatus {
    if (pengumpulanTugas != null && pengumpulanTugas!.isNotEmpty) {
      return pengumpulanTugas![0].status;
    }
    return 'Belum';
  }
  
  String get submissionFile {
    if (pengumpulanTugas != null && pengumpulanTugas!.isNotEmpty) {
      return pengumpulanTugas![0].filePath;
    }
    return '';
  }
  
  String? get submissionDate {
    if (pengumpulanTugas != null && pengumpulanTugas!.isNotEmpty) {
      return pengumpulanTugas![0].waktuSubmit;
    }
    return null;
  }

  // Check if the submission has a valid file
  bool get hasValidSubmission {
    return pengumpulanTugas != null && 
           pengumpulanTugas!.isNotEmpty && 
           pengumpulanTugas![0].filePath.isNotEmpty;
  }

  Submit({
    required this.id,
    required this.userId,
    required this.judulTugas,
    required this.deskripsiTugas,
    required this.kpaId,
    required this.prodiId,
    required this.tmId,
    required this.tanggalPengumpulan,
    required this.file,
    this.status = 'berlangsung',
    this.kategoriTugas = 'Tugas',
    this.createdAt,
    this.updatedAt,
    this.prodi,
    this.kategoriPA,
    this.tahunMasuk,
    this.pengumpulanTugas,
  });

  factory Submit.fromJson(Map<String, dynamic> json) {
    // Debug print to see the raw JSON
    print('Parsing Submit from JSON: ${json.keys}');
    
    try {
      return Submit(
        id: json['id'] ?? 0,
        userId: json['user_id'] ?? 0,
        judulTugas: json['judul_tugas'] ?? '',
        deskripsiTugas: json['deskripsi_tugas'] ?? '',
        kpaId: json['kpa_id'] ?? 0,
        prodiId: json['prodi_id'] ?? 0,
        tmId: json['tm_id'] ?? 0,
        tanggalPengumpulan: json['tanggal_pengumpulan'] ?? '',
        file: json['file'] ?? '',
        status: json['status'] ?? 'berlangsung',
        kategoriTugas: json['kategori_tugas'] ?? 'Tugas',
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        prodi: json['prodi'] != null ? Prodi.fromJson(json['prodi']) : null,
        kategoriPA: json['kategori_pa'] != null ? KategoriPA.fromJson(json['kategori_pa']) : null,
        tahunMasuk: json['tahun_masuk'] != null ? TahunAjaran.fromJson(json['tahun_masuk']) : null,
        pengumpulanTugas: json['pengumpulan_tugas'] != null 
            ? (json['pengumpulan_tugas'] as List).map((item) => PengumpulanTugas.fromJson(item)).toList()
            : null,
      );
    } catch (e) {
      print('Error parsing Submit: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'judul_tugas': judulTugas,
      'deskripsi_tugas': deskripsiTugas,
      'kpa_id': kpaId,
      'prodi_id': prodiId,
      'tm_id': tmId,
      'tanggal_pengumpulan': tanggalPengumpulan,
      'file': file,
      'status': status,
      'kategori_tugas': kategoriTugas,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'prodi': prodi?.toJson(),
      'kategori_pa': kategoriPA?.toJson(),
      'tahun_masuk': tahunMasuk?.toJson(),
      'pengumpulan_tugas': pengumpulanTugas?.map((item) => item.toJson()).toList(),
    };
  }
}

class PengumpulanTugas {
  final int id;
  final int kelompokId;
  final int tugasId;
  final String waktuSubmit;
  final String filePath;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  PengumpulanTugas({
    required this.id,
    required this.kelompokId,
    required this.tugasId,
    required this.waktuSubmit,
    required this.filePath,
    this.status = 'Belum',
    this.createdAt,
    this.updatedAt,
  });

  factory PengumpulanTugas.fromJson(Map<String, dynamic> json) {
    // Debug print to see the raw JSON
    print('Parsing PengumpulanTugas from JSON: ${json.keys}');
    
    try {
      return PengumpulanTugas(
        id: json['id'] ?? 0,
        kelompokId: json['kelompok_id'] ?? 0,
        tugasId: json['tugas_id'] ?? 0,
        waktuSubmit: json['waktu_submit'] ?? '',
        filePath: json['file_path'] ?? '',
        status: json['status'] ?? 'Belum',
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );
    } catch (e) {
      print('Error parsing PengumpulanTugas: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kelompok_id': kelompokId,
      'tugas_id': tugasId,
      'waktu_submit': waktuSubmit,
      'file_path': filePath,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Prodi {
  final int id;
  final String namaProdi;
  final int maksProject;
  final String? createdAt;
  final String? updatedAt;

  Prodi({
    required this.id,
    required this.namaProdi,
    required this.maksProject,
    this.createdAt,
    this.updatedAt,
  });

  factory Prodi.fromJson(Map<String, dynamic> json) {
    try {
      return Prodi(
        id: json['id'] ?? 0,
        namaProdi: json['nama_prodi'] ?? '',
        maksProject: json['maks_project'] ?? 0,
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );
    } catch (e) {
      print('Error parsing Prodi: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_prodi': namaProdi,
      'maks_project': maksProject,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class KategoriPA {
  final int id;
  final String kategoriPA;
  final String? createdAt;
  final String? updatedAt;

  KategoriPA({
    required this.id,
    required this.kategoriPA,
    this.createdAt,
    this.updatedAt,
  });

  factory KategoriPA.fromJson(Map<String, dynamic> json) {
    try {
      return KategoriPA(
        id: json['id'] ?? 0,
        kategoriPA: json['kategori_pa'] ?? '',
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );
    } catch (e) {
      print('Error parsing KategoriPA: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kategori_pa': kategoriPA,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class TahunAjaran {
  final int id;
  final String tahunAjaran;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  TahunAjaran({
    required this.id,
    required this.tahunAjaran,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory TahunAjaran.fromJson(Map<String, dynamic> json) {
    try {
      return TahunAjaran(
        id: json['id'] ?? 0,
        tahunAjaran: json['tahun_ajaran'] ?? '',
        status: json['status'] ?? 'Aktif',
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );
    } catch (e) {
      print('Error parsing TahunAjaran: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tahun_ajaran': tahunAjaran,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
