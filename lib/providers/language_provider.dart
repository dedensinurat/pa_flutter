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
  
  // Comprehensive translations for the entire app
  Map<String, Map<String, String>> get translations => {
    'Indonesia': {
      // App-wide translations
      'app_title': 'Vokasi Tera',
      'settings': 'Pengaturan',
      'profile': 'Profil',
      'help': 'Bantuan',
      'sign_out': 'Keluar',
      'cancel': 'Batal',
      'save': 'Simpan',
      'edit': 'Edit',
      'delete': 'Hapus',
      'submit': 'Kirim',
      'retry': 'Coba Lagi',
      'loading': 'Memuat...',
      'error_occurred': 'Terjadi kesalahan',
      'no_data': 'Tidak ada data',
      'refresh': 'Muat Ulang',
      'ok': 'OK',
      'yes': 'Ya',
      'no': 'Tidak',
      'confirm': 'Konfirmasi',
      
      // Home Page
      'home': 'Beranda',
      'home_subtitle': 'Jadwal dan tugas Anda',
      'schedule_seminar': 'Jadwal Seminar',
      'latest_tasks': 'Tugas Terbaru',
      'view_all': 'Lihat Semua',
      'loading_schedule': 'Memuat jadwal...',
      'loading_tasks': 'Memuat daftar tugas...',
      'failed_load_schedule': 'Gagal memuat jadwal',
      'failed_load_tasks': 'Gagal memuat tugas',
      'no_schedule': 'Belum ada jadwal',
      'no_schedule_message': 'Jadwal seminar akan muncul di sini',
      'no_tasks': 'Belum ada tugas',
      'no_tasks_message': 'Tugas yang diberikan akan muncul di sini',
      'days_left': 'hari lagi',
      'today': 'Hari ini',
      'past_deadline': 'Lewat batas',
      
      // Profile Page
      'view_profile': 'Lihat Profil',
      'view_profile_subtitle': 'Lihat detail informasi profil Anda',
      'settings_subtitle': 'Ubah pengaturan aplikasi',
      'help_subtitle': 'Pusat bantuan dan FAQ',
      'sign_out_subtitle': 'Keluar dari aplikasi',
      'sign_out_confirm': 'Apakah Anda yakin ingin keluar dari aplikasi?',
      'active_student': 'Mahasiswa Aktif',
      'hello': 'Hai,',
      'app_version': 'Vokasi Tera v1.0.0',
      
      // Profile Detail Page
      'academic_info': 'Informasi Akademik',
      'username': 'Username',
      'email': 'Email',
      'study_program': 'Program Studi',
      'faculty': 'Fakultas',
      'batch': 'Angkatan',
      'dormitory': 'Asrama',
      'failed_load_student': 'Gagal memuat data mahasiswa',
      'no_student_data': 'Data tidak tersedia',
      'upload_photo_unavailable': 'Fitur upload foto belum tersedia',
      
      // Settings Page
      'appearance': 'Tampilan',
      'dark_mode': 'Mode Gelap',
      'language': 'Bahasa',
      'notification': 'Notifikasi',
      'enable_notifications': 'Aktifkan Notifikasi',
      'about': 'Tentang',
      'privacy_policy': 'Kebijakan Privasi',
      'terms_of_service': 'Ketentuan Layanan',
      'version': 'Versi',
      'customization': 'Kustomisasi',
      'customize_app': 'Sesuaikan tampilan aplikasi',
      'display_mode': 'Mode Tampilan',
      'light_mode': 'Mode Terang',
      'dark_mode': 'Mode Gelap',
      'language_selection': 'Pilihan Bahasa',
      'light_mode_enabled': 'Mode terang diaktifkan',
      'dark_mode_enabled': 'Mode gelap diaktifkan',
      'language_changed': 'Bahasa diubah ke',
      'settings_info': 'Pengaturan akan disimpan secara otomatis dan akan diterapkan saat aplikasi dibuka kembali.',
      'information': 'Informasi',
      
      // Task Detail Page
      'task_detail': 'Detail Tugas',
      'title': 'Judul',
      'instructions': 'Instruksi',
      'deadline': 'Batas Pengumpulan',
      'attachment': 'File Lampiran',
      'no_attachment': 'Tidak ada file lampiran',
      'submission_status': 'Status Pengumpulan',
      'submitted': 'Sudah Dikumpulkan',
      'resubmitted': 'Sudah Diperbarui',
      'late': 'Terlambat',
      'not_submitted': 'Belum Dikumpulkan',
      'submitted_on': 'Dikumpulkan pada',
      'file': 'File',
      'select_file': 'Pilih File',
      'file_selected': 'File dipilih',
      'upload': 'Kumpulkan',
      'uploading': 'Uploading...',
      'edit_submission': 'Edit Pengumpulan',
      'select_new_file': 'Pilih File Baru',
      'save_changes': 'Simpan Perubahan',
      'updating': 'Updating...',
      'cancel_edit': 'Batal Edit',
      'deadline_passed': 'Batas waktu pengumpulan telah berakhir',
      'select_file_first': 'Pilih file terlebih dahulu',
      'unsupported_format': 'Format file tidak didukung. Hanya menerima file PDF, DOC, DOCX, atau ZIP',
      
      // Schedule Page
      'schedule': 'Jadwal Seminar',
      'schedule_subtitle': 'Semua jadwal seminar Anda',
      
      // Schedule Detail Page
      'schedule_detail': 'Detail Jadwal',
      'schedule_info': 'Informasi Jadwal',
      'date': 'Tanggal',
      'time': 'Waktu',
      'room': 'Ruangan',
      'examiners': 'Penguji',
      'main_examiner': 'Penguji Utama',
      'supporting_examiner': 'Penguji Pendamping',
      'group_info': 'Informasi Kelompok',
      'group': 'Kelompok',
      'group_id': 'ID Kelompok',
      'failed_load_schedule_detail': 'Gagal memuat detail jadwal',
      'no_schedule_data': 'Tidak ada data jadwal',
      
      // Bimbingan (Guidance) Page
      'guidance': 'Bimbingan',
      'guidance_subtitle': 'Kelola jadwal bimbingan dengan dosen',
      'guidance_list': 'Daftar Bimbingan',
      'guidance_count': 'Bimbingan',
      'loading_guidance': 'Memuat data bimbingan...',
      'failed_load_guidance': 'Gagal memuat data',
      'no_guidance': 'Belum ada data bimbingan',
      'no_guidance_message': 'Ajukan bimbingan baru untuk memulai',
      'guidance_detail': 'Detail Bimbingan',
      'purpose': 'Keperluan',
      'start_date': 'Tanggal Mulai',
      'end_date': 'Tanggal Selesai',
      'location': 'Lokasi',
      'give_feedback': 'Berikan Feedback',
      'resubmit': 'Ajukan Ulang',
      'close': 'Tutup',
      'guidance_info': 'Panduan Bimbingan',
      'guidance_step1': 'Ajukan permintaan bimbingan melalui aplikasi.',
      'guidance_step2': 'Mohon menunggu konfirmasi dari dosen pembimbing.',
      'guidance_step3': 'Setelah disetujui, persiapkan diri dan hadir tepat waktu.',
      'guidance_number': 'Bimbingan #',
      
      // Request Guidance Page
      'request_guidance': 'Ajukan Bimbingan',
      'guidance_form': 'Formulir Bimbingan',
      'guidance_form_subtitle': 'Silakan lengkapi formulir di bawah ini untuk mengajukan bimbingan dengan dosen.',
      'guidance_purpose': 'Keperluan Bimbingan',
      'guidance_purpose_hint': 'Tulis keperluan bimbingan Anda',
      'guidance_purpose_required': 'Keperluan wajib diisi',
      'planned_date_time': 'Rencana Tanggal & Waktu',
      'select_date_time': 'Pilih tanggal dan waktu',
      'date_time_required': 'Tanggal dan waktu wajib dipilih',
      'guidance_room': 'Ruangan Bimbingan',
      'select_room': 'Pilih ruangan',
      'room_required': 'Ruangan wajib dipilih',
      'additional_description': 'Deskripsi Tambahan',
      'additional_description_hint': 'Jelaskan lebih detail keperluan Anda (opsional)',
      'submit_request': 'Ajukan',
      'submitting': 'Mengirim...',
      'complete_required_fields': 'Lengkapi semua field yang wajib',
      'end_time_after_start': 'Waktu selesai harus setelah waktu mulai',
      'request_success': 'Berhasil!',
      'request_success_message': 'Permintaan bimbingan berhasil dikirim.',
      'request_failed': 'Gagal mengirim permintaan',
      
      // Notification Page
      'notification': 'Notifikasi',
      'notifications': 'Notifikasi',
      'announcements': 'Pengumuman',
      'announcement_details': 'Detail Pengumuman',
      'error_loading_announcements': 'Gagal memuat pengumuman',
      'no_announcements': 'Tidak ada pengumuman',
      'could_not_open_attachment': 'Tidak dapat membuka lampiran',
      'attachment': 'Lampiran',
      
      // Status translations
      'status_completed': 'Selesai',
      'status_rejected': 'Ditolak',
      'status_waiting': 'Menunggu',
      'status_approved': 'Disetujui',
      'status_scheduled': 'Dijadwalkan',
    },
    'English': {
      // App-wide translations
      'app_title': 'Vokasi Tera',
      'settings': 'Settings',
      'profile': 'Profile',
      'help': 'Help',
      'sign_out': 'Sign Out',
      'cancel': 'Cancel',
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'submit': 'Submit',
      'retry': 'Retry',
      'loading': 'Loading...',
      'error_occurred': 'An error occurred',
      'no_data': 'No data available',
      'refresh': 'Refresh',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'confirm': 'Confirm',
      
      // Home Page
      'home': 'Home',
      'home_subtitle': 'Your schedule and assignments',
      'schedule_seminar': 'Seminar Schedule',
      'latest_tasks': 'Latest Assignments',
      'view_all': 'View All',
      'loading_schedule': 'Loading schedule...',
      'loading_tasks': 'Loading assignments...',
      'failed_load_schedule': 'Failed to load schedule',
      'failed_load_tasks': 'Failed to load assignments',
      'no_schedule': 'No schedule yet',
      'no_schedule_message': 'Seminar schedules will appear here',
      'no_tasks': 'No assignments yet',
      'no_tasks_message': 'Assigned tasks will appear here',
      'days_left': 'days left',
      'today': 'Today',
      'past_deadline': 'Past deadline',
      
      // Profile Page
      'view_profile': 'View Profile',
      'view_profile_subtitle': 'View your profile information details',
      'settings_subtitle': 'Change application settings',
      'help_subtitle': 'Help center and FAQ',
      'sign_out_subtitle': 'Sign out from the application',
      'sign_out_confirm': 'Are you sure you want to sign out?',
      'active_student': 'Active Student',
      'hello': 'Hello,',
      'app_version': 'Vokasi Tera v1.0.0',
      
      // Profile Detail Page
      'academic_info': 'Academic Information',
      'username': 'Username',
      'email': 'Email',
      'study_program': 'Study Program',
      'faculty': 'Faculty',
      'batch': 'Batch',
      'dormitory': 'Dormitory',
      'failed_load_student': 'Failed to load student data',
      'no_student_data': 'No data available',
      'upload_photo_unavailable': 'Photo upload feature is not available yet',
      
      // Settings Page
      'appearance': 'Appearance',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'notification': 'Notification',
      'enable_notifications': 'Enable Notifications',
      'about': 'About',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'version': 'Version',
      'customization': 'Customization',
      'customize_app': 'Customize app appearance',
      'display_mode': 'Display Mode',
      'light_mode': 'Light Mode',
      'dark_mode': 'Dark Mode',
      'language_selection': 'Language Selection',
      'light_mode_enabled': 'Light mode enabled',
      'dark_mode_enabled': 'Dark mode enabled',
      'language_changed': 'Language changed to',
      'settings_info': 'Settings will be saved automatically and applied when you reopen the app.',
      'information': 'Information',
      
      // Task Detail Page
      'task_detail': 'Assignment Detail',
      'title': 'Title',
      'instructions': 'Instructions',
      'deadline': 'Deadline',
      'attachment': 'Attachment',
      'no_attachment': 'No attachment',
      'submission_status': 'Submission Status',
      'submitted': 'Submitted',
      'resubmitted': 'Resubmitted',
      'late': 'Late',
      'not_submitted': 'Not Submitted',
      'submitted_on': 'Submitted on',
      'file': 'File',
      'select_file': 'Select File',
      'file_selected': 'File selected',
      'upload': 'Submit',
      'uploading': 'Uploading...',
      'edit_submission': 'Edit Submission',
      'select_new_file': 'Select New File',
      'save_changes': 'Save Changes',
      'updating': 'Updating...',
      'cancel_edit': 'Cancel Edit',
      'deadline_passed': 'Submission deadline has passed',
      'select_file_first': 'Please select a file first',
      'unsupported_format': 'Unsupported file format. Only PDF, DOC, DOCX, or ZIP files are accepted',
      
      // Schedule Page
      'schedule': 'Seminar Schedule',
      'schedule_subtitle': 'All your seminar schedules',
      
      // Schedule Detail Page
      'schedule_detail': 'Schedule Detail',
      'schedule_info': 'Schedule Information',
      'date': 'Date',
      'time': 'Time',
      'room': 'Room',
      'examiners': 'Examiners',
      'main_examiner': 'Main Examiner',
      'supporting_examiner': 'Supporting Examiner',
      'group_info': 'Group Information',
      'group': 'Group',
      'group_id': 'Group ID',
      'failed_load_schedule_detail': 'Failed to load schedule details',
      'no_schedule_data': 'No schedule data available',
      
      // Bimbingan (Guidance) Page
      'guidance': 'Guidance',
      'guidance_subtitle': 'Manage your guidance schedule with lecturers',
      'guidance_list': 'Guidance List',
      'guidance_count': 'Guidance',
      'loading_guidance': 'Loading guidance data...',
      'failed_load_guidance': 'Failed to load data',
      'no_guidance': 'No guidance data yet',
      'no_guidance_message': 'Submit a new guidance request to start',
      'guidance_detail': 'Guidance Detail',
      'purpose': 'Purpose',
      'start_date': 'Start Date',
      'end_date': 'End Date',
      'location': 'Location',
      'give_feedback': 'Give Feedback',
      'resubmit': 'Resubmit',
      'close': 'Close',
      'guidance_info': 'Guidance Information',
      'guidance_step1': 'Submit a guidance request through the application.',
      'guidance_step2': 'Please wait for confirmation from your supervisor.',
      'guidance_step3': 'After approval, prepare yourself and attend on time.',
      'guidance_number': 'Guidance #',
      
      // Request Guidance Page
      'request_guidance': 'Request Guidance',
      'guidance_form': 'Guidance Form',
      'guidance_form_subtitle': 'Please complete the form below to request guidance with a lecturer.',
      'guidance_purpose': 'Guidance Purpose',
      'guidance_purpose_hint': 'Write your guidance purpose',
      'guidance_purpose_required': 'Purpose is required',
      'planned_date_time': 'Planned Date & Time',
      'select_date_time': 'Select date and time',
      'date_time_required': 'Date and time are required',
      'guidance_room': 'Guidance Room',
      'select_room': 'Select room',
      'room_required': 'Room is required',
      'additional_description': 'Additional Description',
      'additional_description_hint': 'Explain your purpose in more detail (optional)',
      'submit_request': 'Submit',
      'submitting': 'Submitting...',
      'complete_required_fields': 'Please complete all required fields',
      'end_time_after_start': 'End time must be after start time',
      'request_success': 'Success!',
      'request_success_message': 'Guidance request has been successfully sent.',
      'request_failed': 'Failed to send request',
      
      // Notification Page
      'notification': 'Notification',
      'notifications': 'Notifications',
      'announcements': 'Announcements',
      'announcement_details': 'Announcement Details',
      'error_loading_announcements': 'Error loading announcements',
      'no_announcements': 'No announcements available',
      'could_not_open_attachment': 'Could not open the attachment',
      'attachment': 'Attachment',
      
      // Status translations
      'status_completed': 'Completed',
      'status_rejected': 'Rejected',
      'status_waiting': 'Waiting',
      'status_approved': 'Approved',
      'status_scheduled': 'Scheduled',
    },
  };
  
  // Method to translate a key
  String translate(String key) {
    return translations[_currentLanguage]?[key] ?? key;
  }
  
  // Method to translate a key with parameters
  String translateWithParams(String key, Map<String, String> params) {
    String translated = translate(key);
    
    params.forEach((paramKey, paramValue) {
      translated = translated.replaceAll('{$paramKey}', paramValue);
    });
    
    return translated;
  }
  
  // Method to get status translation
  String getStatusTranslation(String status) {
    final statusKey = 'status_${status.toLowerCase()}';
    return translate(statusKey);
  }
  
  // Method to get all available languages
  List<String> get availableLanguages => translations.keys.toList();
}
