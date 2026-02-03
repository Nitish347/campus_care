// import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:campus_care/widgets/common/info_card.dart';
// import 'package:campus_care/widgets/common/empty_state.dart';
// import 'package:campus_care/widgets/common/summary_card.dart';
// import 'package:campus_care/widgets/responsive/responsive_padding.dart';
// import 'package:campus_care/controllers/attendance_controller.dart';
// import 'package:campus_care/controllers/class_controller.dart';
// import 'package:campus_care/models/student/student.dart';
//
// class TeacherAttendanceScreen extends StatefulWidget {
//   const TeacherAttendanceScreen({super.key});
//
//   @override
//   State<TeacherAttendanceScreen> createState() =>
//       _TeacherAttendanceScreenState();
// }
//
// class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen>
//     with SingleTickerProviderStateMixin {
//   final AttendanceController _controller = Get.put(AttendanceController());
//   final ClassController _classController = Get.put(ClassController());
//   late TabController _tabController;
//
//   // Mode: true = Mark Mode, false = View Mode
//   bool _isMarkMode = true;
//   String _selectedFilter = 'All';
//   final List<String> _filters = ['All', 'Present', 'Absent'];
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _classController.fetchClasses();
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _controller.selectedDate,
//       firstDate: DateTime.now().subtract(const Duration(days: 365)),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       _controller.selectDate(picked);
//       // Reload students and attendance
//       if (_controller.selectedClass != null &&
//           _controller.selectedSection != null) {
//         await _controller.loadStudentsAndAttendance();
//       }
//     }
//   }
//
//   Future<void> _saveAttendance() async {
//     if (!_isMarkMode) return;
//
//     if (_controller.selectedClass == null ||
//         _controller.selectedSection == null) {
//       Get.snackbar('Error', 'Please select class and section');
//       return;
//     }
//
//     if (_controller.students.isEmpty) {
//       Get.snackbar('Error', 'No students found');
//       return;
//     }
//
//     await _controller.saveAttendance();
//   }
//
//   void _previousMonth() {
//     final newDate = DateTime(
//       _controller.selectedDate.year,
//       _controller.selectedDate.month - 1,
//     );
//     _controller.selectDate(newDate);
//     if (_controller.selectedClass != null &&
//         _controller.selectedSection != null) {
//       _controller.loadStudentsAndAttendance();
//     }
//   }
//
//   void _nextMonth() {
//     final newDate = DateTime(
//       _controller.selectedDate.year,
//       _controller.selectedDate.month + 1,
//     );
//     _controller.selectDate(newDate);
//     if (_controller.selectedClass != null &&
//         _controller.selectedSection != null) {
//       _controller.loadStudentsAndAttendance();
//     }
//   }
//
//   List<Map<String, dynamic>> _getAttendanceForMonth() {
//     final month = _controller.selectedDate;
//     final firstDay = DateTime(month.year, month.month, 1);
//     final lastDay = DateTime(month.year, month.month + 1, 0);
//     final daysInMonth = lastDay.day;
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//
//     final firstDayOfWeek = firstDay.weekday % 7;
//     final attendance = <Map<String, dynamic>>[];
//
//     // Add empty cells for days before the first day of the month
//     for (int i = 0; i < firstDayOfWeek; i++) {
//       attendance.add({'date': null, 'status': null});
//     }
//
//     // Add days of the month
//     for (int day = 1; day <= daysInMonth; day++) {
//       final date = DateTime(month.year, month.month, day);
//       final dateOnly = DateTime(date.year, date.month, date.day);
//       final isFuture = dateOnly.isAfter(today);
//
//       // For view mode, we would need to check actual attendance records
//       // For now, using current loaded data
//       String? status;
//       if (!isFuture && _controller.students.isNotEmpty) {
//         // Calculate attendance for this day if loaded
//         final selectedDateOnly = DateTime(
//           _controller.selectedDate.year,
//           _controller.selectedDate.month,
//           _controller.selectedDate.day,
//         );
//         if (dateOnly == selectedDateOnly) {
//           // Use current attendance map
//           final present = _controller.presentCount;
//           final total = _controller.totalStudents;
//           if (total > 0) {
//             status = present == total
//                 ? 'present'
//                 : present == 0
//                     ? 'absent'
//                     : 'partial';
//           }
//         }
//       }
//
//       attendance.add({
//         'date': date,
//         'status': status,
//         'isFuture': isFuture,
//       });
//     }
//
//     return attendance;
//   }
//
//   List<Student> get _filteredStudents {
//     if (_selectedFilter == 'All') {
//       return _controller.students;
//     }
//
//     return _controller.students.where((student) {
//       final status = _controller.attendanceMap[student.id];
//       if (_selectedFilter == 'Present') {
//         return status == AttendanceStatus.present;
//       } else if (_selectedFilter == 'Absent') {
//         return status == AttendanceStatus.absent;
//       }
//       return true;
//     }).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_isMarkMode ? 'Mark Attendance' : 'View Attendance'),
//         actions: [
//           if (!_isMarkMode)
//             IconButton(
//               icon: const Icon(Icons.filter_list_outlined),
//               onPressed: _showFilterDialog,
//               tooltip: 'Filter',
//             ),
//           Obx(() => _controller.isLoading
//               ? const Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   ),
//                 )
//               : IconButton(
//                   icon: const Icon(Icons.save),
//                   onPressed: _isMarkMode ? _saveAttendance : null,
//                   tooltip: _isMarkMode ? 'Save Attendance' : 'View Mode',
//                 )),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(48),
//           child: TabBar(
//             controller: _tabController,
//             tabs: const [
//               Tab(
//                 icon: Icon(Icons.calendar_month),
//                 text: 'Calendar',
//               ),
//               Tab(
//                 icon: Icon(Icons.list),
//                 text: 'List',
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Mode Toggle
//           ResponsivePadding(
//             child: Container(
//               margin: const EdgeInsets.symmetric(vertical: 12),
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.surfaceContainerHighest,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () => setState(() => _isMarkMode = true),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         decoration: BoxDecoration(
//                           color: _isMarkMode
//                               ? theme.colorScheme.primary
//                               : Colors.transparent,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           'Mark Mode',
//                           textAlign: TextAlign.center,
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             color: _isMarkMode
//                                 ? theme.colorScheme.onPrimary
//                                 : theme.colorScheme.onSurfaceVariant,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () => setState(() => _isMarkMode = false),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         decoration: BoxDecoration(
//                           color: !_isMarkMode
//                               ? theme.colorScheme.primary
//                               : Colors.transparent,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           'View Mode',
//                           textAlign: TextAlign.center,
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             color: !_isMarkMode
//                                 ? theme.colorScheme.onPrimary
//                                 : theme.colorScheme.onSurfaceVariant,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Filters
//           ResponsivePadding(
//             child: InfoCard(
//               child: Column(
//                 children: [
//                   ClassSectionDropDown(
//                     onChangedClass: (classId) {
//                       _controller.selectClass(classId);
//                     },
//                     onChangedSection: (section) {
//                       _controller.selectSection(section);
//                       if (_controller.selectedClass != null) {
//                         _controller.loadStudentsAndAttendance();
//                       }
//                     },
//                   ),
//                   if (_isMarkMode) ...[
//                     const SizedBox(height: 12),
//                     Obx(() => GestureDetector(
//                           onTap: () => _selectDate(context),
//                           child: Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               border:
//                                   Border.all(color: theme.colorScheme.outline),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(Icons.calendar_today,
//                                     color: theme.colorScheme.primary),
//                                 const SizedBox(width: 12),
//                                 Text(
//                                   DateFormat('EEEE, MMMM dd, yyyy')
//                                       .format(_controller.selectedDate),
//                                   style: theme.textTheme.bodyLarge,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//
//           // Statistics
//           Obx(() => SummaryCard(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildSummaryItem(
//                       context,
//                       Icons.check_circle_outline,
//                       '${_controller.presentCount}',
//                       'Present',
//                       Colors.green,
//                     ),
//                     Container(
//                       width: 1,
//                       height: 40,
//                       color: theme.colorScheme.outline.withValues(alpha: 0.3),
//                     ),
//                     _buildSummaryItem(
//                       context,
//                       Icons.cancel_outlined,
//                       '${_controller.absentCount}',
//                       'Absent',
//                       Colors.red,
//                     ),
//                     Container(
//                       width: 1,
//                       height: 40,
//                       color: theme.colorScheme.outline.withValues(alpha: 0.3),
//                     ),
//                     _buildSummaryItem(
//                       context,
//                       Icons.people_outline,
//                       '${_controller.totalStudents}',
//                       'Total',
//                       theme.colorScheme.primary,
//                     ),
//                     Container(
//                       width: 1,
//                       height: 40,
//                       color: theme.colorScheme.outline.withValues(alpha: 0.3),
//                     ),
//                     _buildSummaryItem(
//                       context,
//                       Icons.percent,
//                       '${_controller.attendancePercentage}%',
//                       'Rate',
//                       _controller.attendancePercentage >= 75
//                           ? Colors.green
//                           : _controller.attendancePercentage >= 50
//                               ? Colors.orange
//                               : Colors.red,
//                     ),
//                   ],
//                 ),
//               )),
//
//           // Month Selector (for View Mode)
//           if (!_isMarkMode)
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.surface,
//                 boxShadow: [
//                   BoxShadow(
//                     color: theme.colorScheme.shadow.withValues(alpha: 0.1),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     onPressed: _previousMonth,
//                     icon: const Icon(Icons.chevron_left),
//                     tooltip: 'Previous Month',
//                   ),
//                   Obx(() => Text(
//                         DateFormat('MMMM yyyy')
//                             .format(_controller.selectedDate),
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       )),
//                   IconButton(
//                     onPressed: _nextMonth,
//                     icon: const Icon(Icons.chevron_right),
//                     tooltip: 'Next Month',
//                   ),
//                 ],
//               ),
//             ),
//
//           // Bulk Actions (for Mark Mode)
//           if (_isMarkMode)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: _controller.markAllPresent,
//                       icon: const Icon(Icons.check_circle),
//                       label: const Text('Mark All Present'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: _controller.markAllAbsent,
//                       icon: const Icon(Icons.cancel),
//                       label: const Text('Mark All Absent'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//           // TabBarView
//           Expanded(
//             child: Obx(() {
//               if (_controller.isLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               return TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildCalendarView(context),
//                   _buildListView(context),
//                 ],
//               );
//             }),
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
//
//   Widget _buildCalendarView(BuildContext context) {
//     final theme = Theme.of(context);
//     final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final attendance = _getAttendanceForMonth();
//
//     if (_controller.students.isEmpty) {
//       return const EmptyState(
//         icon: Icons.people_outline,
//         title: 'No students found',
//         message: 'Please select a class and section',
//       );
//     }
//
//     return ResponsivePadding(
//       child: Column(
//         children: [
//           const SizedBox(height: 16),
//           // Week day headers
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 7,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//             ),
//             itemCount: 7,
//             itemBuilder: (context, index) {
//               return Center(
//                 child: Text(
//                   weekDays[index],
//                   style: theme.textTheme.labelLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.primary,
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 8),
//           // Calendar days
//           Expanded(
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 7,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//               ),
//               itemCount: attendance.length,
//               itemBuilder: (context, index) {
//                 final att = attendance[index];
//                 final date = att['date'] as DateTime?;
//
//                 if (date == null) {
//                   return const SizedBox.shrink();
//                 }
//
//                 final status = att['status'] as String?;
//                 final isFuture = att['isFuture'] as bool;
//                 final isPresent = status == 'present';
//                 final isAbsent = status == 'absent';
//                 final isPartial = status == 'partial';
//                 final dateOnly = DateTime(date.year, date.month, date.day);
//                 final isToday = dateOnly == today;
//
//                 return InkWell(
//                   onTap: () {
//                     if (_isMarkMode) {
//                       _controller.selectDate(date);
//                       _controller.loadStudentsAndAttendance();
//                     }
//                   },
//                   borderRadius: BorderRadius.circular(12),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: isPresent
//                           ? LinearGradient(
//                               colors: [
//                                 Colors.green.withValues(alpha: 0.2),
//                                 Colors.green.withValues(alpha: 0.1),
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             )
//                           : isAbsent
//                               ? LinearGradient(
//                                   colors: [
//                                     Colors.red.withValues(alpha: 0.2),
//                                     Colors.red.withValues(alpha: 0.1),
//                                   ],
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                 )
//                               : isPartial
//                                   ? LinearGradient(
//                                       colors: [
//                                         Colors.orange.withValues(alpha: 0.2),
//                                         Colors.orange.withValues(alpha: 0.1),
//                                       ],
//                                       begin: Alignment.topLeft,
//                                       end: Alignment.bottomRight,
//                                     )
//                                   : null,
//                       color: isFuture
//                           ? theme.colorScheme.surfaceContainerHighest
//                               .withValues(alpha: 0.3)
//                           : !isPresent && !isAbsent && !isPartial
//                               ? theme.colorScheme.surfaceContainerHighest
//                                   .withValues(alpha: 0.5)
//                               : null,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: isToday
//                             ? theme.colorScheme.primary
//                             : isPresent
//                                 ? Colors.green.withValues(alpha: 0.5)
//                                 : isAbsent
//                                     ? Colors.red.withValues(alpha: 0.5)
//                                     : isPartial
//                                         ? Colors.orange.withValues(alpha: 0.5)
//                                         : theme.colorScheme.outline
//                                             .withValues(alpha: 0.2),
//                         width: isToday ? 3 : 1.5,
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           DateFormat('dd').format(date),
//                           style: theme.textTheme.titleSmall?.copyWith(
//                             fontWeight:
//                                 isToday ? FontWeight.bold : FontWeight.w600,
//                             color: isFuture
//                                 ? theme.colorScheme.onSurfaceVariant
//                                     .withValues(alpha: 0.5)
//                                 : isToday
//                                     ? theme.colorScheme.primary
//                                     : null,
//                           ),
//                         ),
//                         if (isPresent || isAbsent || isPartial) ...[
//                           const SizedBox(height: 4),
//                           Icon(
//                             isPresent
//                                 ? Icons.check_circle
//                                 : isAbsent
//                                     ? Icons.cancel
//                                     : Icons.remove_circle,
//                             size: 18,
//                             color: isPresent
//                                 ? Colors.green
//                                 : isAbsent
//                                     ? Colors.red
//                                     : Colors.orange,
//                           ),
//                         ] else if (isFuture) ...[
//                           const SizedBox(height: 4),
//                           Icon(
//                             Icons.schedule,
//                             size: 16,
//                             color: theme.colorScheme.onSurfaceVariant
//                                 .withValues(alpha: 0.4),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildListView(BuildContext context) {
//     final theme = Theme.of(context);
//     final students = _filteredStudents;
//
//     if (students.isEmpty) {
//       return EmptyState(
//         icon: Icons.people_outline,
//         title: 'No students found',
//         message: _selectedFilter == 'All'
//             ? 'Please select a class and section'
//             : 'No $_selectedFilter students found',
//       );
//     }
//
//     return ResponsivePadding(
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         itemCount: students.length,
//         itemBuilder: (context, index) {
//           final student = students[index];
//           final status =
//               _controller.attendanceMap[student.id] ?? AttendanceStatus.present;
//           final isPresent = status == AttendanceStatus.present;
//
//           return Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             child: Card(
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 side: BorderSide(
//                   color: theme.colorScheme.outlineVariant,
//                   width: 1,
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     // Status Icon
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: isPresent
//                               ? [
//                                   Colors.green.withValues(alpha: 0.2),
//                                   Colors.green.withValues(alpha: 0.1),
//                                 ]
//                               : [
//                                   Colors.red.withValues(alpha: 0.2),
//                                   Colors.red.withValues(alpha: 0.1),
//                                 ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         student.rollNumber.isNotEmpty
//                             ? student.rollNumber
//                             : student.id.substring(0, 3).toUpperCase(),
//                         style: TextStyle(
//                           color: isPresent ? Colors.green : Colors.red,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//
//                     // Student Info
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             student.fullName,
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Roll No: ${student.rollNumber.isNotEmpty ? student.rollNumber : student.id.substring(0, 8)}',
//                             style: theme.textTheme.bodyMedium?.copyWith(
//                               color: theme.colorScheme.onSurfaceVariant,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Status Badge and Toggle
//                     if (_isMarkMode)
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           _buildAttendanceChip(
//                             context,
//                             'P',
//                             status == AttendanceStatus.present,
//                             Colors.green,
//                             () => _controller.toggleStudentAttendance(
//                                 student.id, AttendanceStatus.present),
//                           ),
//                           const SizedBox(width: 8),
//                           _buildAttendanceChip(
//                             context,
//                             'A',
//                             status == AttendanceStatus.absent,
//                             Colors.red,
//                             () => _controller.toggleStudentAttendance(
//                                 student.id, AttendanceStatus.absent),
//                           ),
//                         ],
//                       )
//                     else
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isPresent
//                               ? Colors.green.withValues(alpha: 0.1)
//                               : Colors.red.withValues(alpha: 0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           isPresent ? 'Present' : 'Absent',
//                           style: theme.textTheme.labelMedium?.copyWith(
//                             color: isPresent ? Colors.green : Colors.red,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildAttendanceChip(
//     BuildContext context,
//     String label,
//     bool isSelected,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: isSelected ? color : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: color),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? Colors.white : color,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showFilterDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Filter by Status'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: _filters.map((filter) {
//             return RadioListTile<String>(
//               title: Text(filter),
//               value: filter,
//               groupValue: _selectedFilter,
//               onChanged: (value) {
//                 setState(() {
//                   _selectedFilter = value!;
//                 });
//                 Navigator.pop(context);
//               },
//             );
//           }).toList(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _selectedFilter = 'All';
//               });
//               Navigator.pop(context);
//             },
//             child: const Text('Clear'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }
