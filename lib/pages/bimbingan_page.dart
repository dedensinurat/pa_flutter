import 'package:flutter/material.dart';
import 'package:flutter_artefak/models/bimbingan_model.dart';
import 'package:flutter_artefak/services/bimbingan_services.dart';
import 'package:flutter_artefak/pages/request_bimbingan_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_artefak/providers/theme_provider.dart';
import 'package:flutter_artefak/providers/language_provider.dart';

class BimbinganPage extends StatefulWidget {
  const BimbinganPage({super.key});

  @override
  State<BimbinganPage> createState() => _BimbinganPageState();
}

class _BimbinganPageState extends State<BimbinganPage> with SingleTickerProviderStateMixin {
  List<Bimbingan> _bimbinganList = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Setup animations
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
    
    _fetchBimbingan();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Fetch all bimbingan from the API
  Future<void> _fetchBimbingan() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final data = await BimbinganService.getAll();
      setState(() {
        _bimbinganList = data;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Gagal memuat data: $e';
      });
      print('Error fetching data: $e');
    }
  }

  // Format date
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy • HH:mm').format(date);
  }

  // Get status color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return const Color(0xFF38B2AC); // Green for selesai
      case 'ditolak':
        return const Color(0xFFE53E3E); // Red for ditolak
      case 'pending':
        return const Color(0xFFED8936); // Orange for pending
      default:
        return const Color(0xFF718096);
    }
  }

  // Get status background color based on status
  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return const Color(0xFFE6FFFA); // Light green bg for selesai
      case 'ditolak':
        return const Color(0xFFFFF5F5); // Light red bg for ditolak
      case 'pending':
        return const Color(0xFFFFFBEB); // Light yellow bg for pending
      default:
        return const Color(0xFFEDF2F7);
    }
  }

  // Get status icon based on status
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Icons.check_circle;
      case 'ditolak':
        return Icons.cancel;
      case 'pending':
        return Icons.access_time;
      default:
        return Icons.help_outline;
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
                    onPressed: _fetchBimbingan,
                  ),
                ],
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
                          const Text(
                            'Bimbingan',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kelola jadwal bimbingan dengan dosen',
                            style: TextStyle(
                              fontSize: 14,
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
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Request Button
                                _buildRequestButton(),
                                
                                const SizedBox(height: 24),
                                
                                // Bimbingan List Title
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Daftar Bimbingan',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.isDarkMode 
                                            ? Colors.white 
                                            : const Color(0xFF2D3748),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEBF8FF),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${_bimbinganList.length} Bimbingan',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF4299E1),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Bimbingan List
                                Expanded(
                                  child: _isLoading
                                      ? _buildLoadingState()
                                      : _hasError
                                          ? _buildErrorState()
                                          : _bimbinganList.isEmpty
                                              ? _buildEmptyState()
                                              : _buildBimbinganList(),
                                ),
                                
                                // Guidance Info
                                _buildGuidanceInfo(),
                              ],
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

  Widget _buildRequestButton() {
    return ElevatedButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RequestBimbinganPage()),
        );
        if (result == true) {
          _fetchBimbingan();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4299E1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.add, size: 20),
          SizedBox(width: 8),
          Text(
            'Ajukan Bimbingan Baru',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF2D3748) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF4299E1),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat data bimbingan...',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.isDarkMode 
                  ? Colors.white.withOpacity(0.7) 
                  : const Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(35),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: Color(0xFFE53E3E),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.isDarkMode 
                  ? Colors.white.withOpacity(0.7) 
                  : const Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchBimbingan,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4299E1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF8FF),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.calendar_today,
              size: 40,
              color: Color(0xFF4299E1),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data bimbingan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajukan bimbingan baru untuk memulai',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.isDarkMode 
                  ? Colors.white.withOpacity(0.7) 
                  : const Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBimbinganList() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF2D3748) : Colors.white,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          itemCount: _bimbinganList.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: themeProvider.isDarkMode 
                ? const Color(0xFF4A5568) 
                : const Color(0xFFE2E8F0),
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final item = _bimbinganList[index];
            return _buildBimbinganCard(item, index);
          },
        ),
      ),
    );
  }

  Widget _buildBimbinganCard(Bimbingan item, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Show detail or action sheet
          _showBimbinganDetail(item);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode 
                          ? const Color(0xFF4A5568) 
                          : const Color(0xFFEDF2F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Bimbingan #${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: themeProvider.isDarkMode 
                            ? Colors.white.withOpacity(0.9) 
                            : const Color(0xFF4A5568),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(item.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(item.status),
                          size: 14,
                          color: _getStatusColor(item.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(item.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Keperluan
              Text(
                item.keperluan,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode 
                      ? Colors.white 
                      : const Color(0xFF2D3748),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Date and Location
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: themeProvider.isDarkMode 
                        ? Colors.white.withOpacity(0.6) 
                        : const Color(0xFF718096),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(item.rencanaMulai),
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.isDarkMode 
                          ? Colors.white.withOpacity(0.6) 
                          : const Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: themeProvider.isDarkMode 
                        ? Colors.white.withOpacity(0.6) 
                        : const Color(0xFF718096),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.lokasi,
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.isDarkMode 
                            ? Colors.white.withOpacity(0.6) 
                            : const Color(0xFF718096),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBimbinganDetail(Bimbingan item) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? const Color(0xFF2D3748) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode 
                      ? const Color(0xFF4A5568) 
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(item.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStatusIcon(item.status),
                      color: _getStatusColor(item.status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Bimbingan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode 
                                ? Colors.white 
                                : const Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusBgColor(item.status),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(item.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(
              height: 1, 
              color: themeProvider.isDarkMode 
                  ? const Color(0xFF4A5568) 
                  : const Color(0xFFE2E8F0),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem('Keperluan', item.keperluan),
                    _buildDetailItem('Tanggal Mulai', _formatDate(item.rencanaMulai)),
                    _buildDetailItem('Tanggal Selesai', _formatDate(item.rencanaSelesai)),
                    _buildDetailItem('Lokasi', item.lokasi),
                    
                    const SizedBox(height: 24),
                    
                    // Actions based on status
                    if (item.status.toLowerCase() == 'pending')
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                // Add cancel logic
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('Batalkan'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFE53E3E),
                                side: const BorderSide(color: Color(0xFFE53E3E)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                // Add edit logic
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4299E1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    
                    if (item.status.toLowerCase() == 'selesai')
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Add feedback logic
                        },
                        icon: const Icon(Icons.rate_review),
                        label: const Text('Berikan Feedback'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38B2AC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                      
                    if (item.status.toLowerCase() == 'ditolak')
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Add reschedule logic
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Ajukan Ulang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4299E1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Close button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.isDarkMode 
                      ? const Color(0xFF4A5568) 
                      : const Color(0xFFEDF2F7),
                  foregroundColor: themeProvider.isDarkMode 
                      ? Colors.white 
                      : const Color(0xFF4A5568),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.isDarkMode 
                  ? Colors.white.withOpacity(0.6) 
                  : const Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF2D3748),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceInfo() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Text(
                'Panduan Bimbingan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode 
                      ? const Color(0xFF90CDF4) 
                      : const Color(0xFF2C5282),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuidanceStep(
            number: '1',
            text: 'Ajukan permintaan bimbingan melalui aplikasi.',
          ),
          _buildGuidanceStep(
            number: '2',
            text: 'Mohon menunggu konfirmasi dari dosen pembimbing.',
          ),
          _buildGuidanceStep(
            number: '3',
            text: 'Setelah disetujui, persiapkan diri dan hadir tepat waktu.',
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceStep({required String number, required String text}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF4299E1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.isDarkMode 
                    ? Colors.white.withOpacity(0.8) 
                    : const Color(0xFF2A4365),
              ),
            ),
          ),
        ],
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