import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/submit_model.dart';
import '../services/submit_services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_artefak/providers/theme_provider.dart';
import 'package:flutter_artefak/providers/language_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class SubmitDetailPage extends StatefulWidget {
  final Submit submit;

  const SubmitDetailPage({Key? key, required this.submit}) : super(key: key);

  @override
  State<SubmitDetailPage> createState() => _SubmitDetailPageState();
}

class _SubmitDetailPageState extends State<SubmitDetailPage> {
  File? _selectedFile;
  bool _isUploading = false;
  String? _uploadMessage;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      setState(() {
        _uploadMessage = 'Pilih file terlebih dahulu';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadMessage = null;
    });

    try {
      final result = await SubmitService.uploadSubmit(
        widget.submit.id, 
        _selectedFile!.path
      );
      
      setState(() {
        _uploadMessage = result;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _uploadMessage = 'Error: ${e.toString()}';
        _isUploading = false;
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
            : Colors.blueGrey.shade50,
        body: Stack(
          children: [
            // Gelombang latar atas
            ClipPath(
              clipper: WavyClipper(),
              child: Container(
                height: 140, // Lebih pendek
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF81D4FA).withOpacity(0.9),
                      const Color(0xFFB3E5FC).withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Konten utama
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 100, 18, 24), // Naikkan
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(
                      icon: Icons.title_outlined,
                      label: "Judul",
                      value: widget.submit.judul,
                      color: Colors.indigo.shade300,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      icon: Icons.description_outlined,
                      label: "Instruksi",
                      value: widget.submit.instruksi,
                      color: Colors.teal.shade300,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      icon: Icons.calendar_today_outlined,
                      label: "Batas Pengumpulan",
                      value: DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.parse(widget.submit.batas)),
                      color: Colors.deepOrange.shade300,
                    ),
                    
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      icon: Icons.attach_file_outlined,
                      label: "File",
                      value: widget.submit.file.isEmpty ? "Tidak ada file lampiran" : widget.submit.file,
                      color: Colors.purple.shade300,
                    ),
               
                    
                    // File selection section
                    if (_selectedFile != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode 
                              ? Colors.green.shade900.withOpacity(0.3) 
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: themeProvider.isDarkMode 
                                ? Colors.green.shade800 
                                : Colors.green.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'File dipilih: ${_selectedFile!.path.split('/').last}',
                                style: TextStyle(
                                  color: themeProvider.isDarkMode 
                                      ? Colors.green.shade100 
                                      : Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Upload message
                    if (_uploadMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _uploadMessage!.contains('Error') 
                              ? (themeProvider.isDarkMode 
                                  ? Colors.red.shade900.withOpacity(0.3) 
                                  : Colors.red.shade50)
                              : (themeProvider.isDarkMode 
                                  ? Colors.blue.shade900.withOpacity(0.3) 
                                  : Colors.blue.shade50),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _uploadMessage!.contains('Error') 
                                ? (themeProvider.isDarkMode 
                                    ? Colors.red.shade800 
                                    : Colors.red.shade200)
                                : (themeProvider.isDarkMode 
                                    ? Colors.blue.shade800 
                                    : Colors.blue.shade200),
                          ),
                        ),
                        child: Text(
                          _uploadMessage!,
                          style: TextStyle(
                            color: _uploadMessage!.contains('Error') 
                                ? (themeProvider.isDarkMode 
                                    ? Colors.red.shade100 
                                    : Colors.red.shade700)
                                : (themeProvider.isDarkMode 
                                    ? Colors.blue.shade100 
                                    : Colors.blue.shade700),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isUploading ? null : _pickFile,
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Pilih File'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.isDarkMode 
                                  ? const Color(0xFF2D3748) 
                                  : Colors.grey.shade200,
                              foregroundColor: themeProvider.isDarkMode 
                                  ? Colors.white 
                                  : Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isUploading ? null : _uploadFile,
                            icon: _isUploading 
                                ? const SizedBox(
                                    width: 16, 
                                    height: 16, 
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  )
                                : const Icon(Icons.cloud_upload),
                            label: Text(_isUploading ? 'Uploading...' : 'Kumpulkan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue.shade300,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Tombol back dan judul
            Positioned(
              top: 24, // Naikkan dari 40
              left: 16,
              right: 16,
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Detail Pengumpulan',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

  Widget _buildDetailSection({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: themeProvider.isDarkMode 
              ? const Color(0xFF4A5568) 
              : Colors.grey.shade200, 
          width: 1,
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
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: themeProvider.isDarkMode 
                      ? Colors.white.withOpacity(0.7) 
                      : Colors.blueGrey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: themeProvider.isDarkMode 
                  ? Colors.white 
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class WavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 30);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 20);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 50);
    var secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}