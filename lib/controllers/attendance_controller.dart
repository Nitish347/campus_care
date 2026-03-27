import 'package:campus_care/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/services/student_service.dart';
import 'package:campus_care/services/api/attendance_api_service.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/class_controller.dart';

class AttendanceController extends GetxController {
  final AttendanceApiService _attendanceService = AttendanceApiService();
  final AuthController _authController = Get.find<AuthController>();
  final ClassController _classController = Get.put(ClassController());

  final _isLoading = false.obs;
  final _students = <Student>[].obs;
  final _attendanceMap =
      <String, AttendanceStatus>{}.obs; // studentId -> status
  final _existingAttendanceIds =
      <String, String>{}.obs; // studentId -> attendanceId
  final _selectedClass = Rxn<String>();
  final _selectedSection = Rxn<String>();
  final _selectedDate = Rx<DateTime>(DateTime.now());

  // UI State toggles
  final _isEditMode = false.obs;
  final _isTableView = true.obs;
  final _searchQuery = ''.obs;

  bool get isEditMode => _isEditMode.value;
  bool get isTableView => _isTableView.value;
  String get searchQuery => _searchQuery.value;

  void toggleEditMode() => _isEditMode.value = !_isEditMode.value;
  void toggleViewMode() => _isTableView.value = !_isTableView.value;
  void setSearchQuery(String query) => _searchQuery.value = query;

  bool get isLoading => _isLoading.value;
  List<Student> get students => _students;

  List<Student> get filteredStudents {
    if (_searchQuery.value.isEmpty) {
      return _students;
    }
    return _students.where((student) {
      final query = _searchQuery.value.toLowerCase();
      return student.fullName.toLowerCase().contains(query) ||
             student.rollNumber.toLowerCase().contains(query);
    }).toList();
  }

  Map<String, AttendanceStatus> get attendanceMap => _attendanceMap;
  String? get selectedClass => _selectedClass.value;
  String? get selectedSection => _selectedSection.value;
  DateTime get selectedDate => _selectedDate.value;

  // Statistics
  int get totalStudents => _students.length;
  int get presentCount => _attendanceMap.values
      .where((status) => status == AttendanceStatus.present)
      .length;
  int get absentCount => _attendanceMap.values
      .where((status) => status == AttendanceStatus.absent)
      .length;
  int get lateCount => _attendanceMap.values
      .where((status) => status == AttendanceStatus.late)
      .length;
  int get excusedCount => _attendanceMap.values
      .where((status) => status == AttendanceStatus.excused)
      .length;
  int get attendancePercentage =>
      totalStudents > 0 ? ((presentCount / totalStudents) * 100).round() : 0;

  void selectClass(String? classId) {
    _selectedClass.value = classId;
    _selectedSection.value = null;
    _clearData();
  }

  void selectSection(String? section) {
    _selectedSection.value = section;
    _clearData();
  }

  void selectDate(DateTime date) {
    _selectedDate.value = date;
    _clearData();
  }

  void _clearData() {
    _students.clear();
    _attendanceMap.clear();
    _existingAttendanceIds.clear();
  }

