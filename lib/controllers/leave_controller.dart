import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeaveController extends GetxController {
  final leaves = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLeaves();
  }

  void _loadLeaves() {
    // Static UI data
    leaves.value = [
      {
        'id': 'leave_001',
        'type': 'Sick Leave',
        'fromDate': DateTime.now().subtract(const Duration(days: 30)),
        'toDate': DateTime.now().subtract(const Duration(days: 28)),
        'reason': 'Fever and cold',
        'status': 'approved',
        'appliedDate': DateTime.now().subtract(const Duration(days: 32)),
      },
      {
        'id': 'leave_002',
        'type': 'Casual Leave',
        'fromDate': DateTime.now().subtract(const Duration(days: 15)),
        'toDate': DateTime.now().subtract(const Duration(days: 14)),
        'reason': 'Personal work',
        'status': 'approved',
        'appliedDate': DateTime.now().subtract(const Duration(days: 17)),
      },
      {
        'id': 'leave_003',
        'type': 'Earned Leave',
        'fromDate': DateTime.now().add(const Duration(days: 5)),
        'toDate': DateTime.now().add(const Duration(days: 7)),
        'reason': 'Family vacation',
        'status': 'pending',
        'appliedDate': DateTime.now().subtract(const Duration(days: 2)),
      },
    ];
  }

  String getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return 'green';
      case 'rejected':
        return 'red';
      default:
        return 'orange';
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}

