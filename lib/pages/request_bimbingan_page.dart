import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_artefak/services/bimbingan_services.dart';
import 'package:flutter_artefak/models/ruangan_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_artefak/providers/theme_provider.dart';
import 'package:flutter_artefak/providers/language_provider.dart';

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
  int? _selectedRuanganId;
  final _deskripsiController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isSubmitting = false;
  bool _isLoadingRuangan = true;
  List<Ruangan> _ruanganList = [];
  String? _errorMessage;

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
    
    // Load ruangan data
    _loadRuangan();
    
    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  Future<void> _loadRuangan() async {
    try {
      final ruangans = await BimbinganService.getRuangans();
      setState(() {
        _ruanganList = ruangans;
        _isLoadingRuangan = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingRuangan = false;
      });
    }
  }

  @override
  void dispose() {
    _keperluanController.dispose();
    _deskripsiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || 
        _rencanaMulai == null || 
        _rencanaSelesai == null || 
        _selectedRuanganId == null) {
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
        rencanaMulai: _rencanaMulai!,
        rencanaSelesai: _rencanaSelesai!,
        ruanganId: _selectedRuanganId!,
      );

      if (success) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        
        if (!mounted) return;
        
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6FFFA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline, color: Color(0xFF38B2AC), size: 24),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Berhasil!', 
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode 
                          ? Colors.white 
                          : const Color(0xFF2D3748),
                    ),
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
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal mengirim permintaan'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: const Color(0xFFE53E3E),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Gagal mengirim permintaan';
      if (e is NoGroupException) {
        errorMessage = e.message;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: const Color(0xFFE53E3E),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _pickDateTime() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    
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
              onSurface: isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF2D3748),
            ),
            dialogBackgroundColor: isDarkMode 
                ? const Color(0xFF2D3748) 
                : Colors.white,
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
              onSurface: isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF2D3748),
            ),
            dialogBackgroundColor: isDarkMode 
                ? const Color(0xFF2D3748) 
                : Colors.white,
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
              onSurface: isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF2D3748),
            ),
            dialogBackgroundColor: isDarkMode 
                ? const Color(0xFF2D3748) 
                : Colors.white,
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
              onSurface: isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF2D3748),
            ),
            dialogBackgroundColor: isDarkMode 
                ? const Color(0xFF2D3748) 
                : Colors.white,
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
    final isDarkMode = themeProvider.isDarkMode;
    
    final dateTimeFormat = (_rencanaMulai != null && _rencanaSelesai != null)
        ? '${DateFormat('dd-MM-yyyy HH:mm').format(_rencanaMulai!)} - ${DateFormat('HH:mm').format(_rencanaSelesai!)}'
        : '';

    return Theme(
      data: themeProvider.themeData,
      child: Scaffold(
        backgroundColor: isDarkMode 
            ? const Color(0xFF1A202C) 
            : const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(
            'Ajukan Bimbingan',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF2D3748),
            ),
          ),
          centerTitle: true,
          backgroundColor: isDarkMode 
              ? const Color(0xFF2D3748) 
              : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back, 
              color: isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF2D3748),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Formulir Bimbingan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode 
                        ? Colors.white 
                        : const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan lengkapi formulir di bawah ini untuk mengajukan bimbingan dengan dosen.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode 
                        ? Colors.white.withOpacity(0.7) 
                        : const Color(0xFF718096),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode 
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
                      _buildFormLabel('Keperluan Bimbingan', true, isDarkMode),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _keperluanController,
                        hintText: 'Tulis keperluan bimbingan Anda',
                        icon: Icons.subject,
                        validator: (value) => value!.isEmpty ? 'Keperluan wajib diisi' : null,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 24),
                      
                      // Date Time Field
                      _buildFormLabel('Rencana Tanggal & Waktu', true, isDarkMode),
                      const SizedBox(height: 8),
                      _buildDateTimePicker(dateTimeFormat, isDarkMode),
                      const SizedBox(height: 24),
                      
                      // Ruangan Field
                      _buildFormLabel('Ruangan Bimbingan', true, isDarkMode),
                      const SizedBox(height: 8),
                      _buildRuanganDropdown(isDarkMode),
                      const SizedBox(height: 24),
                      
                      // Deskripsi Field (Optional)
                      _buildFormLabel('Deskripsi Tambahan', false, isDarkMode),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _deskripsiController,
                        hintText: 'Jelaskan lebih detail keperluan Anda (opsional)',
                        icon: Icons.description,
                        maxLines: 3,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 32),
                      
                      // Buttons
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Use a column instead of row for narrow screens
                          if (constraints.maxWidth < 400) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildOutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  text: 'Batal',
                                ),
                                const SizedBox(height: 12),
                                _buildElevatedButton(
                                  onPressed: _isSubmitting ? null : _submit,
                                  text: _isSubmitting ? 'Mengirim...' : 'Ajukan',
                                ),
                              ],
                            );
                          }
                          
                          // Use row for wider screens
                          return Row(
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
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? const Color(0xFF2C5282).withOpacity(0.2) 
                        : const Color(0xFFEBF8FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode 
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
                          color: isDarkMode 
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
                                color: isDarkMode 
                                    ? const Color(0xFF90CDF4) 
                                    : const Color(0xFF2C5282),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Permintaan bimbingan akan dikirim ke dosen dan menunggu persetujuan.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode 
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
    );
  }

  Widget _buildFormLabel(String label, bool isRequired, bool isDarkMode) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode 
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
    required bool isDarkMode,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDarkMode 
              ? Colors.white.withOpacity(0.3) 
              : const Color(0xFFA0AEC0),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF4299E1), size: 20),
        filled: true,
        fillColor: isDarkMode 
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
            color: isDarkMode 
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
        color: isDarkMode 
            ? Colors.white 
            : const Color(0xFF2D3748),
      ),
      validator: validator,
    );
  }

  Widget _buildDateTimePicker(String dateTimeFormat, bool isDarkMode) {
    return GestureDetector(
      onTap: _pickDateTime,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            hintText: 'Pilih tanggal dan waktu',
            hintStyle: TextStyle(
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.3) 
                  : const Color(0xFFA0AEC0),
              fontSize: 14,
            ),
            prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF4299E1), size: 20),
            suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4299E1)),
            filled: true,
            fillColor: isDarkMode 
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
                color: isDarkMode 
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
            color: isDarkMode 
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

  Widget _buildRuanganDropdown(bool isDarkMode) {
    if (_isLoadingRuangan) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: CircularProgressIndicator(
            color: const Color(0xFF4299E1),
            strokeWidth: 3,
          ),
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode 
              ? const Color(0xFF2C1A1A) 
              : const Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE53E3E)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFE53E3E)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Gagal memuat ruangan: $_errorMessage',
                style: const TextStyle(color: Color(0xFFE53E3E)),
              ),
            ),
          ],
        ),
      );
    }
    
    return DropdownButtonFormField<int>(
      value: _selectedRuanganId,
      decoration: InputDecoration(
        hintText: 'Pilih ruangan',
        hintStyle: TextStyle(
          color: isDarkMode 
              ? Colors.white.withOpacity(0.3) 
              : const Color(0xFFA0AEC0),
          fontSize: 14,
        ),
        prefixIcon: const Icon(Icons.meeting_room, color: Color(0xFF4299E1), size: 20),
        filled: true,
        fillColor: isDarkMode 
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
            color: isDarkMode 
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
        color: isDarkMode 
            ? Colors.white 
            : const Color(0xFF2D3748),
      ),
      dropdownColor: isDarkMode 
          ? const Color(0xFF2D3748) 
          : Colors.white,
      items: _ruanganList.map((ruangan) {
        return DropdownMenuItem<int>(
          value: ruangan.id,
          child: Text(
            ruangan.ruangan,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRuanganId = value;
        });
      },
      validator: (value) => value == null ? 'Ruangan wajib dipilih' : null,
      isExpanded: true,
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

class NoGroupException implements Exception {
  final String message;
  NoGroupException(this.message);
}