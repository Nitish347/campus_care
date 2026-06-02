import 'dart:convert';

import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/models/medical_record_model.dart';
import 'package:campus_care/services/api/medical_record_api_service.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/common/summary_card.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/student/student_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StudentMedicalReportsScreen extends StatefulWidget {
  const StudentMedicalReportsScreen({super.key});

  @override
  State<StudentMedicalReportsScreen> createState() =>
      _StudentMedicalReportsScreenState();
}

class _StudentMedicalReportsScreenState
    extends State<StudentMedicalReportsScreen> {
  final MedicalRecordApiService _medicalApi = MedicalRecordApiService();
  final AuthController _authController = Get.find<AuthController>();

  bool _isLoading = true;
  List<MedicalRecordModel> _records = [];

  @override
  void initState() {
    super.initState();
    _loadMedicalReports();
  }

  DateTime _parseDate(dynamic raw) {
    if (raw is int) {
      final ms = raw > 10000000000 ? raw : raw * 1000;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    if (raw is String) {
      final asInt = int.tryParse(raw);
      if (asInt != null) {
        final ms = asInt > 10000000000 ? asInt : asInt * 1000;
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }

  List<String> _parseAttachments(dynamic raw) {
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is String && raw.trim().startsWith('[')) {
      try {
        final parsed = jsonDecode(raw);
        if (parsed is List) return parsed.map((e) => e.toString()).toList();
      } catch (_) {
        return [];
      }
    }
    if (raw is String && raw.trim().isNotEmpty) return [raw.trim()];
    return [];
  }

  Future<void> _loadMedicalReports() async {
    final student = _authController.currentStudent;
    if (student == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      setState(() => _isLoading = true);
      final data = await _medicalApi.getMedicalRecords(studentId: student.id);
      final records = data.whereType<Map>().map((raw) {
        final row = Map<String, dynamic>.from(raw);
        final parametersRaw = row['parameters'];

        List<HealthParameters> params = [];
        if (parametersRaw is List) {
          params = parametersRaw
              .whereType<Map>()
              .map((e) =>
                  HealthParameters.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }

        return MedicalRecordModel(
          id: (row['id'] ?? '').toString(),
          userId: (row['student_id'] ?? student.id).toString(),
          checkupDate: _parseDate(row['date']),
          checkupType: (row['record_type'] ?? 'General Checkup').toString(),
          parameters: params,
          drName: (row['doctor_name'] ?? 'School Medical Team').toString(),
          remark: row['description']?.toString(),
          attachment: _parseAttachments(row['attachments']),
          createdAt: _parseDate(row['created_at']),
        );
      }).toList();

      records.sort((a, b) => b.checkupDate.compareTo(a.checkupDate));

      if (!mounted) return;
      setState(() => _records = records);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _typeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('dental')) return Colors.teal;
    if (t.contains('vision')) return Colors.purple;
    if (t.contains('vaccination')) return Colors.green;
    if (t.contains('emergency')) return Colors.red;
    return Colors.blue;
  }

  IconData _typeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('dental')) return Icons.medication_outlined;
    if (t.contains('vision')) return Icons.visibility_outlined;
    if (t.contains('vaccination')) return Icons.vaccines_outlined;
    if (t.contains('emergency')) return Icons.emergency_outlined;
    return Icons.medical_services_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: StudentAppBar(
        title: 'Medical Reports',
        extraActions: [
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _loadMedicalReports,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SummaryCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryItem(
                        context,
                        Icons.medical_services,
                        '${_records.length}',
                        'Total Records',
                        theme.colorScheme.primary,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      _summaryItem(
                        context,
                        Icons.calendar_today,
                        _records.isNotEmpty
                            ? DateFormat('MMM yyyy')
                                .format(_records.first.checkupDate)
                            : 'N/A',
                        'Last Checkup',
                        Colors.green,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _records.isEmpty
                      ? const EmptyState(
                          icon: Icons.medical_services_outlined,
                          title: 'No medical records',
                          message: 'No medical reports available',
                        )
                      : ResponsivePadding(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount: _records.length,
                            itemBuilder: (context, index) {
                              final record = _records[index];
                              final color = _typeColor(record.checkupType);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        color.withValues(alpha: 0.12),
                                    child: Icon(_typeIcon(record.checkupType),
                                        color: color),
                                  ),
                                  title: Text(record.checkupType),
                                  subtitle: Text(
                                    '${DateFormat('MMM dd, yyyy').format(record.checkupDate)}\n'
                                    '${record.drName}',
                                  ),
                                  isThreeLine: true,
                                  trailing: record.attachment.isEmpty
                                      ? null
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme
                                                .surfaceContainerHighest,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${record.attachment.length} file${record.attachment.length > 1 ? 's' : ''}',
                                            style: theme.textTheme.labelSmall,
                                          ),
                                        ),
                                  onTap: () => _showDetails(context, record),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _summaryItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
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

  void _showDetails(BuildContext context, MedicalRecordModel record) {
    final theme = Theme.of(context);
    final color = _typeColor(record.checkupType);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(_typeIcon(record.checkupType), color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    record.checkupType,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Doctor: ${record.drName}'),
            const SizedBox(height: 8),
            Text(
                'Date: ${DateFormat('MMMM dd, yyyy').format(record.checkupDate)}'),
            if ((record.remark ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                record.remark!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
