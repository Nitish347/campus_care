import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:campus_care/core/constants/app_constants.dart';

class StudentService {
  static final List<Map<String, dynamic>> _sampleStudents = [
    {
      'id': 'student_001',
      'studentId': 'STU2024001',
      'name': 'Emma Wilson',
      'email': 'emma.wilson@email.com',
      'phone': '+1234567001',
      'dateOfBirth': DateTime(2010, 3, 15).toIso8601String(),
      'gender': 'Female',
      'address': '123 Main Street, City, State 12345',
      'classId': 'class_001',
      'section': 'A',
      'admissionDate': DateTime(2024, 1, 15).toIso8601String(),
      'guardianName': 'Robert Wilson',
      'guardianPhone': '+1234567101',
      'guardianEmail': 'robert.wilson@email.com',
      'guardianRelation': 'Father',
      'bloodGroup': 'O+',
      'medicalInfo': 'No known allergies',
      'documents': ['birth_certificate.pdf', 'medical_report.pdf'],
      'createdAt':
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    },
    {
      'id': 'student_002',
      'studentId': 'STU2024002',
      'name': 'Liam Johnson',
      'email': 'liam.johnson@email.com',
      'phone': '+1234567002',
      'dateOfBirth': DateTime(2009, 8, 22).toIso8601String(),
      'gender': 'Male',
      'address': '456 Oak Avenue, City, State 12345',
      'classId': 'class_002',
      'section': 'B',
      'admissionDate': DateTime(2024, 1, 15).toIso8601String(),
      'guardianName': 'Lisa Johnson',
      'guardianPhone': '+1234567102',
      'guardianEmail': 'lisa.johnson@email.com',
      'guardianRelation': 'Mother',
      'bloodGroup': 'A+',
      'medicalInfo': 'Mild asthma',
      'documents': ['birth_certificate.pdf', 'medical_report.pdf'],
      'createdAt':
          DateTime.now().subtract(const Duration(days: 28)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    },
    {
      'id': 'student_003',
      'studentId': 'STU2024003',
      'name': 'Olivia Davis',
      'email': 'olivia.davis@email.com',
      'phone': '+1234567003',
      'dateOfBirth': DateTime(2011, 12, 5).toIso8601String(),
      'gender': 'Female',
      'address': '789 Pine Road, City, State 12345',
      'classId': 'class_001',
      'section': 'A',
      'admissionDate': DateTime(2024, 2, 1).toIso8601String(),
      'guardianName': 'James Davis',
      'guardianPhone': '+1234567103',
      'guardianEmail': 'james.davis@email.com',
      'guardianRelation': 'Father',
      'bloodGroup': 'B+',
      'medicalInfo': 'Peanut allergy',
      'documents': ['birth_certificate.pdf', 'medical_report.pdf'],
      'createdAt':
          DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    },
  ];

  static Future<void> initializeSampleData() async {
    if (!StorageService.hasData(AppConstants.keyStudents)) {
      await StorageService.saveData(AppConstants.keyStudents, _sampleStudents);
    }
  }

  static Future<List<Student>> getAllStudents() async {
    await initializeSampleData();
    final studentsData = StorageService.getData(AppConstants.keyStudents);
    return studentsData.map((data) => Student.fromJson(data)).toList();
  }

  static Future<Student?> getStudentById(String id) async {
    final students = await getAllStudents();
    try {
      return students.firstWhere((student) => student.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Student>> getStudentsByClass(
      String classId, String section) async {
    final students = await getAllStudents();
    return students
        .where((student) =>
            student.classId == classId &&
            (section.isEmpty || student.section == section))
        .toList();
  }

  static Future<List<Student>> searchStudents(String query) async {
    final students = await getAllStudents();
    final lowerQuery = query.toLowerCase();
    return students
        .where((student) =>
            student.name.toLowerCase().contains(lowerQuery) ||
            student.studentId.toLowerCase().contains(lowerQuery) ||
            student.email.toLowerCase().contains(lowerQuery))
        .toList();
  }

  static Future<String> addStudent(Student student) async {
    await initializeSampleData();
    final studentsData = StorageService.getData(AppConstants.keyStudents);

    String id = student.id;
    if (id.isEmpty) {
      id = 'student_${DateTime.now().millisecondsSinceEpoch}';
    }

    final newStudent = student.copyWith(
      id: id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    studentsData.add(newStudent.toJson());
    await StorageService.saveData(AppConstants.keyStudents, studentsData);
    return id;
  }

  static Future<bool> updateStudent(Student student) async {
    try {
      final studentsData = StorageService.getData(AppConstants.keyStudents);
      final index = studentsData.indexWhere((data) => data['id'] == student.id);

      if (index != -1) {
        final updatedStudent = student.copyWith(updatedAt: DateTime.now());
        studentsData[index] = updatedStudent.toJson();
        await StorageService.saveData(AppConstants.keyStudents, studentsData);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<String> generateStudentId() async {
    final students = await getAllStudents();
    final year = DateTime.now().year;
    int maxNumber = 0;

    for (final student in students) {
      final studentId = student.studentId;
      if (studentId.startsWith('STU$year')) {
        final numberStr = studentId.substring(7);
        final number = int.tryParse(numberStr) ?? 0;
        if (number > maxNumber) {
          maxNumber = number;
        }
      }
    }

    return 'STU$year${(maxNumber + 1).toString().padLeft(3, '0')}';
  }
}
