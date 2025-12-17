import 'package:flutter/material.dart';

/// 确认按钮组件
class ConfirmButton extends StatelessWidget {
  const ConfirmButton({
    super.key,
    this.onPressed,
    this.isValid = false,
    this.isComplete = false,
  });
  final VoidCallback? onPressed;
  final bool isValid;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isEnabled = onPressed != null && isValid && isComplete;

    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        foregroundColor: isEnabled
            ? colorScheme.onPrimary
            : colorScheme.onSurface.withValues(alpha: 0.4),
        elevation: isEnabled ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isValid && isComplete ? Icons.check : Icons.warning,
            size: 16,
          ),
          const SizedBox(width: 4),
          const Text('确认'),
        ],
      ),
    );
  }
}
