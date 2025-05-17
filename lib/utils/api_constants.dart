class ApiConstants {
  // Base URLs
  static const String baseUrl = "http://192.168.241.227:8080";
  static const String externalApiUrl = "https://cis-dev.del.ac.id/api";
  // Laravel storage URL
  static const String laravelStorageUrl = "https://vokasitera-main-ltziwn.laravel.cloud/storage";

  // API Endpoints
  static const String loginEndpoint = "/login";
  static const String refreshTokenEndpoint = "/refresh_token";
  static const String bimbinganEndpoint = "/bimbingan";
  static const String ruangansEndpoint = "/ruangans";
  static const String pengumumanEndpoint = "/pengumuman";
  static const String jadwalEndpoint = "/jadwal";
  static const String pengumpulanEndpoint = "/pengumpulan";
  static const String dosenEndpoint = "/dosen";
  static const String studentEndpoint = "/api/student";
  
  // File endpoints
  static const String filesEndpoint = "/files"; // Web files (Laravel proxy)
  static const String mobileFilesEndpoint = "/mobile-files"; // Mobile files (direct access)

  // External API Endpoints
  static const String externalStudentEndpoint = "/library-api/mahasiswa";

  // File URL helpers
  static String getFileUrl(String path) {
    if (path.isEmpty) {
      return '';
    }
    
    // Check if the file path is a tugas_files path (Laravel storage)
    if (path.startsWith('tugas_files/')) {
      // Return the URL to our Go proxy endpoint
      return "$baseUrl$filesEndpoint/view/$path";
    } else if (path.startsWith('public/tugas_files/')) {
      // Handle public storage path
      return "$baseUrl$filesEndpoint/view/$path";
    } else if (path.startsWith('uploads/')) {
      // Handle direct uploads path for mobile
      String relativePath = path.replaceFirst('uploads/', '');
      return "$baseUrl$mobileFilesEndpoint/view/$relativePath";
    } else if (path.startsWith('tugas/')) {
      // Handle direct uploads path for mobile
      return "$baseUrl$mobileFilesEndpoint/view/$path";
    } else if (path.startsWith('http')) {
      // Already a full URL
      return path;
    } else {
      // For other files, try mobile files endpoint
      return "$baseUrl$mobileFilesEndpoint/view/$path";
    }
  }

  static String getFileDownloadUrl(String path) {
    if (path.isEmpty) {
      return '';
    }
    
    // Check if the file path is a tugas_files path (Laravel storage)
    if (path.startsWith('tugas_files/')) {
      // Return the URL to our Go proxy endpoint
      return "$baseUrl$filesEndpoint/download/$path";
    } else if (path.startsWith('public/tugas_files/')) {
      // Handle public storage path
      return "$baseUrl$filesEndpoint/download/$path";
    } else if (path.startsWith('uploads/')) {
      // Handle direct uploads path for mobile
      String relativePath = path.replaceFirst('uploads/', '');
      return "$baseUrl$mobileFilesEndpoint/download/$relativePath";
    } else if (path.startsWith('tugas/')) {
      // Handle direct uploads path for mobile
      return "$baseUrl$mobileFilesEndpoint/download/$path";
    } else if (path.startsWith('http')) {
      // Already a full URL
      return path;
    } else {
      // For other files, try mobile files endpoint
      return "$baseUrl$mobileFilesEndpoint/download/$path";
    }
  }
  
  // Get URL to list files in a directory
  static String getFileListUrl(String path) {
    return "$baseUrl$mobileFilesEndpoint/list?path=$path";
  }
}