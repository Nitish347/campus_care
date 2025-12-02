import 'package:campus_care/widgets/common/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/medical_record_model.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class StudentMedicalReportsScreen extends StatefulWidget {
  const StudentMedicalReportsScreen({super.key});

  @override
  State<StudentMedicalReportsScreen> createState() =>
      _StudentMedicalReportsScreenState();
}

class _StudentMedicalReportsScreenState
    extends State<StudentMedicalReportsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'General Checkup',
    'Dental',
    'Vision',
    'Vaccination',
    'Emergency',
  ];

  // Static medical records data
  final List<MedicalRecordModel> _medicalRecords = [
    MedicalRecordModel(
      id: '1',
      userId: 'student1',
      checkupDate: DateTime.now().subtract(const Duration(days: 30)),
      checkupType: 'General Checkup',
      parameters: [
        HealthParameters(name: 'Height', value: '165 cm', status: 'normal'),
        HealthParameters(name: 'Weight', value: '55 kg', status: 'normal'),
        HealthParameters(
            name: 'Blood Pressure', value: '120/80 mmHg', status: 'normal'),
        HealthParameters(name: 'Heart Rate', value: '72 bpm', status: 'normal'),
        HealthParameters(
            name: 'Temperature', value: '98.6°F', status: 'normal'),
      ],
      drName: 'Dr. Sarah Johnson',
      remark:
          'Student is in good health. Continue regular exercise and balanced diet.',
      attachment: ['medical_report_1.pdf'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    MedicalRecordModel(
      id: '2',
      userId: 'student1',
      checkupDate: DateTime.now().subtract(const Duration(days: 90)),
      checkupType: 'Dental',
      parameters: [
        HealthParameters(name: 'Cavities', value: '0', status: 'normal'),
        HealthParameters(name: 'Gum Health', value: 'Good', status: 'normal'),
        HealthParameters(name: 'Plaque', value: 'Minimal', status: 'normal'),
      ],
      drName: 'Dr. Michael Chen',
      remark:
          'Dental health is excellent. Continue regular brushing and flossing.',
      attachment: [],
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    MedicalRecordModel(
      id: '3',
      userId: 'student1',
      checkupDate: DateTime.now().subtract(const Duration(days: 120)),
      checkupType: 'Vision',
      parameters: [
        HealthParameters(name: 'Left Eye', value: '20/20', status: 'normal'),
        HealthParameters(
            name: 'Right Eye', value: '20/25', status: 'not normal'),
        HealthParameters(
            name: 'Color Vision', value: 'Normal', status: 'normal'),
      ],
      drName: 'Dr. Emily White',
      remark:
          'Slight vision issue in right eye. Recommend follow-up in 6 months.',
      attachment: ['vision_test_results.pdf', 'prescription.pdf'],
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    MedicalRecordModel(
      id: '4',
      userId: 'student1',
      checkupDate: DateTime.now().subtract(const Duration(days: 180)),
      checkupType: 'Vaccination',
      parameters: [
        HealthParameters(
            name: 'Vaccine Type', value: 'Flu Shot', status: 'normal'),
        HealthParameters(name: 'Dose', value: '0.5 ml', status: 'normal'),
        HealthParameters(name: 'Reaction', value: 'None', status: 'normal'),
      ],
      drName: 'Dr. Robert Brown',
      remark:
          'Annual flu vaccination administered successfully. No adverse reactions.',
      attachment: ['vaccination_certificate.pdf'],
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
    ),
  ];

  List<MedicalRecordModel> get _filteredRecords {
    if (_selectedFilter == 'All') {
      return _medicalRecords;
    }
    return _medicalRecords
        .where((record) => record.checkupType == _selectedFilter)
        .toList();
  }

  Color _getCheckupTypeColor(String type) {
    switch (type) {
      case 'General Checkup':
        return Colors.blue;
      case 'Dental':
        return Colors.teal;
      case 'Vision':
        return Colors.purple;
      case 'Vaccination':
        return Colors.green;
      case 'Emergency':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getCheckupTypeIcon(String type) {
    switch (type) {
      case 'General Checkup':
        return Icons.medical_services_outlined;
      case 'Dental':
        return Icons.medication_outlined;
      case 'Vision':
        return Icons.visibility_outlined;
      case 'Vaccination':
        return Icons.vaccines_outlined;
      case 'Emergency':
        return Icons.emergency_outlined;
      default:
        return Icons.health_and_safety_outlined;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'not normal':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(AppRoutes.studentNotifications),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Header
          SummaryCard(child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context,
                  Icons.medical_services,
                  '${_medicalRecords.length}',
                  'Total Records',
                  theme.colorScheme.primary,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildSummaryItem(
                  context,
                  Icons.calendar_today,
                  _medicalRecords.isNotEmpty
                      ? DateFormat('MMM yyyy')
                          .format(_medicalRecords.first.checkupDate)
                      : 'N/A',
                  'Last Checkup',
                  Colors.green,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildSummaryItem(
                  context,
                  Icons.attach_file,
                  '${_medicalRecords.fold<int>(0, (sum, record) => sum + record.attachment.length)}',
                  'Documents',
                  Colors.orange,
                ),
              ],
            ),
          ),

          // Records List
          Expanded(
            child: _filteredRecords.isEmpty
                ? EmptyState(
                    icon: Icons.medical_services_outlined,
                    title: 'No medical records',
                    message: _selectedFilter == 'All'
                        ? 'No medical records available'
                        : 'No records found for $_selectedFilter',
                  )
                : ResponsivePadding(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: _filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = _filteredRecords[index];
                        return _buildMedicalRecordCard(context, record);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalRecordCard(
    BuildContext context,
    MedicalRecordModel record,
  ) {
    final theme = Theme.of(context);
    final color = _getCheckupTypeColor(record.checkupType);
    final icon = _getCheckupTypeIcon(record.checkupType);

    // Count normal and abnormal parameters
    final normalCount = record.parameters
        .where((p) => p.status.toLowerCase() == 'normal')
        .length;
    final totalCount = record.parameters.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showRecordDetails(context, record),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Title and Type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.checkupType,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMMM dd, yyyy')
                                .format(record.checkupDate),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: normalCount == totalCount
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            normalCount == totalCount
                                ? Icons.check_circle
                                : Icons.warning_amber,
                            size: 16,
                            color: normalCount == totalCount
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            normalCount == totalCount ? 'Normal' : 'Review',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: normalCount == totalCount
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Doctor Info
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      record.drName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                if (record.remark != null && record.remark!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    record.remark!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                // Footer Row
                Row(
                  children: [
                    // Parameters Count
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$totalCount Parameters',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Attachments
                    if (record.attachment.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_file,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${record.attachment.length} File${record.attachment.length > 1 ? 's' : ''}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Checkup Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filters.map((filter) {
            return RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = 'All';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(BuildContext context, MedicalRecordModel record) {
    final theme = Theme.of(context);
    final color = _getCheckupTypeColor(record.checkupType);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCheckupTypeIcon(record.checkupType),
                      color: color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.checkupType,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('MMMM dd, yyyy')
                              .format(record.checkupDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Doctor Info
              _buildDetailSection(
                context,
                'Doctor Information',
                [
                  _buildDetailRow(
                    context,
                    Icons.person,
                    'Doctor Name',
                    record.drName,
                  ),
                  _buildDetailRow(
                    context,
                    Icons.calendar_today,
                    'Checkup Date',
                    DateFormat('MMMM dd, yyyy - hh:mm a')
                        .format(record.checkupDate),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Health Parameters
              _buildDetailSection(
                context,
                'Health Parameters',
                record.parameters.map((param) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(param.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusColor(param.status).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                param.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                param.value,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(param.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            param.status.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getStatusColor(param.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              if (record.remark != null && record.remark!.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildDetailSection(
                  context,
                  'Doctor\'s Remarks',
                  [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        record.remark!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],

              if (record.attachment.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildDetailSection(
                  context,
                  'Attachments',
                  record.attachment.map((file) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              file,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () {
                              // TODO: Download file
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
