import 'package:flutter/material.dart';

class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vokasi Tera"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Foto Profil + Edit Icon
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      NetworkImage('https://i.pravatar.cc/150?img=3'),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),

            // Username
            Align(
              alignment: Alignment.centerLeft,
              child: const Text("Username", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFD9E8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text("Sofia Assegaf"),
            ),
            const SizedBox(height: 20),

            // Password
            Align(
              alignment: Alignment.centerLeft,
              child: const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFD9E8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text("12345678"),
            ),
            const SizedBox(height: 20),

            // Email Address
            Align(
              alignment: Alignment.centerLeft,
              child: const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFD9E8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text("FofiaAnggriani@Gmail.Com"),
            ),
          ],
        ),
      ),
    );
  }
}
