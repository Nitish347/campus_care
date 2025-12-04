import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/homework_model.dart';
import 'package:campus_care/models/homework_submission_model.dart';
import 'package:campus_care/controllers/homework_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';

class StudentHomeworkDetailScreen extends StatefulWidget {
  final HomeWorkModel homework;
  final Map<String, dynamic> student;
  final HomeworkSubmission? submission;

  const StudentHomeworkDetailScreen({
    super.key,
    required this.homework,
    required this.student,
    this.submission,
  });

  @override
  State<StudentHomeworkDetailScreen> createState() =>
      _StudentHomeworkDetailScreenState();
}

class _StudentHomeworkDetailScreenState
    extends State<StudentHomeworkDetailScreen> {
  final HomeworkController _controller = Get.find<HomeworkController>();
  final TextEditingController _marksController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.submission?.marksObtained != null) {
      _marksController.text = widget.submission!.marksObtained.toString();
    }
    if (widget.submission?.feedback != null) {
      _feedbackController.text = widget.submission!.feedback!;
    }
  }

  @override
  void dispose() {
    _marksController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _saveGrade() async {
    final marks = double.tryParse(_marksController.text);

    if (marks == null) {
      Get.snackbar(
        'Error',
        'Please enter valid marks',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (marks > (widget.homework.totalMarks ?? 100)) {
      Get.snackbar(
        'Error',
        'Marks cannot exceed ${widget.homework.totalMarks}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final submissionId = widget.submission?.id ??
        'sub_${widget.homework.id}_${widget.student['id']}';

    await _controller.gradeSubmission(
      submissionId,
      marks,
      _feedbackController.text,
    );

    Get.snackbar(
      'Success',
      'Grade saved successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final submission = widget.submission;
    final isSubmitted = submission?.isSubmitted ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework Details'),
        actions: [
          if (isSubmitted)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveGrade,
              tooltip: 'Save Grade',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        (widget.student['name'] as String)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.student['name'] as String,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${widget.student['studentId']}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Homework Info
            Text(
              'Homework Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.homework.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.homework.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.subject,
                            size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Subject: ${widget.homework.subject}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Due: ${DateFormat('MMM dd, yyyy - hh:mm a').format(widget.homework.dueDate)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.grade,
                            size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                            'Total Marks: ${widget.homework.totalMarks ?? 'N/A'}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submission Status
            Text(
              'Submission Status',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isSubmitted ? Icons.check_circle : Icons.pending,
                          color: isSubmitted ? Colors.green : Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isSubmitted ? 'Submitted' : 'Not Submitted',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isSubmitted ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (submission?.submittedAt != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Submitted on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(submission!.submittedAt!)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    if (isSubmitted &&
                        submission?.submissionContent != null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Submission Content',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          submission!.submissionContent!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                    if (submission?.attachments.isNotEmpty == true) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Attachments',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...submission!.attachments.map((attachment) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(Icons.attach_file,
                                    size: 20, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(attachment),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),

            if (isSubmitted) ...[
              const SizedBox(height: 24),

              // Grading Section
              Text(
                'Grading',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _marksController,
                        labelText: 'Marks Obtained',
                        hintText:
                            'Enter marks (max: ${widget.homework.totalMarks})',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.grade),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _feedbackController,
                        labelText: 'Feedback',
                        hintText: 'Enter feedback for the student',
                        maxLines: 4,
                        prefixIcon: const Icon(Icons.comment),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saveGrade,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Grade'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (submission?.isGraded == true) ...[
              const SizedBox(height: 24),

              // Graded Info
              Text(
                'Grading Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.green.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Graded',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Marks: ',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            '${submission!.marksObtained}/${widget.homework.totalMarks}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (submission.feedback != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'Feedback',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          submission.feedback!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
