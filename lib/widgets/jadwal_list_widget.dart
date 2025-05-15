import 'package:flutter/material.dart';
import '../models/jadwal_model.dart';
import '../services/jadwal_service.dart';

class JadwalDetailPage extends StatefulWidget {
  final int jadwalId;

  const JadwalDetailPage({
    Key? key,
    required this.jadwalId,
  }) : super(key: key);

  @override
  State<JadwalDetailPage> createState() => _JadwalDetailPageState();
}

class _JadwalDetailPageState extends State<JadwalDetailPage> {
  late Future<Jadwal> _jadwalFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  void _loadJadwal() {
    setState(() {
      _isLoading = true;
      _jadwalFuture = JadwalService.getJadwalById(widget.jadwalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Jadwal'),
      ),
      body: FutureBuilder<Jadwal>(
        future: _jadwalFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadJadwal,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final jadwal = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: jadwal.getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: jadwal.getStatusColor().withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${jadwal.getStatusText()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: jadwal.getStatusColor(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Seminar ${jadwal.kelompokNama ?? 'Kelompok ${jadwal.kelompokId}'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Details section
                  const Text(
                    'Informasi Jadwal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDetailItem(
                    icon: Icons.calendar_today,
                    title: 'Tanggal',
                    value: jadwal.getFormattedDate(),
                  ),
                  
                  _buildDetailItem(
                    icon: Icons.access_time,
                    title: 'Waktu',
                    value: jadwal.getFormattedTime(),
                  ),
                  
                  _buildDetailItem(
                    icon: Icons.location_on,
                    title: 'Ruangan',
                    value: jadwal.ruangan,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Examiners section
                  if (jadwal.penguji1Nama != null || jadwal.penguji2Nama != null) ...[
                    const Text(
                      'Penguji',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (jadwal.penguji1Nama != null)
                      _buildExaminerItem(
                        number: 1,
                        name: jadwal.penguji1Nama!,
                      ),
                    
                    if (jadwal.penguji2Nama != null)
                      _buildExaminerItem(
                        number: 2,
                        name: jadwal.penguji2Nama!,
                      ),
                  ],
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('Jadwal tidak ditemukan'),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExaminerItem({
    required int number,
    required String name,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Penguji $number',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
