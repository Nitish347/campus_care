import 'package:campus_care/models/teacher/teacher.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:campus_care/core/constants/app_constants.dart';

class TeacherService {
  static final List<Map<String, dynamic>> _sampleTeachers = [
    {
      'id': 'teacher_001',
      'teacherId': 'TCH2024001',
      'name': 'Sarah Thompson',
      'email': 'sarah.thompson@school.com',
      'phone': '+1234567201',
      'department': 'Science',
      'qualification': 'M.Sc. Physics',
      'joinDate': DateTime(2020, 8, 15).toIso8601String(),
      'subjects': ['Physics', 'Mathematics'],
      'classes': ['class_001', 'class_002'],
      'address': '321 Elm Street, City',
      'salary': 55000.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 1000)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    },
    {
      'id': 'teacher_002',
      'teacherId': 'TCH2024002',
      'name': 'Michael Chen',
      'email': 'michael.chen@school.com',
      'phone': '+1234567202',
      'department': 'Mathematics',
      'qualification': 'Ph.D. Mathematics',
      'joinDate': DateTime(2019, 6, 1).toIso8601String(),
      'subjects': ['Mathematics', 'Statistics'],
      'classes': ['class_002', 'class_003'],
      'address': '654 Maple Avenue, City',
      'salary': 60000.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 1500)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    },
    {
      'id': 'teacher_003',
      'teacherId': 'TCH2024003',
      'name': 'Emily Rodriguez',
      'email': 'emily.rodriguez@school.com',
      'phone': '+1234567203',
      'department': 'English',
      'qualification': 'M.A. English Literature',
      'joinDate': DateTime(2021, 1, 10).toIso8601String(),
      'subjects': ['English', 'Literature'],
      'classes': ['class_001', 'class_003'],
      'address': '987 Cedar Lane, City',
      'salary': 52000.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 800)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    },
  ];

  static Future<void> initializeSampleData() async {
    if (!StorageService.hasData(AppConstants.keyTeachers)) {
      await StorageService.saveData(AppConstants.keyTeachers, _sampleTeachers);
    }
  }

  static Future<List<Teacher>> getAllTeachers() async {
    await initializeSampleData();
    final teachersData = StorageService.getData(AppConstants.keyTeachers);
    return teachersData.map((data) => Teacher.fromJson(data)).toList();
  }

  static Future<Teacher?> getTeacherById(String id) async {
    final teachers = await getAllTeachers();
    try {
      return teachers.firstWhere((teacher) => teacher.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<String> addTeacher(Teacher teacher) async {
    await initializeSampleData();
    final teachersData = StorageService.getData(AppConstants.keyTeachers);

    String id = teacher.id;
    if (id.isEmpty) {
      id = 'teacher_${DateTime.now().millisecondsSinceEpoch}';
    }

    final newTeacher = teacher.copyWith(
      id: id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    teachersData.add(newTeacher.toJson());
    await StorageService.saveData(AppConstants.keyTeachers, teachersData);
    return id;
  }

  static Future<bool> updateTeacher(Teacher teacher) async {
    try {
      final teachersData = StorageService.getData(AppConstants.keyTeachers);
      final index = teachersData.indexWhere((data) => data['id'] == teacher.id);

      if (index != -1) {
        final updatedTeacher = teacher.copyWith(updatedAt: DateTime.now());
        teachersData[index] = updatedTeacher.toJson();
        await StorageService.saveData(AppConstants.keyTeachers, teachersData);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<String> generateTeacherId() async {
    final teachers = await getAllTeachers();
    final year = DateTime.now().year;
    int maxNumber = 0;

    for (final teacher in teachers) {
      final teacherId = teacher.teacherId;
      if (teacherId.startsWith('TCH$year')) {
        final numberStr = teacherId.substring(7);
        final number = int.tryParse(numberStr) ?? 0;
        if (number > maxNumber) {
          maxNumber = number;
        }
      }
    }

    return 'TCH$year${(maxNumber + 1).toString().padLeft(3, '0')}';
  }
}
