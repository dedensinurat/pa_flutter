import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/submit_model.dart';
import '../services/submit_services.dart';
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
  bool _isEditing = false;
  late Submit _currentSubmit;

  @override
  void initState() {
    super.initState();
    _currentSubmit = widget.submit;
    _refreshSubmitDetails();
  }

  Future<void> _refreshSubmitDetails() async {
    try {
      final updatedSubmit = await SubmitService.fetchSubmitById(_currentSubmit.id);
      setState(() {
        _currentSubmit = updatedSubmit;
      });
    } catch (e) {
      // Handle error silently
      print("Error refreshing submit details: $e");
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'zip'],
    );
    
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

    // Validate file extension
    String extension = _selectedFile!.path.split('.').last.toLowerCase();
    if (!['pdf', 'doc', 'docx', 'zip'].contains(extension)) {
      setState(() {
        _uploadMessage = 'Format file tidak didukung. Hanya menerima file PDF, DOC, DOCX, atau ZIP';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadMessage = null;
    });

    try {
      final result = _isEditing 
          ? await SubmitService.updateSubmit(_currentSubmit.id, _selectedFile!.path)
          : await SubmitService.uploadSubmit(_currentSubmit.id, _selectedFile!.path);
      
      setState(() {
        _uploadMessage = result;
        _isUploading = false;
        _isEditing = false;
      });
      
      // Refresh the submit details to get the updated status
      await _refreshSubmitDetails();
    } catch (e) {
      setState(() {
        _uploadMessage = 'Error: ${e.toString()}';
        _isUploading = false;
      });
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Submitted':
        return 'Sudah Dikumpulkan';
      case 'Resubmitted':
        return 'Sudah Diperbarui';
      case 'Late':
        return 'Terlambat';
      case 'Belum':
        return 'Belum Dikumpulkan';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Submitted':
        return Colors.green;
      case 'Resubmitted':
        return Colors.blue;
      case 'Late':
        return Colors.orange;
      case 'Belum':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSubmitted = _currentSubmit.submissionStatus != 'Belum';
    final bool isDeadlinePassed = DateTime.now().isAfter(DateTime.parse(_currentSubmit.tanggalPengumpulan));
    
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: Stack(
        children: [
          // Gelombang latar atas
          ClipPath(
            clipper: WavyClipper(),
            child: Container(
              height: 140,
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
              padding: const EdgeInsets.fromLTRB(18, 100, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection(
                    icon: Icons.title_outlined,
                    label: "Judul",
                    value: _currentSubmit.judulTugas,
                    color: Colors.indigo.shade300,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    icon: Icons.description_outlined,
                    label: "Instruksi",
                    value: _currentSubmit.deskripsiTugas,
                    color: Colors.teal.shade300,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    icon: Icons.calendar_today_outlined,
                    label: "Batas Pengumpulan",
                    value: DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.parse(_currentSubmit.tanggalPengumpulan)),
                    color: Colors.deepOrange.shade300,
                  ),
                  
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    icon: Icons.attach_file_outlined,
                    label: "File Lampiran",
                    value: _currentSubmit.file.isEmpty ? "Tidak ada file lampiran" : _currentSubmit.file,
                    color: Colors.purple.shade300,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Submission Status Section
                  if (hasSubmitted)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.shade200, 
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
                                  color: _getStatusColor(_currentSubmit.submissionStatus).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.assignment_turned_in,
                                  color: _getStatusColor(_currentSubmit.submissionStatus),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Status Pengumpulan",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueGrey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Fixed: Wrap this row in a Column to prevent overflow
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(_currentSubmit.submissionStatus).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStatusColor(_currentSubmit.submissionStatus),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _getStatusText(_currentSubmit.submissionStatus),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(_currentSubmit.submissionStatus),
                                  ),
                                ),
                              ),
                              if (_currentSubmit.submissionDate != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "Dikumpulkan pada ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(_currentSubmit.submissionDate!))}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_currentSubmit.submissionFile.isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  Icons.insert_drive_file,
                                  size: 16,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _currentSubmit.submissionFile.split('/').last,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue.shade700,
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
                  
                  // File selection section
                  if (_selectedFile != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'File dipilih: ${_selectedFile!.path.split('/').last}',
                              style: const TextStyle(
                                color: Colors.green,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                            ? Colors.red.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _uploadMessage!.contains('Error') 
                              ? Colors.red.shade200
                              : Colors.blue.shade200,
                        ),
                      ),
                      child: Text(
                        _uploadMessage!,
                        style: TextStyle(
                          color: _uploadMessage!.contains('Error') 
                              ? Colors.red.shade700
                              : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Buttons
                  if (!hasSubmitted) ...[
                    // Show submit button only if not yet submitted
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isUploading ? null : _pickFile,
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Pilih File'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
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
                            onPressed: isDeadlinePassed || _isUploading ? null : _uploadFile,
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
                              disabledBackgroundColor: Colors.grey.shade400,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isDeadlinePassed)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Batas waktu pengumpulan telah berakhir',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ] else ...[
                    // Show edit button if already submitted
                    if (_isEditing) ...[
                      // Fixed: Use Column instead of Row for edit buttons to prevent overflow
                      Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isUploading ? null : _pickFile,
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Pilih File Baru'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
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
                                : const Icon(Icons.save),
                            label: Text(_isUploading ? 'Updating...' : 'Simpan Perubahan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _selectedFile = null;
                          });
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Batal Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                        ),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: isDeadlinePassed ? null : () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Pengumpulan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      if (isDeadlinePassed)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Batas waktu pengumpulan telah berakhir',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ),

          // Tombol back dan judul
          Positioned(
            top: 24,
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
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200, 
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
                  color: Colors.blueGrey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
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
