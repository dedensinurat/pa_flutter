import 'package:flutter/material.dart';
import 'package:flutter_artefak/models/bimbingan_model.dart';
import 'package:flutter_artefak/services/bimbingan_services.dart';
import 'request_bimbingan_page.dart';
import 'package:intl/intl.dart';

class BimbinganPage extends StatefulWidget {
  const BimbinganPage({super.key});

  @override
  State<BimbinganPage> createState() => _BimbinganPageState();
}

class _BimbinganPageState extends State<BimbinganPage> {
  List<Bimbingan> bimbinganList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBimbingan();
  }

  Future<void> fetchBimbingan() async {
    try {
      final data = await BimbinganService.getAll();
      setState(() {
        bimbinganList = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy HH:mm').format(date);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sukses':
        return Colors.blue;
      case 'ditolak':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vokasi Tera'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RequestBimbinganPage()),
                );
                if (result == true) {
                  fetchBimbingan();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Request', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            Container(
              color: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: const [
                  Expanded(flex: 1, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text('Keperluan', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: bimbinganList.length,
                      itemBuilder: (context, index) {
                        final item = bimbinganList[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 1, child: Text('${index + 1}')),
                              Expanded(flex: 3, child: Text(item.keperluan)),
                              Expanded(flex: 3, child: Text(formatDate(item.rencanaBimbingan))),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(item.status),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      item.status,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pedoman Bimbingan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('1. Request Bimbingan Melalui VokasiTera'),
                  Text('2. Tunggu Hingga Dosen Menyetujui'),
                  Text('3. Setelah disetujui, hadir 10 hingga 15 menit sebelum pertemuan dilakukan'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