  Future<void> loadStudentsAndAttendance() async {
    if (_selectedClass.value == null || _selectedSection.value == null) {
      Get.snackbar('Error', 'Please select class and section');
      return;
    }

    try {
      _isLoading.value = true;

      // Ensure classes are loaded so we can look up teacher later
      if (_classController.classes.isEmpty) {
        await _classController.fetchClasses();
      }

      // Load students for selected class/section
      final allStudents = await StudentService.getAllStudents();
      _students.value = allStudents
          .where((student) =>
              student.class_ == _selectedClass.value &&
              student.section == _selectedSection.value)
          .toList();

      // Load existing attendance for the selected date
      final dateString = _formatDate(_selectedDate.value);
      final attendanceRecords = await _attendanceService.getAttendance(
        classId: _selectedClass.value,
        section: _selectedSection.value,
        date: dateString,
      );

      // Map existing attendance to students
      _attendanceMap.clear();
      _existingAttendanceIds.clear();

      for (var record in attendanceRecords) {
        // Handle snake_case and camelCase
        dynamic studentIdRaw = record['student_id'] ?? record['studentId'];
        String? studentId;

        if (studentIdRaw is Map) {
          studentId = studentIdRaw['_id'] ?? studentIdRaw['id'];
        } else if (studentIdRaw is String) {
          studentId = studentIdRaw;
        }

        if (studentId != null) {
          final status = record['status'] as String?;
          // D1/SQLite returns 'id'; MongoDB returns '_id' — handle both
          final id = record['id'] as String? ?? record['_id'] as String?;

          // Always apply status even if id is missing (so student isn't shown as absent)
          if (status != null) {
            _attendanceMap[studentId] = _parseAttendanceStatus(status);
            if (id != null) {
              _existingAttendanceIds[studentId] = id;
            }
          }
        }
      }

      // Initialize attendance map for students without records
      for (var student in _students) {
        if (!_attendanceMap.containsKey(student.id)) {
          _attendanceMap[student.id] = AttendanceStatus.absent;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load students: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  void toggleStudentAttendance(String studentId, AttendanceStatus status) {
    _attendanceMap[studentId] = status;
    _attendanceMap.refresh();
  }

  void markAllPresent() {
    for (var student in _students) {
      _attendanceMap[student.id] = AttendanceStatus.present;
    }
    _attendanceMap.refresh();
  }

  void markAllAbsent() {
    for (var student in _students) {
      _attendanceMap[student.id] = AttendanceStatus.absent;
    }
    _attendanceMap.refresh();
  }

  Future<void> saveAttendance() async {
    if (_students.isEmpty) {
      Get.snackbar('Error', 'No students to save attendance for');
      return;
    }
    String? markedBy = _authController.getMarkedBy();
    String? teacherId = _authController.getMarkedBy();
    if (markedBy == null || teacherId == null) {
      Get.snackbar('Error', 'Authentication error: user not found');
      return;
    }
    // // Get current markedBy ID (Admin ID)
    // if (_authController.currentRole != null) {
    //   if (_authController.currentRole == AppConstants.roleAdmin) {
    //     final admin = _authController.currentAdmin;
    //     if (admin == null) {
    //       Get.snackbar('Error', 'Authentication error: user not found');
    //       return;
    //     }
    //     markedBy = admin.id;
    //     // Use Admin ID (Institution ID) as teacherId as requested
    //     teacherId = admin.id;
    //   } else if (_authController.currentRole == AppConstants.roleTeacher) {
    //     final teacher = _authController.currentTeacher;
    //     if (teacher == null) {
    //       Get.snackbar('Error', 'Authentication error: user not found');
    //       return;
    //     }
    //     markedBy = teacher.id;
    //     // Use Admin ID (Institution ID) as teacherId as requested
    //     teacherId = teacher.id;
    //   } else {
    //     Get.snackbar('Error', 'Authentication error: user not found');
    //     return;
    //   }
    // }

    // Use current user ID as teacher_id (Admin or Teacher)
    // The database migration allows Admins (who are not in teachers table) to be stored here

    try {
      _isLoading.value = true;

      final List<Map<String, dynamic>> bulkData = [];
      final List<Future> updateFutures = [];

      for (var student in _students) {
        final status = _attendanceMap[student.id] ?? AttendanceStatus.present;
        final existingId = _existingAttendanceIds[student.id];

        if (existingId != null) {
          // Update existing attendance
          updateFutures.add(
            _attendanceService.updateAttendance(
              existingId,
              {
                'status': _getStatusString(status),
                'date': DateTime(_selectedDate.value.year,
                            _selectedDate.value.month, _selectedDate.value.day)
                        .millisecondsSinceEpoch ~/
                    1000,
                'marked_by': markedBy,
              },
            ),
          );
        } else {
          // Add to bulk create
          bulkData.add({
            // 'teacher_id': teacherId, // REMOVED
            'student_id': student.id,
            'date': DateTime(_selectedDate.value.year,
                        _selectedDate.value.month, _selectedDate.value.day)
                    .millisecondsSinceEpoch ~/
                1000,
            'status': _getStatusString(status),
            'class': _selectedClass.value,
            'section': _selectedSection.value,
            'marked_by': markedBy,
          });
        }
      }

      int successCount = 0;
      int failureCount = 0;
      List<String> errors = [];

      // Execute updates
      if (updateFutures.isNotEmpty) {
        try {
          await Future.wait(updateFutures);
          successCount += updateFutures.length;
        } catch (e) {
          failureCount += updateFutures.length; // Approximate
          errors.add('Update failed: $e');
        }
      }

      // Execute bulk create
      if (bulkData.isNotEmpty) {
        final results = await _attendanceService.bulkMarkAttendance(bulkData);
        for (var result in results) {
          if (result['success'] == true) {
            successCount++;
          } else {
            failureCount++;
            if (result['error'] != null) {
              errors.add(result['error'].toString());
            }
          }
        }
      }

      if (failureCount > 0) {
        Get.dialog(
          AlertDialog(
            title: const Text('Attendance Saved with Errors'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$successCount records saved successfully.'),
                  Text('$failureCount records failed.'),
                  const SizedBox(height: 8),
                  const Text('Errors:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...errors.take(5).map((e) => Text('• $e',
                      style: const TextStyle(color: Colors.red, fontSize: 12))),
                  if (errors.length > 5)
                    Text('...and ${errors.length - 5} more'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  loadStudentsAndAttendance(); // Reload anyway
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        Get.snackbar(
          'Success',
          'Attendance saved successfully ($successCount records)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        // Reload to get updated data
        await loadStudentsAndAttendance();
      }
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to save attendance: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  AttendanceStatus _parseAttendanceStatus(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'excused':
        return AttendanceStatus.excused;
      default:
        return AttendanceStatus.present;
    }
  }

  String _getStatusString(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }
}

enum AttendanceStatus {
  present,
  absent,
  late,
  excused,
}
