import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_artefak/models/ruangan_model.dart'; // Gunakan model dari file ini

class Bimbingan {
  final int id;
  final int kelompokId;
  final int userId;
  final String keperluan;
  final DateTime rencanaMulai;
  final DateTime rencanaSelesai;
  final int ruanganId;
  final String status;
  final String hasilBimbingan;
  final DateTime createdAt;
  final DateTime updatedAt;

  final KelompokMahasiswa? kelompok;
  final Ruangan? ruangan;

  String get lokasi => ruangan?.ruangan ?? '';

  Bimbingan({
    required this.id,
    required this.kelompokId,
    required this.userId,
    required this.keperluan,
    required this.rencanaMulai,
    required this.rencanaSelesai,
    required this.ruanganId,
    required this.status,
    this.hasilBimbingan = '',
    required this.createdAt,
    required this.updatedAt,
    this.kelompok,
    this.ruangan,
  });

  factory Bimbingan.fromJson(Map<String, dynamic> json) {
    return Bimbingan(
      id: json['id'] ?? 0,
      kelompokId: json['kelompok_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      keperluan: json['keperluan'] ?? '',
      rencanaMulai: json['rencana_mulai'] != null
          ? DateTime.parse(json['rencana_mulai'])
          : DateTime.now(),
      rencanaSelesai: json['rencana_selesai'] != null
          ? DateTime.parse(json['rencana_selesai'])
          : DateTime.now(),
      ruanganId: json['ruangan_id'] ?? 0,
      status: json['status'] ?? 'menunggu',
      hasilBimbingan: json['hasil_bimbingan'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      kelompok: json['kelompok'] != null
          ? KelompokMahasiswa.fromJson(json['kelompok'])
          : null,
      ruangan: json['ruangan'] != null
          ? Ruangan.fromJson(json['ruangan'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keperluan': keperluan,
      'rencana_mulai': rencanaMulai.toIso8601String(),
      'rencana_selesai': rencanaSelesai.toIso8601String(),
      'ruangan_id': ruanganId,
    };
  }

  String getFormattedDate() => DateFormat('dd MMM yyyy').format(rencanaMulai);
  String getFormattedTime() => DateFormat('HH:mm').format(rencanaMulai);
  String getFormattedDateTime() =>
      DateFormat('dd MMM yyyy • HH:mm').format(rencanaMulai);
  String getDuration() =>
      '${DateFormat('HH:mm').format(rencanaMulai)} - ${DateFormat('HH:mm').format(rencanaSelesai)}';

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'selesai':
        return const Color(0xFF38A169);
      case 'ditolak':
        return const Color(0xFFE53E3E);
      case 'menunggu':
        return const Color(0xFF718096);
      case 'disetujui':
        return const Color(0xFF3182CE);
      default:
        return const Color(0xFF718096);
    }
  }

  Color getStatusBgColor() {
    switch (status.toLowerCase()) {
      case 'selesai':
        return const Color(0xFFE6FFFA);
      case 'ditolak':
        return const Color(0xFFFFF5F5);
      case 'menunggu':
        return const Color(0xFFEDF2F7);
      case 'disetujui':
        return const Color(0xFFEBF8FF);
      default:
        return const Color(0xFFEDF2F7);
    }
  }

  IconData getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Icons.check_circle;
      case 'ditolak':
        return Icons.cancel;
      case 'menunggu':
        return Icons.access_time;
      case 'disetujui':
        return Icons.thumb_up;
      default:
        return Icons.help_outline;
    }
  }
}

class KelompokMahasiswa {
  final int kelompokId;
  final int userId;
  final String? nama;
  final String? judul;

  KelompokMahasiswa({
    required this.kelompokId,
    required this.userId,
    this.nama,
    this.judul,
  });

  factory KelompokMahasiswa.fromJson(Map<String, dynamic> json) {
    return KelompokMahasiswa(
      kelompokId: json['kelompok_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      nama: json['nama'],
      judul: json['judul'],
    );
  }
}
