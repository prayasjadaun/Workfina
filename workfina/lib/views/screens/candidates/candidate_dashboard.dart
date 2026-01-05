import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return Consumer<CandidateController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.candidateProfile == null) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.secondary),
          );
        }

        final profileData = controller.candidateProfile;

        if (profileData == null) {
          return _buildNoProfileState(context);
        }

        return Container(
          height: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(context, profileData),

                // Main Heading
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to take the\nnext step?',
                        style: AppTheme.getHeadlineStyle(
                          context,
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats Overview Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildStatsSection(profileData),

                      const SizedBox(height: 32),

                      // Quick Actions Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quick Actions',
                            style: AppTheme.getTitleStyle(
                              context,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildQuickActionsSection(profileData),

                      const SizedBox(height: 32),

                      // Profile Tips Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Profile Tips',
                            style: AppTheme.getTitleStyle(
                              context,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildProfileTipsSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> profileData) {
    final fullName = profileData['full_name'] ?? 'User';
    final parts = fullName.trim().split(RegExp(r'\s+'));

    String displayName;
    if (parts.length >= 2) {
      displayName = parts[0];
    } else {
      displayName = parts[0];
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                displayName[0].toUpperCase(),
                style: AppTheme.getTitleStyle(
                  context,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello 👋',
                  style: AppTheme.getSubtitleStyle(
                    context,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  displayName,
                  style: AppTheme.getBodyStyle(
                    context,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Notification Icon
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              'assets/svg/bell.svg',
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.grey.shade600,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> profileData) {
    final completeness = _calculateProfileCompleteness(profileData);
    final experienceYears = profileData['experience_years'] ?? 0;
    final skillsCount = _getSkillsCount(profileData);

    Color statusColor;
    if (completeness >= 90) {
      statusColor = const Color(0xFF10B981);
    } else if (completeness >= 70) {
      statusColor = const Color(0xFF3B82F6);
    } else {
      statusColor = const Color(0xFFF59E0B);
    }

    return GridView.count(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 24),
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.8,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          Icons.verified_user_outlined,
          'Profile',
          '$completeness%',
          statusColor,
        ),
        _buildStatCard(
          Icons.work_outline_rounded,
          'Experience',
          '$experienceYears Yrs',
          AppTheme.secondary,
        ),
        _buildStatCard(
          Icons.emoji_objects_outlined,
          'Skills',
          skillsCount.toString(),
          AppTheme.accentPrimary,
        ),
        _buildStatCard(
          Icons.description_outlined,
          'Resume',
          profileData['resume_url']?.toString().isNotEmpty == true
              ? 'Added'
              : 'Pending',
          profileData['resume_url']?.toString().isNotEmpty == true
              ? const Color(0xFF10B981)
              : AppTheme.accentSecondary,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String value,
    Color accentColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade500.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isDark ? Colors.white : AppTheme.secondary,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTheme.getSubtitleStyle(
                    context,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.getHeadlineStyle(
                    context,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(Map<String, dynamic> profileData) {
    return Column(
      children: [
        _buildActionCard(
          icon: Icons.edit_note_rounded,
          title: 'Edit Profile',
          subtitle: 'Update your information',
          onTap: () => _navigateToEditProfile(context, profileData),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.description_outlined,
          title: 'Update Resume',
          subtitle: 'Keep your resume current',
          onTap: () => _navigateToEditProfile(context, profileData),
        ),
        // const SizedBox(height: 12),
        // _buildActionCard(
        //   icon: Icons.search_rounded,
        //   title: 'Browse Jobs',
        //   subtitle: 'Find your next opportunity',
        //   onTap: () {
        //     // Navigate to jobs
        //   },
        // ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardBackground : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade500.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDark ? Colors.white : AppTheme.secondary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.getBodyStyle(
                      context,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.getSubtitleStyle(
                      context,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTipsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tips = [
      {
        'icon': Icons.photo_camera_outlined,
        'text': 'Add a professional photo to get 3x more profile views',
      },
      {
        'icon': Icons.description_outlined,
        'text': 'Keep your resume updated for better job matches',
      },
      {
        'icon': Icons.star_outline_rounded,
        'text': 'Add detailed skills to stand out from other candidates',
      },
    ];

    return Column(
      children: tips
          .map(
            (tip) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardBackground : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      tip['icon'] as IconData,
                      size: 20,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip['text'] as String,
                      style: AppTheme.getBodyStyle(
                        context,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ============================================================================
  // NO PROFILE STATE (kept same as original)
  // ============================================================================
  Widget _buildNoProfileState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_alt_1,
                size: 64,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Complete Your Profile',
              style: AppTheme.getHeadlineStyle(
                context,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Get started by completing your profile\nand unlock opportunities.',
              textAlign: TextAlign.center,
              style: AppTheme.getBodyStyle(
                context,
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/candidate-setup');
                },
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // HELPER METHODS (kept same as original)
  // ============================================================================

  void _navigateToEditProfile(
    BuildContext context,
    Map<String, dynamic> profileData,
  ) async {
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

    if (profileData['full_name']?.toString().isNotEmpty == true) {
      completedFields++;
    }
    if (profileData['phone']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['age'] != null) completedFields++;
    if (profileData['role_name']?.toString().isNotEmpty == true) {
      completedFields++;
    }
    if (profileData['experience_years'] != null) completedFields++;
    if (profileData['state_name']?.toString().isNotEmpty == true) {
      completedFields++;
    }
    if (profileData['city_name']?.toString().isNotEmpty == true) {
      completedFields++;
    }
    if (profileData['education_name']?.toString().isNotEmpty == true) {
      completedFields++;
    }
    if (profileData['skills']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['resume_url']?.toString().isNotEmpty == true) {
      completedFields++;
    }
    if (profileData['current_ctc'] != null) completedFields++;
    if (profileData['expected_ctc'] != null) completedFields++;

    return ((completedFields / totalFields) * 100).round();
  }

  int _getSkillsCount(Map<String, dynamic> profileData) {
    final skillsList = profileData['skills_list'] as List<dynamic>?;
    return skillsList?.length ?? 0;
  }
}
