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
  String _keperluan = '';
  String _deskripsi = '';
  DateTime? _selectedDate;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;
    _formKey.currentState!.save();

    final success = await BimbinganService.create(
      keperluan: _keperluan,
      deskripsi: _deskripsi,
      rencanaBimbingan: _selectedDate!.toUtc().toIso8601String(),
    );

    if (success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green.shade400,
                size: 30,
              ),
              const SizedBox(width: 10),
              const Text(
                'Berhasil!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Permintaan bimbingan Anda berhasil dikirim.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.thumb_up_alt,
                    color: Colors.green.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Bimbingan Anda akan segera diproses.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.green.shade400,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim permintaan')),
      );
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.lightBlue.shade300,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.lightBlue.shade300, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.lightBlue.shade300,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.lightBlue.shade300, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(
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
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text(
          'Ajukan Bimbingan',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Keperluan Bimbingan"),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: _inputDecoration("Tulis keperluan bimbingan Anda"),
                    onSaved: (value) => _keperluan = value ?? '',
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Keperluan wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel("Rencana Tanggal & Waktu"),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDateTime,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: _inputDecoration("Pilih tanggal dan waktu", icon: Icons.calendar_today_outlined),
                        controller: TextEditingController(
                          text: _selectedDate != null
                              ? DateFormat('dd-MM-yyyy HH:mm').format(_selectedDate!)
                              : '',
                        ),
                        validator: (_) =>
                            _selectedDate == null ? 'Tanggal dan waktu wajib dipilih' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel("Deskripsi Tambahan (Opsional)"),
                  const SizedBox(height: 8),
                  TextFormField(
                    maxLines: 3,
                    decoration: _inputDecoration("Jelaskan lebih detail keperluan Anda"),
                    onSaved: (value) => _deskripsi = value ?? '',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue.shade300,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 2,
                        ),
                        child: const Text('Ajukan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.blueGrey.shade700,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      suffixIcon: icon != null ? Icon(icon, color: Colors.grey.shade400) : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.lightBlue.shade300),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
