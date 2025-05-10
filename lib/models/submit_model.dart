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
    final String prodi;
    final String kategoriPA;
    final String tahunAjaran;
    final String submissionStatus;
    final String submissionFile;
    final String? submissionDate;

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
        prodi: json['prodi']?['nama'] ?? '',
        kategoriPA: json['kategori_pa']?['nama'] ?? '',
        tahunAjaran: json['tahun_ajaran'] ?? '',
        submissionStatus: json['submission_status'] ?? 'Belum',
        submissionFile: json['submission_file'] ?? '',
        submissionDate: json['submission_date'],
      );
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
        'prodi': prodi,
        'kategori_pa': kategoriPA,
        'tahun_ajaran': tahunAjaran,
        'submission_status': submissionStatus,
        'submission_file': submissionFile,
        'submission_date': submissionDate,
      };
    }
  }
    