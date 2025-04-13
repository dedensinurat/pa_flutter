import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_artefak/services/api_service.dart';
import 'package:flutter_artefak/services/artefak_services.dart';
import 'package:flutter_artefak/widgets/bottom_navbar.dart';
import 'package:flutter_artefak/main.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({Key? key}) : super(key: key);

  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  String? fileName;
  String? filePath;
  int? selectedArtefakId;
  List<Map<String, dynamic>> artefakList = [];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchArtefakList();
  }

  Future<void> fetchArtefakList() async {
    final token = await ApiService.getToken();
    final data = await ArtefakService().getArtefakList(token!);
    setState(() {
      artefakList = data;
    });
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'zip', 'xls', 'xlsx'],
    );

    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
        filePath = result.files.single.path;
      });
    }
  }

  Future<void> uploadFile() async {
    if (filePath == null || fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih file terlebih dahulu")),
      );
      return;
    }

    if (selectedArtefakId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih artefak terlebih dahulu")),
      );
      return;
    }

    final token = await ApiService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token tidak ditemukan. Silakan login ulang.")),
      );
      return;
    }

    final result = await ArtefakService().uploadFileForArtefak(
      filePath: filePath!,
      token: token,
      artefakId: selectedArtefakId!,
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Upload Artefak", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: selectedArtefakId,
                decoration: const InputDecoration(labelText: "Pilih Artefak"),
                items: artefakList.map((artefak) {
                  return DropdownMenuItem<int>(
                    value: artefak['artefak_id'],
                    child: Text(artefak['judul']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedArtefakId = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: pickFile,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue.withOpacity(0.05),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload, size: 50, color: Colors.blue),
                      const SizedBox(height: 10),
                      Text(
                        fileName ?? "Pilih file dari perangkat",
                        style: const TextStyle(color: Colors.blue, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      const Text("Maks. 50MB", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text("Format didukung: .pdf, .doc, .docx, .zip, .xls, .xlsx", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal", style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: uploadFile,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("Unggah", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
