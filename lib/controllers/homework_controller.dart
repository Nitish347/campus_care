import 'package:get/get.dart';
import 'package:campus_care/models/homework_model.dart';
import 'package:campus_care/models/homework_submission_model.dart';

class HomeworkController extends GetxController {
  // Observable lists
  final RxList<HomeWorkModel> homeworkList = <HomeWorkModel>[].obs;
  final RxList<HomeworkSubmission> submissions = <HomeworkSubmission>[].obs;

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

    homeworkList.value = [
      HomeWorkModel(
        id: '1',
        title: 'Math Assignment - Algebra',
        description:
            'Complete exercises 1-20 from chapter 5. Focus on quadratic equations.',
        subject: 'Mathematics',
        teacherId: 'teacher1',
        classId: 'class_5a',
        section: 'A',
        assignedStudents: [
          'student1',
          'student2',
          'student3',
          'student4',
          'student5'
        ],
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 2)),
        priority: 'high',
        totalMarks: 20,
        attachments: ['worksheet.pdf'],
      ),
      HomeWorkModel(
        id: '2',
        title: 'Science Project - Photosynthesis',
        description:
            'Create a detailed presentation on the photosynthesis process.',
        subject: 'Science',
        teacherId: 'teacher1',
        classId: 'class_5a',
        section: 'A',
        assignedStudents: ['student1', 'student2', 'student3'],
        dueDate: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 5)),
        priority: 'medium',
        totalMarks: 30,
      ),
      HomeWorkModel(
        id: '3',
        title: 'English Essay - My Favorite Book',
        description: 'Write a 500-word essay about your favorite book.',
        subject: 'English',
        teacherId: 'teacher1',
        classId: 'class_5b',
        section: 'B',
        assignedStudents: ['student6', 'student7', 'student8'],
        dueDate: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 3)),
        priority: 'medium',
        totalMarks: 25,
      ),
      HomeWorkModel(
        id: '4',
        title: 'History Timeline - World War II',
        description: 'Create a timeline of major events in World War II.',
        subject: 'History',
        teacherId: 'teacher1',
        classId: 'class_5a',
        section: 'A',
        assignedStudents: ['student1', 'student2', 'student3', 'student4'],
        dueDate: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 10)),
        priority: 'high',
        totalMarks: 15,
      ),
    ];

    // Create submissions for homework
    submissions.value = [
      // Homework 1 submissions
      HomeworkSubmission(
        id: 'sub1',
        homeworkId: '1',
        studentId: 'student1',
        status: 'submitted',
        submittedAt: now.subtract(const Duration(hours: 5)),
        submissionContent: 'Completed all 20 exercises',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      HomeworkSubmission(
        id: 'sub2',
        homeworkId: '1',
        studentId: 'student2',
        status: 'graded',
        submittedAt: now.subtract(const Duration(days: 1)),
        submissionContent: 'Completed exercises',
        marksObtained: 18,
        feedback: 'Excellent work!',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      HomeworkSubmission(
        id: 'sub3',
        homeworkId: '1',
        studentId: 'student3',
        status: 'pending',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      // Homework 2 submissions
      HomeworkSubmission(
        id: 'sub4',
        homeworkId: '2',
        studentId: 'student1',
        status: 'submitted',
        submittedAt: now.subtract(const Duration(hours: 10)),
        submissionContent: 'Presentation created with diagrams',
        attachments: ['presentation.pptx'],
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(hours: 10)),
      ),
    ];
  }

  // Get homework filtered by class and section
  List<HomeWorkModel> getFilteredHomework() {
    var filtered = homeworkList.toList();

    if (selectedClass.value.isNotEmpty) {
      filtered =
          filtered.where((hw) => hw.classId == selectedClass.value).toList();
    }

    if (selectedSection.value.isNotEmpty) {
      filtered =
          filtered.where((hw) => hw.section == selectedSection.value).toList();
    }

    if (selectedSubject.value != 'All') {
      filtered =
          filtered.where((hw) => hw.subject == selectedSubject.value).toList();
    }

    return filtered;
  }

  // Get submissions for a specific homework
  List<HomeworkSubmission> getHomeworkSubmissions(String homeworkId) {
    return submissions.where((sub) => sub.homeworkId == homeworkId).toList();
  }

  // Get submission statistics for a homework
  Map<String, int> getSubmissionStats(String homeworkId) {
    final hwSubmissions = getHomeworkSubmissions(homeworkId);
    return {
      'total': hwSubmissions.length,
      'submitted': hwSubmissions.where((s) => s.isSubmitted).length,
      'pending': hwSubmissions.where((s) => s.isPending).length,
      'graded': hwSubmissions.where((s) => s.isGraded).length,
    };
  }

  // Add new homework
  Future<void> addHomework(HomeWorkModel homework) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    homeworkList.add(homework);
    isLoading.value = false;
  }

  // Update homework
  Future<void> updateHomework(HomeWorkModel homework) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    final index = homeworkList.indexWhere((hw) => hw.id == homework.id);
    if (index != -1) {
      homeworkList[index] = homework;
    }
    isLoading.value = false;
  }

  // Delete homework
  Future<void> deleteHomework(String homeworkId) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    homeworkList.removeWhere((hw) => hw.id == homeworkId);
    submissions.removeWhere((sub) => sub.homeworkId == homeworkId);
    isLoading.value = false;
  }

  // Grade a submission
  Future<void> gradeSubmission(
    String submissionId,
    double marks,
    String feedback,
  ) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    final index = submissions.indexWhere((sub) => sub.id == submissionId);
    if (index != -1) {
      submissions[index] = submissions[index].copyWith(
        marksObtained: marks,
        feedback: feedback,
        status: 'graded',
        updatedAt: DateTime.now(),
      );
    }
    isLoading.value = false;
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
