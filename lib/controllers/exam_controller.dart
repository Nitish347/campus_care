import 'package:get/get.dart';
import 'package:campus_care/models/exam_model.dart';
import 'package:campus_care/models/exam_result_model.dart';

class ExamController extends GetxController {
  // Observable lists
  final RxList<ExamModel> examList = <ExamModel>[].obs;
  final RxList<ExamResult> examResults = <ExamResult>[].obs;

  // Filters
  final RxString selectedClass = ''.obs;
  final RxString selectedSection = ''.obs;
  final RxString selectedSubject = 'All'.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStaticData();
  }

  // Load static data for demonstration
  void _loadStaticData() {
    final now = DateTime.now();

    examList.value = [
      ExamModel(
        id: 'exam1',
        name: 'Mid-Term Mathematics',
        type: 'mid-term',
        subject: 'Mathematics',
        classId: 'class_5a',
        section: 'A',
        teacherId: 'teacher1',
        totalMarks: 100,
        durationMinutes: 120,
        examDate: now.add(const Duration(days: 10)),
        instructions: 'Bring calculator and geometry box',
        syllabus: 'Chapters 1-5',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      ExamModel(
        id: 'exam2',
        name: 'Science Quiz - Chapter 3',
        type: 'quiz',
        subject: 'Science',
        classId: 'class_5a',
        section: 'A',
        teacherId: 'teacher1',
        totalMarks: 25,
        durationMinutes: 30,
        examDate: now.subtract(const Duration(days: 5)),
        instructions: 'MCQ based quiz',
        syllabus: 'Chapter 3: Photosynthesis',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),
      ExamModel(
        id: 'exam3',
        name: 'English Final Exam',
        type: 'final',
        subject: 'English',
        classId: 'class_5b',
        section: 'B',
        teacherId: 'teacher1',
        totalMarks: 100,
        durationMinutes: 180,
        examDate: now.add(const Duration(days: 30)),
        instructions: 'Bring writing materials',
        syllabus: 'Full syllabus',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
    ];

    examResults.value = [
      // Results for exam2 (Science Quiz)
      ExamResult(
        id: 'result1',
        studentId: 'student1',
        examId: 'exam2',
        subject: 'Science',
        marks: 22,
        totalMarks: 25,
        status: 'graded',
        isPresent: true,
        teacherRemarks: 'Excellent performance',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      ExamResult(
        id: 'result2',
        studentId: 'student2',
        examId: 'exam2',
        subject: 'Science',
        marks: 18,
        totalMarks: 25,
        status: 'graded',
        isPresent: true,
        teacherRemarks: 'Good work',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      ExamResult(
        id: 'result3',
        studentId: 'student3',
        examId: 'exam2',
        subject: 'Science',
        marks: 0,
        totalMarks: 25,
        status: 'pending',
        isPresent: false,
        teacherRemarks: 'Absent',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  // Get exams filtered by class and section
  List<ExamModel> getFilteredExams() {
    var filtered = examList.toList();

    if (selectedClass.value.isNotEmpty) {
      filtered = filtered
          .where((exam) => exam.classId == selectedClass.value)
          .toList();
    }

    if (selectedSection.value.isNotEmpty) {
      filtered = filtered
          .where((exam) => exam.section == selectedSection.value)
          .toList();
    }

    if (selectedSubject.value != 'All') {
      filtered = filtered
          .where((exam) => exam.subject == selectedSubject.value)
          .toList();
    }

    return filtered;
  }

  // Get results for a specific exam
  List<ExamResult> getExamResults(String examId) {
    return examResults.where((result) => result.examId == examId).toList();
  }

  // Get exam statistics
  Map<String, dynamic> getExamStats(String examId) {
    final results = getExamResults(examId).where((r) => r.isPresent).toList();

    if (results.isEmpty) {
      return {
        'average': 0.0,
        'highest': 0.0,
        'lowest': 0.0,
        'totalStudents': 0,
        'present': 0,
        'absent': 0,
      };
    }

    final marks = results.map((r) => r.marks).toList();
    final average = marks.reduce((a, b) => a + b) / marks.length;
    final highest = marks.reduce((a, b) => a > b ? a : b);
    final lowest = marks.reduce((a, b) => a < b ? a : b);
    final allResults = getExamResults(examId);

    return {
      'average': average,
      'highest': highest,
      'lowest': lowest,
      'totalStudents': allResults.length,
      'present': allResults.where((r) => r.isPresent).length,
      'absent': allResults.where((r) => !r.isPresent).length,
    };
  }

  // Add new exam
  Future<void> addExam(ExamModel exam) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    examList.add(exam);
    isLoading.value = false;
  }

  // Update exam
  Future<void> updateExam(ExamModel exam) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    final index = examList.indexWhere((e) => e.id == exam.id);
    if (index != -1) {
      examList[index] = exam;
    }
    isLoading.value = false;
  }

  // Delete exam
  Future<void> deleteExam(String examId) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    examList.removeWhere((e) => e.id == examId);
    examResults.removeWhere((r) => r.examId == examId);
    isLoading.value = false;
  }

  // Save exam results (bulk entry)
  Future<void> saveExamResults(List<ExamResult> results) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    for (var result in results) {
      final index = examResults.indexWhere((r) => r.id == result.id);
      if (index != -1) {
        examResults[index] = result;
      } else {
        examResults.add(result);
      }
    }

    isLoading.value = false;
  }

  // Update single exam result
  Future<void> updateExamResult(ExamResult result) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    final index = examResults.indexWhere((r) => r.id == result.id);
    if (index != -1) {
      examResults[index] = result;
    } else {
      examResults.add(result);
    }
    isLoading.value = false;
  }

  // Get student's all exam results
  List<ExamResult> getStudentResults(String studentId) {
    return examResults.where((r) => r.studentId == studentId).toList();
  }

  // Set filters
  void setClassFilter(String classId) {
    selectedClass.value = classId;
  }

  void setSectionFilter(String section) {
    selectedSection.value = section;
  }

  void setSubjectFilter(String subject) {
    selectedSubject.value = subject;
  }

  // Clear filters
  void clearFilters() {
    selectedClass.value = '';
    selectedSection.value = '';
    selectedSubject.value = 'All';
  }
}
