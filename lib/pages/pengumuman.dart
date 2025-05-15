import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_artefak/providers/theme_provider.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import 'announcement_detail_page.dart';
import 'package:shimmer/shimmer.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Announcement>> _announcementsFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAnnouncements();
  }

  void _loadAnnouncements() {
    setState(() {
      _isLoading = true;
    });
    _announcementsFuture = AnnouncementService.getAnnouncements().then((result) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return result;
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      throw error;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Theme(
      data: themeProvider.themeData,
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF1A202C) : Colors.blueGrey.shade50,
        body: Stack(
          children: [
            // Blue Wavy Background
            ClipPath(
              clipper: WavyClipper(),
              child: Container(
                height: 125,
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

            // App Bar
            AppBar(
              title: Text(
                'Vokasi Tera',
                style: TextStyle(
                  fontWeight: FontWeight.w500, 
                  fontSize: 20, 
                  color: isDarkMode ? Colors.white : Colors.black87
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(
                color: isDarkMode ? Colors.white : const Color.fromARGB(221, 254, 254, 57)
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.only(top: 100.0), // Adjust top padding
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Tab Bar
                    TabBar(
                      controller: _tabController,
                      labelColor: isDarkMode ? const Color(0xFF63B3ED) : Colors.blue,
                      unselectedLabelColor: isDarkMode ? Colors.white.withOpacity(0.5) : Colors.grey,
                      indicatorColor: isDarkMode ? const Color(0xFF63B3ED) : Colors.blue,
                      tabs: const [
                        Tab(text: 'Notifications'),
                        Tab(text: 'Announcements'),
                      ],
                    ),
                    
                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Notifications Tab
                          _buildNotificationsTab(isDarkMode),
                          
                          // Announcements Tab
                          _buildAnnouncementsTab(isDarkMode),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsTab(bool isDarkMode) {
    return ListView(
      children: [
        _buildNotificationCard(
          logoAsset: 'assets/logo.png',
          sender: 'VokasiTera',
          time: 'now',
          date: '2 Feb',
          title: 'Hi Anastassia!',
          message:
              'Jadwal seminar sudah diupload silahkan lihat jadwal seminar anda!!!',
          isDarkMode: isDarkMode,
        ),
        _buildNotificationCard(
          logoAsset: 'assets/logo.png',
          sender: 'VokasiTera',
          time: 'now',
          date: '1 Jan',
          title: 'Hi Anastassia!',
          message:
              'Jadwal seminar sudah diupload silahkan lihat jadwal seminar anda!!!',
          showDot: true,
          isDarkMode: isDarkMode,
        ),
        _buildNotificationCard(
          logoAsset: 'assets/logo.png',
          sender: 'VokasiTera',
          time: 'now',
          date: '1/12/2025',
          title: 'Hi Anastassia!',
          message:
              'Jadwal seminar sudah diupload silahkan lihat jadwal seminar anda!!!',
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildAnnouncementsTab(bool isDarkMode) {
    return FutureBuilder<List<Announcement>>(
      future: _announcementsFuture,
      builder: (context, snapshot) {
        if (_isLoading) {
          return _buildAnnouncementsSkeletonLoading(isDarkMode);
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading announcements',
                  style: TextStyle(
                    color: isDarkMode ? Colors.red[400] : Colors.red[700]
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadAnnouncements,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? const Color(0xFF4299E1) : Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No announcements available',
              style: TextStyle(
                color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.grey[700]
              ),
            ),
          );
        } else {
          final announcements = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadAnnouncements();
              });
            },
            color: isDarkMode ? const Color(0xFF63B3ED) : Colors.blue,
            child: ListView.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return _buildAnnouncementCard(
                  announcement: announcement,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnnouncementDetailPage(
                          announcementId: announcement.id,
                        ),
                      ),
                    );
                  },
                  isDarkMode: isDarkMode,
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildAnnouncementsSkeletonLoading(bool isDarkMode) {
    final baseColor = isDarkMode ? const Color(0xFF2D3748) : Colors.grey[300]!;
    final highlightColor = isDarkMode ? const Color(0xFF4A5568) : Colors.grey[100]!;
    
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          period: Duration(milliseconds: 1500 + (index * 150)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, top: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2D3748) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 80,
                      height: 13,
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 15,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 13,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity * 0.7,
                  height: 13,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard({
    required String logoAsset,
    required String sender,
    required String time,
    required String date,
    required String title,
    required String message,
    required bool isDarkMode,
    bool showDot = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
              Text(
                sender,
                style: TextStyle(
                  color: isDarkMode ? const Color(0xFF63B3ED) : Colors.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12, 
                  color: isDarkMode ? Colors.white.withOpacity(0.5) : Colors.grey, 
                  height: 1.2
                ),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12, 
                  color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54, 
                  height: 1.2
                ),
              ),
              if (showDot)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.circle, size: 8, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required Announcement announcement,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, top: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2D3748) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
                Icon(
                  Icons.announcement_outlined,
                  size: 18,
                  color: isDarkMode ? const Color(0xFF63B3ED) : Colors.blue,
                ),
                const SizedBox(width: 6),
                Text(
                  'VokasiTera',
                  style: TextStyle(
                    color: isDarkMode ? const Color(0xFF63B3ED) : Colors.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  announcement.getFormattedDate(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54,
                    height: 1.2,
                  ),
                ),
                if (_isNewAnnouncement(announcement.tanggalPenulisan))
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.circle, size: 8, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              announcement.judul,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              announcement.deskripsi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isNewAnnouncement(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    // Consider announcements from the last 24 hours as new
    return difference.inHours < 24;
  }
}

// Custom Clipper for Wavy Background
class WavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 20);
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