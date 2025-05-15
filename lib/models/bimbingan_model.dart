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
    // Parse dates and ensure they're in local time
    DateTime parseDateTime(String? dateStr) {
      if (dateStr == null) return DateTime.now();
      
      // Parse the ISO date string to DateTime
      DateTime parsedDate = DateTime.parse(dateStr);
      
      // Convert to local time if it's in UTC
      if (dateStr.endsWith('Z') || !dateStr.contains('+')) {
        parsedDate = parsedDate.toLocal();
        print('Converting UTC time to local: $dateStr -> ${parsedDate.toString()}');
      }
      
      return parsedDate;
    }

    return Bimbingan(
      id: json['id'] ?? 0,
      kelompokId: json['kelompok_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      keperluan: json['keperluan'] ?? '',
      rencanaMulai: parseDateTime(json['rencana_mulai']),
      rencanaSelesai: parseDateTime(json['rencana_selesai']),
      ruanganId: json['ruangan_id'] ?? 0,
      status: json['status'] ?? 'menunggu',
      hasilBimbingan: json['hasil_bimbingan'] ?? '',
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      kelompok: json['kelompok'] != null
          ? KelompokMahasiswa.fromJson(json['kelompok'])
          : null,
      ruangan: json['ruangan'] != null
          ? Ruangan.fromJson(json['ruangan'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Always send dates in UTC format to the server
    return {
      'keperluan': keperluan,
      'rencana_mulai': rencanaMulai.toUtc().toIso8601String(),
      'rencana_selesai': rencanaSelesai.toUtc().toIso8601String(),
      'ruangan_id': ruanganId,
    };
  }

  // Always format dates in local time for display
  String getFormattedDate() => DateFormat('dd MMM yyyy').format(rencanaMulai.toLocal());
  String getFormattedTime() => DateFormat('HH:mm').format(rencanaMulai.toLocal());
  String getFormattedDateTime() =>
      DateFormat('dd MMM yyyy • HH:mm').format(rencanaMulai.toLocal());
  String getDuration() =>
      '${DateFormat('HH:mm').format(rencanaMulai.toLocal())} - ${DateFormat('HH:mm').format(rencanaSelesai.toLocal())}';

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