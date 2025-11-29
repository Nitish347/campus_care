import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class ClassManagementScreen extends StatelessWidget {
  const ClassManagementScreen({super.key});

  // Static UI data
  static final _classes = [
    {
      'id': 'class_001',
      'name': 'Class 1',
      'section': 'A',
      'roomNumber': '101',
      'strength': 30,
      'classTeacher': 'Ms. Sarah Johnson',
      'subjects': ['Mathematics', 'English', 'Science', 'Art'],
    },
    {
      'id': 'class_002',
      'name': 'Class 2',
      'section': 'A',
      'roomNumber': '102',
      'strength': 28,
      'classTeacher': 'Mr. David Smith',
      'subjects': ['Mathematics', 'English', 'Science', 'History'],
    },
    {
      'id': 'class_003',
      'name': 'Class 3',
      'section': 'A',
      'roomNumber': '103',
      'strength': 32,
      'classTeacher': 'Ms. Emily Brown',
      'subjects': ['Mathematics', 'English', 'Science', 'Geography'],
    },
  ];

  static final _subjects = [
    {
      'id': 'sub_001',
      'name': 'Mathematics',
      'code': 'MATH101',
      'teacher': 'Ms. Sarah Johnson',
    },
    {
      'id': 'sub_002',
      'name': 'Science',
      'code': 'SCI101',
      'teacher': 'Mr. David Smith',
    },
    {
      'id': 'sub_003',
      'name': 'English',
      'code': 'ENG101',
      'teacher': 'Ms. Emily Brown',
    },
    {
      'id': 'sub_004',
      'name': 'History',
      'code': 'HIS101',
      'teacher': 'Mr. John Doe',
    },
    {
      'id': 'sub_005',
      'name': 'Geography',
      'code': 'GEO101',
      'teacher': 'Ms. Jane Smith',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Class & Subject Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Classes'),
              Tab(text: 'Subjects'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Classes Tab
            _classes.isEmpty
                ? EmptyState(
                    icon: Icons.class_outlined,
                    title: 'No classes found',
                    message: 'Start by adding a new class',
                  )
                : ResponsivePadding(
                    child: ListView.builder(
                      itemCount: _classes.length,
                      itemBuilder: (context, index) {
                        final classData = _classes[index];
                        return InfoCard(
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.class_,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(
                              '${classData['name'] as String} - ${classData['section'] as String}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Room: ${classData['roomNumber'] as String} | Strength: ${classData['strength']}',
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Class Teacher: ${classData['classTeacher']}',
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Subjects:',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: (classData['subjects'] as List)
                                          .map((subject) => Chip(
                                                label: Text(
                                                  subject,
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

            // Subjects Tab
            _subjects.isEmpty
                ? EmptyState(
                    icon: Icons.book_outlined,
                    title: 'No subjects found',
                    message: 'Start by adding a new subject',
                  )
                : ResponsivePadding(
                    child: ListView.builder(
                      itemCount: _subjects.length,
                      itemBuilder: (context, index) {
                        final subject = _subjects[index];
                        return InfoCard(
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.book,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                            title: Text(
                              subject['name'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Code: ${subject['code']}'),
                                Text('Teacher: ${subject['teacher']}'),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                Get.snackbar('Info', 'Edit functionality coming soon');
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.toNamed(AppRoutes.addClass);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
