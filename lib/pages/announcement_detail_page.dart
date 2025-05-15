import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_artefak/providers/theme_provider.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import 'package:shimmer/shimmer.dart';

class AnnouncementDetailPage extends StatefulWidget {
  final int announcementId;

  const AnnouncementDetailPage({
    super.key,
    required this.announcementId,
  });

  @override
  State<AnnouncementDetailPage> createState() => _AnnouncementDetailPageState();
}

class _AnnouncementDetailPageState extends State<AnnouncementDetailPage> {
  late Future<Announcement> _announcementFuture;
  @override
  bool mounted = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnouncementDetails();
  }

  @override
  void dispose() {
    mounted = false;
    super.dispose();
  }

  void _loadAnnouncementDetails() {
    setState(() {
      _isLoading = true;
    });
    
    _announcementFuture = AnnouncementService.getAnnouncementById(widget.announcementId)
      .then((result) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return result;
      })
      .catchError((error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        throw error;
      });
  }

  Future<void> openAttachment(String filePath) async {
    final baseUrl = "http://192.168.157.227:8080";
    final url = Uri.parse('$baseUrl/$filePath');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the attachment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getFileName(String filePath) {
    return filePath.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Theme(
      data: themeProvider.themeData,
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF1A202C) : Colors.white,
        appBar: AppBar(
          title: Text(
            'Announcement Details',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87
            ),
          ),
          backgroundColor: isDarkMode ? const Color(0xFF2D3748) : Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colors.black87
          ),
        ),
        body: _isLoading
            ? _buildSkeletonLoading(isDarkMode)
            : FutureBuilder<Announcement>(
                future: _announcementFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error loading announcement details',
                            style: TextStyle(
                              color: isDarkMode ? Colors.red[400] : Colors.red[700]
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadAnnouncementDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode ? const Color(0xFF4299E1) : Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData) {
                    return Center(
                      child: Text(
                        'Announcement not found',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87
                        ),
                      ),
                    );
                  } else {
                    final announcement = snapshot.data!;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with date
                          Row(
                            children: [
                              Icon(
                                Icons.announcement_outlined,
                                size: 20,
                                color: isDarkMode ? const Color(0xFF63B3ED) : Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'VokasiTera',
                                style: TextStyle(
                                  color: isDarkMode ? const Color(0xFF63B3ED) : Colors.blue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${announcement.tanggalPenulisan.day}/${announcement.tanggalPenulisan.month}/${announcement.tanggalPenulisan.year}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Title
                          Text(
                            announcement.judul,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Content
                          Text(
                            announcement.deskripsi,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Attachment if available
                          if (announcement.file != null && announcement.file!.isNotEmpty)
                            InkWell(
                              onTap: () {
                                openAttachment(announcement.file!);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isDarkMode 
                                      ? const Color(0xFF2C5282).withOpacity(0.3) 
                                      : Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.attach_file,
                                      color: isDarkMode ? const Color(0xFF63B3ED) : Colors.blue,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Attachment',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode ? const Color(0xFF63B3ED) : Colors.blue,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _getFileName(announcement.file!),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDarkMode 
                                                  ? Colors.white.withOpacity(0.7) 
                                                  : Colors.grey[700],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.download,
                                      color: isDarkMode ? const Color(0xFF63B3ED) : Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }
  
  Widget _buildSkeletonLoading(bool isDarkMode) {
    final baseColor = isDarkMode ? const Color(0xFF2D3748) : Colors.grey[300]!;
    final highlightColor = isDarkMode ? const Color(0xFF4A5568) : Colors.grey[100]!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Title
            Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            
            // Content - multiple lines
            Column(
              children: List.generate(5, (index) => 
                Container(
                  width: double.infinity,
                  height: 16,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Attachment
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 150,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}