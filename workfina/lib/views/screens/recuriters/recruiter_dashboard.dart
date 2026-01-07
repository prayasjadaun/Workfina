import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/views/screens/notification/notification_screen.dart';
import 'package:workfina/views/screens/recuriters/category_screen.dart';
import 'package:workfina/views/screens/recuriters/recruiter_candidate_details_screen.dart';
import 'package:workfina/views/screens/widgets/category_card_widget.dart';

class RecruiterDashboard extends StatefulWidget {
  final VoidCallback? onNavigateToUnlocked;
  const RecruiterDashboard({super.key, this.onNavigateToUnlocked});

  @override
  State<RecruiterDashboard> createState() => _RecruiterDashboardState();
}

class _RecruiterDashboardState extends State<RecruiterDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> _categories = [];
  late Future<Map<String, dynamic>> _filterOptionsFuture;
  bool _categoriesLoaded = false;

  @override
  void initState() {
    super.initState();
    _filterOptionsFuture = ApiService.getFilterCategories();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadDynamicCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecruiterController>().loadCandidates();
    });
  }

  void _loadDynamicCategories() async {
    try {
      final response = await _filterOptionsFuture;
      final filterCategories = response['filter_categories'] as List? ?? [];

      print(
        'DEBUG: Filter Categories: ${filterCategories.length}',
      ); // Debug print

      final availableCategories = filterCategories
          .where((cat) => (cat['dashboard_display'] ?? 0) != 0)
          .take(4)
          .map((cat) => cat['name'] as String)
          .toList();

      print('DEBUG: Available categories: $availableCategories'); // Debug print

      if (mounted) {
        final newCategories = availableCategories.cast<String>();

        print('DEBUG: New categories: $newCategories'); // Debug print

        _tabController.dispose();
        setState(() {
          _categories = newCategories;
          _tabController = TabController(
            length: _categories.length,
            vsync: this,
          );
          _categoriesLoaded = true;
        });

        print('DEBUG: Categories updated: $_categories'); // Debug print
      }
    } catch (e) {
      print('DEBUG: Error loading categories: $e'); // Debug print
      if (mounted) {
        setState(() {
          _categoriesLoaded = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildSliverHeader(context, controller),
            ],
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    color: AppTheme.primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                          child: Text(
                            'What would you like to\nfind today?',
                            style: AppTheme.getHeadlineStyle(
                              context,
                              fontWeight: FontWeight.w600,
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Categories Section
                        SizedBox(
                          height: 220,
                          child: _buildCategoriesSection(controller),
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
                        const SizedBox(height: 24),

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
                              onTap: widget.onNavigateToUnlocked,
                              child: Text(
                                'View all',
                                style: AppTheme.getBodyStyle(
                                  context,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
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
          ),
        );
      },
    );
  }

  Widget _buildSliverHeader(
    BuildContext context,
    RecruiterController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = controller.hrProfile;
    final fullName = profile?['full_name'] ?? 'HR';

    final parts = fullName.trim().split(RegExp(r'\s+'));

    String displayName;
    if (parts.length >= 3) {
      displayName = '${parts[1]} ${parts[2]}';
    } else if (parts.length == 2) {
      displayName = parts[0];
    } else {
      displayName = parts[0];
    }

    return SliverAppBar(
      backgroundColor: AppTheme.primary,
      expandedHeight: 180,
      floating: false,
      pinned: true,
      snap: false,
      elevation: 0,
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          color: AppTheme.primary,
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      SvgPicture.asset(
                        'assets/svgs/search.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Search candidates...',
                          style: AppTheme.getBodyStyle(
                            context,
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          'assets/svgs/filter.svg',
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Bar
              const SizedBox(height: 20),
              if (_categoriesLoaded)
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    // tabAlignment: TabAlignment.start,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorPadding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 4,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: Colors.white.withOpacity(0.8),
                    labelStyle: AppTheme.getBodyStyle(
                      context,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: AppTheme.getBodyStyle(
                      context,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    onTap: (index) {
                      final selectedCategory = _categories[index];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryScreen(
                            categoryKey: selectedCategory.toLowerCase(),
                            categoryName: selectedCategory,
                          ),
                        ),
                      );
                    },

                    tabs: _categories
                        .map(
                          (category) => Tab(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 6,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
              else
                const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          displayName[0].toUpperCase(),
                          style: AppTheme.getTitleStyle(
                            context,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello 👋',
                            style: AppTheme.getSubtitleStyle(
                              context,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            displayName,
                            style: AppTheme.getBodyStyle(
                              context,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationScreen(),
                          ),
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/svg/bell.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(RecruiterController controller) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getFilterCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 220,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data?['error'] != null) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 220,
            child: Center(
              child: Text(
                'Error loading categories',
                style: AppTheme.getBodyStyle(context, color: Colors.white),
              ),
            ),
          );
        }

        final filterCategories =
            snapshot.data?['filter_categories'] as List? ?? [];

        if (filterCategories.isEmpty) {
          return const SizedBox.shrink();
        }

        // Transform API data to the format expected by CategoryCardsWidget
        final categories = filterCategories.map((cat) {
          return {
            'key': cat['slug'],
            'name': cat['name'],
            'total_count': cat['options_count'] ?? 0,
            'candidate_count': cat['options_count'] ?? 0,
            'unlocked_count': 0,
            'locked_count': cat['options_count'] ?? 0,
          };
        }).toList();

        // Filter out categories where bento_grid is 0
        final filteredCategories = filterCategories
            .where((cat) => (cat['bento_grid'] ?? 0) != 0)
            .map((cat) {
              return {
                'key': cat['slug'],
                'name': cat['name'],
                'total_count': cat['options_count'] ?? 0,
                'candidate_count': cat['options_count'] ?? 0,
                'unlocked_count': 0,
                'locked_count': cat['options_count'] ?? 0,
              };
            })
            .take(5)
            .toList();

        if (filteredCategories.isEmpty) {
          return const SizedBox.shrink();
        }

        return CategoryCardsWidget(
          categories: filteredCategories.cast<Map<String, dynamic>>(),
          onCategoryTap: (categoryKey) {
            final category = filteredCategories.firstWhere(
              (c) => c['key'] == categoryKey,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryScreen(
                  categoryKey: categoryKey,
                  categoryName: category['name'],
                ),
              ),
            );
          },
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
          'Total Credits',
          balance.toString(),
        ),
        _buildStatCard(
          'assets/svgs/unlock.svg',
          'Total Unlocked',
          unlockedCount.toString(),
        ),
        _buildStatCard(
          'assets/svgs/spend.svg',
          'Total Spent',
          totalSpent.toString(),
        ),
        _buildStatCard(
          'assets/svgs/candidates.svg',
          'Total Candidates',
          totalCandidates.toString(),
        ),
      ],
    );
  }

  Widget _buildStatCard(String iconPath, String title, String value) {
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
            child: SvgPicture.asset(
              iconPath,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : AppTheme.darkBackground,
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    candidate['profile_image_url'] != null &&
                        candidate['profile_image_url'].toString().isNotEmpty
                    ? Image.network(
                        _getFullImageUrl(candidate['profile_image_url']),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildInitialAvatar(fullName),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : _buildInitialAvatar(fullName),
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
                    '$experienceYears years exp $city',
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

  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
    return 'http://localhost:8000$imageUrl';
  }

  Widget _buildInitialAvatar(String fullName) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          fullName[0].toUpperCase(),
          style: AppTheme.getTitleStyle(
            context,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
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
