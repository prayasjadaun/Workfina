import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';

class CandidateDetailScreen extends StatelessWidget {
  final Map<String, dynamic> candidate;
  final bool isAlreadyUnlocked;

  const CandidateDetailScreen({
    super.key,
    required this.candidate,
    this.isAlreadyUnlocked = false,
  });

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Not Specified';

    final formatter = NumberFormat('#,##,###');
    double value = double.tryParse(amount.toString()) ?? 0;

    return '₹${formatter.format(value.toInt())}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      appBar: AppBar(
        title: Text(
          candidate['full_name'] ?? candidate['masked_name'] ?? 'Candidate',
          style: AppTheme.getAppBarTextStyle(),
        ),
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: isDark ? Colors.white : Colors.black,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            if (isAlreadyUnlocked) _buildStatusBanner(context),

            // Profile Header
            _buildProfileCard(context),
            const SizedBox(height: 24),

            // Contact Information
            _buildSectionCard(
              context,
              'Contact Information',
              'assets/svgs/profile.svg',
              [
                _buildInfoRow(
                  context,
                  'Email',
                  candidate['email'] ?? 'Not Available',
                ),
                _buildInfoRow(
                  context,
                  'Phone',
                  candidate['phone'] ?? 'Not Available',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Professional Details
            _buildSectionCard(
              context,
              'Professional Details',
              'assets/svgs/candidates.svg',
              [
                _buildInfoRow(
                  context,
                  'Role',
                  candidate['role'] ?? 'Not Specified',
                ),
                _buildInfoRow(
                  context,
                  'Experience',
                  '${candidate['experience_years'] ?? 0} years',
                ),
                if (candidate['current_ctc'] != null)
                  _buildInfoRow(
                    context,
                    'Current CTC',
                    _formatCurrency(candidate['current_ctc']),
                  ),
                if (candidate['expected_ctc'] != null)
                  _buildInfoRow(
                    context,
                    'Expected CTC',
                    _formatCurrency(candidate['expected_ctc']),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Personal Details
            _buildSectionCard(
              context,
              'Personal Information',
              'assets/svgs/profile.svg',
              [
                _buildInfoRow(
                  context,
                  'Age',
                  '${candidate['age'] ?? 'N/A'} years',
                ),
                if (candidate['religion'] != null)
                  _buildInfoRow(context, 'Religion', candidate['religion']),
              ],
            ),
            const SizedBox(height: 20),

            // Location
            _buildSectionCard(
              context,
              'Location Details',
              'assets/svgs/home.svg',
              [
                _buildInfoRow(
                  context,
                  'City',
                  candidate['city'] ?? 'Not Available',
                ),
                _buildInfoRow(
                  context,
                  'State',
                  candidate['state'] ?? 'Not Available',
                ),
                _buildInfoRow(
                  context,
                  'Country',
                  candidate['country'] ?? 'India',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Education
            if (candidate['education'] != null)
              _buildSectionCard(
                context,
                'Education Background',
                'assets/svgs/candidates.svg',
                [_buildInfoText(context, candidate['education'])],
              ),
            const SizedBox(height: 20),

            // Skills
            if (candidate['skills'] != null) _buildSkillsCard(context),
            const SizedBox(height: 20),

            // Resume
            if (candidate['resume'] != null) _buildResumeCard(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/svgs/candidates.svg',
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(
              Colors.grey.shade600,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Previously Unlocked',
            style: AppTheme.getBodyStyle(
              context,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                (candidate['full_name'] ?? candidate['masked_name'] ?? 'U')
                    .substring(0, 1)
                    .toUpperCase(),
                style: AppTheme.getTitleStyle(
                  context,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            candidate['full_name'] ?? candidate['masked_name'] ?? 'Unknown',
            style: AppTheme.getTitleStyle(
              context,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            candidate['role'] ?? 'Role not specified',
            style: AppTheme.getBodyStyle(
              context,
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    String svgPath,
    List<Widget> children,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                svgPath,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTheme.getTitleStyle(
                  context,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTheme.getBodyStyle(
                context,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: AppTheme.getBodyStyle(
                context,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      text,
      style: AppTheme.getBodyStyle(
        context,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildSkillsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skills = candidate['skills']?.split(',') ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/svgs/candidates.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Skills & Expertise',
                style: AppTheme.getTitleStyle(
                  context,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills
                .map<Widget>(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      skill.trim(),
                      style: AppTheme.getLabelStyle(
                        context,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/svgs/wallet.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Resume',
                style: AppTheme.getTitleStyle(
                  context,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: candidate['resume'] != null
                  ? () async {
                      try {
                        final baseUrl = ApiService.baseUrl.replaceAll(
                          '/api',
                          '',
                        );
                        final resumeUrl = candidate['resume'].startsWith('http')
                            ? candidate['resume']
                            : '$baseUrl${candidate['resume']}';

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Opening resume...',
                              style: AppTheme.getBodyStyle(context),
                            ),
                            backgroundColor: Colors.grey.shade700,
                          ),
                        );

                        final uri = Uri.parse(resumeUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Could not open resume',
                                  style: AppTheme.getBodyStyle(context),
                                ),
                                backgroundColor: Colors.red.shade700,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to open resume: ${e.toString()}',
                                style: AppTheme.getBodyStyle(context),
                              ),
                              backgroundColor: Colors.red.shade700,
                            ),
                          );
                        }
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svgs/wallet.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      isDark ? Colors.black : Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'View Resume',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
