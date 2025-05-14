import 'package:flutter/material.dart';
import 'package:flutter_artefak/models/student_model.dart';
import 'package:flutter_artefak/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_artefak/providers/theme_provider.dart';
import 'package:flutter_artefak/providers/language_provider.dart';
import 'dart:math' as math;
import 'package:shimmer/shimmer.dart';

class ProfileDetailPage extends StatefulWidget {
  const
  ProfileDetailPage({super.key});

  @override
  State<ProfileDetailPage>
  createState()
  =>
  _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Student? _student;
  String _errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _loadStudentData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final student = await ApiService.getStudentData();
      setState(() {
        _student = student;
        _isLoading = false;
        if (student == null) {
          _errorMessage = 'Gagal memuat data mahasiswa';
        } else {
          _animationController.forward();
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Theme(
      data: themeProvider.themeData,
      child: Scaffold(
        backgroundColor: themeProvider.isDarkMode 
            ? const Color(0xFF1A202C) 
            : const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(
            languageProvider.translate('profile'),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2D3748),
            ),
          ),
          centerTitle: true,
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF2D3748) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2D3748),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2D3748),
              ),
              onPressed: _loadStudentData,
            ),
          ],
        ),
        body: _isLoading
            ? _buildSkeletonLoading(themeProvider)
            : _errorMessage.isNotEmpty
                ? _buildError()
                : _buildProfileContent(),
      ),
    );
  }

  Widget _buildSkeletonLoading(ThemeProvider themeProvider) {
    final baseColor = themeProvider.isDarkMode 
        ? const Color(0xFF2D3748) 
        : Colors.grey[300]!;
    final highlightColor = themeProvider.isDarkMode 
        ? const Color(0xFF4A5568) 
        : Colors.grey[100]!;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Header skeleton
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF2D3748) : Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x0A000000),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Column(
                children: [
                  // Avatar skeleton
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name skeleton
                  Container(
                    width: 200,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // NIM skeleton
                  Container(
                    width: 150,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Status skeleton
                  Container(
                    width: 80,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Academic info skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title skeleton
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: 180,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Info cards skeleton
                ...List.generate(
                  6, // Number of info cards
                  (index) => _buildInfoCardSkeleton(
                    themeProvider, 
                    baseColor, 
                    highlightColor,
                    // Add staggered delay for each card
                    delay: Duration(milliseconds: 100 * index),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardSkeleton(
    ThemeProvider themeProvider, 
    Color baseColor, 
    Color highlightColor,
    {Duration delay = Duration.zero}
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon container skeleton
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              period: const Duration(milliseconds: 1500) + delay,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Text content skeleton
            Expanded(
              child: Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                period: const Duration(milliseconds: 1500) + delay,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title skeleton
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Value skeleton
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
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

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 70, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.red[700], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadStudentData,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4299E1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (_student == null) {
      return Center(
        child: Text(
          'Data tidak tersedia',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2D3748),
          ),
        ),
      );
    }

    final int nameHash = _student!.nama.hashCode;
    final avatarColor = Color((nameHash & 0xFFFFFF) | 0xFF4299E1).withOpacity(1.0);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(themeProvider, avatarColor),
            const SizedBox(height: 24),
            _buildAcademicInfo(themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider, Color avatarColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Hero(
            tag: 'profile-avatar',
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: avatarColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF4299E1),
                    child: Text(
                      _student!.nama.isNotEmpty ? _student!.nama[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: Material(
                    color: themeProvider.isDarkMode ? const Color(0xFF1A202C) : Colors.white,
                    elevation: 4,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur upload foto belum tersedia'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.camera_alt, color: Color(0xFF4299E1), size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _student!.nama,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2D3748)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _student!.nim,
            style: TextStyle(fontSize: 16, color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF718096)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _student!.status.toLowerCase() == 'aktif' ? const Color(0xFFE6FFFA) : const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _student!.status.toLowerCase() == 'aktif' ? Icons.check_circle : Icons.info,
                  size: 16,
                  color: _student!.status.toLowerCase() == 'aktif' ? const Color(0xFF38B2AC) : const Color(0xFFE53E3E),
                ),
                const SizedBox(width: 6),
                Text(
                  _student!.status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _student!.status.toLowerCase() == 'aktif' ? const Color(0xFF38B2AC) : const Color(0xFFE53E3E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfo(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Informasi Akademik",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(icon: Icons.person, title: "Username", value: _student!.userName, color: const Color(0xFF4299E1)),
          _buildInfoCard(icon: Icons.email, title: "Email", value: _student!.email, color: const Color(0xFF48BB78)),
          _buildInfoCard(icon: Icons.school, title: "Program Studi", value: _student!.prodiName, color: const Color(0xFFED8936)),
          _buildInfoCard(icon: Icons.account_balance, title: "Fakultas", value: _student!.fakultas, color: const Color(0xFF9F7AEA)),
          _buildInfoCard(icon: Icons.calendar_today, title: "Angkatan", value: _student!.angkatan.toString(), color: const Color(0xFFE53E3E)),
          if (_student!.asrama.isNotEmpty)
            _buildInfoCard(icon: Icons.home, title: "Asrama", value: _student!.asrama, color: const Color(0xFFDD6B20)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF718096),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2D3748),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
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