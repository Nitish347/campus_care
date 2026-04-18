import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/controllers/lunch_controller.dart';
import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';

class AdminLunchManagementScreen extends StatelessWidget {
  const AdminLunchManagementScreen({super.key});
  static const double _kFilterFieldHeight = 52;
  static const double _kControlChipHeight = 40;

  @override
  Widget build(BuildContext context) {
    final LunchController controller = Get.put(LunchController());
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isSmallMobile = size.width < 390;

    return Scaffold(
      appBar: AdminPageHeader(
        subtitle: 'Manage cafeteria meal plans',
        icon: Icons.restaurant,
        showBreadcrumb: true,
        breadcrumbLabel: 'Lunch',
        showBackButton: true,
        title: const Text('Lunch Management'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: isDesktop ? 14 : 10,
                vertical: isDesktop ? 12 : 8,
              ),
              padding:
                  EdgeInsets.all(isDesktop ? 14 : (isSmallMobile ? 10 : 12)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surfaceContainerLow
                        .withValues(alpha: 0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClassSectionDropDown(
                            onChangedClass: (value) =>
                                controller.selectClass(value),
                            onChangedSection: (value) =>
                                controller.selectSection(value),
                            padding: 0,
                            fieldHeight: _kFilterFieldHeight,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Obx(() =>
                              _buildDatePicker(context, theme, controller)),
                        ),
                        const SizedBox(width: 10),
                        Obx(
                          () => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 132,
                                child: PrimaryButton(
                                  height: _kFilterFieldHeight,
                                  onPressed: controller.selectedClass != null &&
                                          controller.selectedSection != null
                                      ? controller.loadStudentsAndLunch
                                      : null,
                                  child: controller.isLoading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Load'),
                                ),
                              ),
                              if (controller.isEditMode &&
                                  controller.students.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 112,
                                  child: PrimaryButton(
                                    height: _kFilterFieldHeight,
                                    onPressed: controller.saveLunch,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.save_rounded,
                                            color: Colors.white, size: 17),
                                        SizedBox(width: 6),
                                        Text('Save',
                                            style: TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClassSectionDropDown(
                          onChangedClass: (value) =>
                              controller.selectClass(value),
                          onChangedSection: (value) =>
                              controller.selectSection(value),
                          padding: 0,
                          fieldHeight: _kFilterFieldHeight,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Obx(() =>
                                  _buildDatePicker(context, theme, controller)),
                            ),
                            const SizedBox(width: 8),
                            Obx(
                              () => Expanded(
                                flex: controller.isEditMode ? 2 : 1,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: PrimaryButton(
                                        height: _kFilterFieldHeight,
                                        onPressed: controller.selectedClass !=
                                                    null &&
                                                controller.selectedSection !=
                                                    null
                                            ? controller.loadStudentsAndLunch
                                            : null,
                                        child: controller.isLoading
                                            ? const SizedBox(
                                                height: 18,
                                                width: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text('Load', maxLines: 1),
                                      ),
                                    ),
                                    if (controller.isEditMode &&
                                        controller.students.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: PrimaryButton(
                                          height: _kFilterFieldHeight,
                                          onPressed: controller.saveLunch,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.save_rounded,
                                                  color: Colors.white,
                                                  size: 16),
                                              SizedBox(width: 4),
                                              Flexible(
                                                child:
                                                    Text('Save', maxLines: 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  // Toggles and Search when Students are Loaded
                  Obx(() {
                    if (controller.students.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        Divider(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.28),
                          height: 1,
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          fieldHeight: _kFilterFieldHeight,
                          hintText: 'Search by name or roll number...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          onChanged: controller.setSearchQuery,
                        ),
                        const SizedBox(height: 10),
                        isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        _buildModeToggle(controller),
                                        _buildViewTypeToggle(controller),
                                        if (controller.isEditMode)
                                          _buildBulkActions(theme, controller),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Wrap(
                                    alignment: WrapAlignment.end,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildMiniStat(
                                        theme,
                                        Icons.people_outline,
                                        '${controller.totalStudents}',
                                        'Total',
                                        theme.colorScheme.primary,
                                      ),
                                      _buildMiniStat(
                                        theme,
                                        Icons.restaurant,
                                        '${controller.fullMealCount}',
                                        'Full',
                                        Colors.green,
                                      ),
                                      _buildMiniStat(
                                        theme,
                                        Icons.lunch_dining,
                                        '${controller.halfMealCount}',
                                        'Half',
                                        Colors.orange,
                                      ),
                                      _buildMiniStat(
                                        theme,
                                        Icons.percent,
                                        '${controller.lunchPercentage}%',
                                        'Rate',
                                        controller.lunchPercentage >= 75
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildModeToggle(controller,
                                          compactLabels: true),
                                      _buildViewTypeToggle(controller,
                                          compactLabels: true),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final itemWidth =
                                          (constraints.maxWidth - 8) / 2;
                                      return Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          SizedBox(
                                            width: itemWidth,
                                            child: _buildMiniStat(
                                              theme,
                                              Icons.people_outline,
                                              '${controller.totalStudents}',
                                              'Total',
                                              theme.colorScheme.primary,
                                            ),
                                          ),
                                          SizedBox(
                                            width: itemWidth,
                                            child: _buildMiniStat(
                                              theme,
                                              Icons.restaurant,
                                              '${controller.fullMealCount}',
                                              'Full',
                                              Colors.green,
                                            ),
                                          ),
                                          SizedBox(
                                            width: itemWidth,
                                            child: _buildMiniStat(
                                              theme,
                                              Icons.lunch_dining,
                                              '${controller.halfMealCount}',
                                              'Half',
                                              Colors.orange,
                                            ),
                                          ),
                                          SizedBox(
                                            width: itemWidth,
                                            child: _buildMiniStat(
                                              theme,
                                              Icons.percent,
                                              '${controller.lunchPercentage}%',
                                              'Rate',
                                              controller.lunchPercentage >= 75
                                                  ? Colors.green
                                                  : Colors.orange,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  if (controller.isEditMode) ...[
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildBulkActionButton(
                                            theme,
                                            'All Full',
                                            Icons.restaurant,
                                            Colors.green,
                                            controller.markAllFullMeal,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildBulkActionButton(
                                            theme,
                                            'None',
                                            Icons.block,
                                            Colors.red,
                                            controller.markAllNotTaken,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            // Student List or Table View
            Obx(() {
              if (controller.students.isEmpty && !controller.isLoading) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No students loaded',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select class, section, and date\nthen click "Load Students"',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.students.isNotEmpty &&
                  controller.filteredStudents.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64),
                    child: Text(
                      'No students matched your search.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              final isTableView = controller.isTableView;
              final isEditMode = controller.isEditMode;

              return isTableView && isDesktop
                  ? _buildDesktopTable(context, theme, controller, isEditMode)
                  : _buildMobileCards(context, theme, controller, isEditMode);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
      BuildContext context, ThemeData theme, LunchController controller) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: controller.selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          controller.selectDate(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: _kFilterFieldHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded,
                color: theme.colorScheme.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lunch Date',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    DateFormat('MMM dd, yyyy').format(controller.selectedDate),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCards(BuildContext context, ThemeData theme,
      LunchController controller, bool isEditMode) {
    return ResponsivePadding(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredStudents.length,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        itemBuilder: (context, index) {
          final student = controller.filteredStudents[index];
          return Obx(() {
            final status =
                controller.lunchMap[student.id] ?? LunchStatus.notTaken;

            return Card(
              elevation: 3,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.surface,
                      theme.colorScheme.surfaceContainerLow
                          .withValues(alpha: 0.55),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.025),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      color: _getStatusColor(status).withValues(alpha: 0.75),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: _getStatusColor(status)
                                      .withValues(alpha: 0.12),
                                  child: Icon(
                                    _getStatusIcon(status),
                                    color: _getStatusColor(status),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Roll No: ${student.rollNumber}',
                                        style:
                                            theme.textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: theme.colorScheme.primary,
                                          letterSpacing: 0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        student.fullName,
                                        style:
                                            theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          height: 1.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (isEditMode) ...[
                              SizedBox(
                                width: double.infinity,
                                child: _buildLunchStatusButtons(
                                  theme: theme,
                                  selectedStatus: status,
                                  onSelected: (newStatus) {
                                    controller.toggleStudentLunch(
                                        student.id, newStatus);
                                  },
                                ),
                              ),
                            ] else ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getStatusIcon(status),
                                      size: 14,
                                      color: _getStatusColor(status),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getStatusLabel(status),
                                      style: TextStyle(
                                        color: _getStatusColor(status),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, ThemeData theme,
      LunchController controller, bool isEditMode) {
    final viewportWidth = MediaQuery.of(context).size.width;
    final tableWidth = viewportWidth > 800 ? viewportWidth - 24 : 800.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          constraints: BoxConstraints(
            minWidth: tableWidth,
            maxWidth: tableWidth,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.08),
                        theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.04),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      _TableHeaderCell('Roll No', flex: 1),
                      _TableHeaderCell('Student Details', flex: 3),
                      _TableHeaderCell('Lunch Status', flex: 3),
                      _TableHeaderCell('Actions',
                          flex: 1, align: TextAlign.center),
                    ],
                  ),
                ),
                ...controller.filteredStudents.asMap().entries.map((entry) {
                  final index = entry.key;
                  final student = entry.value;
                  final isEven = index % 2 == 0;
                  return Obx(() {
                    final status =
                        controller.lunchMap[student.id] ?? LunchStatus.notTaken;

                    return Container(
                      decoration: BoxDecoration(
                        color: isEven
                            ? Colors.transparent
                            : theme.colorScheme.surfaceContainerLowest
                                .withValues(alpha: 0.42),
                        border: Border(
                          top: BorderSide(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              student.rollNumber.isNotEmpty
                                  ? student.rollNumber
                                  : '-',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: theme
                                      .colorScheme.primaryContainer
                                      .withValues(alpha: 0.5),
                                  child: Text(
                                    student.fullName
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.fullName,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        student.enrollmentNumber,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (isEditMode) ...[
                                  SegmentedButton<LunchStatus>(
                                    segments: LunchStatus.values
                                        .map((s) => ButtonSegment<LunchStatus>(
                                              value: s,
                                              label: Text(
                                                _getStatusLabel(s),
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    selected: {status},
                                    onSelectionChanged:
                                        (Set<LunchStatus> newSelection) {
                                      controller.toggleStudentLunch(
                                          student.id, newSelection.first);
                                    },
                                    style: SegmentedButton.styleFrom(
                                      visualDensity: const VisualDensity(
                                          horizontal: -2, vertical: -2),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      side: BorderSide(
                                        color: theme.colorScheme.outline
                                            .withValues(alpha: 0.25),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 6),
                                    ).copyWith(
                                      backgroundColor: WidgetStateProperty
                                          .resolveWith<Color>((states) {
                                        if (states
                                            .contains(WidgetState.selected)) {
                                          return _getStatusColor(status)
                                              .withValues(alpha: 0.15);
                                        }
                                        return Colors.transparent;
                                      }),
                                    ),
                                    showSelectedIcon: false,
                                  ),
                                ] else ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getStatusIcon(status),
                                          size: 14,
                                          color: _getStatusColor(status),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _getStatusLabel(status),
                                          style: TextStyle(
                                            color: _getStatusColor(status),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints.tightFor(
                                      width: 30, height: 30),
                                  icon: const Icon(Icons.history, size: 18),
                                  onPressed: () {},
                                  tooltip: 'View History',
                                  style: IconButton.styleFrom(
                                    foregroundColor: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle(LunchController controller,
      {bool compactLabels = false}) {
    final theme = Get.theme;
    final isEditMode = controller.isEditMode;
    return _buildSwitchPill(
      theme: theme,
      compact: compactLabels,
      icon: isEditMode ? Icons.edit_rounded : Icons.visibility_rounded,
      label: compactLabels ? 'Edit' : 'Edit Mode',
      value: isEditMode,
      activeText: 'On',
      inactiveText: 'Off',
      onChanged: (_) => controller.toggleEditMode(),
      accent: theme.colorScheme.primary,
    );
  }

  Widget _buildViewTypeToggle(LunchController controller,
      {bool compactLabels = false}) {
    final theme = Get.theme;
    final isCardView = !controller.isTableView;
    return _buildSwitchPill(
      theme: theme,
      compact: compactLabels,
      icon: isCardView ? Icons.view_agenda_rounded : Icons.table_rows_rounded,
      label: compactLabels ? 'Cards' : 'Card View',
      value: isCardView,
      activeText: 'Card',
      inactiveText: 'Table',
      onChanged: (cardEnabled) {
        if (cardEnabled == controller.isTableView) {
          controller.toggleViewMode();
        }
      },
      accent: theme.colorScheme.tertiary,
    );
  }

  Widget _buildSwitchPill({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required bool value,
    required String activeText,
    required String inactiveText,
    required ValueChanged<bool> onChanged,
    required Color accent,
    bool compact = false,
  }) {
    final textColor = value ? accent : theme.colorScheme.onSurfaceVariant;
    return Container(
      height: _kControlChipHeight,
      padding: EdgeInsets.only(left: compact ? 8 : 10, right: compact ? 4 : 6),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: value
              ? accent.withValues(alpha: 0.45)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 15 : 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value ? activeText : inactiveText,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor.withValues(alpha: 0.85),
            ),
          ),
          Transform.scale(
            scale: compact ? 0.75 : 0.82,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: accent,
              activeTrackColor: accent.withValues(alpha: 0.35),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
      ThemeData theme, IconData icon, String value, String label, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 12, color: color),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActions(ThemeData theme, LunchController controller) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBulkActionButton(
          theme,
          'All Full',
          Icons.restaurant,
          Colors.green,
          controller.markAllFullMeal,
        ),
        const SizedBox(width: 8),
        _buildBulkActionButton(
          theme,
          'None',
          Icons.block,
          Colors.red,
          controller.markAllNotTaken,
        ),
      ],
    );
  }

  Widget _buildBulkActionButton(
    ThemeData theme,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        minimumSize: const Size(0, _kControlChipHeight),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildLunchStatusButtons({
    required ThemeData theme,
    required LunchStatus selectedStatus,
    required ValueChanged<LunchStatus> onSelected,
  }) {
    Widget buildButton(LunchStatus status) {
      final color = _getStatusColor(status);
      final selected = selectedStatus == status;
      return Expanded(
        child: OutlinedButton(
          onPressed: () => onSelected(status),
          style: OutlinedButton.styleFrom(
            foregroundColor:
                selected ? color : theme.colorScheme.onSurfaceVariant,
            backgroundColor: selected
                ? color.withValues(alpha: 0.16)
                : theme.colorScheme.surface,
            side: BorderSide(
              color: selected
                  ? color.withValues(alpha: 0.6)
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: const Size(0, 45),
            // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getStatusIcon(status), size: 14),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  _getStatusLabel(status),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            buildButton(LunchStatus.fullMeal),
            const SizedBox(width: 6),
            buildButton(LunchStatus.halfMeal),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            buildButton(LunchStatus.notTaken),
            const SizedBox(width: 6),
            buildButton(LunchStatus.absent),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(LunchStatus status) {
    switch (status) {
      case LunchStatus.fullMeal:
        return Colors.green;
      case LunchStatus.halfMeal:
        return Colors.orange;
      case LunchStatus.notTaken:
        return Colors.grey;
      case LunchStatus.absent:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(LunchStatus status) {
    switch (status) {
      case LunchStatus.fullMeal:
        return Icons.restaurant;
      case LunchStatus.halfMeal:
        return Icons.lunch_dining;
      case LunchStatus.notTaken:
        return Icons.no_meals;
      case LunchStatus.absent:
        return Icons.person_off;
    }
  }

  String _getStatusLabel(LunchStatus status) {
    switch (status) {
      case LunchStatus.fullMeal:
        return 'Full';
      case LunchStatus.halfMeal:
        return 'Half';
      case LunchStatus.notTaken:
        return 'None';
      case LunchStatus.absent:
        return 'Absent';
    }
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String title;
  final int flex;
  final TextAlign? align;

  const _TableHeaderCell(this.title, {required this.flex, this.align});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Text(
        title.toUpperCase(),
        textAlign: align ?? TextAlign.left,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          letterSpacing: 0.35,
          fontSize: 11.5,
        ),
      ),
    );
  }
}
