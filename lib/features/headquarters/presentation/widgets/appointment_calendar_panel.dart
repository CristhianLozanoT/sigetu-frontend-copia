import 'package:flutter/material.dart';

class AppointmentCalendarPanel extends StatelessWidget {
  const AppointmentCalendarPanel({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.onMonthChange,
    required this.onDateSelected,
    required this.isDateSelectable,
  });

  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final ValueChanged<int> onMonthChange;
  final ValueChanged<DateTime> onDateSelected;
  final bool Function(DateTime) isDateSelectable;

  static const List<String> _monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<DateTime?> _buildCalendarDays() {
    final firstDay = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final daysInMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    final offset = (firstDay.weekday + 6) % 7;

    final cells = <DateTime?>[];
    for (var i = 0; i < offset; i++) {
      cells.add(null);
    }

    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(DateTime(displayedMonth.year, displayedMonth.month, day));
    }

    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final calendarDays = _buildCalendarDays();
    final weekLabels = const ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final monthTitle = '${_monthNames[displayedMonth.month - 1]} ${displayedMonth.year}';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => onMonthChange(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      monthTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onMonthChange(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: weekLabels
                  .map(
                    (label) => Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: calendarDays.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final date = calendarDays[index];

                if (date == null) {
                  return const SizedBox.shrink();
                }

                final isSelected = selectedDate != null && _isSameDate(selectedDate!, date);
                final isEnabled = isDateSelectable(date);

                final bgColor = isSelected
                    ? scheme.primary
                    : scheme.surfaceContainerHighest.withValues(alpha: 0.45);
                final textColor = isSelected
                    ? scheme.onPrimary
                    : isEnabled
                        ? scheme.onSurface
                        : scheme.onSurface.withValues(alpha: 0.35);

                return InkWell(
                  onTap: isEnabled ? () => onDateSelected(date) : null,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
