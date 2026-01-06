import 'package:campus_care/screens/admin/profile/admin_profile_screen.dart';
import 'package:get/get.dart';

import 'package:campus_care/screens/auth/tabbed_login_screen.dart';
import 'package:campus_care/screens/splash_screen.dart';
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
import 'package:campus_care/screens/admin/teacher/teacher_details_screen.dart';
import 'package:campus_care/screens/admin/teacher_management/add_teacher_screen.dart';
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
import 'package:campus_care/screens/student/exams/student_exam_timetable_screen.dart';
import 'package:campus_care/screens/student/exams/student_results_screen.dart';
import 'package:campus_care/screens/teacher/homework/teacher_homework_management_screen.dart';
import 'package:campus_care/screens/teacher/attendance/teacher_attendance_management_screen.dart';
import 'package:campus_care/screens/teacher/leave/leave_history_screen.dart';
import 'package:campus_care/screens/teacher/profile/change_password_screen.dart';
import 'package:campus_care/screens/teacher/profile/settings_screen.dart';
import 'package:campus_care/screens/teacher/communication/chat_detail_screen.dart';
import 'package:campus_care/screens/teacher/communication/new_message_screen.dart';
import 'package:campus_care/screens/admin/medical/add_medical_record_screen.dart';
import 'package:campus_care/screens/admin/academic/add_class_screen.dart';
import 'package:campus_care/screens/admin/academic/add_timetable_screen.dart';
import 'package:campus_care/screens/student/payment/payment_screen.dart';
import 'package:campus_care/screens/teacher/homework/homework_submissions_screen.dart';
import 'package:campus_care/screens/teacher/homework/student_homework_detail_screen.dart';
import 'package:campus_care/screens/teacher/marks/exam_management_screen.dart';
import 'package:campus_care/screens/super_admin/super_admin_dashboard.dart';
import 'package:campus_care/screens/super_admin/institute_management_screen.dart';
import 'package:campus_care/models/teacher/teacher.dart';
import 'package:campus_care/screens/super_admin/institute_detail_screen.dart';
import 'package:campus_care/screens/super_admin/add_edit_institute_screen.dart';
import 'package:campus_care/core/middleware/auth_middleware.dart';
import 'package:campus_care/core/middleware/super_admin_middleware.dart';
import 'package:campus_care/core/middleware/school_admin_middleware.dart';
import 'package:campus_care/screens/admin/attendance/admin_attendance_screen.dart';
import 'package:campus_care/controllers/attendance_controller.dart';

class AppRoutes {
  // Auth Routes
  static const String splash = '/splash';
  static const String login = '/login';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProfile = '/admin/profile';

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
  static const String teacherDetails = '/admin/teachers/details';
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
  static const String studentExamTimetable = '/student/exam-timetable';
  static const String studentResults = '/student/results';
  static const String payment = '/student/payment';

  // Teacher Additional Routes
  static const String teacherHomeworkManagement =
      '/teacher/homework-management';
  static const String teacherAttendanceManagement =
      '/teacher/attendance-management';
  static const String leaveHistory = '/teacher/leave-history';
  static const String changePassword = '/teacher/change-password';
  static const String settings = '/teacher/settings';
  static const String chatDetail = '/teacher/chat-detail';
  static const String newMessage = '/teacher/new-message';

  // Admin Additional Routes
  static const String addMedicalRecord = '/admin/medical/add';
  static const String addClass = '/admin/classes/add';
  static const String addTimetable = '/admin/timetable/add';
  static const String adminAttendance = '/admin/attendance';

  // Teacher Homework & Exam Routes
  static const String homeworkSubmissions = '/teacher/homework/submissions';
  static const String studentHomeworkDetail =
      '/teacher/homework/student-detail';
  static const String examManagement = '/teacher/exams';

  // Super Admin Routes
  static const String superAdminDashboard = '/super-admin/dashboard';
  static const String instituteManagement = '/super-admin/institutes';
  static const String instituteDetail = '/super-admin/institute-detail';
  static const String addEditInstitute = '/super-admin/add-edit-institute';

