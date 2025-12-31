import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
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

  void _handleResumeClick(BuildContext context, Map<String, dynamic> profileData) {
    final resumeUrl = profileData['resume_url'];

    if (resumeUrl == null || resumeUrl.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No resume uploaded yet'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Resume',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(
                Icons.visibility,
                color: AppTheme.primaryGreen,
              ),
              title: const Text('View Resume'),
              onTap: () {
                Navigator.pop(context);
                String viewUrl = resumeUrl.toString();
                if (!viewUrl.startsWith('http')) {
                  final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
                  viewUrl = '$baseUrl$viewUrl';
                }
                _launchURL(viewUrl);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: AppTheme.primaryGreen),
              title: const Text('Download Resume'),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(resumeUrl.toString(), context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleVideoClick(BuildContext context, Map<String, dynamic> profileData) {
    final videoUrl = profileData['video_intro_url'];

    if (videoUrl == null || videoUrl.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No video introduction available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Video Introduction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(
                Icons.play_arrow,
                color: AppTheme.primaryGreen,
              ),
              title: const Text('Play Video'),
              subtitle: const Text('Open in external player'),
              onTap: () {
                Navigator.pop(context);
                String playUrl = videoUrl.toString();
                if (!playUrl.startsWith('http')) {
                  final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
                  playUrl = '$baseUrl$playUrl';
                }
                _launchURL(playUrl);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _downloadFile(String url, BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Starting download...'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );

      // Fix URL for local backend
      String downloadUrl = url;
      if (!url.startsWith('http')) {
        final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
        downloadUrl = '$baseUrl$url';
      }

      final dio = Dio();
      final directory = await getApplicationDocumentsDirectory();
      final fileName = url.split('/').last;
      final filePath = '${directory.path}/$fileName';

      await dio.download(downloadUrl, filePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded: $fileName'),
            backgroundColor: AppTheme.primaryGreen,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () => _launchURL('file://$filePath'),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
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
                  candidate['role_name'] ?? 'Not Specified',
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
                if (candidate['religion_name'] != null)
                  _buildInfoRow(context, 'Religion', candidate['religion_name']),
              ],
            ),
            const SizedBox(height: 20),

            // Location
            _buildSectionCard(
              context,
              'Location Details',
              'assets/svgs/location.svg',
              [
                _buildInfoRow(
                  context,
                  'City',
                  candidate['city_name'] ?? 'Not Available',
                ),
                _buildInfoRow(
                  context,
                  'State',
                  candidate['state_name'] ?? 'Not Available',
                ),
                _buildInfoRow(
                  context,
                  'Country',
                  candidate['country_name'] ?? 'India',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Education
            if (candidate['education_name'] != null)
              _buildSectionCard(
                context,
                'Education Background',
                'assets/svgs/candidates.svg',
                [_buildInfoText(context, candidate['education_name'])],
              ),
            const SizedBox(height: 20),

            // Skills
            if (candidate['skills'] != null) _buildSkillsCard(context),
            const SizedBox(height: 20),

            // Resume
            _buildResumeCard(context),
            const SizedBox(height: 20),

            // Video Introduction
            _buildVideoCard(context),
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
            candidate['role_name'] ?? 'Role not specified',
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
          ListTile(
            leading: SvgPicture.asset(
              'assets/svgs/docs.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppTheme.primaryGreen,
                BlendMode.srcIn,
              ),
            ),
            title: const Text('Resume Document'),
            subtitle: candidate['resume_url'] != null &&
                    candidate['resume_url'].toString().isNotEmpty
                ? const Text('View or download resume')
                : const Text('No resume uploaded'),
            onTap: () => _handleResumeClick(context, candidate),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context) {
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
                'Video Introduction',
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
          ListTile(
            leading: SvgPicture.asset(
              'assets/svgs/play.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppTheme.primaryGreen,
                BlendMode.srcIn,
              ),
            ),
            title: const Text('Video Introduction'),
            subtitle: candidate['video_intro_url'] != null &&
                    candidate['video_intro_url'].toString().isNotEmpty
                ? const Text('Tap to play video introduction')
                : const Text('No video introduction available'),
            onTap: () => _handleVideoClick(context, candidate),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}