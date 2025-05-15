import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Jadwal {
  final int id;
  final int kelompokId;
  final String? kelompokNama;
  final String? tanggal;
  final String? waktuMulai;
  final String? waktuSelesai;
  final String ruangan;
  final int? penguji1;
  final int? penguji2;
  final String? penguji1Nama;
  final String? penguji2Nama;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final int? userId;
  final int? ruanganId;

  Jadwal({
    required this.id,
    required this.kelompokId,
    this.kelompokNama,
    this.tanggal,
    this.waktuMulai,
    this.waktuSelesai,
    required this.ruangan,
    this.penguji1,
    this.penguji2,
    this.penguji1Nama,
    this.penguji2Nama,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.ruanganId,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    // Extract date and time from waktu_mulai and waktu_selesai
    String? waktuMulai = json['waktu_mulai'];
    String? waktuSelesai = json['waktu_selesai'];
    String? tanggal;
    
    // If waktu_mulai exists, use it for the date
    if (waktuMulai != null) {
      try {
        tanggal = waktuMulai;
      } catch (e) {
        print('Error parsing waktu_mulai: $e');
      }
    }
    
    return Jadwal(
      id: json['id'] ?? 0,
      kelompokId: json['kelompok_id'] ?? 0,
      kelompokNama: json['kelompok_nama'],
      tanggal: tanggal,
      waktuMulai: waktuMulai,
      waktuSelesai: waktuSelesai,
      ruangan: json['ruangan'] ?? '',
      penguji1: json['penguji1'],
      penguji2: json['penguji2'],
      penguji1Nama: json['penguji1_nama'],
      penguji2Nama: json['penguji2_nama'],
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      userId: json['user_id'],
      ruanganId: json['ruangan_id'],
    );
  }

  String getFormattedDate() {
    try {
      if (tanggal == null) return 'Tanggal tidak tersedia';
      
      final DateTime date = DateTime.parse(tanggal!);
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      print('Error formatting date: $e');
      return tanggal ?? 'Tanggal tidak tersedia';
    }
  }

  String getFormattedTime() {
    if (waktuMulai == null || waktuSelesai == null) {
      return 'Waktu tidak tersedia';
    }
    
    try {
      final DateTime start = DateTime.parse(waktuMulai!);
      final DateTime end = DateTime.parse(waktuSelesai!);
      
      return '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}';
    } catch (e) {
      print('Error formatting time: $e');
      return '$waktuMulai - $waktuSelesai';
    }
  }

  String getStatusText() {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
