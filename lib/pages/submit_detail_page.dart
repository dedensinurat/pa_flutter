import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/submit_model.dart';
import '../services/submit_services.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


// PDF Viewer Page Component
class PDFViewerPage extends StatefulWidget {
  final String filePath;
  final String fileName;

  const PDFViewerPage({Key? key, required this.filePath, required this.fileName}) : super(key: key);

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        backgroundColor: Colors.lightBlue.shade300,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.bookmark),
        //     onPressed: () {
        //     },
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.search),
        //     onPressed: () {
              
        //     },
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.network(
            widget.filePath,
            key: _pdfViewerKey,
            canShowPaginationDialog: true,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            enableDoubleTapZooming: true,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _isLoading = false;
              });
            },
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'Error loading PDF: ${details.error}';
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading PDF: ${details.error}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'Close',
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Submit Detail Page Component
class SubmitDetailPage extends StatefulWidget {
  final Submit submit;

  const SubmitDetailPage({super.key, required this.submit});

  @override
  State<SubmitDetailPage> createState() => _SubmitDetailPageState();
}

class _SubmitDetailPageState extends State<SubmitDetailPage> {
  File? _selectedFile;
  bool _isUploading = false;
  String? _uploadMessage;
  bool _isEditing = false;
  late Submit _currentSubmit;
  bool _isLoading = true;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentSubmit = widget.submit;
    _refreshSubmitDetails();
    _requestPermissions();
  }

  // Request all necessary permissions at startup
  Future<void> _requestPermissions() async {
    // Basic storage permission that works on all Android versions
    await Permission.storage.request();
    
    if (Platform.isAndroid) {
      try {
        // Try to request manage external storage permission (for Android 11+)
        await Permission.manageExternalStorage.request();
      } catch (e) {
        print("Error requesting manageExternalStorage: $e");
      }
      
      try {
        // Try to request media permissions (for Android 13+)
        await Permission.photos.request();
      } catch (e) {
        print("Error requesting photos permission: $e");
      }
      
      try {
        await Permission.videos.request();
      } catch (e) {
        print("Error requesting videos permission: $e");
      }
    }
  }

  Future<void> _refreshSubmitDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedSubmit = await SubmitService.fetchSubmitById(_currentSubmit.id);
      setState(() {
        _currentSubmit = updatedSubmit;
        _isLoading = false;
      });
    } catch (e) {
      print("Error refreshing submit details: $e");
      setState(() {
        _isLoading = false;
      });
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

    // Validasi ekstensi file
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
      // Menggunakan service untuk meng-upload file
      final result = _isEditing
          ? await SubmitService.updateSubmit(_currentSubmit.id, _selectedFile!.path)
          : await SubmitService.uploadSubmit(_currentSubmit.id, _selectedFile!.path);

      // Wait a moment to ensure the server has processed the update
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Refresh submit after upload to get the latest status
      await _refreshSubmitDetails();

      setState(() {
        _uploadMessage = result;
        _isUploading = false;
        _isEditing = false;
      });
    } catch (e) {
      setState(() {
        _uploadMessage = 'Error: ${e.toString()}';
        _isUploading = false;
      });
    }
  }

  // Function to handle file opening
  Future<void> _handleFileAction(String filePath) async {
    final extension = filePath.toLowerCase().split('.').last;

    // For PDF files, directly open the PDF viewer
    if (extension == 'pdf') {
      _openPdfViewer(filePath);
      return;
    }

    // For other file types, show the action sheet
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Tindakan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              const SizedBox(height: 20),
              // Only show PDF viewer option for PDF files
              if (extension == 'pdf')
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: const Text('Buka PDF Viewer'),
                  onTap: () {
                    Navigator.pop(context);
                    _openPdfViewer(filePath);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.download_rounded, color: Colors.blue),
                title: const Text('Download File'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadAndOpenFile(filePath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.open_in_browser, color: Colors.green),
                title: const Text('Buka di Browser'),
                onTap: () {
                  Navigator.pop(context);
                  _openInBrowser(filePath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.orange),
                title: const Text('Bagikan Link'),
                onTap: () {
                  Navigator.pop(context);
                  _shareFileLink(filePath);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // New method to open PDF in the built-in viewer
  Future<void> _openPdfViewer(String filePath) async {
    try {
      final fileUrl = SubmitService.getFileUrl(filePath);
      final fileName = _getFileName(filePath);
      
      print('Opening PDF viewer with URL: $fileUrl');
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(
            filePath: fileUrl,
            fileName: fileName,
          ),
        ),
      );
    } catch (e) {
      _showErrorDialog('Error opening PDF viewer: $e');
    }
  }

  // Open file in browser
  Future<void> _openInBrowser(String filePath) async {
    try {
      // Use the service to get the correct URL based on file path
      final fileUrl = Uri.parse(SubmitService.getFileUrl(filePath));
      
      print('Opening URL in browser: $fileUrl');
      
      if (await canLaunchUrl(fileUrl)) {
        await launchUrl(fileUrl, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog('Tidak dapat membuka browser. URL: $fileUrl');
      }
    } catch (e) {
      _showErrorDialog('Error saat membuka browser: $e');
    }
  }

  // Update the _shareFileLink method
  Future<void> _shareFileLink(String filePath) async {
    try {
      // Use the service to get the correct URL based on file path
      final fileUrl = SubmitService.getFileUrl(filePath);
      
      print('Sharing file URL: $fileUrl');
      
      await Share.share(
        'Lihat file tugas: $fileUrl',
        subject: 'Link File Tugas',
      );
    } catch (e) {
      _showErrorDialog('Error saat membagikan link: $e');
    }
  }

  // Update the _downloadAndOpenFile method
  Future<void> _downloadAndOpenFile(String filePath) async {
    // Check and request storage permissions
    bool hasPermission = false;
    
    if (Platform.isAndroid) {
      // First try with storage permission which works on most Android versions
      var storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) {
        hasPermission = true;
      } else {
        storageStatus = await Permission.storage.request();
        hasPermission = storageStatus.isGranted;
      }
      
      // If basic storage permission failed, try with manage external storage
      if (!hasPermission) {
        try {
          var externalStatus = await Permission.manageExternalStorage.status;
          if (externalStatus.isGranted) {
            hasPermission = true;
          } else {
            externalStatus = await Permission.manageExternalStorage.request();
            hasPermission = externalStatus.isGranted;
          }
        } catch (e) {
          print("Error with manageExternalStorage permission: $e");
        }
      }
    } else {
      // For iOS
      var status = await Permission.storage.status;
      if (status.isGranted) {
        hasPermission = true;
      } else {
        status = await Permission.storage.request();
        hasPermission = status.isGranted;
      }
    }
    
    if (!hasPermission) {
      _showErrorDialog('Izin penyimpanan diperlukan untuk mengunduh file');
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      // Show download progress dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Mengunduh File'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(value: _downloadProgress),
                    const SizedBox(height: 10),
                    Text('${(_downloadProgress * 100).toStringAsFixed(0)}%'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _isDownloading = false;
                      });
                    },
                    child: const Text('Batal'),
                  ),
                ],
              );
            },
          );
        },
      );

      // Get file name from path
      final fileName = path.basename(filePath);
      
      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        try {
          // Try to use the Downloads directory first
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
        } catch (e) {
          print("Error accessing Downloads directory: $e");
          // Fallback to app's external storage
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) {
        throw Exception("Tidak dapat menemukan direktori penyimpanan");
      }

      final savePath = '${directory.path}/$fileName';
      print("Saving file to: $savePath");
      
      final file = File(savePath);

      // Check if file already exists
      if (await file.exists()) {
        // Close download dialog
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        
        // Open the existing file
        _openDownloadedFile(savePath);
        return;
      }

      // Download file using the correct URL
      final dio = Dio();
      final fileUrl = SubmitService.getDownloadUrl(filePath);

      print('Downloading file from: $fileUrl');

      await dio.download(
        fileUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      // Close download dialog
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      setState(() {
        _isDownloading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File berhasil diunduh ke: $savePath'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Open the downloaded file
      _openDownloadedFile(savePath);
    } catch (e) {
      // Close download dialog
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      setState(() {
        _isDownloading = false;
      });

      _showErrorDialog('Error saat mengunduh file: $e');
    }
  }

  // Open downloaded file
  Future<void> _openDownloadedFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        _showErrorDialog('Tidak dapat membuka file: ${result.message}');
      }
    } catch (e) {
      _showErrorDialog('Error saat membuka file: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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

  // Get file icon based on extension
  IconData _getFileIcon(String filePath) {
    if (filePath.isEmpty) return Icons.insert_drive_file;
    
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'zip':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Get file name from path
  String _getFileName(String filePath) {
    if (filePath.isEmpty) return "Tidak ada file";
    
    // Extract just the filename from the path
    return filePath.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildSkeletonLoading();
    }

    final bool hasSubmitted = _currentSubmit.hasValidSubmission;
    final bool isDeadlinePassed = DateTime.now().isAfter(DateTime.parse(_currentSubmit.tanggalPengumpulan));

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        backgroundColor: Colors.lightBlue.shade300,
        elevation: 0,
      ),
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
                  // Section Detail Tugas (Judul, Instruksi, Tanggal Pengumpulan)
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
                  
                  // File Lampiran section with clickable functionality
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
                                color: Colors.purple.shade300.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.attach_file_outlined, color: Colors.purple.shade300, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "File Lampiran",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_currentSubmit.file.isEmpty)
                          Text(
                            "Tidak ada file lampiran",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          )
                        else
                          InkWell(
                            onTap: () => _handleFileAction(_currentSubmit.file),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.purple.shade200),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getFileIcon(_currentSubmit.file), 
                                      size: 24, 
                                      color: Colors.purple.shade700
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getFileName(_currentSubmit.file),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.purple.shade700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Tap untuk membuka file",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.purple.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.more_vert, size: 18, color: Colors.purple.shade400),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
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
                          const SizedBox(height: 12),
                          // Status badge
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
                            const SizedBox(height: 10),
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
                          if (_currentSubmit.submissionFile.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _handleFileAction(_currentSubmit.submissionFile),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getFileIcon(_currentSubmit.submissionFile), 
                                        size: 24, 
                                        color: Colors.blue.shade700
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getFileName(_currentSubmit.submissionFile),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue.shade700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Tap untuk membuka file yang dikumpulkan",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue.shade400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.more_vert, size: 18, color: Colors.blue.shade400),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        backgroundColor: Colors.lightBlue.shade300,
        elevation: 0,
      ),
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
                  // Section Detail Tugas (Judul, Instruksi, Tanggal Pengumpulan)
                  _buildDetailSectionSkeleton(
                    label: "Judul",
                    color: Colors.indigo.shade300,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSectionSkeleton(
                    label: "Instruksi",
                    color: Colors.teal.shade300,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSectionSkeleton(
                    label: "Batas Pengumpulan",
                    color: Colors.deepOrange.shade300,
                  ),
                  const SizedBox(height: 16),
                  
                  // File Lampiran section skeleton
                  _buildFileSectionSkeleton(
                    label: "File Lampiran",
                    color: Colors.purple.shade300,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Submission Status Section skeleton
                  _buildSubmissionStatusSkeleton(),
                  
                  const SizedBox(height: 24),
                  
                  // Buttons skeleton
                  _buildButtonsSkeleton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSectionSkeleton({
    required String label,
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
                child: Icon(Icons.circle, color: color, size: 20),
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
          const SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity * 0.7,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSectionSkeleton({
    required String label,
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
                child: Icon(Icons.attach_file_outlined, color: color, size: 20),
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
          const SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 120,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
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

  Widget _buildSubmissionStatusSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: 36,
                  height: 36,
                ),
                const SizedBox(width: 12),
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              width: 100,
              height: 24,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 200,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
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