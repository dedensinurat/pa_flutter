import 'package:flutter/material.dart';
import 'package:flutter_artefak/pages/profil_detail_page.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vokasi Tera"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
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
    );
  }
}
