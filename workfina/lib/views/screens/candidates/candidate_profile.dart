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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // appBar: AppBar(),
      body: Container(
        height: double.infinity,
        color: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        child: Consumer<CandidateController>(
          builder: (context, profileController, child) {
            // Loading State
            if (profileController.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                ),
              );
            }

            // Error State
            if (profileController.error != null) {
              return _buildErrorState(profileController, isDark);
            }

            final profileData = profileController.candidateProfile;

            // No Profile State
            if (profileData == null) {
              return _buildNoProfileState(isDark);
            }

            // Main Profile Content
            return _buildProfileContent(profileData, user, isDark);
          },
        ),
      ),
    );
  }

  // ============================================================================
  // ERROR STATE
  // ============================================================================
  Widget _buildErrorState(CandidateController controller, bool isDark) {
    return Center(
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
    );
  }

  // ============================================================================
  // NO PROFILE STATE
  // ============================================================================
  Widget _buildNoProfileState(bool isDark) {
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
    );
  }

  // ============================================================================
  // MAIN PROFILE CONTENT
  // ============================================================================
  Widget _buildProfileContent(
    Map<String, dynamic> profileData,
    Map<String, dynamic>? user,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Profile Header
          _buildProfileHeader(profileData, isDark),

          const SizedBox(height: 20),

          // Statistics Card
          _buildStatisticsCard(profileData, isDark),

          const SizedBox(height: 20),

          // Quick Actions Card
          _buildQuickActionsCard(profileData, isDark),

          const SizedBox(height: 20),

          // Contact Information Card
          _buildContactInfoCard(profileData, isDark),

          const SizedBox(height: 20),

          // Professional Information Card
          _buildProfessionalInfoCard(profileData, isDark),

          const SizedBox(height: 20),

          // Skills Card
          _buildSkillsCard(profileData, isDark),

          const SizedBox(height: 20),

          // Education Card
          // _buildEducationCard(profileData, isDark),

          const SizedBox(height: 20),

          // Logout Card
          _buildLogoutCard(isDark),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ============================================================================
  // PROFILE HEADER
  // ============================================================================
  Widget _buildProfileHeader(Map<String, dynamic> profileData, bool isDark) {
  final firstName = (profileData['first_name'] ?? '').trim();
final lastName = (profileData['last_name'] ?? '').trim();
  final fullName = firstName.isNotEmpty||lastName.isNotEmpty ? '$firstName $lastName'.trim() 
      : 'Candidate';
  
  String firstLetter = 'C';
  
  if (fullName.isNotEmpty && fullName != 'Candidate') {
    firstLetter = fullName[0].toUpperCase();
  }
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        // Profile Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
            image: profileData['profile_image_url'] != null
                ? DecorationImage(
                    image: NetworkImage(profileData['profile_image_url']),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: profileData['profile_image_url'] == null
              ? Center(
                  child: Text(
                    firstLetter,
                    style: AppTheme.getHeadlineStyle(
                      context,
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),

        // Name
        Text(
          fullName,
          style: AppTheme.getTitleStyle(
            context,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),

        // Email
        Text(
          profileData['email'] ?? 'N/A',
          style: AppTheme.getSubtitleStyle(
            context,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),

        // Role Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.work_outline_rounded,
                color: AppTheme.primary,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                _formatRole(profileData['role_name']),
                style: AppTheme.getLabelStyle(
                  context,
                  color: AppTheme.primary,
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

  // ============================================================================
  // STATISTICS CARD
  // ============================================================================
  Widget _buildStatisticsCard(Map<String, dynamic> profileData, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 126, 126, 125).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: const Color.fromARGB(255, 16, 16, 16),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Profile Statistics',
                  style: AppTheme.getTitleStyle(
                    context,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Statistics Items
          // _buildProfileInfoItem(
          //   icon: Icons.work_outline_rounded,
          //   title: 'Experience',
          //   value: '${profileData['experience_years'] ?? 0} years',
          //   isDark: isDark,
          //   iconColor: const Color.fromARGB(255, 35, 35, 36),
          // ),
          _buildDivider(isDark),
          _buildProfileInfoItem(
            icon: Icons.cake_outlined,
            title: 'Age',
            value: '${profileData['age'] ?? 0} years',
            isDark: isDark,
            iconColor: const Color.fromARGB(255, 25, 25, 25),
          ),
          _buildDivider(isDark),
          _buildProfileInfoItem(
            icon: Icons.school_outlined,
            title: 'Education',
            value: _getHighestEducation(profileData['educations']),
            isDark: isDark,
            iconColor: const Color.fromARGB(255, 18, 18, 18),
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // QUICK ACTIONS CARD
  // ============================================================================
  Widget _buildQuickActionsCard(Map<String, dynamic> profileData, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
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
                  style: AppTheme.getTitleStyle(
                    context,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          _buildActionItem(
            icon: Icons.description_outlined,
            title: 'View Resume',
            value: 'Download or view your resume',
            isDark: isDark,
            onTap: () => _handleResumeClick(context, profileData),
          ),
          _buildDivider(isDark),
          _buildActionItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            value: 'Update your information',
            isDark: isDark,
            onTap: () => _showEditProfileDialog(context, profileData),
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // CONTACT INFORMATION CARD
  // ============================================================================
  Widget _buildContactInfoCard(Map<String, dynamic> profileData, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.contact_phone_rounded,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Contact Information',
                  style: AppTheme.getTitleStyle(
                    context,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Contact Details
          _buildProfileInfoItem(
            icon: Icons.email_rounded,
            title: 'Email',
            value: profileData['email'] ?? 'N/A',
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildProfileInfoItem(
            icon: Icons.phone_rounded,
            title: 'Phone',
            value: profileData['phone'] ?? 'N/A',
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildProfileInfoItem(
            icon: Icons.location_city_rounded,
            title: 'Location',
            value:
                '${profileData['city_name'] ?? 'N/A'}, ${profileData['state_name'] ?? 'N/A'}',
            isDark: isDark,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PROFESSIONAL INFORMATION CARD
  // ============================================================================
  Widget _buildProfessionalInfoCard(
      Map<String, dynamic> profileData, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 95, 94, 93).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.work_rounded,
                    color: const Color.fromARGB(255, 9, 9, 9),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Professional Information',
                  style: AppTheme.getTitleStyle(
                    context,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Professional Details
          _buildProfileInfoItem(
            icon: Icons.business_center_rounded,
            title: 'Role',
            value: _formatRole(profileData['role_name']),
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildProfileInfoItem(
            icon: Icons.work_history_rounded,
            title: 'Experience',
            value: '${profileData['experience_years'] ?? 0} years',
            isDark: isDark,
          ),
          if (profileData['current_ctc'] != null) ...[
            _buildDivider(isDark),
            _buildProfileInfoItem(
              icon: Icons.currency_rupee_rounded,
              title: 'Current CTC',
              value: '₹${profileData['current_ctc']} LPA',
              isDark: isDark,
            ),
          ],
          if (profileData['expected_ctc'] != null) ...[
            _buildDivider(isDark),
            _buildProfileInfoItem(
              icon: Icons.trending_up_rounded,
              title: 'Expected CTC',
              value: '₹${profileData['expected_ctc']} LPA',
              isDark: isDark,
              isLast: true,
            ),
          ],
          if (profileData['current_ctc'] == null &&
              profileData['expected_ctc'] == null)
            const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ============================================================================
  // SKILLS CARD
  // ============================================================================
  Widget _buildSkillsCard(Map<String, dynamic> profileData, bool isDark) {
    final skillsList = profileData['skills_list'] as List<dynamic>? ?? [];

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _showSkillsDetails(context, profileData, isDark),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.psychology_rounded,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Skills & Expertise',
                        style: AppTheme.getTitleStyle(
                          context,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Skills Display
                skillsList.isEmpty
                    ? Text(
                        'No skills added yet',
                        style: AppTheme.getBodyStyle(
                          context,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
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
  // EDUCATION CARD
  // ============================================================================
  // Widget _buildEducationCard(Map<String, dynamic> profileData, bool isDark) {
  //   return Material(
  //     color: Colors.transparent,
  //     child: Container(
  //       width: double.infinity,
  //       decoration: BoxDecoration(
  //         color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
  //         borderRadius: BorderRadius.circular(16),
  //         boxShadow: [
  //           BoxShadow(
  //             color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
  //             blurRadius: 10,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: InkWell(
  //         onTap: () => _showEducationDetails(context, profileData, isDark),
  //         borderRadius: BorderRadius.circular(16),
  //         child: Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               // Header
  //               Row(
  //                 children: [
  //                   Container(
  //                     padding: const EdgeInsets.all(10),
  //                     decoration: BoxDecoration(
  //                       color: const Color.fromARGB(255, 24, 24, 24).withOpacity(0.1),
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                     child: Icon(
  //                       Icons.school_rounded,
  //                       color: const Color.fromARGB(255, 0, 0, 0),
  //                       size: 22,
  //                     ),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: Text(
  //                       'Education',
  //                       style: AppTheme.getTitleStyle(
  //                         context,
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ),
  //                   Icon(
  //                     Icons.arrow_forward_ios_rounded,
  //                     size: 16,
  //                     color: isDark ? Colors.grey[600] : Colors.grey[400],
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 16),

  //               // Education Info
  //               Text(
  //                 profileData['education_name'] ?? 'Not provided',
  //                 style: AppTheme.getBodyStyle(
  //                   context,
  //                   fontSize: 15,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //               if (profileData['education_details'] != null)
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 8),
  //                   child: Text(
  //                     profileData['education_details'],
  //                     style: AppTheme.getSubtitleStyle(
  //                       context,
  //                       color: isDark ? Colors.grey[400] : Colors.grey[600],
  //                     ),
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // ============================================================================
  // LOGOUT CARD
  // ============================================================================
  Widget _buildLogoutCard(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _showLogoutDialog(context, isDark),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: _buildProfileInfoItem(
              icon: Icons.logout_rounded,
              title: 'Log Out',
              value: 'Log out from your account',
              isDark: isDark,
              isLast: true,
              titleColor: Colors.red,
              iconColor: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // REUSABLE WIDGETS
  // ============================================================================
  Widget _buildProfileInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
    bool isLast = false,
    Color? titleColor,
    Color? iconColor,
  }) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: isLast ? 20 : 16,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor ?? AppTheme.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.getBodyStyle(
                    context,
                    color:
                        titleColor ?? (isDark ? Colors.white : Colors.black87),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.getSubtitleStyle(
                    context,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: isLast ? 20 : 16,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.getBodyStyle(
                      context,
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTheme.getSubtitleStyle(
                      context,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        thickness: 1,
        color: isDark ? Colors.grey[800] : Colors.grey[200],
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

  List<Map<String, dynamic>> _parseBackendList(String? data) {
    if (data == null || data.isEmpty) return [];
    
    try {
      String cleaned = data.trim();
      if (cleaned.startsWith('[') && cleaned.endsWith(']')) {
        cleaned = cleaned.substring(1, cleaned.length - 1);
      }
      
      List<String> items = [];
      int braceCount = 0;
      int startIndex = 0;
      
      for (int i = 0; i < cleaned.length; i++) {
        if (cleaned[i] == '{') {
          braceCount++;
          if (braceCount == 1) startIndex = i;
        } else if (cleaned[i] == '}') {
          braceCount--;
          if (braceCount == 0) {
            items.add(cleaned.substring(startIndex, i + 1));
          }
        }
      }
      
      List<Map<String, dynamic>> result = [];
      for (String item in items) {
        Map<String, dynamic> map = {};
        String content = item.substring(1, item.length - 1);
        
        List<String> pairs = [];
        int depth = 0;
        int lastSplit = 0;
        
        for (int i = 0; i < content.length; i++) {
          if (content[i] == '{') depth++;
          if (content[i] == '}') depth--;
          
          if (depth == 0 && i < content.length - 1) {
            if (content[i] == ',' && content[i + 1] == ' ') {
              pairs.add(content.substring(lastSplit, i));
              lastSplit = i + 2;
            }
          }
        }
        pairs.add(content.substring(lastSplit));
        
        for (String pair in pairs) {
          List<String> parts = pair.split(': ');
          if (parts.length == 2) {
            String key = parts[0].trim();
            String value = parts[1].trim();
            
            if (value == 'null') {
              map[key] = null;
            } else if (value == 'true') {
              map[key] = true;
            } else if (value == 'false') {
              map[key] = false;
            } else {
              map[key] = value;
            }
          }
        }
        
        result.add(map);
      }
      
      return result;
    } catch (e) {
      print('Error parsing: $e');
      return [];
    }
  }

  String _getHighestEducation(List<dynamic>? educationList) {
  if (educationList == null || educationList.isEmpty) {
    return 'Not specified';
  }

  // Find highest degree
  String? highestDegree;

  for (var edu in educationList) {
    String degree = edu['degree']?.toString() ?? '';

    // Priority 1: Post-graduation (MCA, MBA, Master's)
    if (degree.toLowerCase().contains('master') || 
        degree.toLowerCase().contains('post') ||
        degree.toLowerCase().contains('mca') ||
        degree.toLowerCase().contains('mba') ||
        degree.toLowerCase().contains('m.tech')) {
      return degree; // Found highest - return immediately
    } 
    // Priority 2: Graduation (BCA, B.Tech, Bachelor's)
    else if (degree.toLowerCase().contains('bachelor') ||
             degree.toLowerCase().contains('graduation') ||
             degree.toLowerCase().contains('bca') ||
             degree.toLowerCase().contains('b.tech') ||
             degree.toLowerCase().contains('b.e')) {
      if (highestDegree == null) {
        highestDegree = degree;
      }
    } 
    // Priority 3: Others (12th, 10th, etc.)
    else {
      if (highestDegree == null && degree.isNotEmpty) {
        highestDegree = degree;
      }
    }
  }

  return highestDegree ?? 'Not specified';
}


 
  // ============================================================================
  // DIALOG & INTERACTION HANDLERS
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
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
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                _launchURL(resumeUrl.toString());
              },
            ),
            const SizedBox(height: 12),
            // _buildBottomSheetOption(
            //   icon: Icons.download_rounded,
            //   label: 'Download Resume',
            //   isDark: isDark,
            //   onTap: () {
            //     Navigator.pop(context);
            //     _launchURL(resumeUrl.toString());
            //   },
            // ),
            // const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey.shade300),
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

  void _showSkillsDetails(
    BuildContext context,
    Map<String, dynamic> profileData,
    bool isDark,
  ) {
    final skillsList = profileData['skills_list'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'All Skills',
          style: AppTheme.getTitleStyle(context, fontWeight: FontWeight.w600),
        ),
        content: skillsList.isEmpty
            ? Text(
                'No skills added yet',
                style: AppTheme.getBodyStyle(context),
              )
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
            child: Text(
              'Close',
              style: AppTheme.getBodyStyle(
                context,
                color: AppTheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEducationDetails(
    BuildContext context,
    Map<String, dynamic> profileData,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Education',
          style: AppTheme.getTitleStyle(context, fontWeight: FontWeight.w600),
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
                  color: isDark ? Colors.grey[400] : Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTheme.getBodyStyle(
                context,
                color: AppTheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout',
          style: AppTheme.getTitleStyle(context, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTheme.getBodyStyle(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.getBodyStyle(
                context,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              await context.read<AuthController>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/email',
                (route) => false,
              );
            },
            child: Text(
              'Logout',
              style: AppTheme.getBodyStyle(
                context,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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