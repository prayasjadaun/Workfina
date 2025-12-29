import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workfina/theme/app_theme.dart';

class CandidateDetailScreen extends StatelessWidget {
  final Map<String, dynamic> candidate;
  final bool isAlreadyUnlocked;

  const CandidateDetailScreen({
    super.key,
    required this.candidate,
    this.isAlreadyUnlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${candidate['full_name'] ?? candidate['masked_name']}'),
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: AppTheme.getGradientDecoration(context),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Banner
              if (isAlreadyUnlocked)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryGreen),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Previously Unlocked',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // Profile Header
              _buildProfileCard(context),
              const SizedBox(height: 16),

              // Contact Information
              _buildSectionCard(
                context,
                'Contact Information',
                Icons.contact_phone,
                [
                  _buildInfoRow('Email', candidate['email'] ?? 'N/A'),
                  _buildInfoRow('Phone', candidate['phone'] ?? 'N/A'),
                ],
              ),
              const SizedBox(height: 16),

              // Professional Details
              _buildSectionCard(context, 'Professional Details', Icons.work, [
                _buildInfoRow('Role', candidate['role'] ?? 'N/A'),
                _buildInfoRow(
                  'Experience',
                  '${candidate['experience_years'] ?? 0} years',
                ),
                if (candidate['current_ctc'] != null)
                  _buildInfoRow('Current CTC', '₹${candidate['current_ctc']}'),
                if (candidate['expected_ctc'] != null)
                  _buildInfoRow(
                    'Expected CTC',
                    '₹${candidate['expected_ctc']}',
                  ),
              ]),
              const SizedBox(height: 16),

              // Personal Details
              _buildSectionCard(context, 'Personal Details', Icons.person, [
                _buildInfoRow('Age', '${candidate['age'] ?? 'N/A'} years'),
                if (candidate['religion'] != null)
                  _buildInfoRow('Religion', candidate['religion']),
              ]),
              const SizedBox(height: 16),

              // Location
              _buildSectionCard(context, 'Location', Icons.location_on, [
                _buildInfoRow('City', candidate['city'] ?? 'N/A'),
                _buildInfoRow('State', candidate['state'] ?? 'N/A'),
                _buildInfoRow('Country', candidate['country'] ?? 'India'),
              ]),
              const SizedBox(height: 16),

              // Education
              if (candidate['education'] != null)
                _buildSectionCard(context, 'Education', Icons.school, [
                  _buildInfoText(candidate['education']),
                ]),
              const SizedBox(height: 16),

              // Skills
              if (candidate['skills'] != null) _buildSkillsCard(context),
              const SizedBox(height: 16),

              // Resume
              if (candidate['resume'] != null) _buildResumeCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryGreen,
            child: Text(
              (candidate['full_name'] ?? candidate['masked_name'] ?? 'U')
                  .substring(0, 1)
                  .toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            candidate['full_name'] ?? candidate['masked_name'] ?? 'Unknown',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            candidate['role'] ?? 'N/A',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w500));
  }

  Widget _buildSkillsCard(BuildContext context) {
    final skills = candidate['skills']?.split(',') ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Skills',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                      color: AppTheme.secondaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.secondaryBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      skill.trim(),
                      style: TextStyle(
                        color: AppTheme.secondaryBlue,
                        fontWeight: FontWeight.w500,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Resume',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: candidate['resume'] != null
                ? () async {
                    try {
                      final baseUrl = 'http://localhost:8000';
                      final resumeUrl = '$baseUrl${candidate['resume']}';

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloading resume...')),
                      );

                      final dir = await getDownloadsDirectory();
                      final savePath =
                          '${dir?.path}/resume_${candidate['id']}.pdf';

                      await Dio().download(resumeUrl, savePath);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Downloaded to: $savePath')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Download failed')),
                        );
                      }
                    }
                  }
                : null,
            icon: const Icon(Icons.download),
            label: const Text('Download Resume'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
