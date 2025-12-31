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
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          );
        }

        final profile = controller.hrProfile;
        final wallet = controller.wallet;
        final balance = wallet?['balance'] ?? 0;
        final totalSpent = profile?['total_spent'] ?? 0;
        final unlockedCount = controller.unlockedCandidateIds.length;

        return Container(
          height: double.infinity,
          decoration: AppTheme.getGradientDecoration(context),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Overview Section
                _buildStatsSection(
                  balance,
                  unlockedCount,
                  totalSpent,
                  controller.candidates.length,
                ),

                const SizedBox(height: 32),

                // Recent Activity Section
                _buildSectionTitle(context, 'Recent Activity'),

                const SizedBox(height: 16),

                _buildRecentActivitySection(controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection(
    int balance,
    int unlockedCount,
    int totalSpent,
    int totalCandidates,
  ) {
    return Column(
      children: [
        // Top Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'assets/svgs/wallet.svg',
                'Credits',
                balance.toString(),
                AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'assets/svgs/unlock.svg',
                'Unlocked',
                unlockedCount.toString(),
                AppTheme.accentOrange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Bottom Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'assets/svgs/spend.svg',
                'Total Spent',
                totalSpent.toString(),
                AppTheme.accentPurple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'assets/svgs/candidates.svg',
                'Candidates',
                totalCandidates.toString(),
                AppTheme.secondaryBlue,
              ),
            ),
          ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: AppTheme.getHeadlineStyle(
              context,
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 28,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: AppTheme.getSubtitleStyle(
              context,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTheme.getTitleStyle(
        context,
        fontWeight: FontWeight.w700,
        fontSize: 20,
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppTheme.getCardShadow(context)],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  fullName[0].toUpperCase(),
                  style: AppTheme.getTitleStyle(
                    context,
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

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
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '-$creditsUsed',
                style: AppTheme.getLabelStyle(
                  context,
                  color: AppTheme.accentOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SvgPicture.asset(
              'assets/svgs/empty.svg',
              width: 48,
              height: 48,
              colorFilter: ColorFilter.mode(
                AppTheme.primaryGreen.withOpacity(0.5),
                BlendMode.srcIn,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'No Activity Yet',
            style: AppTheme.getTitleStyle(context, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

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
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
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
