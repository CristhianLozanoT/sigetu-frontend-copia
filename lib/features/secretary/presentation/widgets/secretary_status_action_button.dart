import 'package:flutter/material.dart';

enum SecretaryStatusActionVariant {
  successFilled,
  dangerOutlined,
}

class SecretaryStatusActionButton extends StatelessWidget {
  const SecretaryStatusActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
    this.variant = SecretaryStatusActionVariant.successFilled,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;
  final SecretaryStatusActionVariant variant;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    final isDanger = variant == SecretaryStatusActionVariant.dangerOutlined;

    final foregroundColor = isDanger ? errorColor : Colors.white;
    final backgroundColor = isDanger ? Colors.transparent : Colors.green;
    final side = isDanger
        ? BorderSide(color: errorColor)
        : const BorderSide(color: Colors.transparent);

    return SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: loading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          side: side,
        ),
      ),
    );
  }
}
