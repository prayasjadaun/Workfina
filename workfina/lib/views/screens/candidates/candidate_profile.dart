import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/auth_controller.dart';
import 'package:workfina/controllers/candidate_controller.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workfina/views/screens/candidates/candidate_edit_profile.dart';

class CandidateProfileScreen extends StatefulWidget {
  const CandidateProfileScreen({super.key});

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch profile data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateController>().checkProfileExists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    return Container(
      decoration: AppTheme.getGradientDecoration(context),
      child: Consumer<CandidateController>(
        builder: (context, profileController, child) {
          // Show loading indicator
          if (profileController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            );
          }

          // Show error message
          if (profileController.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      profileController.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        profileController.checkProfileExists();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final profileData = profileController.candidateProfile;

          // Show message if no profile data
          if (profileData == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No profile data available',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please complete your profile to continue',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/candidate-setup');
                      },
                      child: const Text('Complete Profile'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Display profile with real data
          return RefreshIndicator(
            onRefresh: () => profileController.checkProfileExists(),
            color: AppTheme.primaryGreen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add safe area padding at top
                    SizedBox(height: MediaQuery.of(context).padding.top + 16),

                    // Profile Header
                    _buildProfileHeader(profileData, user),

                    const SizedBox(height: 24),

                    // Profile Information Section
                    Text(
                      'Profile Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Edit Profile Card
                    _buildProfileCard(
                      context,
                      icon: Icons.edit,
                      title: 'Edit Profile',
                      subtitle: 'Update your personal information',
                      onTap: () => _showEditProfileDialog(context, profileData),
                    ),

                    // Resume Card
                    _buildProfileCard(
                      context,
                      icon: Icons.description,
                      title: 'Resume',
                      subtitle:
                          profileData['resume_url'] != null &&
                              profileData['resume_url'].toString().isNotEmpty
                          ? 'View or download resume'
                          : 'No resume uploaded',
                      onTap: () => _handleResumeClick(context, profileData),
                      trailing:
                          profileData['resume_url'] != null &&
                              profileData['resume_url'].toString().isNotEmpty
                          ? const Icon(
                              Icons.download,
                              color: AppTheme.primaryGreen,
                            )
                          : null,
                    ),

                    // Experience Card
                    _buildProfileCard(
                      context,
                      icon: Icons.work_history,
                      title: 'Experience',
                      subtitle:
                          '${profileData['experience_years'] ?? 0} years in ${_formatRole(profileData['role'])}',
                      onTap: () => _showExperienceDetails(context, profileData),
                    ),

                    // Education Card
                    _buildProfileCard(
                      context,
                      icon: Icons.school,
                      title: 'Education',
                      subtitle: profileData['education_name'] ?? 'Not provided',
                      onTap: () => _showEducationDetails(context, profileData),
                    ),

                    // Skills Card
                    _buildProfileCard(
                      context,
                      icon: Icons.computer_rounded,
                      title: 'Skills',
                      subtitle: _getSkillsSummary(profileData['skills_list']),
                      onTap: () => _showSkillsDetails(context, profileData),
                    ),

                    const SizedBox(height: 24),

                    // Edit Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showEditProfileDialog(context, profileData),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    Map<String, dynamic> profileData,
    Map<String, dynamic>? user,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryGreen,
            backgroundImage: profileData['profile_image_url'] != null
                ? NetworkImage(profileData['profile_image_url'])
                : null,
            child: profileData['profile_image_url'] == null
                ? Text(
                    (profileData['full_name']?[0] ?? 'C').toUpperCase(),
                    style: const TextStyle(fontSize: 36, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            profileData['full_name'] ?? 'Candidate',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            profileData['email'] ?? user?['email'] ?? 'No email',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            profileData['phone'] ?? 'No phone',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(Icons.work, _formatRole(profileData['role_name'])),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.location_city,
                '${profileData['city_name'] ?? 'N/A'}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGreen),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Card(
      color: AppTheme.getCardColor(context),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Methods

  String _formatRole(String? role) {
    if (role == null) return 'Not specified';
    final roleMap = {
      'IT': 'IT',
      'HR': 'HR',
      'SUPPORT': 'Support',
      'SALES': 'Sales',
      'MARKETING': 'Marketing',
      'FINANCE': 'Finance',
      'DESIGN': 'Design',
      'OTHER': 'Other',
    };
    return roleMap[role] ?? role;
  }

  String _getSkillsSummary(List<dynamic>? skillsList) {
    if (skillsList == null || skillsList.isEmpty) {
      return 'No skills added';
    }
    if (skillsList.length <= 2) {
      return skillsList.join(', ');
    }
    return '${skillsList.take(2).join(', ')} +${skillsList.length - 2} more';
  }

  // Click Handlers

  // Update the _showEditProfileDialog method in your candidate_profile.dart

  void _showEditProfileDialog(
    BuildContext context,
    Map<String, dynamic> profileData,
  ) async {
    // Navigate to edit profile screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profileData: profileData),
      ),
    );

    // If profile was updated, refresh the profile data
    if (result == true && mounted) {
      context.read<CandidateController>().checkProfileExists();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile refreshed successfully!'),
          backgroundColor: AppTheme.primaryGreen,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleResumeClick(
    BuildContext context,
    Map<String, dynamic> profileData,
  ) {
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
                _launchURL(resumeUrl.toString());
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: AppTheme.primaryGreen),
              title: const Text('Download Resume'),
              onTap: () {
                Navigator.pop(context);
                _launchURL(resumeUrl.toString());
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showExperienceDetails(
    BuildContext context,
    Map<String, dynamic> profileData,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Experience Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Role', _formatRole(profileData['role_name'])),
            _buildDetailRow(
              'Years',
              '${profileData['experience_years'] ?? 0} years',
            ),
            if (profileData['current_ctc'] != null)
              _buildDetailRow(
                'Current CTC',
                'Ã¢â€šÂ¹${profileData['current_ctc']} LPA',
              ),
            if (profileData['expected_ctc'] != null)
              _buildDetailRow(
                'Expected CTC',
                'Ã¢â€šÂ¹${profileData['expected_ctc']} LPA',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEducationDetails(
    BuildContext context,
    Map<String, dynamic> profileData,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Education'),
        content: Text(
          profileData['education_name'] ?? 'Not provided',
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSkillsDetails(
    BuildContext context,
    Map<String, dynamic> profileData,
  ) {
    final skillsList = profileData['skills_list'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skills'),
        content: skillsList.isEmpty
            ? const Text('No skills added yet')
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skillsList.map((skill) {
                  return Chip(
                    label: Text(skill.toString()),
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                    side: const BorderSide(color: AppTheme.primaryGreen),
                  );
                }).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open resume')));
      }
    }
  }
}

// Edit Profile Bottom Sheet
class _EditProfileSheet extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const _EditProfileSheet({required this.profileData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Edit Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            Icons.person,
            'Name',
            profileData['full_name'] ?? 'N/A',
          ),
          _buildInfoRow(Icons.email, 'Email', profileData['email'] ?? 'N/A'),
          _buildInfoRow(Icons.phone, 'Phone', profileData['phone'] ?? 'N/A'),
          _buildInfoRow(Icons.cake, 'Age', '${profileData['age'] ?? 'N/A'}'),
          _buildInfoRow(
            Icons.location_city,
            'Location',
            '${profileData['city_name'] ?? 'N/A'}, ${profileData['state_name'] ?? 'N/A'}',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit functionality coming soon!'),
                  ),
                );
              },
              child: const Text('Update Profile'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}