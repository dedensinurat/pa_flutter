import 'package:flutter/material.dart';
import 'package:flutter_artefak/pages/jadwal_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_artefak/providers/theme_provider.dart';
import '../models/submit_model.dart';
import '../models/jadwal_model.dart';
import '../services/submit_services.dart';
import '../services/jadwal_service.dart';
import '../pages/submit_detail_page.dart';
import '../pages/jadwal_detail_page.dart';
import '../widgets/jadwal_card.dart';
import 'package:intl/intl.dart';
import '../utils/enhanced_wavy_header.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late Future<List<Submit>> _futureSubmits;
  late Future<List<Jadwal>> _futureJadwal;
  bool _isRefreshing = false;

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
    
    _futureSubmits = _fetchSubmits();
    _futureJadwal = _fetchJadwal();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Submit>> _fetchSubmits() async {
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      print('Fetching submissions in HomePage');
      final result = await SubmitService.fetchSubmits();
      
      setState(() {
        _isRefreshing = false;
      });
      
      // Start animation after data is loaded
      _animationController.forward();
      
      print('Fetched ${result.length} submissions successfully');
      return result;
    } catch (e) {
      setState(() {
        _isRefreshing = false;
      });
<<<<<<< Updated upstream
      print('Error fetching submissions in HomePage: $e');
      throw e;
=======
      rethrow;
>>>>>>> Stashed changes
    }
  }

  Future<List<Jadwal>> _fetchJadwal() async {
    try {
      print('Fetching jadwal in HomePage');
      final jadwals = await JadwalService.getJadwal();
      print('Fetched ${jadwals.length} jadwals');
      
      // Start animation after data is loaded
      _animationController.forward();
      
      return jadwals;
    } catch (e) {
      print('Error fetching jadwal: $e');
      return [];
    }
  }

  Future<void> _refreshData() async {
    print('Refreshing data in HomePage');
    setState(() {
      _futureSubmits = _fetchSubmits();
      _futureJadwal = _fetchJadwal();
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      print('Error formatting date: $e');
      return dateString;
    }
  }

  String _getRemainingDays(String dateString) {
    try {
      final deadline = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = deadline.difference(now).inDays;
      
      if (difference < 0) {
        return 'Lewat batas';
      } else if (difference == 0) {
        return 'Hari ini';
      } else {
        return '$difference hari lagi';
      }
    } catch (e) {
      print('Error calculating remaining days: $e');
      return 'Tanggal tidak valid';
    }
  }

  Color _getDeadlineColor(String dateString) {
    try {
      final deadline = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = deadline.difference(now).inDays;
      
      if (difference < 0) {
        return const Color(0xFFE53E3E); // Red for past deadline
      } else if (difference <= 2) {
        return const Color(0xFFED8936); // Orange for close deadline
      } else if (difference <= 7) {
        return const Color(0xFFECC94B); // Yellow for approaching deadline
      } else {
        return const Color(0xFF38B2AC); // Green for far deadline
      }
    } catch (e) {
      print('Error getting deadline color: $e');
      return Colors.grey; // Default color for invalid dates
    }
  }

  // Check if a submission has been submitted
  bool _isSubmitted(Submit submit) {
    // Check both the hasValidSubmission flag and the submissionStatus
    return submit.hasValidSubmission && 
           (submit.submissionStatus == 'Submitted' || 
            submit.submissionStatus == 'Resubmitted' || 
            submit.submissionStatus == 'Late' ||
            submit.submissionFile.isNotEmpty); // Also check if there's a submission file
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Theme(
      data: themeProvider.themeData,
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF1A202C) : const Color(0xFFF5F7FA),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          color: const Color(0xFF4299E1),
          child: Stack(
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
                  title: const Text(
                    'Vokasi Tera',
                    style: TextStyle(
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
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                    ),
                  ],
                ),
              ),

              // Main Content
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 70.0, bottom: 24.0),
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
                                'Beranda',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Jadwal dan tugas Anda',
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
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1A202C) : const Color(0xFFF5F7FA),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Jadwal Section
                                Row(
                                  children: [
                                    Text(
                                      'Jadwal Seminar',
                                      style: TextStyle(
                                        fontFamily: 'Serif',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const JadwalPage(),
                                          ),
                                        ).then((_) => _refreshData());
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: isDarkMode ? const Color(0xFF63B3ED) : const Color(0xFF4299E1),
                                      ),
                                      child: const Text('Lihat Semua'),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Jadwal List
                                FutureBuilder<List<Jadwal>>(
                                  future: _futureJadwal,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting && !_isRefreshing) {
                                      return _buildJadwalSkeletonLoading(isDarkMode);
                                    } else if (snapshot.hasError) {
                                      return _buildErrorState('Gagal memuat jadwal: ${snapshot.error}', isDarkMode);
                                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return _buildEmptyState(
                                        'Belum ada jadwal',
                                        'Jadwal seminar akan muncul di sini',
                                        Icons.event_busy,
                                        isDarkMode
                                      );
                                    }
                                    
                                    final jadwalList = snapshot.data!;
                                    // Show only the first 2 jadwal items
                                    final displayedJadwals = jadwalList.length > 2 
                                        ? jadwalList.sublist(0, 2) 
                                        : jadwalList;
                                        
                                    return FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: Column(
                                        children: displayedJadwals.map((jadwal) => 
                                          JadwalCard(
                                            jadwal: jadwal,
                                            onRefresh: _refreshData,
                                          )
                                        ).toList(),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Tugas Section
                                Row(
                                  children: [
                                    Text(
                                      'Tugas Terbaru',
                                      style: TextStyle(
                                        fontFamily: 'Serif',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Simple List view for tasks
                                FutureBuilder<List<Submit>>(
                                  future: _futureSubmits,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting && !_isRefreshing) {
                                      return _buildTasksSkeletonLoading(isDarkMode);
                                    } else if (snapshot.hasError) {
                                      return _buildErrorState(snapshot.error.toString(), isDarkMode);
                                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return _buildEmptyState(
                                        'Belum ada tugas',
                                        'Tugas yang diberikan akan muncul di sini',
                                        Icons.assignment_outlined,
                                        isDarkMode
                                      );
                                    }
                                    
                                    final submits = snapshot.data!;
                                    return FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: submits.length,
                                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                                        itemBuilder: (context, index) {
                                          final submit = submits[index];
                                          return _buildSimpleTaskItem(context, submit, index, isDarkMode);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJadwalSkeletonLoading(bool isDarkMode) {
    final baseColor = isDarkMode ? const Color(0xFF2D3748) : Colors.grey[300]!;
    final highlightColor = isDarkMode ? const Color(0xFF4A5568) : Colors.grey[100]!;
    
    return Column(
      children: List.generate(2, (index) => _buildJadwalCardSkeleton(index, baseColor, highlightColor, isDarkMode)),
    );
  }

  Widget _buildJadwalCardSkeleton(int index, Color baseColor, Color highlightColor, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: Duration(milliseconds: 1500 + (index * 200)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2D3748) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 120,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksSkeletonLoading(bool isDarkMode) {
    final baseColor = isDarkMode ? const Color(0xFF2D3748) : Colors.grey[300]!;
    final highlightColor = isDarkMode ? const Color(0xFF4A5568) : Colors.grey[100]!;
    
    return Column(
      children: List.generate(4, (index) => _buildTaskItemSkeleton(index, baseColor, highlightColor, isDarkMode)),
    );
  }

  Widget _buildTaskItemSkeleton(int index, Color baseColor, Color highlightColor, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: Duration(milliseconds: 1500 + (index * 150)),
      child: Card(
        margin: EdgeInsets.only(bottom: 8),
        elevation: 0.5,
        color: isDarkMode ? const Color(0xFF2D3748) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isDarkMode ? const Color(0xFF4A5568) : Colors.grey.shade200, 
            width: 0.5
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 100,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                width: 70,
                height: 20,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF4A5568) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(String message, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2D3748) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: isDarkMode ? const Color(0xFF63B3ED) : const Color(0xFF4A6572),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2C1A1A) : const Color(0xFFFFF5F5),
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
            'Terjadi kesalahan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? const Color(0xFF4299E1) : const Color(0xFF4A6572),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2C5282).withOpacity(0.2) : const Color(0xFFEBF8FF),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              icon,
              size: 40,
              color: isDarkMode ? const Color(0xFF63B3ED) : const Color(0xFF4A6572),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Muat Ulang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? const Color(0xFF4299E1) : const Color(0xFF4A6572),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTaskItem(BuildContext context, Submit submit, int index, bool isDarkMode) {
    final iconColor = isDarkMode ? const Color(0xFF63B3ED) : const Color(0xFF4A6572);
    const icon = Icons.assignment_outlined; // Use assignment icon for all tasks
    final deadlineColor = _getDeadlineColor(submit.tanggalPengumpulan);
    final remainingDays = _getRemainingDays(submit.tanggalPengumpulan);
    
    // Check if the submission has been submitted using our improved method
    final bool isSubmitted = _isSubmitted(submit);

    // Format submission date if available
    String submissionDate = '';
    if (submit.submissionDate != null && submit.submissionDate!.isNotEmpty) {
      try {
        final date = DateTime.parse(submit.submissionDate!);
        submissionDate = 'Dikumpulkan: ${DateFormat('dd MMM').format(date)}';
      } catch (e) {
        submissionDate = 'Sudah dikumpulkan';
      }
    } else if (isSubmitted) {
      submissionDate = 'Sudah dikumpulkan';
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0.5,
      color: isDarkMode ? const Color(0xFF2D3748) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDarkMode ? const Color(0xFF4A5568) : Colors.grey.shade200, 
          width: 0.5
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubmitDetailPage(submit: submit),
            ),
          ).then((_) => _refreshData());
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Small icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      submit.judulTugas,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 2),
                    
                    // Date or submission info
                    Text(
                      isSubmitted ? submissionDate : _formatDate(submit.tanggalPengumpulan),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSubmitted 
                            ? Colors.green.shade700 
                            : isDarkMode 
                                ? Colors.white.withOpacity(0.6) 
                                : Colors.grey[600],
                        fontWeight: isSubmitted ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Deadline chip or Submitted status
              isSubmitted 
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Text(
                      "Dikumpulkan",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: deadlineColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: deadlineColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      remainingDays,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: deadlineColor,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}