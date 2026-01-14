import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/candidate_controller.dart';
import 'package:workfina/controllers/app_version_controller.dart';
import 'package:workfina/models/banner_model.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/views/screens/candidates/candidate_edit_profile.dart';
import 'package:workfina/views/screens/appVersion/app_version.dart';

class CandidateDashboard extends StatefulWidget {
  const CandidateDashboard({super.key});

  @override
  State<CandidateDashboard> createState() => _CandidateDashboardState();
}

class _CandidateDashboardState extends State<CandidateDashboard> {
    bool _isJobSearchActive = true; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateController>().checkProfileExists();
      _checkAppVersion();
    });
  }

  /// Check app version and show update dialog if needed
  Future<void> _checkAppVersion() async {
    final versionController = context.read<AppVersionController>();

    // Only check if not already checked
    if (versionController.hasChecked) return;

    await versionController.checkAppVersion();

    if (!mounted) return;

    // Show update dialog if update is available
    if (versionController.hasUpdate && versionController.versionInfo != null) {
      showAppVersionBottomSheet(
        context,
        versionInfo: versionController.versionInfo!,
      );
    }
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: FutureBuilder<BannerModel?>(
                    future: ApiService.fetchActiveBanner(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 180,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return SizedBox(
                          height: 180,
                          child: Center(
                            child: Text(
                              'Error loading banner: ${snapshot.error}',
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData) {
                        return SizedBox(
                          height: 180,
                          child: const Center(
                            child: Text('No banner available'),
                          ),
                        );
                      }

                      final banner = snapshot.data!; // Banner data

                      // ✅ Dynamic banner widget
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: 16 / 7,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(banner.image, fit: BoxFit.cover),

                              // Gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.65),
                                      Colors.black.withOpacity(0.10),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                              ),

                              // Content
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      banner.title, // API se aaya title
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                      ),
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                      ),
                                      child: Text(banner.buttonText),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

                      const SizedBox(height: 16),

                      _buildJobSearchToggleSection(),

const SizedBox(height: 24),

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
  // final fullName = profileData['full_name'] ?? 'User';
  final firstName = profileData['first_name'] ?? '';
  final lastName = profileData['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();

  final parts = fullName.trim().split(RegExp(r'\s+'));

  String displayName = parts.isNotEmpty && parts[0].isNotEmpty 
      ? parts[0] 
      : 'User';


    return AppBar(
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  elevation: 0,
  toolbarHeight: 60,
  titleSpacing: 0,
  automaticallyImplyLeading: false,
  title: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18 ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center, 
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
        const SizedBox(width: 16),
        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
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
      ],
    ),
  ),
  actions: [
    Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SvgPicture.asset(
        'assets/svg/bell.svg',
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.grey.shade600,
          BlendMode.srcIn,
        ),
      ),
    ),
  ],
);
  }

  Map<String, int> _calculateTotalExperience(Map<String, dynamic> profileData) {
    final workExperiences = profileData['work_experiences'] as List<dynamic>?;
    if (workExperiences == null || workExperiences.isEmpty) {
      return {'years': 0, 'months': 0};
    }

    int totalMonths = 0;
    final now = DateTime.now();

    for (var exp in workExperiences) {
      try {
        final startDate = DateTime.parse(exp['start_date']);
        final endDate = exp['is_current'] == true
            ? now
            : (exp['end_date'] != null ? DateTime.parse(exp['end_date']) : now);

        totalMonths +=
            ((endDate.year - startDate.year) * 12) +
            (endDate.month - startDate.month);
      } catch (e) {
        continue;
      }
    }

    return {'years': totalMonths ~/ 12, 'months': totalMonths % 12};
  }

  String _formatExperience(Map<String, dynamic> profileData) {
    final exp = _calculateTotalExperience(profileData);
    final years = exp['years']!;
    final months = exp['months']!;

    if (years == 0 && months == 0) return '0 Yrs';
    if (years == 0) return '$months Mo';
    if (months == 0) return '$years Yrs';

    return '$years Yrs $months Mo';
  }

  Widget _buildStatsSection(Map<String, dynamic> profileData) {
    final completeness = _calculateProfileCompleteness(profileData);
    final experienceYears = _calculateTotalExperience(profileData);
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
          _formatExperience(profileData),
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
    int totalFields = 16;
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
    // if (profileData['education_name']?.toString().isNotEmpty == true) {
    //   completedFields++;
    // }
    if (profileData['skills']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['resume_url']?.toString().isNotEmpty == true) {
      completedFields++;
    }
    if (profileData['current_ctc'] != null) completedFields++;
    if (profileData['expected_ctc'] != null) completedFields++;

    if (profileData['languages']?.toString().isNotEmpty == true)
      completedFields++;
    if (profileData['street_address']?.toString().isNotEmpty == true)
      completedFields++;
    if (profileData['career_objective']?.toString().isNotEmpty == true)
      completedFields++;
    if (profileData['profile_image_url']?.toString().isNotEmpty == true)
      completedFields++;

    final educations = profileData['educations'] as List<dynamic>?;
    if (educations != null && educations.isNotEmpty) completedFields++;

    return ((completedFields / totalFields) * 100).round();
  }

  int _getSkillsCount(Map<String, dynamic> profileData) {
    final skillsList = profileData['skills_list'] as List<dynamic>?;
    return skillsList?.length ?? 0;
  }

  Widget _buildJobSearchToggleSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 3), 
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(12), // ✅ Quick actions radius
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44, // ✅ Quick actions exact size
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade500.withOpacity(0.3), // ✅ Quick actions style
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isJobSearchActive ? Icons.visibility : Icons.visibility_off_outlined,
              size: 20, // ✅ Quick actions size
              color: isDark ? Colors.white : AppTheme.secondary,
            ),
          ),
          const SizedBox(width: 12), 
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ // ✅ Removed mainAxisAlignment.center
                Text(
                  'Job Search Status',
                  style: AppTheme.getBodyStyle(
                    context,
                    fontWeight: FontWeight.w600,
                    fontSize: 15, // ✅ Quick actions font
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isJobSearchActive 
                      ? 'Your profile is visible to recruiters' 
                      : 'Job search is paused - recruiters can\'t see you',
                  style: AppTheme.getSubtitleStyle(
                    context,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Toggle Switch
          Switch(
            value: _isJobSearchActive, // ✅ State variable use
            onChanged: (value) {
              setState(() {
                _isJobSearchActive = value; // ✅ State variable update
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '✅ Job search activated!' : '⏸️ Job search paused!'),
                  backgroundColor: value ? Colors.green : Colors.orange,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            activeColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withOpacity(0.6),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

}
