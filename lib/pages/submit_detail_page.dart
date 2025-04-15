import 'package:flutter/material.dart';
import '../models/submit_model.dart';

class SubmitDetailPage extends StatelessWidget {
  final Submit submit;

  const SubmitDetailPage({Key? key, required this.submit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: Stack(
        children: [
          // Gelombang latar atas
          ClipPath(
            clipper: WavyClipper(),
            child: Container(
              height: 140, // Lebih pendek
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF81D4FA).withOpacity(0.9),
                    const Color(0xFFB3E5FC).withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Konten utama
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 100, 18, 24), // Naikkan
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection(
                    icon: Icons.title_outlined,
                    label: "Judul",
                    value: submit.judul,
                    color: Colors.indigo.shade300,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    icon: Icons.description_outlined,
                    label: "Instruksi",
                    value: submit.instruksi,
                    color: Colors.teal.shade300,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    icon: Icons.calendar_today_outlined,
                    label: "Batas Pengumpulan",
                    value: submit.batas,
                    color: Colors.deepOrange.shade300,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    icon: Icons.attach_file_outlined,
                    label: "File",
                    value: submit.file,
                    color: Colors.purple.shade300,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    icon: Icons.account_circle_outlined,
                    label: "Dosen Pengampu",
                    value: 'Dosen ID: ${submit.userId}',
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tombol Kumpulkan ditekan')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue.shade300,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Kumpulkan Artefak',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tombol back dan judul
          Positioned(
            top: 24, // Naikkan dari 40
            left: 16,
            right: 16,
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Detail Pengumpulan',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class WavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 30);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 20);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 50);
    var secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
