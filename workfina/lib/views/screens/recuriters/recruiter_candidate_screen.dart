import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/views/screens/recuriters/recruiter_candidate_details_screen.dart';
import 'package:workfina/views/screens/recuriters/recruiter_filter_screen.dart';

class RecruiterCandidate extends StatefulWidget {
  final ValueChanged<int>? onSwitchToWallet;
  const RecruiterCandidate({super.key, this.onSwitchToWallet});

  @override
  State<RecruiterCandidate> createState() => _RecruiterCandidateState();
}

class _RecruiterCandidateState extends State<RecruiterCandidate>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'All';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecruiterController>().loadCandidates();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
        title: Text('Candidates', style: AppTheme.getAppBarTextStyle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined, color: Colors.white),
            onPressed: () => _showSearchBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.tune_outlined, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RecruiterFilterScreen(),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: AppTheme.primaryGreen,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              indicatorWeight: 2,
              labelStyle: AppTheme.getTabBarTextStyle(context, true),
              unselectedLabelStyle: AppTheme.getTabBarTextStyle(context, false),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Available'),
                Tab(text: 'Unlocked'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildLockedCandidatesTab(), _buildUnlockedCandidatesTab()],
      ),
    );
  }

  Widget _buildLockedCandidatesTab() {
    return Consumer<RecruiterController>(
      builder: (context, hrController, child) {
        if (hrController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          );
        }

        final isVerified = hrController.hrProfile?['is_verified'] ?? false;
        if (!isVerified) {
          return _buildVerificationPending(context);
        }

        final lockedCandidates = hrController.candidates
            .where((c) => !hrController.isCandidateUnlocked(c['id'].toString()))
            .toList();

        if (lockedCandidates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No candidates available',
                  style: AppTheme.getTitleStyle(
                    context,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: lockedCandidates.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final candidate = lockedCandidates[index];
            return _buildCandidateCard(context, candidate, hrController);
          },
        );
      },
    );
  }

  Widget _buildUnlockedCandidatesTab() {
    return Consumer<RecruiterController>(
      builder: (context, hrController, child) {
        if (hrController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          );
        }

        final unlockedCandidates = hrController.candidates
            .where((c) => hrController.isCandidateUnlocked(c['id']))
            .toList();

        if (unlockedCandidates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_open_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No unlocked profiles yet',
                  style: AppTheme.getTitleStyle(
                    context,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: unlockedCandidates.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final candidate = unlockedCandidates[index];
            return _buildCandidateCard(context, candidate, hrController);
          },
        );
      },
    );
  }

  Widget _buildVerificationPending(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [AppTheme.getCardShadow(context)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_empty_outlined,
                size: 48,
                color: AppTheme.accentOrange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Company Verification Pending',
              style: AppTheme.getHeadlineStyle(
                context,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your company profile is under review. Candidates will be visible once verified.',
              textAlign: TextAlign.center,
              style: AppTheme.getBodyStyle(
                context,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verification typically takes 24-48 hours',
              textAlign: TextAlign.center,
              style: AppTheme.getLabelStyle(
                context,
                color: AppTheme.accentOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 60,
        ),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Search Candidates',
                style: AppTheme.getHeadlineStyle(
                  context,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTheme.getBodyStyle(context),
                decoration: InputDecoration(
                  hintText: 'Search by skills, role, location...',
                  hintStyle: AppTheme.getBodyStyle(
                    context,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(
                    Icons.search_outlined,
                    color: AppTheme.primaryGreen,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {
                  _filterCandidates();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _filterCandidates();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Search',
                    style: AppTheme.getPrimaryButtonTextStyle(context),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCandidateCard(
    BuildContext context,
    Map<String, dynamic> candidate,
    RecruiterController hrController,
  ) {
    final isUnlocked = hrController.isCandidateUnlocked(candidate['id']);
    final canAffordUnlock = hrController.canUnlockCandidate();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.getCardShadow(context)],
        border: isUnlocked
            ? Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppTheme.primaryGreen.withOpacity(0.1)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    border: isUnlocked
                        ? Border.all(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      (candidate['masked_name']?.substring(0, 1) ?? 'C')
                          .toUpperCase(),
                      style: AppTheme.getHeadlineStyle(
                        context,
                        color: isUnlocked
                            ? AppTheme.primaryGreen
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isUnlocked
                                  ? (candidate['full_name'] ??
                                        candidate['masked_name'] ??
                                        'Unknown')
                                  : (candidate['masked_name'] ?? 'Unknown'),
                              style: AppTheme.getCardTitleStyle(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnlocked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.primaryGreen.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'UNLOCKED',
                                style: AppTheme.getLabelStyle(
                                  context,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        candidate['role_name'] ?? 'N/A',
                        style: AppTheme.getCardSubtitleStyle(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info chips
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  context,
                  Icons.work_outline,
                  '${candidate['experience_years']} years',
                  AppTheme.secondaryBlue,
                ),
                _buildInfoChip(
                  context,
                  Icons.location_on_outlined,
                  candidate['city_name'] ?? 'N/A',
                  AppTheme.accentOrange,
                ),
                _buildInfoChip(
                  context,
                  Icons.person_outline,
                  '${candidate['age']} years old',
                  AppTheme.accentPurple,
                ),
              ],
            ),

            if (isUnlocked &&
                (candidate['phone'] != null || candidate['email'] != null)) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (candidate['phone'] != null)
                      _buildContactInfo(
                        context,
                        Icons.phone_outlined,
                        candidate['phone'],
                      ),
                    if (candidate['phone'] != null &&
                        candidate['email'] != null)
                      const SizedBox(height: 4),
                    if (candidate['email'] != null)
                      _buildContactInfo(
                        context,
                        Icons.email_outlined,
                        candidate['email'],
                      ),
                  ],
                ),
              ),
            ],

            if (candidate['skills'] != null) ...[
              const SizedBox(height: 16),
              Text(
                'Skills',
                style: AppTheme.getLabelStyle(
                  context,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              () {
                final allSkills = candidate['skills'].split(',');
                final displaySkills = allSkills.take(3).toList();
                final remainingCount = allSkills.length - 3;

                return Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ...displaySkills.map<Widget>(
                      (skill) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryGreen.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          skill.trim(),
                          style: AppTheme.getLabelStyle(
                            context,
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    if (remainingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.secondaryBlue.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          '+$remainingCount more',
                          style: AppTheme.getLabelStyle(
                            context,
                            color:AppTheme.secondaryBlue,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                );
              }(),
            ],

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: canAffordUnlock
                          ? AppTheme.accentOrange.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: canAffordUnlock
                            ? AppTheme.accentOrange.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stars_outlined,
                          size: 16,
                          color: canAffordUnlock
                              ? AppTheme.accentOrange
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '10 credits to unlock',
                          style: AppTheme.getLabelStyle(
                            context,
                            color: canAffordUnlock
                                ? AppTheme.accentOrange
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/svgs/unlock.svg',
                          width: 16,
                          height: 16,
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Profile unlocked',
                          style: AppTheme.getLabelStyle(
                            context,
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                ElevatedButton(
                  onPressed: isUnlocked
                      ? () => _navigateToDetail(context, candidate, true)
                      : canAffordUnlock
                      ? () => _unlockCandidate(context, candidate, hrController)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUnlocked
                        ? AppTheme.secondaryBlue
                        : canAffordUnlock
                        ? AppTheme.primaryGreen
                        : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        isUnlocked
                            ? 'assets/svgs/eye.svg'
                            : 'assets/svgs/lock.svg',
                        width: 16,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isUnlocked ? 'View Profile' : 'Unlock Profile',
                        style: AppTheme.getPrimaryButtonTextStyle(
                          context,
                        ).copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // color: color.withOpacity(0.1),
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTheme.getLabelStyle(
              context,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.getBodyStyle(
              context,
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _navigateToDetail(
    BuildContext context,
    Map<String, dynamic> candidate,
    bool isAlreadyUnlocked,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidateDetailScreen(
          candidate: candidate,
          isAlreadyUnlocked: isAlreadyUnlocked,
        ),
      ),
    );
  }

  void _unlockCandidate(
    BuildContext context,
    Map<String, dynamic> candidate,
    RecruiterController hrController,
  ) {
    if (!hrController.canUnlockCandidate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.getCardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Colors.red),
              const SizedBox(width: 12),
              Text(
                'Insufficient Credits',
                style: AppTheme.getHeadlineStyle(
                  context,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'You need 10 credits to unlock this profile but you have ${hrController.walletBalance} credits.\n\nPlease recharge your wallet first.',
            style: AppTheme.getBodyStyle(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTheme.getBodyStyle(
                  context,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (widget.onSwitchToWallet != null) {
                  widget.onSwitchToWallet!(2);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Recharge',
                style: AppTheme.getPrimaryButtonTextStyle(context),
              ),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lock_open_outlined, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            Text(
              'Unlock Profile',
              style: AppTheme.getHeadlineStyle(
                context,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unlock ${candidate['masked_name']} for 10 credits?',
              style: AppTheme.getBodyStyle(context),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: AppTheme.primaryGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Current balance: ${hrController.walletBalance} credits',
                    style: AppTheme.getLabelStyle(
                      context,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.getBodyStyle(
                context,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await hrController.unlockCandidate(
                candidate['id'].toString(),
              );
              if (result != null) {
                _navigateToDetail(
                  context,
                  result['candidate'],
                  result['already_unlocked'],
                );
                if (!result['already_unlocked']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Profile unlocked! ${result['credits_used']} credits deducted.',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else if (hrController.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      hrController.error!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Unlock',
              style: AppTheme.getPrimaryButtonTextStyle(context),
            ),
          ),
        ],
      ),
    );
  }

  void _filterCandidates() {
    final hrController = context.read<RecruiterController>();
    hrController.loadCandidates(
      role: _selectedRole == 'All' ? null : _selectedRole,
      skills: _searchController.text.isEmpty ? null : _searchController.text,
    );
  }
}
