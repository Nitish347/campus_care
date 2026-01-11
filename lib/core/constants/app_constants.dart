class AppConstants {
  static const String appName = 'School Stream';
  static const String appVersion = '1.0.0';

  // User Roles
  static const String roleSuperAdmin = 'super_admin';
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

  // API Configuration
  // For emulator: use 'http://10.0.2.2:3000' (Android) or 'http://localhost:3000' (iOS/Web)
  // For physical device: use 'http://YOUR_COMPUTER_IP:3000'
  static const String baseUrl = 'http://localhost:5000';
  static const String apiVersion = '/api/v1';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String studentsEndpoint = '/students';
  static const String teachersEndpoint = '/teachers';
  static const String adminsEndpoint = '/admin';
  static const String adminEndpoint = '/admin';
  static const String classesEndpoint = '/classes';
  static const String subjectsEndpoint = '/subjects';
  static const String attendanceEndpoint = '/attendance';
  static const String homeworkEndpoint = '/homework';
  static const String homeworkSubmissionsEndpoint = '/homework-submissions';
  static const String examsEndpoint = '/exams';
  static const String examTypesEndpoint = '/exam-types';
  static const String examResultsEndpoint = '/exam-results';
  static const String feesEndpoint = '/fees';
  static const String noticesEndpoint = '/notices';
  static const String timetablesEndpoint = '/timetables';
  static const String medicalRecordsEndpoint = '/medical-records';
  static const String institutesEndpoint = '/institutes';

  // Storage Keys for API
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';

  // Request Configuration
  static const int requestTimeout = 30; // seconds

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
