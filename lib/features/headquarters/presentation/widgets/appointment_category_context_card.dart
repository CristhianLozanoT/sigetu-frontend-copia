import 'package:flutter/material.dart';
import 'package:sigetu/core/theme/appointment_context_palette.dart';

class AppointmentCategoryContextCard extends StatelessWidget {
  const AppointmentCategoryContextCard({
    super.key,
    this.selectedContext,
    this.contextOptions = const [],
    this.onContextChanged,
    this.showContextSelector = true,
  });

  final String? selectedContext;
  final List<String> contextOptions;
  final ValueChanged<String?>? onContextChanged;
  final bool showContextSelector;

  static const List<IconData> _icons = [
    Icons.chat_bubble_outline_rounded,
    Icons.assignment_turned_in_outlined,
    Icons.autorenew_rounded,
    Icons.help_outline_rounded,
  ];

  String _contextSubtitle(String context) {
    final normalized = context.toLowerCase();

    if (normalized.contains('grado')) {
      return 'Consulta y orientación sobre este proceso';
    }
    if (normalized.contains('docentes') || normalized.contains('horarios')) {
      return 'Gestión de asignación y programación académica';
    }
    if (normalized.contains('cancelaciones') || normalized.contains('petición')) {
      return 'Atención de solicitudes administrativas y legales';
    }
    if (normalized.contains('financier')) {
      return 'Soporte en pagos, cursos y trámites financieros';
    }
    if (normalized.contains('otros')) {
      return 'Atención para solicitudes adicionales';
    }

    return 'Selecciona este motivo para continuar';
  }

  Widget _buildContextTile(BuildContext context, String option, int index) {
    final isSelected = selectedContext == option;
    final icon = _icons[index % _icons.length];
    final scheme = Theme.of(context).colorScheme;
    final contextPalette =
        Theme.of(context).extension<AppointmentContextPalette>() ??
            AppointmentContextPalette.defaults;
    final iconColor = contextPalette.iconColorFor(index);
    final iconBackground = contextPalette.iconBackgroundFor(index);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = scheme.surface;
    final tileBorderColor = isSelected
        ? scheme.primary.withValues(alpha: isDark ? 0.58 : 0.28)
        : scheme.outline.withValues(alpha: isDark ? 0.35 : 0.18);
    final shadowColor = (isDark ? scheme.shadow : Colors.black)
        .withValues(alpha: isDark ? 0.32 : (isSelected ? 0.12 : 0.08));

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onContextChanged != null ? () => onContextChanged!(option) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: tileBorderColor,
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: isSelected ? 14 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: scheme.primary,
                          size: 18,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _contextSubtitle(option),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showContextSelector)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < contextOptions.length; i++) ...[
                _buildContextTile(context, contextOptions[i], i),
                if (i < contextOptions.length - 1) const SizedBox(height: 10),
              ],
            ],
          )
        else
          _buildContextTile(
            context,
            selectedContext ?? '',
            0,
          ),
      ],
    );
  }
}
