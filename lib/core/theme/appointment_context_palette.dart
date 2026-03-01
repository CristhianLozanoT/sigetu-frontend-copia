import 'package:flutter/material.dart';

@immutable
class AppointmentContextPalette extends ThemeExtension<AppointmentContextPalette> {
  const AppointmentContextPalette({
    required this.iconColors,
    required this.iconBackgrounds,
  });

  static const AppointmentContextPalette defaults = AppointmentContextPalette(
    iconColors: [
      Color(0xFF2563EB),
      Color(0xFF16A34A),
      Color(0xFF9333EA),
      Color(0xFFEA580C),
    ],
    iconBackgrounds: [
      Color(0xFFDBEAFE),
      Color(0xFFDCFCE7),
      Color(0xFFF3E8FF),
      Color(0xFFFFEDD5),
    ],
  );

  final List<Color> iconColors;
  final List<Color> iconBackgrounds;

  Color iconColorFor(int index) => iconColors[index % iconColors.length];

  Color iconBackgroundFor(int index) =>
      iconBackgrounds[index % iconBackgrounds.length];

  @override
  AppointmentContextPalette copyWith({
    List<Color>? iconColors,
    List<Color>? iconBackgrounds,
  }) {
    return AppointmentContextPalette(
      iconColors: iconColors ?? this.iconColors,
      iconBackgrounds: iconBackgrounds ?? this.iconBackgrounds,
    );
  }

  @override
  AppointmentContextPalette lerp(
    ThemeExtension<AppointmentContextPalette>? other,
    double t,
  ) {
    if (other is! AppointmentContextPalette) {
      return this;
    }

    if (iconColors.length != other.iconColors.length ||
        iconBackgrounds.length != other.iconBackgrounds.length) {
      return t < 0.5 ? this : other;
    }

    return AppointmentContextPalette(
      iconColors: List.generate(
        iconColors.length,
        (index) => Color.lerp(iconColors[index], other.iconColors[index], t)!,
      ),
      iconBackgrounds: List.generate(
        iconBackgrounds.length,
        (index) =>
            Color.lerp(iconBackgrounds[index], other.iconBackgrounds[index], t)!,
      ),
    );
  }
}