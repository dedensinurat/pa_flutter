import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- Tambahkan ini
import 'package:flutter_artefak/providers/language_provider.dart';
import 'package:flutter_artefak/login.dart';
import 'pages/home_page.dart';
import 'pages/bimbingan_page.dart';
import 'pages/pengumuman.dart';
import 'pages/profile_page.dart';
import 'pages/artefak/dokumen_pengembangan_page.dart';
// import 'pages/artefak/upload_page.dart';
import 'widgets/bottom_navbar.dart';
import 'package:flutter_artefak/providers/theme_provider.dart';
import 'package:flutter_artefak/pages/jadwal_page.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'VokasiTera',
          theme: themeProvider.themeData,
          home: const LoginPage(), // LANGSUNG KE LOGIN
          routes: {
            '/login': (context) => const LoginPage(),
            '/main': (context) => const MainScreen(),
            // '/upload': (context) => FileUploadScreen(),
            '/dokumen': (context) => const DokumenPengembanganPage(),
             '/jadwal': (context) => const JadwalPage(),
          },
        );
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