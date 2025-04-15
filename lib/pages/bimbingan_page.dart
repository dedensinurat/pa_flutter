import 'package:flutter/material.dart';
import 'package:flutter_artefak/models/bimbingan_model.dart';
import 'package:flutter_artefak/services/bimbingan_services.dart';
import 'request_bimbingan_page.dart';
import 'package:intl/intl.dart';

class BimbinganPage extends StatefulWidget {
  const BimbinganPage({super.key});

  @override
  State<BimbinganPage> createState() => _BimbinganPageState();
}

class _BimbinganPageState extends State<BimbinganPage> {
  List<Bimbingan> _bimbinganList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBimbingan();
  }

  Future<void> _fetchBimbingan() async {
    try {
      final data = await BimbinganService.getAll();
      setState(() {
        _bimbinganList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy HH:mm').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sukses':
        return const Color(0xFFE8F5E9);
      case 'ditolak':
        return const Color(0xFFFBE9E7);
      case 'pending':
        return const Color(0xFFFFFDE7);
      default:
        return Colors.grey.shade100;
    }
  }

  TextStyle _getStatusTextStyle(String status) {
    switch (status.toLowerCase()) {
      case 'sukses':
        return const TextStyle(color: Color(0xFF388E3C), fontWeight: FontWeight.w500);
      case 'ditolak':
        return const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w500);
      case 'pending':
        return const TextStyle(color: Color.fromARGB(255, 231, 138, 44), fontWeight: FontWeight.w500);
      default:
        return const TextStyle(color: Colors.black54);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: Stack(
        children: [
          // Background
          ClipPath(
            clipper: WavyClipper(),
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF81D4FA).withOpacity(0.7),
                    const Color(0xFFB3E5FC).withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),

          // App Bar
          AppBar(
            title: const Text(
              'Vokasi Tera',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: Colors.black87),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.only(top: 140.0, left: 18.0, right: 18.0, bottom: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RequestBimbinganPage()),
                    );
                    if (result == true) {
                      _fetchBimbingan();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue.shade200,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 2,
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text(
                    'Ajukan Bimbingan Baru',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(height: 16),

                // Header Tabel
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: const [
                      Expanded(flex: 1, child: Text('No.', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54))),
                      Expanded(flex: 3, child: Text('Keperluan', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54))),
                      Expanded(flex: 3, child: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54))),
                      Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // List Bimbingan
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.lightBlueAccent))
                    : Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ListView.separated(
                            itemCount: _bimbinganList.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                            itemBuilder: (context, index) {
                              final item = _bimbinganList[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '${index + 1}.',
                                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        item.keperluan,
                                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        _formatDate(item.rencanaBimbingan),
                                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(item.status),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Center(
                                          child: Text(
                                            item.status,
                                            style: _getStatusTextStyle(item.status).copyWith(fontSize: 13),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                const SizedBox(height: 18),

                // Panduan
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.lightBlue.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Panduan Bimbingan', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87)),
                      SizedBox(height: 8),
                      Text('1. Ajukan permintaan bimbingan melalui aplikasi.', style: TextStyle(fontSize: 14, color: Colors.black54)),
                      SizedBox(height: 4),
                      Text('2. Mohon menunggu konfirmasi dari dosen pembimbing.', style: TextStyle(fontSize: 14, color: Colors.black54)),
                      SizedBox(height: 4),
                      Text('3. Setelah disetujui, persiapkan diri dan hadir tepat waktu.', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
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

// Custom Clipper for Wavy Background
class WavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
