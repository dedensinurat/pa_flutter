import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_artefak/services/bimbingan_services.dart';

class RequestBimbinganPage extends StatefulWidget {
  const RequestBimbinganPage({super.key});

  @override
  State<RequestBimbinganPage> createState() => _RequestBimbinganPageState();
}

class _RequestBimbinganPageState extends State<RequestBimbinganPage> {
  final _formKey = GlobalKey<FormState>();
  String keperluan = '';
  String deskripsi = '';
  DateTime? selectedDate;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || selectedDate == null) return;
    _formKey.currentState!.save();

    final success = await BimbinganService.create(
      keperluan: keperluan,
      deskripsi: deskripsi,
      rencanaBimbingan: selectedDate!.toUtc().toIso8601String(),
    );

    if (success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Berhasil'),
          content: const Text('Request bimbingan berhasil dikirim.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pop(context, true); // Close page and return
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim request')),
      );
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null) return;

    setState(() {
      selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vokasi Tera'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Keperluan Bimbingan"),
              const SizedBox(height: 6),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Keperluan Bimbingan',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => keperluan = value ?? '',
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              const Text("Rencana Bimbingan"),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDateTime,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'dd/mm/yy',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: selectedDate != null
                          ? DateFormat('dd-MM-yyyy HH:mm').format(selectedDate!)
                          : '',
                    ),
                    validator: (_) =>
                        selectedDate == null ? 'Wajib pilih tanggal' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Deskripsi Bimbingan"),
              const SizedBox(height: 6),
              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Diskusi PRS',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => deskripsi = value ?? '',
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Request'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
