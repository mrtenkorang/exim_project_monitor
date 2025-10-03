import 'package:flutter/material.dart';

enum SnackbarType { success, error, info, warning }

class CustomSnackbar extends StatelessWidget {
  final String message;
  final SnackbarType type;
  final Duration duration;
  final VoidCallback? onDismissed;

  const CustomSnackbar({
    Key? key,
    required this.message,
    this.type = SnackbarType.info,
    this.duration = const Duration(seconds: 4),
    this.onDismissed,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onDismissed,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: CustomSnackbar(
          message: message,
          type: type,
          duration: duration,
          onDismissed: onDismissed,
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
      onDismissed?.call();
    });
  }

  Color _getBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (type) {
      case SnackbarType.success:
        return Colors.green.shade100;
      case SnackbarType.error:
        return theme.colorScheme.error;
      case SnackbarType.warning:
        return Colors.orange.shade100;
      case SnackbarType.info:
      return theme.colorScheme.secondary;
    }
  }

  Color _getTextColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (type) {
      case SnackbarType.success:
        return Colors.green.shade900;
      case SnackbarType.error:
        return theme.colorScheme.surface;
      case SnackbarType.warning:
        return Colors.orange.shade900;
      case SnackbarType.info:
      return theme.textTheme.bodyLarge?.color ?? Colors.black87;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.warning:
        return Icons.warning_amber_rounded;
      case SnackbarType.info:
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset(0, -50 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Dismissible(
          key: const Key('dismissible_snackbar'),
          direction: DismissDirection.up,
          onDismissed: (_) => onDismissed?.call(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _getBackgroundColor(context),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(_getIcon(), color: _getTextColor(context)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _getTextColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: _getTextColor(context).withOpacity(0.7),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    onDismissed?.call();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Usage example:
/*
// Show success message
CustomSnackbar.show(
  context,
  message: 'Farmer added successfully!',
  type: SnackbarType.success,
);

// Show error message
CustomSnackbar.show(
  context,
  message: 'Failed to add farmer. Please try again.',
  type: SnackbarType.error,
);

// Show info message with custom duration
CustomSnackbar.show(
  context,
  message: 'This is an information message',
  type: SnackbarType.info,
  duration: const Duration(seconds: 3),
  onDismissed: () {
    // Do something when snackbar is dismissed
  },
);
*/
