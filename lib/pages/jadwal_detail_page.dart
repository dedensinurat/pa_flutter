import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/jadwal_service.dart';
import '../utils/enhanced_wavy_header.dart';

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
  bool _isLoading = true;
  Map<String, dynamic>? _jadwalData;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    try {
      final jadwal = await JadwalService.getJadwalById(widget.jadwalId);
      setState(() {
        _jadwalData = {
          'id': jadwal.id,
          'kelompok_id': jadwal.kelompokId,
          'ruangan': jadwal.ruangan,
          'waktu': jadwal.waktu.toIso8601String(),
          'user_id': jadwal.userId,
          'penguji1': jadwal.penguji1,
          'penguji2': jadwal.penguji2,
          'kelompok_nama': jadwal.kelompokNama,
          'penguji1_nama': jadwal.penguji1Nama,
          'penguji2_nama': jadwal.penguji2Nama,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load schedule details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4299E1)))
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : _buildDetailView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadJadwal,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4299E1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailView() {
    if (_jadwalData == null) {
      return const Center(child: Text('No schedule data available'));
    }

    // Format the date
    final DateTime waktu = DateTime.parse(_jadwalData!['waktu']);
    final String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(waktu);
    final String formattedTime = DateFormat('HH:mm').format(waktu);

    return Stack(
      children: [
        // Enhanced Wavy Background
        ClipPath(
          clipper: EnhancedWavyClipper(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4299E1),
                  const Color(0xFF63B3ED),
                  const Color(0xFF90CDF4).withOpacity(0.8),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Decorative elements
                Positioned(
                  top: -20,
                  left: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // App Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            title: const Text(
              'Detail Jadwal',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),

        // Main Content
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 70.0, bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seminar Kelompok ${_jadwalData!['kelompok_nama'] ?? _jadwalData!['kelompok_id']}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ruangan: ${_jadwalData!['ruangan']}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content Area
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Schedule Information Card
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Informasi Jadwal',
                                    style: TextStyle(
                                      fontFamily: 'Serif',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Divider(height: 24),
                                  
                                  // Date and Time
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInfoItem(
                                          icon: Icons.calendar_today,
                                          title: 'Tanggal',
                                          value: formattedDate,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildInfoItem(
                                          icon: Icons.access_time,
                                          title: 'Waktu',
                                          value: formattedTime,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Room
                                  _buildInfoItem(
                                    icon: Icons.room,
                                    title: 'Ruangan',
                                    value: _jadwalData!['ruangan'],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Examiners Card
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Penguji',
                                    style: TextStyle(
                                      fontFamily: 'Serif',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Divider(height: 24),
                                  
                                  // Examiner 1
                                  _buildExaminerItem(
                                    name: _jadwalData!['penguji1_nama'] ?? 'Penguji 1',
                                    role: 'Penguji Utama',
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Examiner 2
                                  _buildExaminerItem(
                                    name: _jadwalData!['penguji2_nama'] ?? 'Penguji 2',
                                    role: 'Penguji Pendamping',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Group Information Card
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Informasi Kelompok',
                                    style: TextStyle(
                                      fontFamily: 'Serif',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Divider(height: 24),
                                  
                                  // Group Name
                                  _buildInfoItem(
                                    icon: Icons.group,
                                    title: 'Kelompok',
                                    value: _jadwalData!['kelompok_nama'] ?? 'Kelompok ${_jadwalData!['kelompok_id']}',
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Group ID
                                  _buildInfoItem(
                                    icon: Icons.tag,
                                    title: 'ID Kelompok',
                                    value: _jadwalData!['kelompok_id'].toString(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Action Button
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4299E1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF4299E1),
          ),
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
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExaminerItem({
    required String name,
    required String role,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF4299E1).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: Color(0xFF4299E1),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
  