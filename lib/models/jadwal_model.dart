import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Jadwal {
  final int id;
  final int kelompokId;
  final String ruangan;
  final DateTime waktu;
  final DateTime? waktuSelesai;
  final int userId;
  final int ruanganId;
  final int penguji1;
  final int penguji2;
  final String? kelompokNama;
  final String? judul;
  String? penguji1Nama;
  String? penguji2Nama;

  Jadwal({
    required this.id,
    required this.kelompokId,
    required this.ruangan,
    required this.waktu,
    this.waktuSelesai,
    required this.userId,
    required this.ruanganId,
    required this.penguji1,
    required this.penguji2,
    this.kelompokNama,
    this.judul,
    this.penguji1Nama,
    this.penguji2Nama,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    print('Parsing jadwal JSON: $json');
    return Jadwal(
      id: json['id'],
      kelompokId: json['kelompok_id'],
      ruangan: json['ruangan'] ?? '',
      waktu: DateTime.parse(json['waktu']),
      waktuSelesai: json['waktu_selesai'] != null ? DateTime.parse(json['waktu_selesai']) : null,
      userId: json['user_id'],
      ruanganId: json['ruangan_id'] ?? 0,
      penguji1: json['penguji1'] ?? 0,
      penguji2: json['penguji2'] ?? 0,
      kelompokNama: json['kelompok_nama'],
      judul: json['judul'],
      // These will be filled in later by the service
      penguji1Nama: json['penguji1_nama'],
      penguji2Nama: json['penguji2_nama'],
    );
  }

  String getFormattedDate() {
    return DateFormat('EEEE, d MMMM yyyy').format(waktu);
  }

  String getFormattedTime() {
    return DateFormat('HH:mm').format(waktu);
  }

  String getDuration() {
    if (waktuSelesai == null) return getFormattedTime();
    return '${DateFormat('HH:mm').format(waktu)} - ${DateFormat('HH:mm').format(waktuSelesai!)}';
  }

  bool isUpcoming() {
    return waktu.isAfter(DateTime.now());
  }

  int getDaysRemaining() {
    final now = DateTime.now();
    return waktu.difference(now).inDays;
  }
  
  Color getStatusColor() {
    if (!isUpcoming()) {
      return Colors.grey;
    } else if (getDaysRemaining() <= 1) {
      return Colors.red;
    } else if (getDaysRemaining() <= 3) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
  
  String getStatusText() {
    if (!isUpcoming()) {
      return 'Selesai';
    } else if (getDaysRemaining() <= 0) {
      return 'Hari ini';
    } else {
      return '${getDaysRemaining()} hari lagi';
    }
  }
}

class Ruangan {
  final int id;
  final String nama;

  Ruangan({
    required this.id,
    required this.nama,
  });

  factory Ruangan.fromJson(Map<String, dynamic> json) {
    return Ruangan(
      id: json['id'],
      nama: json['ruangan'],
    );
  }
}
