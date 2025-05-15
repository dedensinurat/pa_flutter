import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;
  
  ThemeProvider() {
    _loadThemePreference();
  }
  
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
  
  Future<void> setTheme(bool isDarkMode) async {
    if (_isDarkMode == isDarkMode) return;
    
    _isDarkMode = isDarkMode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    
    notifyListeners();
  }
  
  // Light theme definition
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF4299E1),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF4299E1),
      secondary: const Color(0xFF38B2AC),
      surface: Colors.white,
      error: const Color(0xFFE53E3E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF2D3748),
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4299E1),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF4299E1),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF4299E1),
        side: const BorderSide(color: Color(0xFF4299E1)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF7FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4299E1), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE53E3E)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE2E8F0),
      thickness: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFF1A202C)),
      displayMedium: TextStyle(color: Color(0xFF1A202C)),
      displaySmall: TextStyle(color: Color(0xFF1A202C)),
      headlineLarge: TextStyle(color: Color(0xFF1A202C)),
      headlineMedium: TextStyle(color: Color(0xFF1A202C)),
      headlineSmall: TextStyle(color: Color(0xFF1A202C)),
      titleLarge: TextStyle(color: Color(0xFF1A202C)),
      titleMedium: TextStyle(color: Color(0xFF1A202C)),
      titleSmall: TextStyle(color: Color(0xFF1A202C)),
      bodyLarge: TextStyle(color: Color(0xFF1A202C)),
      bodyMedium: TextStyle(color: Color(0xFF1A202C)),
      bodySmall: TextStyle(color: Color(0xFF718096)),
      labelLarge: TextStyle(color: Color(0xFF1A202C)),
      labelMedium: TextStyle(color: Color(0xFF1A202C)),
      labelSmall: TextStyle(color: Color(0xFF718096)),
    ),
  );
  
  // Dark theme definition
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF4299E1),
    scaffoldBackgroundColor: const Color(0xFF1A202C),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF4299E1),
      secondary: const Color(0xFF38B2AC),
      surface: const Color(0xFF2D3748),
      error: const Color(0xFFE53E3E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2D3748),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF2D3748),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4299E1),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF63B3ED),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF63B3ED),
        side: const BorderSide(color: Color(0xFF63B3ED)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A202C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4A5568)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4299E1), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE53E3E)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF4A5568),
      thickness: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white),
      displayMedium: TextStyle(color: Colors.white),
      displaySmall: TextStyle(color: Colors.white),
      headlineLarge: TextStyle(color: Colors.white),
      headlineMedium: TextStyle(color: Colors.white),
      headlineSmall: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Color(0xFFA0AEC0)),
      labelLarge: TextStyle(color: Colors.white),
      labelMedium: TextStyle(color: Colors.white),
      labelSmall: TextStyle(color: Color(0xFFA0AEC0)),
    ),
  );
}
