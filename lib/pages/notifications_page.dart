import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Gradient
        Container(
          height: 130,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDDEEFF), Color(0xFFEEF4FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                'Vokasi Tera',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),

        // Divider
        Container(
          height: 1,
          color: Colors.grey.withOpacity(0.2),
        ),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notification',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Utama',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'new',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _buildNotificationCard(
                        logoAsset: 'assets/logo.jpg',
                        sender: 'VokasiTera',
                        time: 'now',
                        date: '2 Feb',
                        title: 'Hi Anastassia!',
                        message:
                            'Jadwal seminar sudah diupload silahkan lihat jadwal seminar anda!!!',
                      ),
                      _buildNotificationCard(
                        logoAsset: 'assets/logo.jpg',
                        sender: 'VokasiTera',
                        time: 'now',
                        date: '1 Jan',
                        title: 'Hi Anastassia!',
                        message:
                            'Jadwal seminar sudah diupload silahkan lihat jadwal seminar anda!!!',
                        showDot: true,
                      ),
                      _buildNotificationCard(
                        logoAsset: 'assets/logo.jpg',
                        sender: 'VokasiTera',
                        time: 'now',
                        date: '1/12/2025',
                        title: 'Hi Anastassia!',
                        message:
                            'Jadwal seminar sudah diupload silahkan lihat jadwal seminar anda!!!',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard({
    required String logoAsset,
    required String sender,
    required String time,
    required String date,
    required String title,
    required String message,
    bool showDot = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                logoAsset,
                width: 18,
                height: 18,
              ),
              const SizedBox(width: 6),
              Text(sender,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  )),
              const Spacer(),
              Text(time,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey, height: 1.2)),
              const SizedBox(width: 8),
              Text(date,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54, height: 1.2)),
              if (showDot)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.circle, size: 8, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              )),
          const SizedBox(height: 4),
          Text(message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
              )),
        ],
      ),
    );
  }
}
