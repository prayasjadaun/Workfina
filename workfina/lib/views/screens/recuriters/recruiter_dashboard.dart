import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/services/notification_service.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/views/screens/notification/notification_screen.dart';
import 'package:workfina/views/screens/recuriters/category_screen.dart';
import 'package:workfina/views/screens/recuriters/recruiter_candidate_details_screen.dart';
import 'package:workfina/views/screens/widgets/category_card_widget.dart';
import 'package:workfina/views/screens/widgets/refresh_indicator_wrapper.dart';
import 'package:workfina/views/screens/widgets/search_bar.dart';

class RecruiterDashboard extends StatefulWidget {
  final VoidCallback? onNavigateToUnlocked;
  final VoidCallback? onNavigateToWallet;
  const RecruiterDashboard({
    super.key,
    this.onNavigateToUnlocked,
    this.onNavigateToWallet,
  });

  @override
  State<RecruiterDashboard> createState() => _RecruiterDashboardState();
}

class _RecruiterDashboardState extends State<RecruiterDashboard>
    with TickerProviderStateMixin {
      final bool isDark =
    WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
  late TabController _tabController;
  List<String> _categories = [];
  late Future<Map<String, dynamic>> _filterOptionsFuture;
  bool _categoriesLoaded = false;
  Timer? _hintTimer;
  Timer? _searchDebounce;
  bool _isExpanded = false;

  Timer? _typeTimer;
  int _charIndex = 0;

  final ValueNotifier<String> _animatedHint = ValueNotifier<String>('');

  Future<Map<String, dynamic>>? _unlockedCandidatesFuture;
  late final ValueNotifier<int> _hintNotifier;

  String _searchQuery = '';

  int _hintIndex = 0;
  late final AnimationController _hintController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _unlockedCandidatesFuture = ApiService.getUnlockedCandidates();
    _hintNotifier = ValueNotifier<int>(0);
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _hintController,
      curve: Curves.easeInOut,
    );

    _filterOptionsFuture = ApiService.getFilterCategories();
    _tabController = TabController(length: _categories.length, vsync: this);

    _loadDynamicCategories();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = context.read<RecruiterController>();
      await controller.loadCandidates();
      controller.totalCandidatesCount = controller.candidates.length;

      // Request notification permissions after dashboard loads
      await NotificationService.requestPermissionsLater();
    });
  }

  bool _matchSearch(Map<String, dynamic> candidate) {
    final q = _searchQuery;
    if (q.isEmpty) return true;

    return [
      candidate['full_name'],
      candidate['city_name'],
      candidate['state_name'],
      candidate['department'],
      candidate['religion'],
    ].any(
      (field) => field != null && field.toString().toLowerCase().contains(q),
    );
  }

  Future<void> _handleRefresh() async {
    final controller = context.read<RecruiterController>();

    setState(() {
      _unlockedCandidatesFuture = ApiService.getUnlockedCandidates();
      _filterOptionsFuture = ApiService.getFilterCategories();
    });

    await Future.wait<void>([
      controller.loadCandidates(),
      controller.loadHRProfile(),
      controller.loadWalletBalance(),
      controller.loadUnlockedCandidates(),
    ]);

    await _loadDynamicCategories();
  }

  Future<void> _loadDynamicCategories() async {
    try {
      final response = await _filterOptionsFuture;
      final filterCategories = response['filter_categories'] as List? ?? [];

      print(
        'DEBUG: Filter Categories: ${filterCategories.length}',
      ); // Debug print

      final availableCategories =
          filterCategories
              .where((cat) => (cat['dashboard_display'] ?? 0) != 0)
              .toList()
            ..sort(
              (a, b) => (a['dashboard_display'] ?? 0).compareTo(
                b['dashboard_display'] ?? 0,
              ),
            );

      print('DEBUG: Sorted categories with dashboard_display:');
      for (var cat in availableCategories) {
        print(
          '${cat['name']}: dashboard_display = ${cat['dashboard_display']}',
        );
      }

      final categoryNames = availableCategories
          .take(4)
          .map((cat) => cat['name'] as String)
          .toList();

      print('DEBUG: Available categories: $availableCategories'); // Debug print

      if (mounted) {
        final newCategories = categoryNames.cast<String>();

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
    _typeTimer?.cancel();
    _hintTimer?.cancel();
    _hintController.dispose();
    _hintNotifier.dispose();
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
          // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          backgroundColor: isDark ? AppTheme.primary : Colors.white,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildSliverHeader(context, controller),
            ],
            body: RefreshIndicatorWrapper(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
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
                            controller.totalCandidatesCount,
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
          child: Column(
            children: [
              // Search Bar
              GlobalSearchBar(
                onSearch: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
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
        collapseMode: CollapseMode.parallax,
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
                            color: isDark ? Colors.black : Colors.white,
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
                      onTap: widget.onNavigateToWallet,
                      child: SvgPicture.asset(
                        'assets/svg/wallet.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
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
      future: _filterOptionsFuture,

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

        final filteredCategories =
            filterCategories
                .where((cat) => (cat['bento_grid'] ?? 0) != 0)
                .toList()
              ..sort(
                (a, b) =>
                    (a['bento_grid'] ?? 0).compareTo(b['bento_grid'] ?? 0),
              );

        final categories = filteredCategories
            .map((cat) {
              final subcategories = cat['subcategories'] as List? ?? [];
              final totalCandidates = subcategories.fold<int>(
                0,
                (sum, sub) => sum + (sub['total_candidates'] as int? ?? 0),
              );
              final lockedCandidates = subcategories.fold<int>(
                0,
                (sum, sub) => sum + (sub['locked_candidates'] as int? ?? 0),
              );
              final unlockedCandidates = subcategories.fold<int>(
                0,
                (sum, sub) => sum + (sub['unlocked_candidates'] as int? ?? 0),
              );

              return {
                'key': cat['slug'],
                'name': cat['name'],
                'total_count': totalCandidates,
                'candidate_count': totalCandidates,
                'unlocked_count': unlockedCandidates,
                'locked_count': lockedCandidates,
                'subcategory_count': subcategories.length,
              };
            })
            .take(5)
            .toList();

        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return CategoryCardsWidget(
          categories: categories.cast<Map<String, dynamic>>(),
          onCategoryTap: (categoryKey) {
            final category = categories.firstWhere(
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
      future: _unlockedCandidatesFuture,

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final unlockedCandidates =
            snapshot.data?['unlocked_candidates'] as List? ?? [];

        final filteredCandidates = unlockedCandidates
            .where((c) => _matchSearch(c))
            .toList();

        if (filteredCandidates.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: filteredCandidates
              .map((candidate) => _buildActivityCard(candidate))
              .toList(),
        );
      },
    );
  }

  String _getCandidateName(Map<String, dynamic> candidate) {
    final firstName = candidate['first_name'] ?? '';
    final lastName = candidate['last_name'] ?? '';

    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }

    return candidate['full_name'] ?? candidate['masked_name'] ?? 'Unknown';
  }

  Widget _buildActivityCard(Map<String, dynamic> candidate) {
    final fullName = _getCandidateName(candidate);
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
                isDark? Colors.white :
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
