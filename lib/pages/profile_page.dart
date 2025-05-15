import 'package:flutter/material.dart';
import 'package:flutter_artefak/models/student_model.dart';
import 'package:flutter_artefak/services/api_service.dart';
import 'package:flutter_artefak/pages/profil_detail_page.dart';
import 'package:flutter_artefak/pages/setting_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_artefak/providers/theme_provider.dart';
import 'package:flutter_artefak/providers/language_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Student data
  bool _isLoading = true;
  Student? _student;
  String _errorMessage = '';

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
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Start animation immediately - don't wait for data
    _animationController.forward();
    
    // Load student data from API
    _loadStudentData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Use the same API call as in ProfileDetailPage
      final student = await ApiService.getStudentData();
      
      if (!mounted) return;
      
      setState(() {
        _student = student;
        _isLoading = false;
        if (student == null) {
          _errorMessage = 'Gagal memuat data mahasiswa';
        }
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  void _showSignOutDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF2D3748) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2D3748),
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.8) : const Color(0xFF4A5568),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal', 
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.6) : const Color(0xFF718096),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4299E1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text(languageProvider.translate('sign_out')),
          ),
        ],
      ),
    );
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
        body: Stack(
          children: [
            // Enhanced Wavy Background
            ClipPath(
              clipper: EnhancedWavyClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.3,
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

            // App Bar with "Vokasi Tera"
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                title: Text(
                  languageProvider.translate('app_title'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadStudentData,
                  ),
                ],
              ),
            ),

            // Main Content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 70), // Space for app bar
                        
                        // Profile Card
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode 
                                ? const Color(0xFF2D3748) 
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              
                              // Profile Image with initial letter and camera
                              _isLoading
                              ? Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF4299E1),
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  ),
                                )
                              : Hero(
                                  tag: 'profile-avatar',
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF4299E1).withOpacity(0.3),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 60,
                                          backgroundColor: const Color(0xFF4299E1),
                                          child: Text(
                                            _student != null && _student!.nama.isNotEmpty 
                                              ? _student!.nama[0].toUpperCase() 
                                              : '?',
                                            style: const TextStyle(
                                              fontSize: 40, 
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 4,
                                        child: Material(
                                          color: themeProvider.isDarkMode 
                                              ? const Color(0xFF1A202C) 
                                              : Colors.white,
                                          elevation: 4,
                                          shape: const CircleBorder(),
                                          child: InkWell(
                                            onTap: () {
                                              // Handle camera tap
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
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.camera_alt,
                                                color: Color(0xFF4299E1),
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 16),
                              
                              // Greeting and Name
                              Text(
                                "Hai,",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: themeProvider.isDarkMode 
                                      ? Colors.white.withOpacity(0.7) 
                                      : const Color(0xFF718096),
                                ),
                              ),
                              const SizedBox(height: 4),
                              _isLoading
                              ? Container(
                                  width: 150,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF4299E1),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  _student != null ? _student!.nama : 'Data tidak tersedia',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.isDarkMode 
                                        ? Colors.white 
                                        : const Color(0xFF2D3748),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              const SizedBox(height: 8),
                              
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6FFFA).withOpacity(themeProvider.isDarkMode ? 0.2 : 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: Color(0xFF38B2AC),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "Mahasiswa Aktif",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF38B2AC),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Quick Stats
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Menu Options
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode 
                                ? const Color(0xFF2D3748) 
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Lihat Profil
                              _buildMenuOption(
                                icon: Icons.person,
                                title: "Lihat Profil",
                                subtitle: "Lihat detail informasi profil Anda",
                                iconColor: const Color(0xFF4299E1),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ProfileDetailPage()),
                                  );
                                },
                              ),
                              
                              _buildDividerHorizontal(),
                              
                              // Pengaturan - Updated to navigate to SettingsPage
                              _buildMenuOption(
                                icon: Icons.settings,
                                title: languageProvider.translate('settings'),
                                subtitle: "Ubah pengaturan aplikasi",
                                iconColor: const Color(0xFF9F7AEA),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                                  );
                                },
                              ),
                              
                              _buildDividerHorizontal(),
                              
                              // _buildMenuOption(
                              //   icon: Icons.help_outline,
                              //   title: languageProvider.translate('help'),
                              //   subtitle: "Pusat bantuan dan FAQ",
                              //   iconColor: const Color(0xFF48BB78),
                              //   onTap: () {
                              //     ScaffoldMessenger.of(context).showSnackBar(
                              //       const SnackBar(
                              //         content: Text('Fitur bantuan akan segera hadir'),
                              //         behavior: SnackBarBehavior.floating,
                              //       ),
                              //     );
                              //   },
                              // ),
                              
                              _buildDividerHorizontal(),
                              
                              // Sign Out
                              _buildMenuOption(
                                icon: Icons.logout,
                                title: languageProvider.translate('sign_out'),
                                subtitle: "Keluar dari aplikasi",
                                iconColor: const Color(0xFFE53E3E),
                                onTap: _showSignOutDialog,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // App Version
                        Text(
                          "Vokasi Tera v1.0.0",
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.isDarkMode 
                                ? Colors.white.withOpacity(0.5) 
                                : Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // No bottom navigation bar
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.isDarkMode 
                  ? Colors.white.withOpacity(0.6) 
                  : const Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Container(
      height: 30,
      width: 1,
      color: themeProvider.isDarkMode 
          ? const Color(0xFF4A5568) 
          : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildDividerHorizontal() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        color: themeProvider.isDarkMode 
            ? const Color(0xFF4A5568) 
            : const Color(0xFFE2E8F0),
        height: 1,
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode 
                            ? Colors.white 
                            : const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.isDarkMode 
                            ? Colors.white.withOpacity(0.6) 
                            : const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: themeProvider.isDarkMode 
                    ? Colors.white.withOpacity(0.3) 
                    : const Color(0xFFCBD5E0),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced Wavy Clipper for a more modern look
class EnhancedWavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);

    // First wave
    var firstControlPoint = Offset(size.width / 4, size.height - 10);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // Second wave
    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
