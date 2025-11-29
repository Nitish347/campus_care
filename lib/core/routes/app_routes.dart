import 'package:get/get.dart';

import 'package:campus_care/screens/auth/login_screen.dart';
import 'package:campus_care/screens/admin/admin_dashboard.dart';
import 'package:campus_care/screens/admin/student_management/student_list_screen.dart';
import 'package:campus_care/screens/admin/student_management/add_student_screen.dart';
import 'package:campus_care/screens/admin/academic/class_management_screen.dart';
import 'package:campus_care/screens/admin/academic/timetable_screen.dart';
import 'package:campus_care/screens/admin/examination/exam_scheduler_screen.dart';
import 'package:campus_care/screens/admin/fee/fee_management_screen.dart';
import 'package:campus_care/screens/admin/medical/medical_dashboard_screen.dart';
import 'package:campus_care/screens/admin/communication/notice_management_screen.dart';
import 'package:campus_care/screens/admin/teacher/teacher_list_screen.dart';
import 'package:campus_care/screens/admin/admin/admin_list_screen.dart';
import 'package:campus_care/screens/teacher/teacher_dashboard.dart';
import 'package:campus_care/screens/teacher/attendance/attendance_screen.dart';
import 'package:campus_care/screens/teacher/homework/homework_screen.dart';
import 'package:campus_care/screens/teacher/communication/chat_list_screen.dart';
import 'package:campus_care/screens/teacher/marks/marks_entry_screen.dart';
import 'package:campus_care/screens/teacher/profile/teacher_profile_screen.dart';
import 'package:campus_care/screens/teacher/timetable/teacher_timetable_screen.dart';
import 'package:campus_care/screens/student/student_dashboard.dart';
import 'package:campus_care/screens/student/homework/student_homework_screen.dart';
import 'package:campus_care/screens/student/attendance/student_attendance_screen.dart';
import 'package:campus_care/screens/student/fees/student_fees_screen.dart';
import 'package:campus_care/screens/student/profile/student_profile_screen.dart';
import 'package:campus_care/screens/student/timetable/student_timetable_screen.dart';
import 'package:campus_care/screens/student/notifications/student_notifications_screen.dart';
import 'package:campus_care/screens/student/medical/student_medical_reports_screen.dart';
import 'package:campus_care/screens/teacher/leave/leave_history_screen.dart';
import 'package:campus_care/screens/teacher/profile/change_password_screen.dart';
import 'package:campus_care/screens/teacher/profile/settings_screen.dart';
import 'package:campus_care/screens/teacher/communication/chat_detail_screen.dart';
import 'package:campus_care/screens/teacher/communication/new_message_screen.dart';
import 'package:campus_care/screens/admin/medical/add_medical_record_screen.dart';
import 'package:campus_care/screens/admin/academic/add_class_screen.dart';
import 'package:campus_care/screens/admin/academic/add_timetable_screen.dart';
import 'package:campus_care/screens/student/payment/payment_screen.dart';

class AppRoutes {
  // Auth Routes
  static const String login = '/login';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String studentList = '/admin/students';
  static const String addStudent = '/admin/students/add';
  static const String classManagement = '/admin/classes';
  static const String timetable = '/admin/timetable';
  static const String examScheduler = '/admin/exams';
  static const String feeManagement = '/admin/fees';
  static const String medicalDashboard = '/admin/medical';
  // static const String medicalDashboard = '/admin/medical';
  static const String noticeManagement = '/admin/notices';
  static const String teacherList = '/admin/teachers';
  static const String addTeacher = '/admin/teachers/add';
  static const String adminList = '/admin/admins';
  static const String addAdmin = '/admin/admins/add';

  // Teacher Routes
  static const String teacherDashboard = '/teacher/dashboard';
  static const String attendance = '/teacher/attendance';
  static const String homework = '/teacher/homework';
  static const String chatList = '/teacher/chat';
  static const String marksEntry = '/teacher/marks';
  static const String teacherProfile = '/teacher/profile';
  static const String teacherTimetable = '/teacher/timetable';

