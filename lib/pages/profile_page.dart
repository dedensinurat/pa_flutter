import 'package:flutter/material.dart';
import 'package:flutter_artefak/pages/profil_detail_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: Stack(
        children: [
          // Blue Wavy Background
          ClipPath(
            clipper: WavyClipper(),
            child: Container(
              height: 120, // Adjust height as needed
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF81D4FA).withOpacity(0.7), // Slightly darker top
                    const Color(0xFFB3E5FC).withOpacity(0.5), // Match the lighter submit box
                  ],
                ),
              ),
            ),
          ),

          // App Bar with "Vokasi Tera"
          AppBar(
            title: const Text(
              'Vokasi Tera',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: Colors.black87),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent, // Make app bar transparent
            elevation: 0, // Remove app bar shadow
            iconTheme: const IconThemeData(color: Colors.black87),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.only(top: 100.0), // Adjust top padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Foto Profil
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                ),
                const SizedBox(height: 12),

                // Nama Pengguna
                const Text(
                  "Hai,\nSofia Assegaf",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Menu Lihat Profil
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: const Text("Lihat Profil"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileDetailPage()),
                    );
                    // Navigasi ke halaman detail profil (Tambahkan nanti)
                  },
                ),
                const Divider(),

                // Menu Sign Out
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Sign Out"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
                const Divider(),
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
    path.lineTo(0, size.height - 20); // Reduced wave height

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 15);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 45);
    var secondEndPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}