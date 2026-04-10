class AdminModulePermissionKeys {
  static const String studentManagement = 'student_management';
  static const String teacherManagement = 'teacher_management';
  static const String classManagement = 'class_management';
  static const String subjectManagement = 'subject_management';
  static const String timetable = 'timetable';
  static const String attendance = 'attendance';
  static const String lunchManagement = 'lunch_management';
  static const String transportManagement = 'transport_management';
  static const String homeworkManagement = 'homework_management';
  static const String examinations = 'examinations';
  static const String examResults = 'exam_results';
  static const String noticesEvents = 'notices_events';

  static const List<String> all = [
    studentManagement,
    teacherManagement,
    classManagement,
    subjectManagement,
    timetable,
    attendance,
    lunchManagement,
    transportManagement,
    homeworkManagement,
    examinations,
    examResults,
    noticesEvents,
  ];
}

const Map<String, bool> defaultAdminModulePermissions = {
  AdminModulePermissionKeys.studentManagement: true,
  AdminModulePermissionKeys.teacherManagement: true,
  AdminModulePermissionKeys.classManagement: true,
  AdminModulePermissionKeys.subjectManagement: true,
  AdminModulePermissionKeys.timetable: true,
  AdminModulePermissionKeys.attendance: true,
  AdminModulePermissionKeys.lunchManagement: true,
  AdminModulePermissionKeys.transportManagement: true,
  AdminModulePermissionKeys.homeworkManagement: true,
  AdminModulePermissionKeys.examinations: true,
  AdminModulePermissionKeys.examResults: true,
  AdminModulePermissionKeys.noticesEvents: true,
};

const Map<String, String> adminModulePermissionLabels = {
  AdminModulePermissionKeys.studentManagement: 'Student Management',
  AdminModulePermissionKeys.teacherManagement: 'Teacher Management',
  AdminModulePermissionKeys.classManagement: 'Class Management',
  AdminModulePermissionKeys.subjectManagement: 'Subject Management',
  AdminModulePermissionKeys.timetable: 'Timetable',
  AdminModulePermissionKeys.attendance: 'Attendance',
  AdminModulePermissionKeys.lunchManagement: 'Lunch Management',
  AdminModulePermissionKeys.transportManagement: 'Transport',
  AdminModulePermissionKeys.homeworkManagement: 'Homework',
  AdminModulePermissionKeys.examinations: 'Examinations',
  AdminModulePermissionKeys.examResults: 'Exam Results & Marks',
  AdminModulePermissionKeys.noticesEvents: 'Notices & Events',
};
