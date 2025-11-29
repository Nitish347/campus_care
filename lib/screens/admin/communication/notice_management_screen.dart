import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';

class NoticeManagementScreen extends StatefulWidget {
  const NoticeManagementScreen({super.key});

  @override
  State<NoticeManagementScreen> createState() => _NoticeManagementScreenState();
}

class _NoticeManagementScreenState extends State<NoticeManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedPriority;

  // Static UI data
  static final _notices = [
    {
      'id': 'notice_001',
      'title': 'Holiday Notice',
      'description': 'School will be closed on Friday for a public holiday',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'priority': 'high',
    },
    {
      'id': 'notice_002',
      'title': 'Fee Payment Reminder',
      'description': 'Please pay the pending fees before the due date',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'priority': 'medium',
    },
    {
      'id': 'notice_003',
      'title': 'Library Book Return',
      'description': 'All library books must be returned by end of month',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'priority': 'low',
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _publishNotice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPriority == null) {
      Get.snackbar('Error', 'Please select priority');
      return;
    }

    Get.snackbar('Success', 'Notice published successfully');
    
    _formKey.currentState!.reset();
    setState(() {
      _selectedPriority = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notice Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Publish Notice'),
              Tab(text: 'View Notices'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Publish Notice Tab
            SingleChildScrollView(
              child: ResponsivePadding(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionHeader(title: 'Create New Notice'),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _titleController,
                        labelText: 'Notice Title',
                        hintText: 'Enter notice title',
                        prefixIcon: const Icon(Icons.title),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter notice title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descriptionController,
                        labelText: 'Description',
                        hintText: 'Enter description',
                        maxLines: 6,
                        prefixIcon: const Icon(Icons.description),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomDropdown<String>(
                        value: _selectedPriority,
                        labelText: 'Priority',
                        prefixIcon: const Icon(Icons.flag),
                        items: [
                          DropdownMenuItem(
                            value: 'high',
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('High'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'medium',
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Medium'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'low',
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Low'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select priority';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        onPressed: _publishNotice,
                        child: const Text('Publish Notice'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // View Notices Tab
            _notices.isEmpty
                ? EmptyState(
                    icon: Icons.announcement_outlined,
                    title: 'No notices found',
                    message: 'Start by publishing a notice',
                  )
                : ResponsivePadding(
                    child: ListView.builder(
                      itemCount: _notices.length,
                      itemBuilder: (context, index) {
                        final notice = _notices[index];
                        final date = notice['date'] as DateTime;
                        final priority = notice['priority'] as String;
                        
                        Color priorityColor;
                        switch (priority) {
                          case 'high':
                            priorityColor = Colors.red;
                            break;
                          case 'medium':
                            priorityColor = Colors.orange;
                            break;
                          default:
                            priorityColor = Colors.blue;
                        }

                        return InfoCard(
                          child: ListTile(
                            leading: Container(
                              width: 4,
                              decoration: BoxDecoration(
                                color: priorityColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            title: Text(
                              notice['title'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(notice['description'] as String),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: priorityColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        priority.toUpperCase(),
                                        style: TextStyle(
                                          color: priorityColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(date),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
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
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditDialog(context, notice);
                                } else if (value == 'delete') {
                                  _showDeleteDialog(context, notice);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> notice) {
    Get.snackbar('Info', 'Edit notice: ${notice['title']}');
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> notice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notice'),
        content: Text('Are you sure you want to delete "${notice['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar('Success', 'Notice deleted successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
