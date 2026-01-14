import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workfina/models/app_version_model.dart';
import 'package:workfina/theme/app_theme.dart';

/// Shows the app version update bottom sheet
/// Returns true if user chose to update, false if dismissed
Future<bool?> showAppVersionBottomSheet(
  BuildContext context, {
  required AppVersionModel versionInfo,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: versionInfo.canDismiss,
    enableDrag: versionInfo.canDismiss,
    backgroundColor: Colors.transparent,
    builder: (context) => AppVersionBottomSheet(versionInfo: versionInfo),
  );
}

class AppVersionBottomSheet extends StatelessWidget {
  final AppVersionModel versionInfo;

  const AppVersionBottomSheet({
    super.key,
    required this.versionInfo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: versionInfo.canDismiss,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            if (versionInfo.canDismiss)
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Update Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: versionInfo.isMandatory
                            ? Colors.red.withOpacity(0.1)
                            : AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        versionInfo.isMandatory
                            ? Icons.warning_rounded
                            : Icons.system_update_rounded,
                        size: 40,
                        color: versionInfo.isMandatory
                            ? Colors.red
                            : AppTheme.primary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title
                    Text(
                      versionInfo.isMandatory
                          ? 'Mandatory Update Required'
                          : 'New Update Available',
                      style: AppTheme.getHeadlineStyle(
                        context,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Version Info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Version ${versionInfo.latestVersion}',
                        style: AppTheme.getBodyStyle(
                          context,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Message
                    if (versionInfo.message != null &&
                        versionInfo.message!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          versionInfo.message!,
                          style: AppTheme.getBodyStyle(
                            context,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Mandatory Warning
                    if (versionInfo.isMandatory)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This update is mandatory. You cannot use the app without updating.',
                                style: AppTheme.getSubtitleStyle(
                                  context,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Features Section
                    if (versionInfo.features.isNotEmpty) ...[
                      _buildSectionTitle(context, 'What\'s New'),
                      const SizedBox(height: 8),
                      ...versionInfo.features.map(
                        (feature) => _buildListItem(
                          context,
                          feature,
                          Icons.star_rounded,
                          AppTheme.accentPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Bug Fixes Section
                    if (versionInfo.bugFixes.isNotEmpty) ...[
                      _buildSectionTitle(context, 'Bug Fixes'),
                      const SizedBox(height: 8),
                      ...versionInfo.bugFixes.map(
                        (fix) => _buildListItem(
                          context,
                          fix,
                          Icons.bug_report_rounded,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Release Notes
                    if (versionInfo.releaseNotes != null &&
                        versionInfo.releaseNotes!.isNotEmpty) ...[
                      _buildSectionTitle(context, 'Release Notes'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          versionInfo.releaseNotes!,
                          style: AppTheme.getSubtitleStyle(
                            context,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 8),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => _launchUpdateUrl(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: versionInfo.isMandatory
                              ? Colors.red
                              : AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Update Now',
                              style: AppTheme.getBodyStyle(
                                context,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Skip Button (only if not mandatory)
                    if (versionInfo.canDismiss) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Maybe Later',
                            style: AppTheme.getBodyStyle(
                              context,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTheme.getTitleStyle(
          context,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    String text,
    IconData icon,
    Color iconColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTheme.getSubtitleStyle(
                context,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUpdateUrl(BuildContext context) async {
    if (versionInfo.downloadUrl != null &&
        versionInfo.downloadUrl!.isNotEmpty) {
      final uri = Uri.parse(versionInfo.downloadUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      }
    }
  }
}

/// Full screen version update page (for force updates)
class AppVersionFullScreen extends StatelessWidget {
  final AppVersionModel versionInfo;

  const AppVersionFullScreen({
    super.key,
    required this.versionInfo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Update Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  size: 60,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Update Required',
                style: AppTheme.getHeadlineStyle(
                  context,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Version Info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Version ${versionInfo.latestVersion}',
                  style: AppTheme.getBodyStyle(
                    context,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Message
              Text(
                versionInfo.message ??
                    'A new version of the app is available. Please update to continue using the app.',
                style: AppTheme.getBodyStyle(
                  context,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _launchUpdateUrl(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.download_rounded),
                      const SizedBox(width: 8),
                      Text(
                        'Update Now',
                        style: AppTheme.getBodyStyle(
                          context,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUpdateUrl(BuildContext context) async {
    if (versionInfo.downloadUrl != null &&
        versionInfo.downloadUrl!.isNotEmpty) {
      final uri = Uri.parse(versionInfo.downloadUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
