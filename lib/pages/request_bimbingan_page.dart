import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_artefak/services/bimbingan_services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_artefak/providers/theme_provider.dart';
import 'package:flutter_artefak/providers/language_provider.dart';
import 'dart:ui';

class RequestBimbinganPage extends StatefulWidget {
  const RequestBimbinganPage({super.key});

  @override
  State<RequestBimbinganPage> createState() => _RequestBimbinganPageState();
}

class _RequestBimbinganPageState extends State<RequestBimbinganPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  DateTime? _rencanaMulai;
  DateTime? _rencanaSelesai;

  final _keperluanController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isSubmitting = false;

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
    
    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _keperluanController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _rencanaMulai == null || _rencanaSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lengkapi semua field yang wajib'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: const Color(0xFFE53E3E),
        ),
      );
      return;
    }

    if (_rencanaSelesai!.isBefore(_rencanaMulai!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Waktu selesai harus setelah waktu mulai'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: const Color(0xFFE53E3E),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await BimbinganService.create(
        keperluan: _keperluanController.text,
        rencanaMulai: _rencanaMulai!.toUtc(), // ⬅️ penting: kirim dalam UTC
        rencanaSelesai: _rencanaSelesai!.toUtc(),
        lokasi: _lokasiController.text,
      );

      if (success) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: themeProvider.isDarkMode 
                ? const Color(0xFF2D3748) 
                : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6FFFA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline, color: Color(0xFF38B2AC), size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Berhasil!', 
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode 
                        ? Colors.white 
                        : const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            content: Text(
              'Permintaan bimbingan berhasil dikirim.',
              style: TextStyle(
                color: themeProvider.isDarkMode 
                    ? Colors.white.withOpacity(0.7) 
                    : const Color(0xFF4A5568),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context, true);
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4299E1),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal mengirim permintaan'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: const Color(0xFFE53E3E),
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _pickDateTime() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    final dateMulai = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF4299E1),
              onPrimary: Colors.white,
              onSurface: themeProvider.isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF2D3748),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4299E1),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (dateMulai == null) return;

    final timeMulai = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF4299E1),
              onPrimary: Colors.white,
              onSurface: themeProvider.isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF2D3748),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4299E1),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (timeMulai == null) return;

    final dateSelesai = await showDatePicker(
      context: context,
      initialDate: dateMulai,
      firstDate: dateMulai,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF4299E1),
              onPrimary: Colors.white,
              onSurface: themeProvider.isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF2D3748),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4299E1),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (dateSelesai == null) return;

    final timeSelesai = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF4299E1),
              onPrimary: Colors.white,
              onSurface: themeProvider.isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF2D3748),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4299E1),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (timeSelesai == null) return;

    setState(() {
      _rencanaMulai = DateTime(dateMulai.year, dateMulai.month, dateMulai.day, timeMulai.hour, timeMulai.minute);
      _rencanaSelesai = DateTime(dateSelesai.year, dateSelesai.month, dateSelesai.day, timeSelesai.hour, timeSelesai.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    final dateTimeFormat = (_rencanaMulai != null && _rencanaSelesai != null)
        ? '${DateFormat('dd-MM-yyyy HH:mm').format(_rencanaMulai!)} - ${DateFormat('HH:mm').format(_rencanaSelesai!)}'
        : '';

    return Theme(
      data: themeProvider.themeData,
      child: Scaffold(
        backgroundColor: themeProvider.isDarkMode 
            ? const Color(0xFF1A202C) 
            : const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(
            'Ajukan Bimbingan',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF2D3748),
            ),
          ),
          centerTitle: true,
          backgroundColor: themeProvider.isDarkMode 
              ? const Color(0xFF2D3748) 
              : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back, 
              color: themeProvider.isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF2D3748),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4299E1).withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4299E1).withOpacity(0.05),
                ),
              ),
            ),
            
            // Main content
            FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Text(
                        'Formulir Bimbingan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode 
                              ? Colors.white 
                              : const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Silakan lengkapi formulir di bawah ini untuk mengajukan bimbingan dengan dosen.',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode 
                              ? Colors.white.withOpacity(0.7) 
                              : const Color(0xFF718096),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Form Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode 
                              ? const Color(0xFF2D3748) 
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Keperluan Field
                            _buildFormLabel('Keperluan Bimbingan', true),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _keperluanController,
                              hintText: 'Tulis keperluan bimbingan Anda',
                              icon: Icons.subject,
                              validator: (value) => value!.isEmpty ? 'Keperluan wajib diisi' : null,
                            ),
                            const SizedBox(height: 24),
                            
                            // Date Time Field
                            _buildFormLabel('Rencana Tanggal & Waktu', true),
                            const SizedBox(height: 8),
                            _buildDateTimePicker(dateTimeFormat),
                            const SizedBox(height: 24),
                            
                            // Lokasi Field
                            _buildFormLabel('Lokasi Bimbingan', true),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _lokasiController,
                              hintText: 'Tulis lokasi bimbingan',
                              icon: Icons.location_on,
                              validator: (value) => value!.isEmpty ? 'Lokasi wajib diisi' : null,
                            ),
                            const SizedBox(height: 24),
                            
                            // Deskripsi Field (Optional)
                            _buildFormLabel('Deskripsi Tambahan', false),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _deskripsiController,
                              hintText: 'Jelaskan lebih detail keperluan Anda (opsional)',
                              icon: Icons.description,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 32),
                            
                            // Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _buildOutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    text: 'Batal',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildElevatedButton(
                                    onPressed: _isSubmitting ? null : _submit,
                                    text: _isSubmitting ? 'Mengirim...' : 'Ajukan',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode 
                              ? const Color(0xFF2C5282).withOpacity(0.2) 
                              : const Color(0xFFEBF8FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: themeProvider.isDarkMode 
                                ? const Color(0xFF4299E1).withOpacity(0.5) 
                                : const Color(0xFF90CDF4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: themeProvider.isDarkMode 
                                    ? const Color(0xFF2D3748) 
                                    : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: Color(0xFF4299E1),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Informasi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.isDarkMode 
                                          ? const Color(0xFF90CDF4) 
                                          : const Color(0xFF2C5282),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Permintaan bimbingan akan dikirim ke dosen dan menunggu persetujuan.',
                                    style: TextStyle(
                                      fontSize: 12,
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label, bool isRequired) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode 
                ? Colors.white.withOpacity(0.7) 
                : const Color(0xFF4A5568),
          ),
        ),
        const SizedBox(width: 4),
        if (isRequired)
          const Text(
            '*',
            style: TextStyle(
              color: Color(0xFFE53E3E),
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: themeProvider.isDarkMode 
              ? Colors.white.withOpacity(0.3) 
              : const Color(0xFFA0AEC0),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF4299E1), size: 20),
        filled: true,
        fillColor: themeProvider.isDarkMode 
            ? const Color(0xFF1A202C) 
            : const Color(0xFFF7FAFC),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.isDarkMode 
                ? const Color(0xFF4A5568) 
                : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4299E1), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53E3E)),
        ),
      ),
      style: TextStyle(
        fontSize: 14,
        color: themeProvider.isDarkMode 
            ? Colors.white 
            : const Color(0xFF2D3748),
      ),
      validator: validator,
    );
  }

  Widget _buildDateTimePicker(String dateTimeFormat) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return GestureDetector(
      onTap: _pickDateTime,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            hintText: 'Pilih tanggal dan waktu',
            hintStyle: TextStyle(
              color: themeProvider.isDarkMode 
                  ? Colors.white.withOpacity(0.3) 
                  : const Color(0xFFA0AEC0),
              fontSize: 14,
            ),
            prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF4299E1), size: 20),
            suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4299E1)),
            filled: true,
            fillColor: themeProvider.isDarkMode 
                ? const Color(0xFF1A202C) 
                : const Color(0xFFF7FAFC),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode 
                    ? const Color(0xFF4A5568) 
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4299E1), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE53E3E)),
            ),
          ),
          controller: TextEditingController(text: dateTimeFormat),
          style: TextStyle(
            fontSize: 14,
            color: themeProvider.isDarkMode 
                ? Colors.white 
                : const Color(0xFF2D3748),
          ),
          validator: (_) => (_rencanaMulai == null || _rencanaSelesai == null)
              ? 'Tanggal dan waktu wajib dipilih'
              : null,
        ),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required VoidCallback onPressed,
    required String text,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF4299E1),
        side: const BorderSide(color: Color(0xFF4299E1)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildElevatedButton({
    required VoidCallback? onPressed,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4299E1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}