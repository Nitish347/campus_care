import 'dart:math';
import 'package:get/get.dart';
import 'package:campus_care/services/api/student_api_service.dart';
import 'package:campus_care/services/api/teacher_api_service.dart';
import 'package:campus_care/services/api/class_api_service.dart';
import 'package:campus_care/services/api/notice_api_service.dart';
import 'package:campus_care/controllers/auth_controller.dart';

class DummyDataService {
  final StudentApiService _studentService = StudentApiService();
  final TeacherApiService _teacherService = TeacherApiService();
  final ClassApiService _classService = ClassApiService();
  final NoticeApiService _noticeService = NoticeApiService();
  final AuthController _authController = Get.find<AuthController>();

  final Random _random = Random();

  Future<void> generateDummyData() async {
    try {
      final instituteId = _authController.currentAdmin?.id;
      if (instituteId == null) {
        throw Exception('Institute ID not found');
      }

      // 1. Create Classes
      print('Creating classes...');
      List<String> classIds = [];
      for (int i = 1; i <= 10; i++) {
        final className = 'Class $i';
        try {
          // Create class with default sections A and B
          final result = await _classService.createClass({
            'name': className,
            'grade': '$i',
            'sections': ['A', 'B'],
            'instituteId': instituteId
          });
          if (result['_id'] != null) classIds.add(result['_id']);
        } catch (e) {
          print('Error creating class $className: $e');
        }
      }

      // Re-fetch classes to get IDs for students
      final classes = await _classService.getClasses(instituteId: instituteId);

      // 2. Create Teachers
      print('Creating teachers...');
      List<String> teacherIds = [];
      final subjects = [
        'Mathematics',
        'Science',
        'English',
        'History',
        'Geography',
        'Physics',
        'Chemistry'
      ];
      for (int i = 0; i < 10; i++) {
        try {
          final teacherData = {
            'firstName': _getRandomFirstName(),
            'lastName': _getRandomLastName(),
            'email': 'teacher$i@test.com',
            'password': 'password123',
            'phone': '987654321$i',
            'subject': subjects[i % subjects.length],
            'qualification': 'B.Ed, M.Sc',
            'experience': '${_random.nextInt(15) + 1} years',
            'role': 'teacher',
            'instituteId': instituteId,
          };
          final result = await _teacherService.createTeacher(teacherData);
          if (result['_id'] != null) teacherIds.add(result['_id']);
        } catch (e) {
          print('Error creating teacher $i: $e');
        }
      }

      // 3. Create Students
      print('Creating students...');
      if (classes.isNotEmpty) {
        for (int i = 0; i < 50; i++) {
          try {
            // Pick random class
            final classObj = classes[_random.nextInt(classes.length)];
            // If classObj has sections array, pick one.
            // Checking structure via API is hard here, assuming standard structure.
            // If API returns: { _id: "...", name: "Class 1", sections: ["A", "B"] }
            String section = 'A';
            if (classObj['sections'] is List &&
                (classObj['sections'] as List).isNotEmpty) {
              section = (classObj['sections'] as List)[0];
            }

            final studentData = {
              'firstName': _getRandomFirstName(),
              'lastName': _getRandomLastName(),
              'email': 'student$i@test.com',
              'password': 'password123',
              'phone': '98765432$i',
              'enrollmentNumber': 'EN${2025000 + i}',
              'rollNumber': '${i + 1}',
              'class': classObj[
                  '_id'], // Send ID or Name depending on backend expectation. Usually ID.
              'section': section,
              'gender': i % 2 == 0 ? 'Male' : 'Female',
              'dateOfBirth': '2010-01-01',
              'admissionDate': '2025-01-01',
              'instituteId': instituteId,
              'address': '123 Test St, Test City',
              'guardian': {
                'name': 'Guardian of Student $i',
                'phone': '9999999999',
                'relation': 'Parent'
              }
            };
            await _studentService.createStudent(studentData);
          } catch (e) {
            print('Error creating student $i: $e');
          }
        }
      }

      // 4. Create Notices
      print('Creating notices...');
      for (int i = 0; i < 5; i++) {
        try {
          final noticeData = {
            'title': 'Generic Notice Title $i',
            'content':
                'This is a sample notice content for demonstration purposes. Important information here.',
            'category': 'General',
            'priority': i % 2 == 0 ? 'High' : 'Normal',
            'targetRole': 'all', // or student, teacher, etc.
            'instituteId': instituteId,
          };
          await _noticeService.createNotice(noticeData);
        } catch (e) {
          print('Error creating notice $i: $e');
        }
      }

      // 5. Create Timetables (Optional/Complex)
      // Skipping for simplicity or add basic if needed.

      Get.snackbar('Success', 'Dummy data generation completed!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate data: $e');
      print('Fatal error in dummy generation: $e');
    }
  }

  String _getRandomFirstName() {
    const names = [
      'James',
      'Mary',
      'John',
      'Patricia',
      'Robert',
      'Jennifer',
      'Michael',
      'Linda',
      'William',
      'Elizabeth',
      'David',
      'Barbara',
      'Richard',
      'Susan',
      'Joseph',
      'Jessica'
    ];
    return names[_random.nextInt(names.length)];
  }

  String _getRandomLastName() {
    const names = [
      'Smith',
      'Johnson',
      'Williams',
      'Brown',
      'Jones',
      'Garcia',
      'Miller',
      'Davis',
      'Rodriguez',
      'Martinez'
    ];
    return names[_random.nextInt(names.length)];
  }
}
