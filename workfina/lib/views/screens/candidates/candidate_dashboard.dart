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
      backgroundColor: const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: () => context.read<CandidateController>().checkProfileExists(),
        color: AppTheme.primary,
        child: Consumer<CandidateController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return _buildLoadingState();
            }

            final profileData = controller.candidateProfile;

            if (profileData == null) {
              return _buildNoProfileState(context);
            }

            return _buildDashboardContent(profileData);
          },
        ),
      ),
    );
  }

  // ============================================================================
  // LOADING STATE
  // ============================================================================
  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading Dashboard...',
              style: AppTheme.getBodyStyle(
                context,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // NO PROFILE STATE
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // MAIN DASHBOARD CONTENT
  // ============================================================================
  Widget _buildDashboardContent(Map<String, dynamic> profileData) {
    return CustomScrollView(
      slivers: [
        // Modern App Bar
        _buildModernAppBar(profileData),

        // Dashboard Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Profile Strength Card
                _buildProfileStrengthCard(profileData),

                const SizedBox(height: 20),

                // Quick Stats Grid
                _buildQuickStatsGrid(profileData),

                const SizedBox(height: 24),

                // Section Header
                Text(
                  'Quick Actions',
                  style: AppTheme.getHeadlineStyle(
                    context,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Action Cards
                _buildActionCards(profileData),

                const SizedBox(height: 24),

                // Recent Activity or Tips
                _buildTipsSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // MODERN APP BAR
  // ============================================================================
  Widget _buildModernAppBar(Map<String, dynamic> profileData) {
    final firstName = (profileData['full_name'] ?? 'User').toString().split(' ').first;

    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: false,
      backgroundColor: AppTheme.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primary,
                AppTheme.primaryDark,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    firstName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        // title: Text(
        //   firstName,
        //   style: const TextStyle(
        //     color: Colors.white,
        //     fontSize: 20,
        //     fontWeight: FontWeight.w600,
        //   ),
        // ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {
            // Notification action
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ============================================================================
  // PROFILE STRENGTH CARD
  // ============================================================================
  Widget _buildProfileStrengthCard(Map<String, dynamic> profileData) {
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
      statusText = 'Needs Work';
      statusIcon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Strength',
                style: AppTheme.getHeadlineStyle(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
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
              // Progress Circle
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: completeness / 100,
                        strokeWidth: 8,
                        backgroundColor: AppTheme.lightBackground,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$completeness%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Completion',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (missingFields.isNotEmpty)
                      Text(
                        'Missing: ${missingFields.join(", ")}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (completeness < 100) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToEditProfile(context, profileData),
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Complete Profile',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================================
  // QUICK STATS GRID
  // ============================================================================
  Widget _buildQuickStatsGrid(Map<String, dynamic> profileData) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.work_outline_rounded,
            value: '${profileData['experience_years'] ?? 0}',
            label: 'Years Experience',
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_objects_outlined,
            value: '${_getSkillsCount(profileData)}',
            label: 'Skills Added',
            color: const Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
              height: 1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================================
  // ACTION CARDS
  // ============================================================================
  Widget _buildActionCards(Map<String, dynamic> profileData) {
    return Column(
      children: [
        _buildActionCard(
          icon: Icons.edit_note_rounded,
          title: 'Edit Profile',
          subtitle: 'Update your information',
          color: const Color(0xFF3B82F6),
          onTap: () => _navigateToEditProfile(context, profileData),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.description_outlined,
          title: 'Update Resume',
          subtitle: 'Keep your resume current',
          color: const Color(0xFF10B981),
          onTap: () => _navigateToEditProfile(context, profileData),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.search_rounded,
          title: 'Browse Jobs',
          subtitle: 'Find your next opportunity',
          color: const Color(0xFF8B5CF6),
          onTap: () {
            // Navigate to jobs
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
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
      ),
    );
  }

  // ============================================================================
  // TIPS SECTION
  // ============================================================================
  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withOpacity(0.1),
            AppTheme.primaryDark.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Profile Tips',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem('Add a professional photo to get 3x more profile views'),
          const SizedBox(height: 10),
          _buildTipItem('Keep your resume updated for better job matches'),
          const SizedBox(height: 10),
          _buildTipItem('Add detailed skills to stand out from other candidates'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // HELPER METHODS
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

    if (profileData['full_name']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['phone']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['age'] != null) completedFields++;
    if (profileData['role_name']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['experience_years'] != null) completedFields++;
    if (profileData['state_name']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['city_name']?.toString().isNotEmpty == true) completedFields++;
    if (profileData['education_name']?.toString().isNotEmpty == true) completedFields++;
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
}