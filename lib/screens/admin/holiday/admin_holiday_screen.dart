import 'package:campus_care/controllers/holiday_controller.dart';
import 'package:campus_care/models/holiday_model.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminHolidayScreen extends StatelessWidget {
  const AdminHolidayScreen({super.key});

  static const _types = ['National', 'Religious', 'School', 'Exam', 'Other'];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HolidayController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AdminPageHeader(
        title: const Text('Holidays'),
        subtitle: 'Manage annual school holidays',
        icon: Icons.event_busy_rounded,
        showBreadcrumb: true,
        breadcrumbLabel: 'Holidays',
        showBackButton: true,
        actions: [
          HeaderActionButton(
            icon: Icons.add_rounded,
            label: 'Holiday',
            tooltip: 'Add holiday',
            onPressed: () => _showHolidayForm(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        final holidays = controller.holidays;
        final selectedMonth =
            DateTime(controller.selectedYear, controller.selectedMonth);
        final monthHolidays = holidays
            .where((holiday) =>
                holiday.date.year == selectedMonth.year &&
                holiday.date.month == selectedMonth.month)
            .toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'Previous month',
                          onPressed: controller.previousMonth,
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMMM yyyy').format(selectedMonth),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${monthHolidays.length} holiday${monthHolidays.length == 1 ? '' : 's'} marked',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _showHolidayForm(
                            context,
                            controller,
                            initialDate: selectedMonth,
                          ),
                          icon: const Icon(Icons.date_range_rounded, size: 18),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (controller.errorMessage != null)
              _errorBanner(theme, controller.errorMessage!, controller),
            Expanded(
              child: controller.isLoading && holidays.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: controller.loadHolidays,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1180),
                              child: _calendarCard(
                                context,
                                theme,
                                controller,
                                selectedMonth,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1180),
                              child: monthHolidays.isEmpty
                                  ? _emptyState(theme)
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          'Holidays this month',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ...monthHolidays.map(
                                          (holiday) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: _holidayTile(
                                              context,
                                              theme,
                                              controller,
                                              holiday,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _errorBanner(
    ThemeData theme,
    String message,
    HolidayController controller,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
          IconButton(
            tooltip: 'Retry',
            onPressed: controller.loadHolidays,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  Widget _calendarCard(
    BuildContext context,
    ThemeData theme,
    HolidayController controller,
    DateTime month,
  ) {
    final width = MediaQuery.of(context).size.width.clamp(320.0, 1180.0);
    final dayCellAspectRatio = width >= 1000
        ? 2.05
        : width >= 720
            ? 1.55
            : 1.0;
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final leadingEmptyCells = firstDay.weekday % 7;
    final totalCells = leadingEmptyCells + lastDay.day;
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 2.2,
            ),
            itemCount: weekDays.length,
            itemBuilder: (_, index) => Center(
              child: Text(
                weekDays[index],
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: dayCellAspectRatio,
            ),
            itemCount: totalCells,
            itemBuilder: (_, index) {
              if (index < leadingEmptyCells) return const SizedBox.shrink();
              final day = index - leadingEmptyCells + 1;
              final date = DateTime(month.year, month.month, day);
              final holiday = controller.holidayForDate(date);
              final today = DateTime.now();
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final color = holiday == null
                  ? theme.colorScheme.outline
                  : theme.colorScheme.primary;

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showHolidayForm(
                  context,
                  controller,
                  existing: holiday,
                  initialDate: date,
                ),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: holiday == null
                        ? theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.35)
                        : theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isToday
                          ? theme.colorScheme.primary
                          : color.withValues(
                              alpha: holiday == null ? 0.16 : 0.42),
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$day',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: isToday
                                    ? theme.colorScheme.onPrimary
                                    : holiday == null
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            holiday == null
                                ? Icons.add_circle_outline_rounded
                                : Icons.event_busy_rounded,
                            size: 15,
                            color: holiday == null
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (holiday == null)
                        Text(
                          'Add holiday',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            holiday.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded,
                size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              'No holidays added',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Add yearly holidays so attendance and lunch skip those dates.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _holidayTile(
    BuildContext context,
    ThemeData theme,
    HolidayController controller,
    HolidayModel holiday,
  ) {
    final dateText = DateFormat('EEE, MMM d, yyyy').format(holiday.date);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          child:
              Icon(Icons.event_busy_rounded, color: theme.colorScheme.primary),
        ),
        title: Text(
          holiday.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${holiday.type} - $dateText',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              tooltip: 'Edit',
              onPressed: () =>
                  _showHolidayForm(context, controller, existing: holiday),
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: () => _confirmDelete(context, controller, holiday),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHolidayForm(
    BuildContext context,
    HolidayController controller, {
    HolidayModel? existing,
    DateTime? initialDate,
  }) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');
    final selectedDate =
        Rx<DateTime>(existing?.date ?? initialDate ?? DateTime.now());
    final selectedRange = Rxn<DateTimeRange>();
    final isRangeMode = false.obs;
    final selectedType = RxString(existing?.type ?? 'School');
    final isActive = RxBool(existing?.isActive ?? true);
    final formError = RxnString();

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(existing == null ? 'Add Holiday' : 'Edit Holiday'),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (existing == null)
                  Obx(
                    () => SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.event_rounded),
                          label: Text('Single Day'),
                        ),
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.date_range_rounded),
                          label: Text('Date Range'),
                        ),
                      ],
                      selected: {isRangeMode.value},
                      onSelectionChanged: (values) {
                        isRangeMode.value = values.first;
                        formError.value = null;
                      },
                    ),
                  ),
                if (existing == null) const SizedBox(height: 14),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Holiday name',
                    prefixIcon: Icon(Icons.badge_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => _datePickerTile(
                    context: context,
                    theme: Theme.of(context),
                    isRange: existing == null && isRangeMode.value,
                    selectedDate: selectedDate.value,
                    selectedRange: selectedRange.value,
                    onTap: () async {
                      formError.value = null;
                      if (existing == null && isRangeMode.value) {
                        final picked = await _showCompactRangePicker(
                          context: context,
                          initialRange: selectedRange.value,
                          fallbackDate: selectedDate.value,
                        );
                        if (picked != null) {
                          selectedRange.value = picked;
                          selectedDate.value = picked.start;
                        }
                        return;
                      }

                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate.value,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) selectedDate.value = picked;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue: selectedType.value,
                    decoration: const InputDecoration(
                      labelText: 'Holiday type',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    items: _types
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) selectedType.value = value;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                Obx(
                  () => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isActive.value,
                    title: const Text('Active'),
                    onChanged: (value) => isActive.value = value,
                  ),
                ),
                Obx(
                  () => formError.value == null
                      ? const SizedBox.shrink()
                      : Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .errorContainer
                                .withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            formError.value!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Builder(
            builder: (dialogContext) => TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ),
          Builder(
            builder: (dialogContext) => FilledButton.icon(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  formError.value = 'Holiday name is required.';
                  return;
                }
                if (existing == null &&
                    isRangeMode.value &&
                    selectedRange.value == null) {
                  formError.value = 'Select a start and end date.';
                  return;
                }

                Navigator.of(dialogContext).pop();
                if (existing == null && isRangeMode.value) {
                  final range = selectedRange.value!;
                  controller.saveHolidayRange(
                    name: name,
                    startDate: range.start,
                    endDate: range.end,
                    type: selectedType.value,
                    description: descriptionController.text,
                    isActive: isActive.value,
                  );
                  return;
                }

                controller.saveHoliday(
                  existing: existing,
                  name: name,
                  date: selectedDate.value,
                  type: selectedType.value,
                  description: descriptionController.text,
                  isActive: isActive.value,
                );
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePickerTile({
    required BuildContext context,
    required ThemeData theme,
    required bool isRange,
    required DateTime selectedDate,
    required DateTimeRange? selectedRange,
    required VoidCallback onTap,
  }) {
    final title = isRange ? 'Date range' : 'Date';
    final value = isRange
        ? selectedRange == null
            ? 'Select start and end date'
            : '${DateFormat('MMM d, yyyy').format(selectedRange.start)} - ${DateFormat('MMM d, yyyy').format(selectedRange.end)}'
        : DateFormat('EEE, MMM d, yyyy').format(selectedDate);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                isRange
                    ? Icons.date_range_rounded
                    : Icons.calendar_today_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_calendar_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTimeRange?> _showCompactRangePicker({
    required BuildContext context,
    DateTimeRange? initialRange,
    required DateTime fallbackDate,
  }) {
    final theme = Theme.of(context);
    final visibleMonth = Rx<DateTime>(
      DateTime(
        initialRange?.start.year ?? fallbackDate.year,
        initialRange?.start.month ?? fallbackDate.month,
      ),
    );
    final startDate = Rxn<DateTime>(initialRange?.start);
    final endDate = Rxn<DateTime>(initialRange?.end);
    final error = RxnString();

    DateTime dayOnly(DateTime date) =>
        DateTime(date.year, date.month, date.day);

    void selectDate(DateTime date) {
      final selected = dayOnly(date);
      error.value = null;
      if (startDate.value == null ||
          (startDate.value != null && endDate.value != null)) {
        startDate.value = selected;
        endDate.value = null;
        return;
      }
      if (selected.isBefore(startDate.value!)) {
        endDate.value = startDate.value;
        startDate.value = selected;
      } else {
        endDate.value = selected;
      }
    }

    return showDialog<DateTimeRange>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
          contentPadding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
          actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          title: Row(
            children: [
              Icon(Icons.date_range_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Select Date Range',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 390,
            child: Obx(() {
              final month = visibleMonth.value;
              final firstDay = DateTime(month.year, month.month, 1);
              final lastDay = DateTime(month.year, month.month + 1, 0);
              final leading = firstDay.weekday % 7;
              final totalCells = 42;
              final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
              final start = startDate.value;
              final end = endDate.value;

              bool isSame(DateTime a, DateTime b) =>
                  a.year == b.year && a.month == b.month && a.day == b.day;
              bool inRange(DateTime date) =>
                  start != null &&
                  end != null &&
                  !date.isBefore(start) &&
                  !date.isAfter(end);

              final rangeLabel = start == null
                  ? 'Tap a start date'
                  : end == null
                      ? '${DateFormat('MMM d, yyyy').format(start)} - choose end date'
                      : '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            rangeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (start != null)
                          IconButton(
                            tooltip: 'Clear',
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              startDate.value = null;
                              endDate.value = null;
                              error.value = null;
                            },
                            icon: const Icon(Icons.close_rounded, size: 18),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Previous month',
                        onPressed: () {
                          visibleMonth.value =
                              DateTime(month.year, month.month - 1);
                        },
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            DateFormat('MMMM yyyy').format(month),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Next month',
                        onPressed: () {
                          visibleMonth.value =
                              DateTime(month.year, month.month + 1);
                        },
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1.55,
                    ),
                    itemCount: weekDays.length,
                    itemBuilder: (_, index) => Center(
                      child: Text(
                        weekDays[index],
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: totalCells,
                    itemBuilder: (_, index) {
                      final day = index - leading + 1;
                      final isInMonth = day >= 1 && day <= lastDay.day;
                      if (!isInMonth) return const SizedBox.shrink();

                      final date = DateTime(month.year, month.month, day);
                      final isStart = start != null && isSame(date, start);
                      final isEnd = end != null && isSame(date, end);
                      final selected = isStart || isEnd;
                      final ranged = inRange(date);

                      return Material(
                        color: selected
                            ? theme.colorScheme.primary
                            : ranged
                                ? theme.colorScheme.primary
                                    .withValues(alpha: 0.14)
                                : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => selectDate(date),
                          child: Center(
                            child: Text(
                              '$day',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: selected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Obx(
                    () => error.value == null
                        ? const SizedBox(height: 8)
                        : Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              error.value!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                ],
              );
            }),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                if (startDate.value == null || endDate.value == null) {
                  error.value = 'Select both start and end date.';
                  return;
                }
                Navigator.of(dialogContext).pop(
                  DateTimeRange(
                    start: dayOnly(startDate.value!),
                    end: dayOnly(endDate.value!),
                  ),
                );
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HolidayController controller,
    HolidayModel holiday,
  ) async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Delete Holiday'),
        content: Text('Delete ${holiday.name}?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.deleteHoliday(holiday);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
