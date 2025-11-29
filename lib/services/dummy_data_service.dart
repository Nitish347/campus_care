import 'package:campus_care/core/constants/app_constants.dart';

class DummyDataService {
  // Initialize all dummy data
  static Future<void> initializeAllData() async {
    // This will be called when the app starts
    // Individual services will check and initialize their data
  }

  // Sample students for student role login
  static List<Map<String, dynamic>> getSampleStudents() {
    return [
      {
        'id': 'student_001',
        'studentId': 'STU2024001',
        'email': 'student1@schoolstream.com',
        'password': 'student123',
        'name': 'Emma Wilson',
        'role': AppConstants.roleStudent,
        'phone': '+1234567001',
        'classId': 'class_001',
        'section': 'A',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'student_002',
        'studentId': 'STU2024002',
        'email': 'student2@schoolstream.com',
        'password': 'student123',
        'name': 'Liam Johnson',
        'role': AppConstants.roleStudent,
        'phone': '+1234567002',
        'classId': 'class_002',
        'section': 'B',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 28)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isActive': true,
      },
    ];
  }

  // Sample homework data
  static List<Map<String, dynamic>> getSampleHomework() {
    return [
      {
        'id': 'hw_001',
        'title': 'Math Assignment - Algebra',
        'description': 'Complete exercises 1-20 from chapter 5',
        'subject': 'Mathematics',
        'classId': 'class_001',
        'section': 'A',
        'assignedDate':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'dueDate':
            DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'status': 'active',
        'attachments': ['algebra_exercises.pdf'],
      },
      {
        'id': 'hw_002',
        'title': 'Science Project - Photosynthesis',
        'description': 'Create a presentation on photosynthesis process',
        'subject': 'Science',
        'classId': 'class_001',
        'section': 'A',
        'assignedDate':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'dueDate':
            DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'status': 'active',
        'attachments': ['photosynthesis_guide.pdf'],
      },
      {
        'id': 'hw_003',
        'title': 'English Essay - My Favorite Book',
        'description': 'Write a 500-word essay about your favorite book',
        'subject': 'English',
        'classId': 'class_001',
        'section': 'A',
        'assignedDate':
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'dueDate':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'status': 'overdue',
        'attachments': [],
      },
    ];
  }

  // Sample attendance data
  static List<Map<String, dynamic>> getSampleAttendance() {
    final now = DateTime.now();
    return List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      return {
        'id': 'att_${date.millisecondsSinceEpoch}',
        'userId': 'student_001',
        'dateTime': date.toIso8601String(),
        'status': index % 7 == 0 ? 'absent' : 'present',
        'type': 'daily',
        'markedBy': 'teacher_001',
        'remark': index % 7 == 0 ? 'Absent due to illness' : null,
      };
    });
  }

  // Sample fee data
  static List<Map<String, dynamic>> getSampleFees() {
    return [
      {
        'id': 'fee_001',
        'studentId': 'student_001',
        'feeType': 'Tuition Fee',
        'amount': 5000.0,
        'dueDate':
            DateTime.now().add(const Duration(days: 15)).toIso8601String(),
        'status': 'pending',
        'paidAmount': 0.0,
        'paidDate': null,
      },
      {
        'id': 'fee_002',
        'studentId': 'student_001',
        'feeType': 'Library Fee',
        'amount': 500.0,
        'dueDate':
            DateTime.now().add(const Duration(days: 20)).toIso8601String(),
        'status': 'pending',
        'paidAmount': 0.0,
        'paidDate': null,
      },
      {
        'id': 'fee_003',
        'studentId': 'student_001',
        'feeType': 'Sports Fee',
        'amount': 1000.0,
        'dueDate':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'status': 'paid',
        'paidAmount': 1000.0,
        'paidDate':
            DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      },
    ];
  }

  // Sample events
  static List<Map<String, dynamic>> getSampleEvents() {
    return [
      {
        'id': 'event_001',
        'title': 'Annual Sports Day',
        'description': 'School annual sports competition',
        'date': DateTime.now().add(const Duration(days: 10)).toIso8601String(),
        'type': 'sports',
      },
      {
        'id': 'event_002',
        'title': 'Science Fair',
        'description': 'Student science projects exhibition',
        'date': DateTime.now().add(const Duration(days: 20)).toIso8601String(),
        'type': 'academic',
      },
      {
        'id': 'event_003',
        'title': 'Parent-Teacher Meeting',
        'description': 'Quarterly parent-teacher conference',
        'date': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        'type': 'meeting',
      },
    ];
  }

  // Sample notices
  static List<Map<String, dynamic>> getSampleNotices() {
    return [
      {
        'id': 'notice_001',
        'title': 'Holiday Notice',
        'description': 'School will be closed on Friday for a public holiday',
        'date':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'priority': 'high',
      },
      {
        'id': 'notice_002',
        'title': 'Fee Payment Reminder',
        'description': 'Please pay the pending fees before the due date',
        'date':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'priority': 'medium',
      },
      {
        'id': 'notice_003',
        'title': 'Library Book Return',
        'description': 'All library books must be returned by end of month',
        'date':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'priority': 'low',
      },
    ];
  }

  // Sample classes
  static List<Map<String, dynamic>> getSampleClasses() {
    return [
      {
        'id': 'class_001',
        'name': 'Class 5',
        'section': 'A',
        'classTeacher': 'Sarah Johnson',
        'roomNumber': '101',
        'strength': 35,
        'subjects': ['Mathematics', 'Science', 'English', 'History', 'Geography'],
      },
      {
        'id': 'class_002',
        'name': 'Class 5',
        'section': 'B',
        'classTeacher': 'Michael Brown',
        'roomNumber': '102',
        'strength': 32,
        'subjects': ['Mathematics', 'Science', 'English', 'History', 'Geography'],
      },
      {
        'id': 'class_003',
        'name': 'Class 6',
        'section': 'A',
        'classTeacher': 'Emily Davis',
        'roomNumber': '201',
        'strength': 38,
        'subjects': ['Mathematics', 'Science', 'English', 'History', 'Geography', 'Art'],
      },
    ];
  }

  // Sample subjects
  static List<Map<String, dynamic>> getSampleSubjects() {
    return [
      {'id': 'sub_001', 'name': 'Mathematics', 'code': 'MATH', 'teacher': 'Michael Brown'},
      {'id': 'sub_002', 'name': 'Science', 'code': 'SCI', 'teacher': 'Sarah Johnson'},
      {'id': 'sub_003', 'name': 'English', 'code': 'ENG', 'teacher': 'Emily Davis'},
      {'id': 'sub_004', 'name': 'History', 'code': 'HIS', 'teacher': 'John Smith'},
      {'id': 'sub_005', 'name': 'Geography', 'code': 'GEO', 'teacher': 'Lisa Anderson'},
      {'id': 'sub_006', 'name': 'Art', 'code': 'ART', 'teacher': 'Robert Wilson'},
    ];
  }

  // Sample exams
  static List<Map<String, dynamic>> getSampleExams() {
    return [
      {
        'id': 'exam_001',
        'name': 'Mid-Term Examination',
        'subject': 'Mathematics',
        'classId': 'class_001',
        'section': 'A',
        'date': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
        'startTime': '09:00',
        'endTime': '11:00',
        'room': 'Hall A',
        'maxMarks': 100,
      },
      {
        'id': 'exam_002',
        'name': 'Mid-Term Examination',
        'subject': 'Science',
        'classId': 'class_001',
        'section': 'A',
        'date': DateTime.now().add(const Duration(days: 16)).toIso8601String(),
        'startTime': '09:00',
        'endTime': '11:00',
        'room': 'Hall A',
        'maxMarks': 100,
      },
      {
        'id': 'exam_003',
        'name': 'Final Examination',
        'subject': 'English',
        'classId': 'class_001',
        'section': 'A',
        'date': DateTime.now().add(const Duration(days: 45)).toIso8601String(),
        'startTime': '09:00',
        'endTime': '12:00',
        'room': 'Hall B',
        'maxMarks': 100,
      },
    ];
  }

  // Sample marks
  static List<Map<String, dynamic>> getSampleMarks() {
    return [
      {
        'id': 'mark_001',
        'studentId': 'student_001',
        'studentName': 'Emma Wilson',
        'subject': 'Mathematics',
        'examType': 'Mid-Term',
        'marks': 85,
        'maxMarks': 100,
        'grade': 'A',
        'date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      },
      {
        'id': 'mark_002',
        'studentId': 'student_001',
        'studentName': 'Emma Wilson',
        'subject': 'Science',
        'examType': 'Mid-Term',
        'marks': 92,
        'maxMarks': 100,
        'grade': 'A+',
        'date': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      },
      {
        'id': 'mark_003',
        'studentId': 'student_002',
        'studentName': 'Liam Johnson',
        'subject': 'Mathematics',
        'examType': 'Mid-Term',
        'marks': 78,
        'maxMarks': 100,
        'grade': 'B+',
        'date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      },
    ];
  }

  // Sample timetable
  static List<Map<String, dynamic>> getSampleTimetable() {
    return [
      {
        'id': 'tt_001',
        'day': 'Monday',
        'period': 1,
        'time': '09:00 - 09:45',
        'subject': 'Mathematics',
        'teacher': 'Michael Brown',
        'classId': 'class_001',
        'section': 'A',
        'room': '101',
      },
      {
        'id': 'tt_002',
        'day': 'Monday',
        'period': 2,
        'time': '09:45 - 10:30',
        'subject': 'Science',
        'teacher': 'Sarah Johnson',
        'classId': 'class_001',
        'section': 'A',
        'room': '102',
      },
      {
        'id': 'tt_003',
        'day': 'Monday',
        'period': 3,
        'time': '10:45 - 11:30',
        'subject': 'English',
        'teacher': 'Emily Davis',
        'classId': 'class_001',
        'section': 'A',
        'room': '103',
      },
      {
        'id': 'tt_004',
        'day': 'Monday',
        'period': 4,
        'time': '11:30 - 12:15',
        'subject': 'History',
        'teacher': 'John Smith',
        'classId': 'class_001',
        'section': 'A',
        'room': '104',
      },
      {
        'id': 'tt_005',
        'day': 'Monday',
        'period': 5,
        'time': '01:00 - 01:45',
        'subject': 'Geography',
        'teacher': 'Lisa Anderson',
        'classId': 'class_001',
        'section': 'A',
        'room': '105',
      },
    ];
  }

  // Sample medical records
  static List<Map<String, dynamic>> getSampleMedicalRecords() {
    return [
      {
        'id': 'med_001',
        'studentId': 'student_001',
        'studentName': 'Emma Wilson',
        'date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'type': 'Checkup',
        'description': 'Regular health checkup - All normal',
        'doctor': 'Dr. Smith',
        'prescription': 'No medication required',
      },
      {
        'id': 'med_002',
        'studentId': 'student_002',
        'studentName': 'Liam Johnson',
        'date': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        'type': 'Treatment',
        'description': 'Asthma management consultation',
        'doctor': 'Dr. Johnson',
        'prescription': 'Inhaler as needed',
      },
      {
        'id': 'med_003',
        'studentId': 'student_003',
        'studentName': 'Olivia Davis',
        'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'type': 'Emergency',
        'description': 'Allergic reaction - treated with antihistamine',
        'doctor': 'Dr. Brown',
        'prescription': 'Antihistamine tablets',
      },
    ];
  }

  // Sample chat messages
  static List<Map<String, dynamic>> getSampleChats() {
    return [
      {
        'id': 'chat_001',
        'parentName': 'Robert Wilson',
        'studentName': 'Emma Wilson',
        'lastMessage': 'Thank you for the update on Emma\'s progress',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'unreadCount': 2,
        'avatar': null,
      },
      {
        'id': 'chat_002',
        'parentName': 'Lisa Johnson',
        'studentName': 'Liam Johnson',
        'lastMessage': 'Can we schedule a meeting?',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'unreadCount': 0,
        'avatar': null,
      },
      {
        'id': 'chat_003',
        'parentName': 'James Davis',
        'studentName': 'Olivia Davis',
        'lastMessage': 'Olivia is doing great in class!',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'unreadCount': 1,
        'avatar': null,
      },
    ];
  }
}
