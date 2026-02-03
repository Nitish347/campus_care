// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:campus_care/widgets/responsive/responsive_padding.dart';
// import 'package:campus_care/widgets/common/summary_card.dart';
//
// class TeacherAttendanceManagementScreen extends StatefulWidget {
//   const TeacherAttendanceManagementScreen({super.key});
//
//   @override
//   State<TeacherAttendanceManagementScreen> createState() =>
//       _TeacherAttendanceManagementScreenState();
// }
//
// class _TeacherAttendanceManagementScreenState
//     extends State<TeacherAttendanceManagementScreen> {
//   DateTime _selectedDate = DateTime.now();
//   final List<Map<String, dynamic>> _students = [
//     {'id': '1', 'name': 'John Doe', 'rollNo': '101', 'present': true},
//     {'id': '2', 'name': 'Jane Smith', 'rollNo': '102', 'present': true},
//     {'id': '3', 'name': 'Mike Johnson', 'rollNo': '103', 'present': false},
//     {'id': '4', 'name': 'Sarah Williams', 'rollNo': '104', 'present': true},
//     {'id': '5', 'name': 'Tom Brown', 'rollNo': '105', 'present': true},
//   ];
//
//   int get _presentCount => _students.where((s) => s['present'] == true).length;
//   int get _absentCount => _students.where((s) => s['present'] == false).length;
//   int get _attendancePercentage =>
//       (_presentCount / _students.length * 100).round();
//
//   void _toggleAttendance(int index) {
//     setState(() {
//       _students[index]['present'] = !_students[index]['present'];
//     });
//   }
//
//   void _markAllPresent() {
//     setState(() {
//       for (var student in _students) {
//         student['present'] = true;
//       }
//     });
//   }
//
//   void _markAllAbsent() {
//     setState(() {
//       for (var student in _students) {
//         student['present'] = false;
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Mark Attendance'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.history),
//             onPressed: () {
//               // TODO: View attendance history
//             },
//             tooltip: 'History',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Summary Header
//           SummaryCard(
//             padding: 0,
//             child: Column(
//               children: [
//                 Text(
//                   DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildSummaryItem(
//                       context,
//                       Icons.people_outline,
//                       '${_students.length}',
//                       'Total',
//                       theme.colorScheme.primary,
//                     ),
//                     Container(
//                       width: 1,
//                       height: 40,
//                       color: theme.colorScheme.outline.withOpacity(0.3),
//                     ),
//                     _buildSummaryItem(
//                       context,
//                       Icons.check_circle_outline,
//                       '$_presentCount',
//                       'Present',
//                       Colors.green,
//                     ),
//                     Container(
//                       width: 1,
//                       height: 40,
//                       color: theme.colorScheme.outline.withOpacity(0.3),
//                     ),
//                     _buildSummaryItem(
//                       context,
//                       Icons.cancel_outlined,
//                       '$_absentCount',
//                       'Absent',
//                       Colors.red,
//                     ),
//                     Container(
//                       width: 1,
//                       height: 40,
//                       color: theme.colorScheme.outline.withOpacity(0.3),
//                     ),
//                     _buildSummaryItem(
//                       context,
//                       Icons.percent,
//                       '$_attendancePercentage%',
//                       'Rate',
//                       _attendancePercentage >= 75
//                           ? Colors.green
//                           : Colors.orange,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // Bulk Actions
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: _markAllPresent,
//                     icon: const Icon(Icons.check_circle),
//                     label: const Text('Mark All Present'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: _markAllAbsent,
//                     icon: const Icon(Icons.cancel),
//                     label: const Text('Mark All Absent'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Student List
//           Expanded(
//             child: ResponsivePadding(
//               child: ListView.builder(
//                 itemCount: _students.length,
//                 itemBuilder: (context, index) {
//                   final student = _students[index];
//                   final isPresent = student['present'] as bool;
//
//                   return Container(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     child: Card(
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                         side: BorderSide(
//                           color: theme.colorScheme.outlineVariant,
//                           width: 1,
//                         ),
//                       ),
//                       child: ListTile(
//                         contentPadding: const EdgeInsets.all(16),
//                         leading: CircleAvatar(
//                           backgroundColor: isPresent
//                               ? Colors.green.withOpacity(0.1)
//                               : Colors.red.withOpacity(0.1),
//                           child: Text(
//                             student['rollNo'] as String,
//                             style: TextStyle(
//                               color: isPresent ? Colors.green : Colors.red,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         title: Text(
//                           student['name'] as String,
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         subtitle: Text('Roll No: ${student['rollNo']}'),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: isPresent
//                                     ? Colors.green.withOpacity(0.1)
//                                     : Colors.red.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Text(
//                                 isPresent ? 'Present' : 'Absent',
//                                 style: theme.textTheme.labelMedium?.copyWith(
//                                   color: isPresent ? Colors.green : Colors.red,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Switch(
//                               value: isPresent,
//                               onChanged: (_) => _toggleAttendance(index),
//                               activeColor: Colors.green,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//
//           // Save Button
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: SizedBox(
//               width: double.infinity,
//               child: FilledButton.icon(
//                 onPressed: () {
//                   // TODO: Save attendance
//                   Get.snackbar(
//                     'Success',
//                     'Attendance saved successfully',
//                     snackPosition: SnackPosition.BOTTOM,
//                     backgroundColor: Colors.green,
//                     colorText: Colors.white,
//                   );
//                 },
//                 icon: const Icon(Icons.save),
//                 label: const Text('Save Attendance'),
//                 style: FilledButton.styleFrom(
//                   padding: const EdgeInsets.all(16),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryItem(
//     BuildContext context,
//     IconData icon,
//     String value,
//     String label,
//     Color color,
//   ) {
//     final theme = Theme.of(context);
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 24),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: theme.textTheme.bodySmall?.copyWith(
//             color: theme.colorScheme.onSurfaceVariant,
//           ),
//         ),
//       ],
//     );
//   }
// }
