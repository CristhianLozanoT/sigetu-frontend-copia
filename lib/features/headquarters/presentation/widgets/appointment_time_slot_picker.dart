import 'package:flutter/material.dart';
import 'package:sigetu/features/headquarters/presentation/widgets/appointment_picker_button.dart';

class AppointmentTimeSlotPicker extends StatelessWidget {
  const AppointmentTimeSlotPicker({
    super.key,
    required this.selectedTime,
    required this.onChanged,
    this.enabled = true,
    this.startMinutes = 8 * 60,
    this.endMinutes = 17 * 60,
    this.breakStartMinutes = 11 * 60 + 20,
    this.breakEndMinutes = 14 * 60 + 30,
    this.intervalMinutes = 30,
  });

  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay> onChanged;
  final bool enabled;
  final int startMinutes;
  final int endMinutes;
  final int breakStartMinutes;
  final int breakEndMinutes;
  final int intervalMinutes;

  static String formatRange(TimeOfDay? start, {int intervalMinutes = 30}) {
    if (start == null) return 'Seleccionar horario';

    final startTotalMinutes = start.hour * 60 + start.minute;
    final endTotalMinutes = startTotalMinutes + intervalMinutes;
    final end = TimeOfDay(
      hour: endTotalMinutes ~/ 60,
      minute: endTotalMinutes % 60,
    );

    return '${_formatAmPm(start)} - ${_formatAmPm(end)}';
  }

  static String _formatAmPm(TimeOfDay time) {
    final int hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour12:$minute $period';
  }

  List<TimeOfDay> _buildAvailableSlots() {
    final slots = <TimeOfDay>[];

    for (
      int minutes = startMinutes;
      minutes + intervalMinutes <= endMinutes;
      minutes += intervalMinutes
    ) {
      final slotStart = minutes;
      final slotEnd = minutes + intervalMinutes;
      final overlapsBreak =
          slotStart < breakEndMinutes && slotEnd > breakStartMinutes;
      if (overlapsBreak) continue;

      slots.add(TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60));
    }

    return slots;
  }

  Future<void> _openSlotPicker(BuildContext context) async {
    final slots = _buildAvailableSlots();
    final colorScheme = Theme.of(context).colorScheme;

    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 380,
                  child: ListView.separated(
                    itemCount: slots.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final slot = slots[index];
                      final isSelected =
                          selectedTime?.hour == slot.hour &&
                          selectedTime?.minute == slot.minute;

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? colorScheme.primary.withOpacity(0.4)
                                : colorScheme.outline.withOpacity(0.20),
                          ),
                        ),
                        tileColor: isSelected
                            ? colorScheme.primary.withOpacity(0.08)
                            : colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        title: Text(
                          formatRange(slot, intervalMinutes: intervalMinutes),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: colorScheme.primary,
                              )
                            : Icon(
                                Icons.radio_button_unchecked,
                                color: colorScheme.outline.withOpacity(0.6),
                              ),
                        onTap: () => Navigator.pop(context, slot),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted) return;

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppointmentPickerButton(
      onPressed: enabled ? () => _openSlotPicker(context) : null,
      icon: Icons.access_time_outlined,
      label: formatRange(selectedTime, intervalMinutes: intervalMinutes),
    );
  }
}
