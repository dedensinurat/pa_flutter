import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'Indonesia';
  
  String get currentLanguage => _currentLanguage;
  
  LanguageProvider() {
    _loadLanguagePreference();
  }
  
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'Indonesia';
    notifyListeners();
  }
  
  Future<void> setLanguage(String language) async {
    if (_currentLanguage == language) return;
    
    _currentLanguage = language;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    
    notifyListeners();
  }
  
  // This would typically contain localized strings for the app
  Map<String, Map<String, String>> get translations => {
    'Indonesia': {
      'app_title': 'Vokasi Tera',
      'settings': 'Pengaturan',
      'profile': 'Profil',
      'help': 'Bantuan',
      'sign_out': 'Keluar',
      // Add more translations as needed
    },
    'English': {
      'app_title': 'Vokasi Tera',
      'settings': 'Settings',
      'profile': 'Profile',
      'help': 'Help',
      'sign_out': 'Sign Out',
      // Add more translations as needed
    },
  };
  
  String translate(String key) {
    return translations[_currentLanguage]?[key] ?? key;
  }
}