  // Student Routes
  static const String studentDashboard = '/student/dashboard';
  static const String studentHomework = '/student/homework';
  static const String studentAttendance = '/student/attendance';
  static const String studentFees = '/student/fees';
  static const String studentProfile = '/student/profile';
  static const String studentTimetable = '/student/timetable';
  static const String studentNotifications = '/student/notifications';
  static const String studentMedicalReports = '/student/medical-reports';
  static const String payment = '/student/payment';

  // Teacher Additional Routes
  static const String leaveHistory = '/teacher/leave-history';
  static const String changePassword = '/teacher/change-password';
  static const String settings = '/teacher/settings';
  static const String chatDetail = '/teacher/chat-detail';
  static const String newMessage = '/teacher/new-message';

  // Admin Additional Routes
  static const String addMedicalRecord = '/admin/medical/add';
  static const String addClass = '/admin/classes/add';
  static const String addTimetable = '/admin/timetable/add';

  static List<GetPage> getPages = [
    GetPage(name: login, page: () => const LoginScreen()),

    // Admin Pages
    GetPage(name: adminDashboard, page: () => const AdminDashboard()),
    GetPage(name: studentList, page: () => const StudentListScreen()),
    GetPage(name: addStudent, page: () => const AddStudentScreen()),
    GetPage(name: classManagement, page: () => const ClassManagementScreen()),
    GetPage(name: timetable, page: () => const TimetableScreen()),
    GetPage(name: examScheduler, page: () => const ExamSchedulerScreen()),
    GetPage(name: feeManagement, page: () => const FeeManagementScreen()),
    GetPage(name: medicalDashboard, page: () => const MedicalDashboardScreen()),
    GetPage(name: noticeManagement, page: () => const NoticeManagementScreen()),
    GetPage(name: teacherList, page: () => const TeacherListScreen()),
    GetPage(name: adminList, page: () => const AdminListScreen()),
    // TODO: Add AddTeacherScreen and AddAdminScreen when created

    // Teacher Pages
    GetPage(name: teacherDashboard, page: () => const TeacherDashboard()),
    GetPage(name: attendance, page: () => const AttendanceScreen()),
    GetPage(name: homework, page: () => const HomeworkScreen()),
    GetPage(name: chatList, page: () => const ChatListScreen()),
    GetPage(name: marksEntry, page: () => const MarksEntryScreen()),
    GetPage(name: teacherProfile, page: () => const TeacherProfileScreen()),
    GetPage(name: teacherTimetable, page: () => const TeacherTimetableScreen()),

    // Student Pages
    GetPage(name: studentDashboard, page: () => const StudentDashboard()),
    GetPage(name: studentHomework, page: () => const StudentHomeworkScreen()),
    GetPage(
        name: studentAttendance, page: () => const StudentAttendanceScreen()),
    GetPage(name: studentFees, page: () => const StudentFeesScreen()),
    GetPage(name: studentProfile, page: () => const StudentProfileScreen()),
    GetPage(name: studentTimetable, page: () => const StudentTimetableScreen()),
    GetPage(
        name: studentNotifications,
        page: () => const StudentNotificationsScreen()),
    GetPage(
        name: studentMedicalReports,
        page: () => const StudentMedicalReportsScreen()),
    GetPage(
        name: payment,
        page: () {
          final fee = Get.arguments as Map<String, dynamic>;
          return PaymentScreen(fee: fee);
        }),

    // Teacher Additional Pages
    GetPage(name: leaveHistory, page: () => const LeaveHistoryScreen()),
    GetPage(name: changePassword, page: () => const ChangePasswordScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),
    GetPage(
        name: chatDetail,
        page: () {
          final chat = Get.arguments as Map<String, dynamic>;
          return ChatDetailScreen(chat: chat);
        }),
    GetPage(name: newMessage, page: () => const NewMessageScreen()),

    // Admin Additional Pages
    GetPage(name: addMedicalRecord, page: () => const AddMedicalRecordScreen()),
    GetPage(name: addClass, page: () => const AddClassScreen()),
    GetPage(name: addTimetable, page: () => const AddTimetableScreen()),
  ];
}
