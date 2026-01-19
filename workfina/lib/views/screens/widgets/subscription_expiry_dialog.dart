import 'package:flutter/material.dart';
import 'package:workfina/models/subscription_model.dart';
import 'package:workfina/theme/app_theme.dart';

class SubscriptionExpiryDialog extends StatelessWidget {
  final SubscriptionStatus status;
  final VoidCallback? onRenewPressed;
  final VoidCallback? onDismiss;

  const SubscriptionExpiryDialog({
    super.key,
    required this.status,
    this.onRenewPressed,
    this.onDismiss,
  });

  static Future<void> showIfNeeded(
    BuildContext context,
    SubscriptionStatus status, {
    VoidCallback? onRenewPressed,
    VoidCallback? onDismiss,
  }) async {
    if (!status.hasSubscription ||
        status.warningLevel == 'CRITICAL' ||
        status.warningLevel == 'HIGH') {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => SubscriptionExpiryDialog(
          status: status,
          onRenewPressed: onRenewPressed,
          onDismiss: onDismiss,
        ),
      );
    }
  }

  Color _getDialogColor() {
    if (!status.hasSubscription) {
      return Colors.red;
    }

    switch (status.warningLevel) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      default:
        return AppTheme.accentPrimary;
    }
  }

  IconData _getDialogIcon() {
    if (!status.hasSubscription) {
      return Icons.error_outline;
    }

    switch (status.warningLevel) {
      case 'CRITICAL':
        return Icons.warning_amber_rounded;
      case 'HIGH':
        return Icons.notifications_active;
      default:
        return Icons.info_outline;
    }
  }

  String _getTitle() {
    if (!status.hasSubscription) {
      return 'No Active Subscription';
    }

    switch (status.warningLevel) {
      case 'CRITICAL':
        return 'Subscription Expiring Soon!';
      case 'HIGH':
        return 'Subscription Reminder';
      default:
        return 'Subscription Notice';
    }
  }

  String _getMessage() {
    if (!status.hasSubscription) {
      return 'You don\'t have an active subscription. Subscribe now to unlock candidates and access all features.';
    }

    final daysText = status.daysRemaining == 1 ? 'day' : 'days';

    if (status.warningLevel == 'CRITICAL') {
      return 'Your subscription "${status.plan}" will expire in ${status.daysRemaining} $daysText. Renew now to avoid service interruption!';
    } else if (status.warningLevel == 'HIGH') {
      return 'Your subscription "${status.plan}" will expire in ${status.daysRemaining} $daysText. Consider renewing to ensure uninterrupted service.';
    }

    return 'Your subscription "${status.plan}" has ${status.daysRemaining} $daysText remaining.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogColor = _getDialogColor();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardBackground : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dialogColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getDialogIcon(),
                size: 48,
                color: dialogColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _getTitle(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _getMessage(),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (status.hasSubscription && !status.isUnlimited) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Credits Used',
                      '${status.creditsUsed}',
                      Icons.credit_card,
                      isDark,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                    _buildStatItem(
                      'Credits Left',
                      '${(status.creditsLimit ?? 0) - status.creditsUsed}',
                      Icons.account_balance_wallet,
                      isDark,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDismiss?.call();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      status.hasSubscription ? 'Later' : 'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onRenewPressed?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dialogColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      status.hasSubscription
                          ? 'Renew Now'
                          : 'View Plans',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      ],
    );
  }
}
