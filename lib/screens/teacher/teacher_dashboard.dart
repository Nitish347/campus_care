import 'package:campus_care/screens/admin/admin_dashboard.dart';
import 'package:flutter/widgets.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminDashboard(isTeacherDashboard: true);
  }
}
