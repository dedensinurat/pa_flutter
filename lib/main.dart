import 'package:flutter/material.dart';
import 'package:flutter_artefak/login.dart';
import 'pages/home_page.dart';
import 'pages/bimbingan_page.dart';
import 'pages/notifications_page.dart';
import 'pages/profile_page.dart';
import 'pages/artefak/dokumen_pengembangan_page.dart';
import 'pages/artefak/upload_page.dart';
import 'widgets/bottom_navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VokasiTera',
      home: const LoginPage(), // LANGSUNG KE LOGIN
      routes: {
        '/login':(context) => const LoginPage(),
        '/main': (context) => const MainScreen(),
        '/upload': (context) => FileUploadScreen(),
        '/dokumen': (context) => const DokumenPengembanganPage(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    HomePage(),
    BimbinganPage(),
    NotificationPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