  static List<GetPage> getPages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const TabbedLoginScreen()),

    // Admin Pages (Protected by SchoolAdminMiddleware)
    GetPage(
      name: adminDashboard,
      page: () => const AdminDashboard(),
      middlewares: [SchoolAdminMiddleware()],
    ),
    GetPage(
      name: adminProfile,
      page: () => const AdminProfileScreen(),
      middlewares: [SchoolAdminMiddleware()],
    ),
    GetPage(
      name: studentList,
      page: () => const StudentListScreen(),
      middlewares: [SchoolAdminMiddleware()],
    ),
    GetPage(
      name: addStudent,
      page: () => const AddStudentScreen(),
      middlewares: [SchoolAdminMiddleware()],
    ),
    GetPage(
      name: classManagement,
      page: () => ClassManagementScreen(),
      middlewares: [SchoolAdminMiddleware()],
    ),
    GetPage(
      name: timetable,
      page: () => const TimetableScreen(),
      middlewares: [SchoolAdminMiddleware()],
    ),
    GetPage(
      name: adminAttendance,
      page: () => const AdminAttendanceScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AttendanceController());
      }),
      middlewares: [SchoolAdminMiddleware()],
    ),
    GetPage(
      name: examScheduler,
      page: () => const ExamSchedulerScreen(),
      middlewares: [SchoolAdminMiddleware()],
    ),
    GetPage(name: feeManagement, page: () => const FeeManagementScreen()),
    GetPage(name: medicalDashboard, page: () => const MedicalDashboardScreen()),
    GetPage(name: noticeManagement, page: () => const NoticeManagementScreen()),
    GetPage(name: teacherList, page: () => const TeacherListScreen()),
    GetPage(
      name: teacherDetails,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        final teacher = args['teacher'] as Teacher;
        return TeacherDetailsScreen(teacher: teacher);
      },
      middlewares: [SchoolAdminMiddleware()],
    ),
    GetPage(
      name: addTeacher,
      page: () => const AddTeacherScreen(),
      middlewares: [SchoolAdminMiddleware()],
    ),
    GetPage(name: adminList, page: () => const AdminListScreen()),
    // TODO: Add AddAdminScreen when created

    // Teacher Pages
    GetPage(name: teacherDashboard, page: () => const TeacherDashboard()),
    GetPage(
        name: teacherHomeworkManagement,
        page: () => const TeacherHomeworkManagementScreen()),
    GetPage(
        name: teacherAttendanceManagement,
        page: () => const TeacherAttendanceManagementScreen()),
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
        name: studentExamTimetable,
        page: () => const StudentExamTimetableScreen()),
    GetPage(name: studentResults, page: () => const StudentResultsScreen()),
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

    // Teacher Homework & Exam Pages
    GetPage(
        name: homeworkSubmissions,
        page: () {
          final homework = Get.arguments;
          return HomeworkSubmissionsScreen(homework: homework);
        }),
    GetPage(
        name: studentHomeworkDetail,
        page: () {
          final args = Get.arguments as Map<String, dynamic>;
          final homework = args['homework'];
          final submission = args['submission'];
          final student = args['student'];
          return StudentHomeworkDetailScreen(
            homework: homework,
            submission: submission,
            student: student,
          );
        }),
    GetPage(name: examManagement, page: () => const ExamManagementScreen()),

    // Super Admin Pages (Protected by SuperAdminMiddleware)
    GetPage(
      name: superAdminDashboard,
      page: () => const SuperAdminDashboard(),
      middlewares: [SuperAdminMiddleware()],
    ),
    GetPage(
      name: instituteManagement,
      page: () => const InstituteManagementScreen(),
      middlewares: [SuperAdminMiddleware()],
    ),
    GetPage(
      name: instituteDetail,
      page: () => const InstituteDetailScreen(),
      middlewares: [SuperAdminMiddleware()],
    ),
    GetPage(
      name: addEditInstitute,
      page: () => const AddEditInstituteScreen(),
      middlewares: [SuperAdminMiddleware()],
    ),
  ];
}
