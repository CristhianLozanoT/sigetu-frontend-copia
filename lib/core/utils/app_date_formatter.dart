import 'package:flutter/material.dart';

class AppDateFormatter {
  static const List<String> _monthNamesEs = [
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

  static String dateShort(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd/$mm/${date.year}';
  }

  static String dateLongEs(DateTime date) {
    return '${date.day} de ${_monthNamesEs[date.month - 1]}, ${date.year}';
  }

  static String time12FromDateTime(DateTime dateTime) {
    return time12(
      TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
    );
  }

  static String time12(TimeOfDay time) {
    final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour12:$minute $period';
  }

  static String timeRange12(TimeOfDay start, {int intervalMinutes = 30}) {
    final startTotal = start.hour * 60 + start.minute;
    final endTotal = startTotal + intervalMinutes;
    final end = TimeOfDay(hour: endTotal ~/ 60, minute: endTotal % 60);
    return '${time12(start)} - ${time12(end)}';
  }
}