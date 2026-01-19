import 'package:flutter/material.dart';
import 'package:workfina/models/subscription_model.dart';
import 'package:workfina/theme/app_theme.dart';

class SubscriptionStatusBanner extends StatelessWidget {
  final SubscriptionStatus status;
  final VoidCallback? onRenewPressed;

  const SubscriptionStatusBanner({
    super.key,
    required this.status,
    this.onRenewPressed,
  });

  Color _getBannerColor() {
    if (!status.hasSubscription) {
      return Colors.red.shade700;
    }

    switch (status.warningLevel) {
      case 'CRITICAL':
        return Colors.red.shade700;
      case 'HIGH':
        return Colors.orange.shade700;
      case 'MEDIUM':
        return Colors.yellow.shade700;
      case 'LOW':
        return AppTheme.greenCard;
      default:
        return AppTheme.primary;
    }
  }

  IconData _getBannerIcon() {
    if (!status.hasSubscription) {
      return Icons.error_outline;
    }

    switch (status.warningLevel) {
      case 'CRITICAL':
        return Icons.warning_amber_rounded;
      case 'HIGH':
        return Icons.notifications_active;
      case 'MEDIUM':
        return Icons.info_outline;
      case 'LOW':
        return Icons.check_circle_outline;
      default:
        return Icons.card_membership;
    }
  }

  String _getMessage() {
    if (!status.hasSubscription) {
      return 'No active subscription. Subscribe to unlock candidates!';
    }

    if (status.isUnlimited) {
      return 'Unlimited plan active - ${status.daysRemaining} days remaining';
    }

    final remaining = (status.creditsLimit ?? 0) - status.creditsUsed;
    return '$remaining credits left - ${status.daysRemaining} days remaining';
  }

  @override
  Widget build(BuildContext context) {
    final bannerColor = _getBannerColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? bannerColor.withOpacity(0.2) : bannerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bannerColor,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bannerColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getBannerIcon(),
                color: bannerColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.plan ?? 'No Plan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getMessage(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (!status.hasSubscription ||
                status.warningLevel == 'CRITICAL' ||
                status.warningLevel == 'HIGH')
              TextButton(
                onPressed: onRenewPressed,
                style: TextButton.styleFrom(
                  backgroundColor: bannerColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  status.hasSubscription ? 'Renew' : 'Subscribe',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
