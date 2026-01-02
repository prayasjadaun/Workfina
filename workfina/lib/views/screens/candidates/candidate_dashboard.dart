import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/candidate_controller.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/views/screens/candidates/candidate_edit_profile.dart';

class CandidateDashboard extends StatefulWidget {
  const CandidateDashboard({super.key});

  @override
  State<CandidateDashboard> createState() => _CandidateDashboardState();
}

class _CandidateDashboardState extends State<CandidateDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateController>().checkProfileExists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: () => context.read<CandidateController>().checkProfileExists(),
        color: AppTheme.primary,
        child: Consumer<CandidateController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            final profileData = controller.candidateProfile;

            if (profileData == null) {
              return _buildNoProfileState(context);
            }

            return CustomScrollView(
              slivers: [
                // Minimal App Bar
                _buildMinimalAppBar(context, profileData),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // Profile Strength - Minimal Card
                        _buildProfileStrengthCard(context, profileData),

                        const SizedBox(height: 24),

                        // Stats Row - Clean & Minimal
                        _buildStatsRow(context, profileData),

                        const SizedBox(height: 32),

                        // Profile Overview
                        _buildSectionTitle('Profile Overview'),
                        const SizedBox(height: 16),
                        _buildProfileOverview(context, profileData),

                        const SizedBox(height: 32),

                        // Quick Actions - Minimal
                        _buildSectionTitle('Quick Actions'),
                        const SizedBox(height: 16),
                        _buildQuickActions(context, profileData),

                        const SizedBox(height: 32),

                        // Recommendations
                        if (_calculateProfileCompleteness(profileData) < 100) ...[
                          _buildSectionTitle('Recommendations'),
                          const SizedBox(height: 16),
                          _buildRecommendations(context, profileData),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMinimalAppBar(BuildContext context, Map<String, dynamic> profileData) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final firstName = (profileData['full_name'] ?? 'User').toString().split(' ').first;

  return SliverAppBar(
    expandedHeight: 80,
    floating: true,
    pinned: true,
    snap: false,
    backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    flexibleSpace: FlexibleSpaceBar(
      titlePadding: EdgeInsets.zero,
      background: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          alignment: Alignment.bottomLeft,
          child: Row(
            children: [
              Text(
                'Welcome back, ',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.3,
                ),
              ),
              Expanded(
                child: Text(
                  firstName,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  Widget _buildNoProfileState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                size: 56,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Complete Your Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Get started by completing your professional profile\nand unlock opportunities.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/candidate-setup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Complete Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStrengthCard(BuildContext context, Map<String, dynamic> profileData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completeness = _calculateProfileCompleteness(profileData);
    final missingFields = _getMissingFields(profileData);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (completeness >= 90) {
      statusColor = const Color(0xFF10B981);
      statusText = 'Excellent';
      statusIcon = Icons.verified_rounded;
    } else if (completeness >= 70) {
      statusColor = const Color(0xFF3B82F6);
      statusText = 'Good';
      statusIcon = Icons.thumb_up_rounded;
    } else {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'Needs Attention';
      statusIcon = Icons.warning_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile Strength',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completeness%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: completeness / 100,
                        strokeWidth: 8,
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Icon(
                      statusIcon,
                      size: 32,
                      color: statusColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (missingFields.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Missing fields',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    missingFields.join(', '),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _navigateToEditProfile(context, profileData),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Complete Profile',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, Map<String, dynamic> profileData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.work_history_rounded,
            value: '${profileData['experience_years'] ?? 0}',
            label: 'Years',
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.code_rounded,
            value: '${_getSkillsCount(profileData)}',
            label: 'Skills',
            color: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.visibility_rounded,
            value: '0',
            label: 'Views',
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildProfileOverview(BuildContext context, Map<String, dynamic> profileData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildOverviewItem(
            context,
            icon: Icons.business_center_rounded,
            label: 'Role',
            value: _formatRole(profileData['role']),
            color: const Color(0xFF3B82F6),
          ),
          _buildDivider(context),
          _buildOverviewItem(
            context,
            icon: Icons.location_city_rounded,
            label: 'Location',
            value: '${profileData['city'] ?? 'N/A'}, ${profileData['state'] ?? 'N/A'}',
            color: const Color(0xFF10B981),
          ),
          _buildDivider(context),
          _buildOverviewItem(
            context,
            icon: Icons.school_rounded,
            label: 'Education',
            value: profileData['education'] ?? 'Not provided',
            color: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
      height: 1,
    );
  }

  Widget _buildQuickActions(BuildContext context, Map<String, dynamic> profileData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildActionButton(
          context,
          icon: Icons.edit_rounded,
          label: 'Edit Profile',
          subtitle: 'Update your information',
          onTap: () => _navigateToEditProfile(context, profileData),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          icon: Icons.description_rounded,
          label: 'Update Resume',
          subtitle: 'Keep your resume current',
          onTap: () => _navigateToEditProfile(context, profileData),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context, Map<String, dynamic> profileData) {
    final recommendations = _getRecommendations(profileData);

    return Column(
      children: recommendations.map((rec) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: rec['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: rec['color'].withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(rec['icon'], color: rec['color'], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rec['text'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: rec['color'],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Helper Methods

  void _navigateToEditProfile(BuildContext context, Map<String, dynamic> profileData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profileData: profileData),
      ),
    );

    if (result == true && mounted) {
      context.read<CandidateController>().checkProfileExists();
    }
  }

  int _calculateProfileCompleteness(Map<String, dynamic> profileData) {
    int totalFields = 12;
    int completedFields = 0;

    if (profileData['full_name']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['phone']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['age'] != null) completedFields++;
    if (profileData['role']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['experience_years'] != null) completedFields++;
    if (profileData['state']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['city']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['education']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['skills']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['resume_url']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['current_ctc'] != null) completedFields++;
    if (profileData['expected_ctc'] != null) completedFields++;

    return ((completedFields / totalFields) * 100).round();
  }

  List<String> _getMissingFields(Map<String, dynamic> profileData) {
    List<String> missing = [];

    if (profileData['resume_url']?.toString().isEmpty != false) missing.add('Resume');
    if (profileData['video_intro_url']?.toString().isEmpty != false) missing.add('Video');
    if (profileData['current_ctc'] == null) missing.add('Current CTC');
    if (profileData['expected_ctc'] == null) missing.add('Expected CTC');

    return missing.take(3).toList();
  }

  int _getSkillsCount(Map<String, dynamic> profileData) {
    final skillsList = profileData['skills_list'] as List<dynamic>?;
    return skillsList?.length ?? 0;
  }

  String _formatRole(String? role) {
    if (role == null) return 'Not specified';
    final roleMap = {
      'IT': 'IT Professional',
      'HR': 'HR Professional',
      'SUPPORT': 'Support',
      'SALES': 'Sales',
      'MARKETING': 'Marketing',
      'FINANCE': 'Finance',
      'DESIGN': 'Design',
      'OTHER': 'Other',
    };
    return roleMap[role] ?? role;
  }

  List<Map<String, dynamic>> _getRecommendations(Map<String, dynamic> profileData) {
    List<Map<String, dynamic>> recommendations = [];

    if (profileData['resume']?.toString().isEmpty != false) {
      recommendations.add({
        'icon': Icons.upload_file_rounded,
        'text': 'Upload your resume to get 3x more profile views',
        'color': const Color(0xFF3B82F6),
      });
    }

    if (profileData['video_intro']?.toString().isEmpty != false) {
      recommendations.add({
        'icon': Icons.videocam_rounded,
        'text': 'Add a video intro to stand out from other candidates',
        'color': const Color(0xFFEF4444),
      });
    }

    if (profileData['current_ctc'] == null || profileData['expected_ctc'] == null) {
      recommendations.add({
        'icon': Icons.payments_rounded,
        'text': 'Add salary details to match with relevant opportunities',
        'color': const Color(0xFF10B981),
      });
    }

    return recommendations.take(2).toList();
  }
}