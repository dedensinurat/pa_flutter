import 'package:flutter/material.dart';
import '../models/submit_model.dart';
import '../services/submit_services.dart';
import '../pages/submit_detail_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Submit>> _futureSubmits;

  @override
  void initState() {
    super.initState();
    _futureSubmits = SubmitService.fetchSubmits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: Stack(
        children: [
          // Blue Wavy Background (Consistent with Submit Box)
          ClipPath(
            clipper: WavyClipper(),
            child: Container(
              height: 130, // Adjust height as needed
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF81D4FA).withOpacity(0.7), // Slightly darker top
                    const Color(0xFFB3E5FC).withOpacity(0.5), // Match the lighter submit box
                  ],
                ),
              ),
            ),
          ),

          // App Bar (positioned on top of the wavy background)
          AppBar(
            title: const Text(
              'Vokasi Tera',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: Colors.black87),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent, // Make app bar transparent
            elevation: 0, // Remove app bar shadow
          ),

          // Main Content (positioned below the app bar)
          Padding(
            padding: const EdgeInsets.only(top: 80, left: 16.0, right: 16.0, bottom: 16.0), // Adjust top padding
            child: FutureBuilder<List<Submit>>(
              future: _futureSubmits,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.lightBlueAccent));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Terjadi kesalahan: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Belum ada data pengumpulan.', style: TextStyle(color: Colors.black54)));
                }

                final submits = snapshot.data!;
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: submits.length,
                  itemBuilder: (context, index) {
                    final submit = submits[index];
                    return _buildGridItem(context, submit, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, Submit submit, int index) {
    final List<Color> bgColors = [
      const Color.fromARGB(255, 192, 227, 227),
      Colors.amber.shade100,
      Colors.purple.shade100,
      Colors.green.shade100,
    ];

    final List<Color> textColors = [
      const Color.fromARGB(255, 51, 85, 103),
      Colors.amber.shade700,
      Colors.purple.shade700,
      Colors.green.shade700,
    ];

    final List<IconData> icons = [
      Icons.book_outlined,
      Icons.assignment_outlined,
      Icons.folder_outlined,
      Icons.event_outlined,
    ];

    final bgColor = bgColors[index % bgColors.length];
    final textColor = textColors[index % textColors.length];
    final icon = icons[index % icons.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubmitDetailPage(submit: submit),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Icon(icon, size: 32, color: textColor),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      submit.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Batas: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(submit.batas))}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: textColor),
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
}

// Custom Clipper for Wavy Background
class WavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40); // Start with a straight line down

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0); // Line back to the top
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}