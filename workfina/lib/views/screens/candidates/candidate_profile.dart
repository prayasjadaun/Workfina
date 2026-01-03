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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateController>().checkProfileExists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: Consumer<CandidateController>(
        builder: (context, profileController, child) {
          // Loading State
          if (profileController.isLoading) {
            return _buildLoadingState();
          }

          // Error State
          if (profileController.error != null) {
            return _buildErrorState(profileController);
          }

          final profileData = profileController.candidateProfile;

          // No Profile State
          if (profileData == null) {
            return _buildNoProfileState();
          }

          // Main Profile Content
          return _buildProfileContent(profileData, user);
        },
      ),
    );
  }

  // ============================================================================
  // STEP 1: LOADING STATE
  // ============================================================================
  Widget _buildLoadingState() {
    return Container(
      decoration: AppTheme.getGradientDecoration(context),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [AppTheme.getCardShadow(context)],
              ),
              child: const CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading your profile...',
              style: AppTheme.getTitleStyle(
                context,
                fontSize: 16,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // STEP 2: ERROR STATE
  // ============================================================================
  Widget _buildErrorState(CandidateController controller) {
    return Container(
      decoration: AppTheme.getGradientDecoration(context),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: AppTheme.getHeadlineStyle(
                  context,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                controller.error!,
                style: AppTheme.getBodyStyle(
                  context,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => controller.checkProfileExists(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // STEP 3: NO PROFILE STATE
  // ============================================================================
  Widget _buildNoProfileState() {
    return Container(
      decoration: AppTheme.getGradientDecoration(context),
      child: Center(
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
                  Icons.person_add_outlined,
                  size: 80,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Complete Your Profile',
                style: AppTheme.getHeadlineStyle(
                  context,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Set up your profile to unlock amazing job opportunities and connect with top recruiters',
                style: AppTheme.getBodyStyle(
                  context,
                  color: Colors.grey.shade600,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/candidate-setup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // STEP 4: MAIN PROFILE CONTENT
  // ============================================================================
  Widget _buildProfileContent(
    Map<String, dynamic> profileData,
    Map<String, dynamic>? user,
  ) {
    return Container(
      decoration: AppTheme.getGradientDecoration(context),
      child: RefreshIndicator(
        onRefresh: () =>
            context.read<CandidateController>().checkProfileExists(),
        color: AppTheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Custom App Bar
            _buildSliverAppBar(profileData),

            // Profile Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Stats Cards
                    _buildStatsRow(profileData),

                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActions(profileData),

                    const SizedBox(height: 24),

                    // Profile Sections
                    _buildProfileSections(profileData),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // STEP 5: SLIVER APP BAR (Header with Profile Picture)
  // ============================================================================
  Widget _buildSliverAppBar(Map<String, dynamic> profileData) {
    return SliverAppBar(
      expandedHeight: 250,
      floating: false,
      pinned: false,
      backgroundColor: AppTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          // decoration: BoxDecoration(
          //   // gradient: LinearGradient(
          //   //   begin: Alignment.topLeft,
          //   //   end: Alignment.bottomRight,
          //   //   // colors: [
          //   //   //   AppTheme.primary,
          //   //   //   AppTheme.primaryDark,
          //   //   // ],
          //   // ),
          // ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 13),
                // Profile Picture
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            profileData['profile_image_url'] != null
                            ? NetworkImage(profileData['profile_image_url'])
                            : null,
                        child: profileData['profile_image_url'] == null
                            ? Text(
                                (profileData['full_name']?[0] ?? 'C')
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 36,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Name
                Text(
                  profileData['full_name'] ?? 'Candidate',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Role
                Text(
                  _formatRole(profileData['role_name']),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                // Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      profileData['city_name'] ?? 'N/A',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.edit_outlined, color: Colors.white),
      //     onPressed: () => _showEditProfileDialog(context, profileData),
      //   ),
      // ],
    );
  }

  // ============================================================================
  // STEP 6: STATS ROW (Experience, Age, etc.)
  // ============================================================================

  Widget _buildStatsRow(Map<String, dynamic> profileData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: const Color(0xFFFF9800),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Profile Statistics',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Experience
          _buildStatInfoRow(
            icon: Icons.work_outline_rounded,
            label: 'Experience',
            value: '${profileData['experience_years'] ?? 0} years',
            iconColor: const Color(0xFF1976D2),
          ),

          const SizedBox(height: 16),

          // Age
          _buildStatInfoRow(
            icon: Icons.cake_outlined,
            label: 'Age',
            value: '${profileData['age'] ?? 0} years',
            iconColor: const Color(0xFF388E3C),
          ),

          const SizedBox(height: 8),

          // Education
          _buildStatInfoRow(
            icon: Icons.school_outlined,
            label: 'Education',
            value: _getHighestEducation(profileData['education_details']),
            iconColor: const Color(0xFF7B1FA2),
          ),
        ],
      ),
    );
  }

  String _getHighestEducation(String? educationDetails) {
    if (educationDetails == null || educationDetails.isEmpty)
      return 'Not specified';

    // Split by | to get individual education entries
    List<String> educations = educationDetails.split('|');

    // Priority order: Post-Graduation > Graduation > 12th > 10th
    String? postGrad;
    String? grad;
    String? twelfth;
    String? tenth;

    for (String edu in educations) {
      String trimmed = edu.trim();
      if (trimmed.startsWith('Post-Graduation:')) {
        postGrad = trimmed
            .replaceFirst('Post-Graduation:', '')
            .split(',')
            .first
            .trim();
      } else if (trimmed.startsWith('Graduation:')) {
        grad = trimmed.replaceFirst('Graduation:', '').split(',').first.trim();
      } else if (trimmed.startsWith('12th:')) {
        twelfth = trimmed.replaceFirst('12th:', '').split(',').first.trim();
      } else if (trimmed.startsWith('10th:')) {
        tenth = trimmed.replaceFirst('10th:', '').split(',').first.trim();
      }
    }

    // Return highest qualification
    if (postGrad != null) return postGrad;
    if (grad != null) return grad;
    if (twelfth != null) return twelfth;
    if (tenth != null) return tenth;

    return 'Not specified';
  }

  Widget _buildStatInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
            letterSpacing: 0.1,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  // ============================================================================
  // STEP 7: QUICK ACTIONS (Resume, Edit Profile, etc.)
  // ============================================================================
  Widget _buildQuickActions(Map<String, dynamic> profileData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.flash_on_outlined,
                  color: AppTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Resume Action
          _buildActionRow(
            icon: Icons.description_outlined,
            label: 'View Resume',
            subtitle: 'Download or view your resume',
            onTap: () => _handleResumeClick(context, profileData),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),

          // Edit Profile Action
          _buildActionRow(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            subtitle: 'Update your information',
            onTap: () => _showEditProfileDialog(context, profileData),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),

          // Share Profile Action (Optional)
          // _buildActionRow(
          //   icon: Icons.share_outlined,
          //   label: 'Share Profile',
          //   subtitle: 'Share with recruiters',
          //   onTap: () {
          //     // Add share functionality
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(
          //         content: const Text('Share profile feature coming soon'),
          //         behavior: SnackBarBehavior.floating,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.1,
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

  // ============================================================================
  // STEP 8: PROFILE SECTIONS (Contact, Professional, etc.)
  // ============================================================================
  Widget _buildProfileSections(Map<String, dynamic> profileData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Details',
          style: AppTheme.getHeadlineStyle(
            context,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Contact Information
        _buildSectionCard(
          title: 'Contact Information',
          icon: Icons.contact_phone_rounded,
          iconColor: AppTheme.primary,
          children: [
            _buildInfoRow(
              icon: Icons.email_rounded,
              label: 'Email',
              value: profileData['email'] ?? 'N/A',
            ),
            _buildInfoRow(
              icon: Icons.phone_rounded,
              label: 'Phone',
              value: profileData['phone'] ?? 'N/A',
            ),
            _buildInfoRow(
              icon: Icons.location_city_rounded,
              label: 'Location',
              value:
                  '${profileData['city_name'] ?? 'N/A'}, ${profileData['state_name'] ?? 'N/A'}',
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Professional Information
        _buildSectionCard(
          title: 'Professional Information',
          icon: Icons.work_rounded,
          iconColor: AppTheme.accentPrimary,
          children: [
            _buildInfoRow(
              icon: Icons.business_center_rounded,
              label: 'Role',
              value: _formatRole(profileData['role_name']),
            ),
            _buildInfoRow(
              icon: Icons.work_history_rounded,
              label: 'Experience',
              value: '${profileData['experience_years'] ?? 0} years',
            ),
            if (profileData['current_ctc'] != null)
              _buildInfoRow(
                icon: Icons.currency_rupee_rounded,
                label: 'Current CTC',
                value: '₹${profileData['current_ctc']} LPA',
              ),
            if (profileData['expected_ctc'] != null)
              _buildInfoRow(
                icon: Icons.trending_up_rounded,
                label: 'Expected CTC',
                value: '₹${profileData['expected_ctc']} LPA',
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Skills Section
        _buildSkillsSection(profileData),

        const SizedBox(height: 16),

        // Education Section
        _buildSectionCard(
          title: 'Education',
          icon: Icons.school_rounded,
          iconColor: AppTheme.accentSecondary,
          onTap: () => _showEducationDetails(context, profileData),
          children: [
            Text(
              profileData['education_name'] ?? 'Not provided',
              style: AppTheme.getBodyStyle(context, fontSize: 15),
            ),
            if (profileData['education_details'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  profileData['education_details'],
                  style: AppTheme.getSubtitleStyle(
                    context,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ============================================================================
  // STEP 9: SECTION CARD WIDGET
  // ============================================================================
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTheme.getCardTitleStyle(context),
                      ),
                    ),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // STEP 10: INFO ROW WIDGET
  // ============================================================================
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primary.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.getBodyStyle(
                context,
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.getBodyStyle(
                context,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // STEP 11: SKILLS SECTION
  // ============================================================================
  Widget _buildSkillsSection(Map<String, dynamic> profileData) {
    final skillsList = profileData['skills_list'] as List<dynamic>? ?? [];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSkillsDetails(context, profileData),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: AppTheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Skills & Expertise',
                        style: AppTheme.getCardTitleStyle(context),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                skillsList.isEmpty
                    ? Text(
                        'No skills added yet',
                        style: AppTheme.getBodyStyle(
                          context,
                          color: Colors.grey.shade600,
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: skillsList.take(6).map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              skill.toString(),
                              style: AppTheme.getLabelStyle(
                                context,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                if (skillsList.length > 6)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '+${skillsList.length - 6} more skills',
                      style: AppTheme.getBodyStyle(
                        context,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

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

  String _getEducationShort(String? education) {
    if (education == null) return 'N/A';
    if (education.toLowerCase().contains('post')) return 'PG';
    if (education.toLowerCase().contains('grad')) return 'UG';
    return education.substring(0, education.length > 3 ? 3 : education.length);
  }

  // ============================================================================
  // CLICK HANDLERS
  // ============================================================================

  void _showEditProfileDialog(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile refreshed successfully!'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
        SnackBar(
          content: const Text('No resume uploaded yet'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Resume Options',
              style: AppTheme.getHeadlineStyle(
                context,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildBottomSheetOption(
              icon: Icons.visibility_rounded,
              label: 'View Resume',
              onTap: () {
                Navigator.pop(context);
                _launchURL(resumeUrl.toString());
              },
            ),
            const SizedBox(height: 12),
            _buildBottomSheetOption(
              icon: Icons.download_rounded,
              label: 'Download Resume',
              onTap: () {
                Navigator.pop(context);
                _launchURL(resumeUrl.toString());
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTheme.getTitleStyle(
                context,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Experience Details',
          style: AppTheme.getHeadlineStyle(
            context,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                '₹${profileData['current_ctc']} LPA',
              ),
            if (profileData['expected_ctc'] != null)
              _buildDetailRow(
                'Expected CTC',
                '₹${profileData['expected_ctc']} LPA',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Education',
          style: AppTheme.getHeadlineStyle(
            context,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profileData['education_name'] ?? 'Not provided',
              style: AppTheme.getBodyStyle(context, fontSize: 16),
            ),
            if (profileData['education_details'] != null) ...[
              const SizedBox(height: 12),
              Text(
                'Details:',
                style: AppTheme.getBodyStyle(
                  context,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                profileData['education_details'],
                style: AppTheme.getBodyStyle(
                  context,
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
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

  void _showSkillsDetails(
    BuildContext context,
    Map<String, dynamic> profileData,
  ) {
    final skillsList = profileData['skills_list'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'All Skills',
          style: AppTheme.getHeadlineStyle(
            context,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: skillsList.isEmpty
            ? const Text('No skills added yet')
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skillsList.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      skill.toString(),
                      style: AppTheme.getLabelStyle(
                        context,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open resume'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
