class AppConstants {
  static const String appName = 'School Stream';
  static const String appVersion = '1.0.0';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleStudent = 'student';

  // Storage Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyCurrentUser = 'current_user';
  static const String keyUserRole = 'user_role';
  static const String keyThemeMode = 'theme_mode';

  // Data Storage Keys
  static const String keyStudents = 'students_data';
  static const String keyTeachers = 'teachers_data';
  static const String keyAdmins = 'admins_data';
  static const String keyClasses = 'classes_data';
  static const String keySubjects = 'subjects_data';
  static const String keyAttendance = 'attendance_data';
  static const String keyExams = 'exams_data';
  static const String keyFees = 'fees_data';
  static const String keyNotices = 'notices_data';
  static const String keyHomework = 'homework_data';
  static const String keyMedicalRecords = 'medical_records_data';
  static const String keyMessages = 'messages_data';
  static const String keyTimetables = 'timetables_data';

  // API Endpoints (for future Firebase integration)
  static const String baseUrl = '';

  // Pagination
  static const int defaultPageSize = 20;

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocTypes = ['pdf', 'doc', 'docx'];

  // Validation
  static const int minPasswordLength = 6;
  static const String phoneRegex = r'^\+?[\d\s\-\(\)]{10,}$';
  static const String emailRegex = r'^[\w\.-]+@[\w\.-]+\.\w+$';
}
