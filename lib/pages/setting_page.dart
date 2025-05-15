import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_artefak/providers/theme_provider.dart';
import 'package:flutter_artefak/providers/language_provider.dart';
import 'package:shimmer/shimmer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Simulate loading
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Start animation after build
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access providers
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Theme(
      // Apply current theme to this page
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
                height: MediaQuery.of(context).size.height * 0.25,
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

            // App Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                title: Text(
                  languageProvider.translate('settings'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            languageProvider.translate('customization'),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            languageProvider.translate('customize_app'),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Content Area
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode 
                              ? const Color(0xFF1A202C) 
                              : const Color(0xFFF5F7FA),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: _isLoading 
                            ? _buildSkeletonLoading(themeProvider)
                            : FadeTransition(
                                opacity: _fadeAnimation,
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Theme Section
                                        _buildSectionTitle(languageProvider.translate('display_mode')),
                                        const SizedBox(height: 16),
                                        _buildThemeSelector(themeProvider, languageProvider),
                                        
                                        const SizedBox(height: 32),
                                        
                                        // Language Section
                                        _buildSectionTitle(languageProvider.translate('language_selection')),
                                        const SizedBox(height: 16),
                                        _buildLanguageSelector(languageProvider),
                                        
                                        const SizedBox(height: 32),
                                        
                                        // Info Card
                                        _buildInfoCard(languageProvider),
                                        
                                        const SizedBox(height: 24),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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

  Widget _buildSkeletonLoading(ThemeProvider themeProvider) {
    final baseColor = themeProvider.isDarkMode 
        ? const Color(0xFF2D3748) 
        : Colors.grey[300]!;
    final highlightColor = themeProvider.isDarkMode 
        ? const Color(0xFF4A5568) 
        : Colors.grey[100]!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section Title Skeleton
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 120,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Theme Selector Skeleton
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Language Section Title Skeleton
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 150,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Language Selector Skeleton
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Info Card Skeleton
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF4299E1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode 
                ? Colors.white 
                : const Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(ThemeProvider themeProvider, LanguageProvider languageProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode 
            ? const Color(0xFF2D3748) 
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Light Mode Option
          _buildThemeOption(
            title: languageProvider.translate('light_mode'),
            icon: Icons.light_mode,
            isSelected: !themeProvider.isDarkMode,
            onTap: () {
              themeProvider.setTheme(false);
              _showFeedbackSnackbar(languageProvider.translate('light_mode_enabled'));
            },
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: themeProvider.isDarkMode 
                  ? const Color(0xFF4A5568) 
                  : const Color(0xFFE2E8F0),
              height: 1,
            ),
          ),
          
          // Dark Mode Option
          _buildThemeOption(
            title: languageProvider.translate('dark_mode'),
            icon: Icons.dark_mode,
            isSelected: themeProvider.isDarkMode,
            onTap: () {
              themeProvider.setTheme(true);
              _showFeedbackSnackbar(languageProvider.translate('dark_mode_enabled'));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF4299E1).withOpacity(0.1)
                      : themeProvider.isDarkMode 
                          ? const Color(0xFF4A5568) 
                          : const Color(0xFFEDF2F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected 
                      ? const Color(0xFF4299E1)
                      : themeProvider.isDarkMode 
                          ? Colors.white.withOpacity(0.7) 
                          : const Color(0xFF718096),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected 
                        ? themeProvider.isDarkMode 
                            ? Colors.white 
                            : const Color(0xFF2D3748)
                        : themeProvider.isDarkMode 
                            ? Colors.white.withOpacity(0.7) 
                            : const Color(0xFF4A5568),
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4299E1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(LanguageProvider languageProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final availableLanguages = ['Indonesia', 'English'];
    
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode 
            ? const Color(0xFF2D3748) 
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: availableLanguages.map((language) {
          final isSelected = language == languageProvider.currentLanguage;
          final isLast = language == availableLanguages.last;
          
          return Column(
            children: [
              _buildLanguageOption(
                title: language,
                flag: language == 'Indonesia' ? '🇮🇩' : '🇺🇸',
                isSelected: isSelected,
                onTap: () {
                  languageProvider.setLanguage(language);
                  _showFeedbackSnackbar('${languageProvider.translate('language_changed')} $language');
                },
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    color: themeProvider.isDarkMode 
                        ? const Color(0xFF4A5568) 
                        : const Color(0xFFE2E8F0),
                    height: 1,
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF4299E1).withOpacity(0.1)
                      : themeProvider.isDarkMode 
                          ? const Color(0xFF4A5568) 
                          : const Color(0xFFEDF2F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  flag,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected 
                        ? themeProvider.isDarkMode 
                            ? Colors.white 
                            : const Color(0xFF2D3748)
                        : themeProvider.isDarkMode 
                            ? Colors.white.withOpacity(0.7) 
                            : const Color(0xFF4A5568),
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4299E1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(LanguageProvider languageProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode 
            ? const Color(0xFF2C5282).withOpacity(0.2) 
            : const Color(0xFFEBF8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode 
              ? const Color(0xFF4299E1).withOpacity(0.5) 
              : const Color(0xFF90CDF4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode 
                  ? const Color(0xFF2D3748) 
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFF4299E1),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageProvider.translate('information'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode 
                        ? const Color(0xFF90CDF4) 
                        : const Color(0xFF2C5282),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  languageProvider.translate('settings_info'),
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.isDarkMode 
                        ? Colors.white.withOpacity(0.8) 
                        : const Color(0xFF2A4365),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showFeedbackSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4299E1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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