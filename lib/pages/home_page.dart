import 'package:flutter/material.dart';
import '../models/submit_model.dart';
import '../services/submit_services.dart';
import '../pages/submit_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Submit>> futureSubmits;

  @override
  void initState() {
    super.initState();
    futureSubmits = SubmitService.fetchSubmits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vokasi Tera',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Submit>>(
          future: futureSubmits,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Belum ada data pengumpulan.'));
            }

            final submits = snapshot.data!;
            return ListView.builder(
              itemCount: submits.length,
              itemBuilder: (context, index) {
                final submit = submits[index];
                return _buildArtefakItem(context, submit);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildArtefakItem(BuildContext context, Submit submit) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.article, color: Colors.blue, size: 30),
        title: Text(
          submit.judul,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue),
        ),
        subtitle: Text("Batas: ${submit.batas}"),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubmitDetailPage(submit: submit),
            ),
          );
        },
      ),
    );
  }
}
