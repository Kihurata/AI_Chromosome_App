import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Enum defining all notification types used throughout the application.
/// Cubit/BLoC emits states with this type so NotificationFactory knows
/// exactly which UI treatment to render.
enum NotificationType {
  /// Green snackbar — operation completed successfully
  success,

  /// Blue snackbar — informational message
  info,

  /// Yellow/amber snackbar — soft warning, non-blocking
  warning,

  /// Red snackbar — error occurred, no retry option
  error,

  /// Red dialog with "Retry" button — server/network error that can be retried
  errorRetry,

  /// Red snackbar — validation/input error from user
  validationError,
}

/// Centralized notification factory for the entire application.
///
/// Usage from a BlocListener:
/// ```dart
/// BlocListener<MyCubit, MyState>(
///   listener: (context, state) {
///     if (state is MyError) {
///       NotificationFactory.show(
///         context,
///         type: NotificationType.error,
///         message: state.message,
///       );
///     }
///   },
/// )
/// ```
class NotificationFactory {
  NotificationFactory._(); // Prevent instantiation

  // ──────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────

  /// Main entry point — dispatches to the correct UI based on [type].
  static void show(
    BuildContext context, {
    required NotificationType type,
    required String message,
    String? title,
    VoidCallback? onRetry,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    switch (type) {
      case NotificationType.success:
        _showSnackbar(
          context,
          message: message,
          icon: Icons.check_circle_rounded,
          backgroundColor: AppColors.successBg,
          textColor: AppColors.successText,
          iconColor: AppColors.successText,
          duration: duration,
          actionLabel: actionLabel,
          onAction: onAction,
        );
        break;

      case NotificationType.info:
        _showSnackbar(
          context,
          message: message,
          icon: Icons.info_rounded,
          backgroundColor: AppColors.processingBg,
          textColor: AppColors.processingText,
          iconColor: AppColors.processingText,
          duration: duration,
          actionLabel: actionLabel,
          onAction: onAction,
        );
        break;

      case NotificationType.warning:
        _showSnackbar(
          context,
          message: message,
          icon: Icons.warning_amber_rounded,
          backgroundColor: AppColors.warningBg,
          textColor: AppColors.warningText,
          iconColor: AppColors.warningText,
          duration: duration,
          actionLabel: actionLabel,
          onAction: onAction,
        );
        break;

      case NotificationType.error:
        _showSnackbar(
          context,
          message: message,
          icon: Icons.error_rounded,
          backgroundColor: AppColors.dangerBg,
          textColor: AppColors.dangerText,
          iconColor: AppColors.dangerText,
          duration: duration,
          actionLabel: actionLabel,
          onAction: onAction,
        );
        break;

      case NotificationType.validationError:
        _showSnackbar(
          context,
          message: message,
          icon: Icons.report_gmailerrorred_rounded,
          backgroundColor: AppColors.dangerBg,
          textColor: AppColors.dangerText,
          iconColor: AppColors.dangerText,
          duration: duration,
          actionLabel: actionLabel,
          onAction: onAction,
        );
        break;

      case NotificationType.errorRetry:
        _showRetryDialog(
          context,
          title: title ?? 'Đã xảy ra lỗi',
          message: message,
          onRetry: onRetry,
        );
        break;
    }
  }

  // ──────────────────────────────────────────────
  // Convenience shortcuts
  // ──────────────────────────────────────────────

  static void showSuccess(BuildContext context, String message) =>
      show(context, type: NotificationType.success, message: message);

  static void showInfo(BuildContext context, String message) =>
      show(context, type: NotificationType.info, message: message);

  static void showWarning(BuildContext context, String message) =>
      show(context, type: NotificationType.warning, message: message);

  static void showError(BuildContext context, String message) =>
      show(context, type: NotificationType.error, message: message);

  static void showValidationError(BuildContext context, String message) =>
      show(context, type: NotificationType.validationError, message: message);

  static void showErrorRetry(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onRetry,
  }) =>
      show(
        context,
        type: NotificationType.errorRetry,
        message: message,
        title: title,
        onRetry: onRetry,
      );

  // ──────────────────────────────────────────────
  // Private renderers
  // ──────────────────────────────────────────────

  static void _showSnackbar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: textColor.withAlpha(40)),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4, right: 8),
          duration: duration,
          dismissDirection: DismissDirection.horizontal,
          elevation: 4,
          action: (actionLabel != null && onAction != null)
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: textColor,
                  onPressed: onAction,
                )
              : null,
        ),
      );
  }

  static void _showRetryDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(
          Icons.cloud_off_rounded,
          color: AppColors.dangerText,
          size: 48,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Đóng',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          if (onRetry != null)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onRetry();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
