import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/views/screens/recuriters/recruiter_candidate_details_screen.dart';

class RecruiterDashboard extends StatefulWidget {
  const RecruiterDashboard({super.key});

  @override
  State<RecruiterDashboard> createState() => _RecruiterDashboardState();
}

class _RecruiterDashboardState extends State<RecruiterDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecruiterController>().loadCandidates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecruiterController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.hrProfile == null) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.secondary),
          );
        }

        final profile = controller.hrProfile;
        final wallet = controller.wallet;
        final balance = wallet?['balance'] ?? 0;
        final totalSpent = profile?['total_spent'] ?? 0;
        final unlockedCount = controller.unlockedCandidateIds.length;

        return Container(
          height: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(context, controller),

                // Main Heading
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What would you like to\nfind today?',
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
                      _buildStatsSection(
                        balance,
                        unlockedCount,
                        totalSpent,
                        controller.candidates.length,
                      ),

                      const SizedBox(height: 32),

                      // Recent Activity Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Activity',
                            style: AppTheme.getTitleStyle(
                              context,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to full activity
                            },
                            child: Text(
                              'View all',
                              style: AppTheme.getBodyStyle(
                                context,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildRecentActivitySection(controller),
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

  Widget _buildHeader(BuildContext context, RecruiterController controller) {
    final profile = controller.hrProfile;
    final fullName = profile?['full_name'] ?? 'HR';

    final parts = fullName.trim().split(RegExp(r'\s+'));

    String displayName;

    if (parts.length >= 3) {
      displayName = '${parts[1]} ${parts[2]}';
    } else if (parts.length == 2) {
      displayName = '${parts[0]}';
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
            // width: 30,
            // height: 30,
            decoration: BoxDecoration(
              color: Colors.grey.shade200.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              'assets/svgs/notification.svg',
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

  Widget _buildStatsSection(
    int balance,
    int unlockedCount,
    int totalSpent,
    int totalCandidates,
  ) {
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
          'assets/svgs/wallet.svg',
          'Credits',
          balance.toString(),
          AppTheme.secondary,
        ),
        _buildStatCard(
          'assets/svgs/unlock.svg',
          'Unlocked',
          unlockedCount.toString(),
          AppTheme.accentPrimary,
        ),
        _buildStatCard(
          'assets/svgs/spend.svg',
          'Total Spent',
          totalSpent.toString(),
          AppTheme.accentSecondary,
        ),
        _buildStatCard(
          'assets/svgs/candidates.svg',
          'Candidates',
          totalCandidates.toString(),
          AppTheme.secondary,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String iconPath,
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
              color: Colors.grey.shade200.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              iconPath,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : AppTheme.secondary,
                BlendMode.srcIn,
              ),
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

  Widget _buildRecentActivitySection(RecruiterController controller) {
    if (controller.unlockedCandidateIds.isEmpty) {
      return _buildEmptyState();
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUnlockedCandidates(controller),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final unlockedCandidates =
            snapshot.data?['unlocked_candidates'] as List? ?? [];

        if (unlockedCandidates.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: unlockedCandidates
              .map((candidate) => _buildActivityCard(candidate))
              .toList(),
        );
      },
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> candidate) {
    final fullName = candidate['full_name'] ?? 'Unknown';
    final experienceYears = candidate['experience_years'] ?? 0;
    final city = candidate['city_name'] ?? 'N/A';
    final creditsUsed = candidate['credits_used'] ?? 10;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CandidateDetailScreen(
              candidate: candidate,
              isAlreadyUnlocked: true,
            ),
          ),
        );
      },
      child: Container(
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
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  fullName[0].toUpperCase(),
                  style: AppTheme.getTitleStyle(
                    context,
                    // color: AppTheme.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: AppTheme.getBodyStyle(
                      context,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '$experienceYears years exp • $city',
                    style: AppTheme.getSubtitleStyle(
                      context,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Credits Used
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '-$creditsUsed',
                style: AppTheme.getLabelStyle(
                  context,
                  color: AppTheme.accentPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              'assets/svgs/empty.svg',
              width: 40,
              height: 40,
              colorFilter: ColorFilter.mode(
                AppTheme.secondary.withOpacity(0.5),
                BlendMode.srcIn,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'No Activity Yet',
            style: AppTheme.getTitleStyle(context, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 4),

          Text(
            'Start unlocking candidate profiles to see your activity here',
            style: AppTheme.getSubtitleStyle(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(color: AppTheme.secondary),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchUnlockedCandidates(
    RecruiterController controller,
  ) async {
    final response = await ApiService.getUnlockedCandidates();
    return response;
  }
}
