import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/services/student_service.dart';
import 'package:campus_care/services/api/lunch_api_service.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/class_controller.dart';

class LunchController extends GetxController {
  final LunchApiService _lunchService = LunchApiService();
  final AuthController _authController = Get.find<AuthController>();
  final ClassController _classController = Get.put(ClassController());

  final _isLoading = false.obs;
  final _students = <Student>[].obs;
  final _lunchMap = <String, LunchStatus>{}.obs; // studentId -> status
  final _existingLunchIds = <String, String>{}.obs; // studentId -> lunchId
  final _selectedClass = Rxn<String>();
  final _selectedSection = Rxn<String>();
  final _selectedDate = Rx<DateTime>(DateTime.now());
  final _searchQuery = ''.obs;
  
  // UI State toggles
  final _isEditMode = false.obs;
  final _isTableView = true.obs;

  bool get isEditMode => _isEditMode.value;
  bool get isTableView => _isTableView.value;

  void toggleEditMode() => _isEditMode.value = !_isEditMode.value;
  void toggleViewMode() => _isTableView.value = !_isTableView.value;

  bool get isLoading => _isLoading.value;
  List<Student> get students => _students;
  
  List<Student> get filteredStudents {
    if (_searchQuery.value.isEmpty) {
      return _students;
    }
    final query = _searchQuery.value.toLowerCase();
    return _students.where((s) =>
        s.fullName.toLowerCase().contains(query) ||
        s.rollNumber.toLowerCase().contains(query) ||
        s.enrollmentNumber.toLowerCase().contains(query)).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }
  Map<String, LunchStatus> get lunchMap => _lunchMap;
  String? get selectedClass => _selectedClass.value;
  String? get selectedSection => _selectedSection.value;
  DateTime get selectedDate => _selectedDate.value;

  // Statistics
  int get totalStudents => _students.length;
  int get fullMealCount =>
      _lunchMap.values.where((status) => status == LunchStatus.fullMeal).length;
  int get halfMealCount =>
      _lunchMap.values.where((status) => status == LunchStatus.halfMeal).length;
  int get notTakenCount =>
      _lunchMap.values.where((status) => status == LunchStatus.notTaken).length;
  int get absentCount =>
      _lunchMap.values.where((status) => status == LunchStatus.absent).length;
  int get lunchPercentage =>
      totalStudents > 0 ? ((fullMealCount / totalStudents) * 100).round() : 0;

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
    _lunchMap.clear();
    _existingLunchIds.clear();
  }

  Future<void> loadStudentsAndLunch() async {
    if (_selectedClass.value == null || _selectedSection.value == null) {
      Get.snackbar('Error', 'Please select class and section');
      return;
    }

    try {
      _isLoading.value = true;

      // Ensure classes are loaded
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

      // Load existing lunch records for the selected date
      final dateString = _formatDate(_selectedDate.value);
      final lunchRecords = await _lunchService.getLunch(
        classId: _selectedClass.value,
        section: _selectedSection.value,
        date: dateString,
      );

      // Map existing lunch to students
      _lunchMap.clear();
      _existingLunchIds.clear();

      for (var record in lunchRecords) {
        // Backend returns snake_case: student_id
        dynamic studentIdRaw = record['student_id'] ?? record['studentId'];
        String? studentId;

        if (studentIdRaw is Map) {
          studentId = studentIdRaw['_id'] ?? studentIdRaw['id'];
        } else if (studentIdRaw is String) {
          studentId = studentIdRaw;
        }

        if (studentId != null) {
          final status = record['status'] as String?;
          // D1/SQLite returns 'id'; handle both
          final id = record['id'] as String? ?? record['_id'] as String?;

          // Always apply status even if id is missing
          if (status != null) {
            _lunchMap[studentId] = _parseLunchStatus(status);
            if (id != null) {
              _existingLunchIds[studentId] = id;
            }
          }
        }
      }

      // Initialize lunch map for students without records (default to Not Taken)
      for (var student in _students) {
        if (!_lunchMap.containsKey(student.id)) {
          _lunchMap[student.id] = LunchStatus.notTaken;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load students: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  void toggleStudentLunch(String studentId, LunchStatus status) {
    _lunchMap[studentId] = status;
    _lunchMap.refresh();
  }

  void markAllFullMeal() {
    for (var student in _students) {
      _lunchMap[student.id] = LunchStatus.fullMeal;
    }
    _lunchMap.refresh();
  }

  void markAllNotTaken() {
    for (var student in _students) {
      _lunchMap[student.id] = LunchStatus.notTaken;
    }
    _lunchMap.refresh();
  }

  Future<void> saveLunch() async {
    if (_students.isEmpty) {
      Get.snackbar('Error', 'No students to save lunch for');
      return;
    }

    String? markedBy = _authController.getMarkedBy();
    String? teacherId = _authController.getMarkedBy();
    if (markedBy == null || teacherId == null) {
      Get.snackbar('Error', 'Authentication error: user not found');
      return;
    }

    try {
      _isLoading.value = true;

      final List<Map<String, dynamic>> bulkData = [];
      final List<Future> updateFutures = [];

      for (var student in _students) {
        final status = _lunchMap[student.id] ?? LunchStatus.notTaken;
        final existingId = _existingLunchIds[student.id];

        if (existingId != null) {
          // Update existing lunch record
          updateFutures.add(
            _lunchService.updateLunch(
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
          // Add to bulk create with snake_case fields and unix timestamp date
          bulkData.add({
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
          failureCount += updateFutures.length;
          errors.add('Update failed: $e');
        }
      }

      // Execute bulk create
      if (bulkData.isNotEmpty) {
        final results = await _lunchService.bulkMarkLunch(bulkData);
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
            title: const Text('Lunch Saved with Errors'),
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
                  loadStudentsAndLunch();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        Get.snackbar(
          'Success',
          'Lunch records saved successfully ($successCount records)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        await loadStudentsAndLunch();
      }
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to save lunch records: ${e.toString()}'),
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

  LunchStatus _parseLunchStatus(String status) {
    switch (status.toLowerCase()) {
      case 'full meal':
        return LunchStatus.fullMeal;
      case 'half meal':
        return LunchStatus.halfMeal;
      case 'not taken':
        return LunchStatus.notTaken;
      case 'absent':
        return LunchStatus.absent;
      default:
        return LunchStatus.notTaken;
    }
  }

  String _getStatusString(LunchStatus status) {
    switch (status) {
      case LunchStatus.fullMeal:
        return 'Full Meal';
      case LunchStatus.halfMeal:
        return 'Half Meal';
      case LunchStatus.notTaken:
        return 'Not Taken';
      case LunchStatus.absent:
        return 'Absent';
    }
  }
}

enum LunchStatus {
  fullMeal,
  halfMeal,
  notTaken,
  absent,
}
