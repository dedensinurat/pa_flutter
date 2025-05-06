import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Jadwal {
  final int id;
  final int kelompokId;
  final String ruangan;
  final DateTime waktu;
  final int userId;
  final int penguji1;
  final int penguji2;
  final String? kelompokNama;
  String? penguji1Nama;
  String? penguji2Nama;

  Jadwal({
    required this.id,
    required this.kelompokId,
    required this.ruangan,
    required this.waktu,
    required this.userId,
    required this.penguji1,
    required this.penguji2,
    this.kelompokNama,
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
      userId: json['user_id'],
      penguji1: json['penguji1'],
      penguji2: json['penguji2'],
      kelompokNama: json['kelompok_nama'],
      // These will be filled in later by the service
      penguji1Nama: json['penguji1_nama'] ?? 'Penguji 1',
      penguji2Nama: json['penguji2_nama'] ?? 'Penguji 2',
    );
  }

  String getFormattedDate() {
    return DateFormat('EEEE, d MMMM yyyy').format(waktu);
  }

  String getFormattedTime() {
    return DateFormat('HH:mm').format(waktu);
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