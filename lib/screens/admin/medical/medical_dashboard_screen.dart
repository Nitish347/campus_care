import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/icon_label_tile.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

import 'package:campus_care/widgets/admin/admin_page_header.dart';
class MedicalDashboardScreen extends StatelessWidget {
  const MedicalDashboardScreen({super.key});

  // Static UI data
  static final _checkups = [
    {
      'id': 'med_001',
      'studentName': 'Emma Wilson',
      'date': DateTime.now().subtract(const Duration(days: 30)),
      'type': 'Checkup',
      'description': 'Regular health checkup - All normal',
      'doctor': 'Dr. Smith',
      'prescription': 'No medication required',
    },
    {
      'id': 'med_002',
      'studentName': 'Liam Johnson',
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'type': 'Checkup',
      'description': 'Annual physical examination',
      'doctor': 'Dr. Johnson',
      'prescription': null,
    },
  ];

  static final _treatments = [
    {
      'id': 'med_003',
      'studentName': 'Olivia Davis',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'type': 'Treatment',
      'description': 'Asthma management consultation',
      'doctor': 'Dr. Brown',
      'prescription': 'Inhaler as needed',
    },
  ];

  static final _emergencies = [
    {
      'id': 'med_004',
      'studentName': 'Noah Martinez',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'type': 'Emergency',
      'description': 'Allergic reaction - treated with antihistamine',
      'doctor': 'Dr. Wilson',
      'prescription': 'Antihistamine tablets',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AdminPageHeader(
        subtitle: 'Clinic health overview',
        icon: Icons.health_and_safety,
        showBreadcrumb: true,
        breadcrumbLabel: 'Medical',
          showBackButton: true,
          title: const Text('Medical Records'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Checkups'),
              Tab(text: 'Treatments'),
              Tab(text: 'Emergencies'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRecordsList(context, _checkups, Colors.blue),
            _buildRecordsList(context, _treatments, Colors.orange),
            _buildRecordsList(context, _emergencies, Colors.red),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.toNamed(AppRoutes.addMedicalRecord);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildRecordsList(
      BuildContext context, List<Map<String, dynamic>> records, Color color) {
    if (records.isEmpty) {
      return EmptyState(
        icon: Icons.medical_services_outlined,
        title: 'No records found',
        message: 'There are no medical records in this category',
      );
    }

    return ResponsivePadding(
      child: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];

          return InfoCard(
            onTap: () => _showRecordDetails(context, record),
            child: IconLabelTile(
              icon: Icons.medical_services,
              title: record['studentName'],
              subtitle: record['description'],
              iconColor: color,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showRecordDetails(context, record),
            ),
          );
        },
      ),
    );
  }

  void _showRecordDetails(BuildContext context, Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medical Record Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Student', record['studentName']),
              _buildDetailRow('Type', record['type']),
              _buildDetailRow(
                  'Date',
                  DateFormat('MMM dd, yyyy')
                      .format(record['date'] as DateTime)),
              _buildDetailRow('Doctor', record['doctor']),
              _buildDetailRow('Description', record['description']),
              if (record['prescription'] != null)
                _buildDetailRow('Prescription', record['prescription']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
