import 'package:get/get.dart';
import 'package:campus_care/models/admin/admin.dart';
import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/models/teacher/teacher.dart';
import 'package:campus_care/services/super_admin_service.dart';

class SuperAdminController extends GetxController {
  final _isLoading = false.obs;
  final _schools = <Admin>[].obs;
  final _selectedSchool = Rxn<Admin>();
  final _searchQuery = ''.obs;
  final _dashboardStats = <String, dynamic>{}.obs;

  // Students
  final _students = <Student>[].obs;
  final _schoolStudents = <Student>[].obs;
  final _isLoadingSchoolStudents = false.obs;

  // Teachers
  final _teachers = <Teacher>[].obs;
  final _schoolTeachers = <Teacher>[].obs;
  final _isLoadingSchoolTeachers = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<Admin> get schools => _schools;
  Admin? get selectedSchool => _selectedSchool.value;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  List<Student> get students => _students;
  List<Student> get schoolStudents => _schoolStudents;
  List<Teacher> get teachers => _teachers;
  List<Teacher> get schoolTeachers => _schoolTeachers;
  RxBool get isLoadingSchoolStudents => _isLoadingSchoolStudents;
  RxBool get isLoadingSchoolTeachers => _isLoadingSchoolTeachers;

  List<Admin> get filteredSchools {
    if (_searchQuery.value.isEmpty) {
      return _schools;
    }
    return _schools.where((school) {
      final query = _searchQuery.value.toLowerCase();
      return school.instituteName.toLowerCase().contains(query) ||
          school.email.toLowerCase().contains(query) ||
          (school.city?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    refreshDashboardData();
  }

  Future<void> refreshDashboardData() async {
    await Future.wait([
      loadAllSchools(showLoader: false),
      loadAllStudents(showLoader: false),
      loadAllTeachers(showLoader: false),
    ]);
    await loadDashboardStats();
  }

  void _syncDashboardStats() {
    _dashboardStats.value = {
      'schools': _schools.length,
      'students': _students.length,
      'teachers': _teachers.length,
      'activeSchools': _schools.where((school) => school.isActive).length,
      'inactiveSchools': _schools.where((school) => !school.isActive).length,
    };
  }

  // Dashboard
  Future<void> loadDashboardStats() async {
    try {
      final stats = await SuperAdminService.getDashboardStats();
      _dashboardStats.value = {
        ..._dashboardStats,
        ...stats,
      };
    } catch (e) {
      _syncDashboardStats();
    }
  }

  // School Management
  Future<void> loadAllSchools({bool showLoader = true}) async {
    try {
      if (showLoader) {
        _isLoading.value = true;
      }
      final schools = await SuperAdminService.getAllSchools();
      _schools.assignAll(schools);
      _syncDashboardStats();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load schools: $e');
    } finally {
      if (showLoader) {
        _isLoading.value = false;
      }
    }
  }

  Future<void> loadSchoolById(String id) async {
    try {
      _isLoading.value = true;
      final school = await SuperAdminService.getSchoolById(id);
      _selectedSchool.value = school;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load school: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void selectSchool(Admin school) {
    _selectedSchool.value = school;
    // Load school-specific data
    loadSchoolStudents(school.id);
    loadSchoolTeachers(school.id);
  }

  void clearSelectedSchool() {
    _selectedSchool.value = null;
    _schoolStudents.clear();
    _schoolTeachers.clear();
  }

  Future<bool> updateSchool(String id, Map<String, dynamic> schoolData) async {
    try {
      _isLoading.value = true;
      await SuperAdminService.updateSchool(id, schoolData);
      await loadAllSchools();
      if (_selectedSchool.value?.id == id) {
        await loadSchoolById(id);
      }
      Get.snackbar('Success', 'School updated successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update school: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteSchool(String id) async {
    try {
      _isLoading.value = true;
      await SuperAdminService.deleteSchool(id);
      await loadAllSchools();
      if (_selectedSchool.value?.id == id) {
        clearSelectedSchool();
      }
      Get.snackbar('Success', 'School deleted successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete school: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void searchSchools(String query) {
    _searchQuery.value = query;
  }

  Future<bool> createSchool(Map<String, dynamic> schoolData) async {
    try {
      _isLoading.value = true;
      await SuperAdminService.createSchool(schoolData);
      await loadAllSchools();
      Get.snackbar('Success', 'School created successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create school: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Student Management
  Future<void> loadAllStudents({bool showLoader = true}) async {
    try {
      if (showLoader) {
        _isLoading.value = true;
      }
      final students = await SuperAdminService.getAllStudents();
      _students.assignAll(students);
      _syncDashboardStats();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load students: $e');
    } finally {
      if (showLoader) {
        _isLoading.value = false;
      }
    }
  }

  Future<void> loadSchoolStudents(String schoolId) async {
    try {
      _isLoadingSchoolStudents.value = true;
      final students = await SuperAdminService.getSchoolStudents(schoolId);
      _schoolStudents.assignAll(students);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load school students: $e');
    } finally {
      _isLoadingSchoolStudents.value = false;
    }
  }

  Future<void> createSchoolStudent(String schoolId, Student student) async {
    try {
      _isLoading.value = true;
      await SuperAdminService.createSchoolStudent(schoolId, student);
      await loadSchoolStudents(schoolId);
      Get.back();
      Get.snackbar('Success', 'Student created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create student: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateStudent(String id, Student student) async {
    try {
      _isLoading.value = true;
      await SuperAdminService.updateStudent(id, student);
      if (_selectedSchool.value != null) {
        await loadSchoolStudents(_selectedSchool.value!.id);
      } else {
        await loadAllStudents();
      }
      Get.back();
      Get.snackbar('Success', 'Student updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update student: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      _isLoading.value = true;
      await SuperAdminService.deleteStudent(id);
      if (_selectedSchool.value != null) {
        await loadSchoolStudents(_selectedSchool.value!.id);
      } else {
        await loadAllStudents();
      }
      Get.snackbar('Success', 'Student deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete student: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Teacher Management
  Future<void> loadAllTeachers({bool showLoader = true}) async {
    try {
      if (showLoader) {
        _isLoading.value = true;
      }
      final teachers = await SuperAdminService.getAllTeachers();
      _teachers.assignAll(teachers);
      _syncDashboardStats();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load teachers: $e');
    } finally {
      if (showLoader) {
        _isLoading.value = false;
      }
    }
  }

  Future<void> loadSchoolTeachers(String schoolId) async {
    try {
      _isLoadingSchoolTeachers.value = true;
      final teachers = await SuperAdminService.getSchoolTeachers(schoolId);
      _schoolTeachers.assignAll(teachers);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load school teachers: $e');
    } finally {
      _isLoadingSchoolTeachers.value = false;
    }
  }

  Future<void> createSchoolTeacher(String schoolId, Teacher teacher) async {
    try {
      _isLoading.value = true;
      await SuperAdminService.createSchoolTeacher(schoolId, teacher);
      await loadSchoolTeachers(schoolId);
      Get.back();
      Get.snackbar('Success', 'Teacher created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create teacher: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateTeacher(String id, Teacher teacher) async {
    try {
      _isLoading.value = true;
      await SuperAdminService.updateTeacher(id, teacher);
      if (_selectedSchool.value != null) {
        await loadSchoolTeachers(_selectedSchool.value!.id);
      } else {
        await loadAllTeachers();
      }
      Get.back();
      Get.snackbar('Success', 'Teacher updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update teacher: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteTeacher(String id) async {
    try {
      _isLoading.value = true;
      await SuperAdminService.deleteTeacher(id);
      if (_selectedSchool.value != null) {
        await loadSchoolTeachers(_selectedSchool.value!.id);
      } else {
        await loadAllTeachers();
      }
      Get.snackbar('Success', 'Teacher deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete teacher: $e');
    } finally {
      _isLoading.value = false;
    }
  }
}
