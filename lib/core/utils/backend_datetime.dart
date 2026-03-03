import 'package:sigetu/core/constants/api_constants.dart';

class BackendDateTime {
  static final RegExp _timezoneSuffix = RegExp(r'(Z|[+-]\d{2}:?\d{2})$');

  static Duration get _offset => Duration(
        minutes: ApiConstants.backendTimezoneOffsetMinutes,
      );

  static DateTime parse(dynamic value) {
    if (value == null) return DateTime.now();

    final raw = value.toString();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return DateTime.now();

    final hasExplicitTimezone = _timezoneSuffix.hasMatch(raw);

    if (!hasExplicitTimezone) {
      return DateTime(
        parsed.year,
        parsed.month,
        parsed.day,
        parsed.hour,
        parsed.minute,
        parsed.second,
        parsed.millisecond,
        parsed.microsecond,
      );
    }

    final backendTime = parsed.toUtc().add(_offset);

    return DateTime(
      backendTime.year,
      backendTime.month,
      backendTime.day,
      backendTime.hour,
      backendTime.minute,
      backendTime.second,
      backendTime.millisecond,
      backendTime.microsecond,
    );
  }

  static String formatForApi(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');

    final dateTimePart =
        '${value.year.toString().padLeft(4, '0')}-${two(value.month)}-${two(value.day)}T${two(value.hour)}:${two(value.minute)}:${two(value.second)}';

    final sign = _offset.isNegative ? '-' : '+';
    final absOffset = _offset.abs();
    final offsetHours = two(absOffset.inHours);
    final offsetMinutes = two(absOffset.inMinutes.remainder(60));

    return '$dateTimePart$sign$offsetHours:$offsetMinutes';
  }
}