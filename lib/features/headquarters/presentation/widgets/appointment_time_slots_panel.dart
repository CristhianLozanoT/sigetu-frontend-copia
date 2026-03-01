import 'package:flutter/material.dart';

class AppointmentTimeSlotsPanel extends StatefulWidget {
  const AppointmentTimeSlotsPanel({
    super.key,
    required this.timeSlots,
    required this.selectedTime,
    required this.isSlotEnabled,
    required this.onSelectSlot,
    required this.formatSlot,
  });

  final List<TimeOfDay> timeSlots;
  final TimeOfDay? selectedTime;
  final bool Function(TimeOfDay) isSlotEnabled;
  final ValueChanged<TimeOfDay> onSelectSlot;
  final String Function(TimeOfDay) formatSlot;

  @override
  State<AppointmentTimeSlotsPanel> createState() =>
      _AppointmentTimeSlotsPanelState();
}

class _AppointmentTimeSlotsPanelState extends State<AppointmentTimeSlotsPanel> {
  static const double _slotItemWidth = 112;
  static const double _slotSpacing = 10;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scheduleScrollToSelected(animated: false);
  }

  @override
  void didUpdateWidget(covariant AppointmentTimeSlotsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    final selectedChanged = oldWidget.selectedTime?.hour != widget.selectedTime?.hour ||
        oldWidget.selectedTime?.minute != widget.selectedTime?.minute;
    final slotsChanged = oldWidget.timeSlots.length != widget.timeSlots.length;

    if (selectedChanged || slotsChanged) {
      _scheduleScrollToSelected(animated: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleScrollToSelected({required bool animated}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(animated: animated);
    });
  }

  void _scrollToSelected({required bool animated}) {
    final selected = widget.selectedTime;
    if (selected == null || !_scrollController.hasClients) {
      return;
    }

    final selectedIndex = widget.timeSlots.indexWhere(
      (slot) => slot.hour == selected.hour && slot.minute == selected.minute,
    );

    if (selectedIndex < 0) return;

    final itemExtent = _slotItemWidth + _slotSpacing;
    final selectedOffset = selectedIndex * itemExtent;
    final viewport = _scrollController.position.viewportDimension;
    final centeredOffset = selectedOffset - ((viewport - _slotItemWidth) / 2);

    final targetOffset = centeredOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    if (animated) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(targetOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget legendDot(Color color) {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Horarios disponibles',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Row(
                  children: [
                    legendDot(scheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Disponible',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 68,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                controller: _scrollController,
                itemCount: widget.timeSlots.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final slot = widget.timeSlots[index];
                  final enabled = widget.isSlotEnabled(slot);
                  final isSelected = widget.selectedTime != null &&
                      widget.selectedTime!.hour == slot.hour &&
                      widget.selectedTime!.minute == slot.minute;

                  final bgColor = isSelected
                      ? scheme.primary
                      : enabled
                          ? scheme.surfaceContainerHighest.withValues(alpha: 0.5)
                          : scheme.surfaceContainerHighest.withValues(alpha: 0.28);

                  final fgColor = isSelected
                      ? scheme.onPrimary
                      : enabled
                          ? scheme.onSurface
                          : scheme.onSurface.withValues(alpha: 0.35);

                  final borderColor = isSelected
                      ? scheme.primary
                      : scheme.outline.withValues(alpha: enabled ? 0.28 : 0.16);

                  return InkWell(
                    onTap: enabled ? () => widget.onSelectSlot(slot) : null,
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: _slotItemWidth,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: borderColor,
                          width: isSelected ? 1.4 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.formatSlot(slot),
                          style: TextStyle(
                            color: fgColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
