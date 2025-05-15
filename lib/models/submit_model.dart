class Submit {
  final int id;
  final int? userId;
  final String judulTugas;
  final String deskripsiTugas;
  final int? kpaId;
  final int? prodiId;
  final int? tmId;
  final String tanggalPengumpulan;
  final String file;
  final String? status;
  final String? kategoriTugas;
  final String? createdAt;
  final String? updatedAt;

  // Relasi
  final Prodi? prodi;
  final KategoriPA? kategoriPA;
  final TahunMasuk? tahunMasuk;
  final List<PengumpulanTugas>? pengumpulanTugas;
  
  // Derived fields for UI convenience
  final bool hasValidSubmission;
  final String submissionStatus;
  final String? submissionDate;
  final String submissionFile;

  Submit({
    required this.id,
    this.userId,
    required this.judulTugas,
    required this.deskripsiTugas,
    this.kpaId,
    this.prodiId,
    this.tmId,
    required this.tanggalPengumpulan,
    required this.file,
    this.status,
    this.kategoriTugas,
    this.createdAt,
    this.updatedAt,
    this.prodi,
    this.kategoriPA,
    this.tahunMasuk,
    this.pengumpulanTugas,
    this.hasValidSubmission = false,
    this.submissionStatus = '',
    this.submissionDate,
    this.submissionFile = '',
  });

  factory Submit.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing Submit from JSON: ${json.keys}');
      
      // Parse pengumpulan_tugas if it exists
      List<PengumpulanTugas>? pengumpulanList;
      bool hasSubmission = false;
      String submissionStatus = '';
      String submissionDate = '';
      String submissionFile = '';

      if (json['pengumpulan_tugas'] != null) {
        try {
          pengumpulanList = (json['pengumpulan_tugas'] as List)
              .map((item) => PengumpulanTugas.fromJson(item))
              .toList();
          
          // Check if there's a valid submission
          if (pengumpulanList.isNotEmpty) {
            hasSubmission = true;
            submissionStatus = pengumpulanList[0].status ?? '';
            submissionDate = pengumpulanList[0].waktuSubmit ?? '';
            submissionFile = pengumpulanList[0].filePath ?? '';
          }
        } catch (e) {
          print('Error parsing pengumpulan_tugas: $e');
        }
      }

      // Parse kategori_pa
      KategoriPA? kategoriPA;
      if (json['kategori_pa'] != null) {
        try {
          kategoriPA = KategoriPA.fromJson(json['kategori_pa']);
        } catch (e) {
          print('Error parsing kategori_pa: $e');
        }
      }

      // Parse prodi
      Prodi? prodi;
      if (json['prodi'] != null) {
        try {
          prodi = Prodi.fromJson(json['prodi']);
        } catch (e) {
          print('Error parsing prodi: $e');
        }
      }

      // Parse tahun_masuk
      TahunMasuk? tahunMasuk;
      if (json['tahun_masuk'] != null) {
        try {
          tahunMasuk = TahunMasuk.fromJson(json['tahun_masuk']);
        } catch (e) {
          print('Error parsing tahun_masuk: $e');
        }
      }

      return Submit(
        id: json['id'] ?? 0,
        userId: json['user_id'],
        judulTugas: json['judul_tugas'] ?? '',
        deskripsiTugas: json['deskripsi_tugas'] ?? '',
        kpaId: json['kpa_id'],
        prodiId: json['prodi_id'],
        tmId: json['tm_id'],
        tanggalPengumpulan: json['tanggal_pengumpulan'] ?? '',
        file: json['file'] ?? '',
        status: json['status'],
        kategoriTugas: json['kategori_tugas'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        prodi: prodi,
        kategoriPA: kategoriPA,
        tahunMasuk: tahunMasuk,
        pengumpulanTugas: pengumpulanList,
        hasValidSubmission: hasSubmission,
        submissionStatus: submissionStatus,
        submissionDate: submissionDate,
        submissionFile: submissionFile,
      );
    } catch (e) {
      print('Error in Submit.fromJson: $e');
      rethrow;
    }
  }
}

class PengumpulanTugas {
  final int? id;
  final int? kelompokId;
  final int? tugasId;
  final String? waktuSubmit;
  final String? filePath;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  PengumpulanTugas({
    this.id,
    this.kelompokId,
    this.tugasId,
    this.waktuSubmit,
    this.filePath,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PengumpulanTugas.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing PengumpulanTugas from JSON: ${json.keys}');
      
      return PengumpulanTugas(
        id: json['id'],
        kelompokId: json['kelompok_id'],
        tugasId: json['tugas_id'],
        waktuSubmit: json['waktu_submit'],
        filePath: json['file_path'],
        status: json['status'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );
    } catch (e) {
      print('Error in PengumpulanTugas.fromJson: $e');
      rethrow;
    }
  }
}

class Prodi {
  final int? id;
  final String? namaProdi;
  final int? maksProject;
  final String? createdAt;
  final String? updatedAt;

  Prodi({
    this.id,
    this.namaProdi,
    this.maksProject,
    this.createdAt,
    this.updatedAt,
  });

  factory Prodi.fromJson(Map<String, dynamic> json) {
    try {
      return Prodi(
        id: json['id'],
        namaProdi: json['nama_prodi'],
        maksProject: json['maks_project'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );
    } catch (e) {
      print('Error in Prodi.fromJson: $e');
      rethrow;
    }
  }
}

class KategoriPA {
  final int? id;
  final String? kategoriPA;
  final String? createdAt;
  final String? updatedAt;

  KategoriPA({
    this.id,
    this.kategoriPA,
    this.createdAt,
    this.updatedAt,
  });

  factory KategoriPA.fromJson(Map<String, dynamic> json) {
    try {
      return KategoriPA(
        id: json['id'],
        kategoriPA: json['kategori_pa'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );
    } catch (e) {
      print('Error in KategoriPA.fromJson: $e');
      rethrow;
    }
  }
}

class TahunMasuk {
  final int? id;
  final String? tahunMasuk;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  TahunMasuk({
    this.id,
    this.tahunMasuk,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory TahunMasuk.fromJson(Map<String, dynamic> json) {
    try {
      return TahunMasuk(
        id: json['id'],
        tahunMasuk: json['tahun_masuk'],
        status: json['status'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );
    } catch (e) {
      print('Error in TahunMasuk.fromJson: $e');
      rethrow;
    }
  }
}
