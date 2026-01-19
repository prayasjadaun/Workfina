import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/views/screens/recuriters/recruiter_candidate_details_screen.dart';
import 'package:workfina/views/screens/widgets/category_card_widget.dart';
import 'package:workfina/views/screens/widgets/candidate_card_widget.dart';
import 'package:workfina/views/screens/widgets/search_bar.dart';
import 'package:workfina/views/screens/widgets/horizontal_category_tabs.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryKey;
  final String categoryName;

  const CategoryScreen({
    super.key,
    required this.categoryKey,
    required this.categoryName,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with TickerProviderStateMixin {
  late Future<Map<String, dynamic>> _filterCategoriesFuture;

  Timer? _hintTimer;
  Timer? _searchDebounce;
  late final ValueNotifier<int> _hintNotifier;

  late final AnimationController _hintController;
  late final Animation<double> _fadeAnimation;
  String _searchQuery = '';

  // State for subcategory mode
  bool _isSubcategoryMode = false;
  String? _selectedCategoryKey;
  late TabController _tabController;

  Map<String, String> _selectedFilters = {};
  Set<String> _selectedCards = {};
  List<String> _tabCategories = [];
  String _selectedCategory = '';
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _filterCategoriesFuture = ApiService.getFilterCategories();
    _selectedCategory = widget.categoryName;
    _tabController = TabController(length: 1, vsync: this);
    _hintNotifier = ValueNotifier<int>(0);
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _hintController,
      curve: Curves.easeInOut,
    );

    _initializeTabController();
  }

  void _initializeTabController() async {
    try {
      final response = await _filterCategoriesFuture;
      final filterCategories = response['filter_categories'] as List? ?? [];

      final availableCategories =
          filterCategories
              .where((cat) => (cat['inner_filter'] ?? 0) != 0)
              .toList()
            ..sort(
              (a, b) =>
                  (a['inner_filter'] ?? 0).compareTo(b['inner_filter'] ?? 0),
            );

      final categoryNames = availableCategories
          .take(5)
          .map((cat) => cat['name'] as String)
          .toList();

      if (mounted) {
        final newCategories = categoryNames.cast<String>();
        _tabController.dispose();
        setState(() {
          _tabCategories = newCategories;
          _tabController = TabController(
            length: _tabCategories.length,
            vsync: this,
          );
          final initialIndex = _tabCategories.indexOf(widget.categoryName);
          _selectedTabIndex = initialIndex >= 0 ? initialIndex : 0;
          _tabController.animateTo(_selectedTabIndex);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _tabCategories = ['Religion', 'Department', 'City', 'State'];
          _tabController.dispose();
          _tabController = TabController(
            length: _tabCategories.length,
            vsync: this,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _hintController.dispose();
    _hintNotifier.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadCandidates() {
    final recruiterController = Provider.of<RecruiterController>(
      context,
      listen: false,
    );
    recruiterController.loadCandidates(
      role: _selectedFilters['department'],
      religion: _selectedFilters['religion'],
      country: _selectedFilters['country'],
      state: _selectedFilters['state'],
      city: _selectedFilters['city'],
    );
  }

  void _onCategorySelected(String categoryKey, String categoryValue) {
    if (_selectedFilters[categoryKey] == categoryValue) {
      return;
    }
    setState(() {
      _selectedFilters[categoryKey] = categoryValue;
      _selectedCategoryKey = categoryValue;

      _selectedCards.clear();
      _selectedCards.add(categoryValue);
    });
    _loadCandidates();
  }

  void _clearFilter(String filterKey) {
    setState(() {
      final removedValue = _selectedFilters.remove(filterKey);
      if (removedValue != null) {
        _selectedCards.remove(removedValue);
      }
    });
    _loadCandidates();
  }

  bool _matchCandidateSearch(Map<String, dynamic> candidate) {
    final q = _searchQuery;
    if (q.isEmpty) return true;

    return [
      candidate['full_name'],
      candidate['masked_name'],
      candidate['city_name'],
      candidate['state_name'],
      candidate['department'],
      candidate['religion'],
    ].any(
      (field) => field != null && field.toString().toLowerCase().contains(q),
    );
  }

  bool _matchSubcategorySearch(Map<String, dynamic> subcategory) {
    final q = _searchQuery;
    if (q.isEmpty) return true;

    return [subcategory['name'], subcategory['key']].any(
      (field) => field != null && field.toString().toLowerCase().contains(q),
    );
  }

  void _onCategoryTap(String subcategoryKey) {
    if (_selectedCategoryKey == subcategoryKey && _isSubcategoryMode) {
      return;
    }
    setState(() {
      _isSubcategoryMode = true;
      _selectedCategoryKey = subcategoryKey;
      _selectedCards.clear();
      // Set first category as selected instead of current widget.categoryName
      if (_tabCategories.isNotEmpty) {
        _selectedCategory = _tabCategories[0];
        _selectedTabIndex = 0;
        _tabController.animateTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isSubcategoryMode
          ? Theme.of(context).scaffoldBackgroundColor
          : AppTheme.primary,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverHeader(context),
        ],
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                color: AppTheme.primary,
                child: _isSubcategoryMode
                    ? _buildCategoriesSection()
                    : _buildSubcategoriesSection(),
              ),
              if (_isSubcategoryMode && _selectedFilters.isNotEmpty)
                _buildActiveFilters(),
              if (_isSubcategoryMode) _buildCandidatesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.primary,
      expandedHeight: _isSubcategoryMode ? 180 : 80,
      floating: false,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          if (_isSubcategoryMode) {
            setState(() {
              _isSubcategoryMode = false;
              _selectedCategoryKey = null;
              _selectedFilters.clear();
              _selectedCards.clear();
            });
          } else {
            Navigator.pop(context);
          }
        },
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      bottom: _isSubcategoryMode
          ? PreferredSize(
              preferredSize: const Size.fromHeight(130),
              child: Container(
                color: AppTheme.primary,
                // padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    
                    const SizedBox(height: 12),
                    // Search Bar
                    GlobalSearchBar(
                      onSearch: (query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                    ),

                    // Horizontal Category Tabs
                    const SizedBox(height: 12),
                    if (_tabCategories.isNotEmpty)
                      HorizontalCategoryTabs(
                        categories: _tabCategories,
                        selectedIndex: _selectedTabIndex,
                        onCategoryTap: (index) {
                          setState(() {
                            _selectedTabIndex = index;
                            _selectedCategory = _tabCategories[index];
                          });
                        },
                      )
                    else
                      const SizedBox(height: 68),
                  ],
                ),
              ),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Container(
                color: AppTheme.primary,
                padding: const EdgeInsets.only(bottom: 0),
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
      title: Text(
        _appBarTitle,
        style: AppTheme.getTitleStyle(
          context,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    );
  }

  String get _appBarTitle {
    if (!_isSubcategoryMode) {
      return widget.categoryName;
    }

    final category = _selectedCategory;
    final subCategory = _selectedCategoryKey;

    if (subCategory == null || subCategory.isEmpty) {
      return category;
    }

    return '$category (${_formatKey(subCategory)})';
  }

  String _formatKey(String value) {
    // IT, HR jaise cases ke liye
    if (value.length <= 3) return value.toUpperCase();

    // normal text ke liye
    return value[0].toUpperCase() + value.substring(1);
  }

  Widget _buildSubcategoriesSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _filterCategoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data?['error'] != null) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                'Error loading subcategories',
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

        final categoryKey = widget.categoryKey.toLowerCase();
        final categoryData = filterCategories.firstWhere(
          (cat) => (cat['slug'] as String?)?.toLowerCase() == categoryKey,
          orElse: () => null,
        );

        if (categoryData == null) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                'No subcategories available for $categoryKey',
                style: AppTheme.getBodyStyle(context, color: Colors.white),
              ),
            ),
          );
        }

        final subcategories = categoryData['subcategories'] as List? ?? [];

        if (subcategories.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                'No subcategories available',
                style: AppTheme.getBodyStyle(context, color: Colors.white),
              ),
            ),
          );
        }

        var options = subcategories.map((sub) {
          return {
            'key': sub['slug'],
            'name': sub['name'],
            'locked_count': sub['locked_candidates'] ?? 0,
            'unlocked_count': sub['unlocked_candidates'] ?? 0,
            'total_count': sub['total_candidates'] ?? 0,
            'icon': getCategoryIcon(categoryKey),
          };
        }).toList();

        options = options
            .where((subcategory) => _matchSubcategorySearch(subcategory))
            .toList();

        if (options.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/svgs/empty.svg',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No subcategories available'
                        : 'No results found for "$_searchQuery"',
                    style: AppTheme.getHeadlineStyle(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Try selecting a different category'
                        : 'Try a different search term',
                    style: AppTheme.getBodyStyle(
                      context,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return CategoryCardsWidget(
          categories: options,
          isCategoryMode: true,
          isGridLayout: true,
          selectedCards: const {},
          onCategoryTap: _onCategoryTap,
        );
      },
    );
  }

  String getCategoryIcon(String key) {
    switch (key) {
      case 'department':
        return 'assets/svg/work.svg';
      case 'religion':
        return 'assets/svgs/religion.svg';
      case 'country':
        return 'assets/svgs/country.svg';
      case 'state':
        return 'assets/svgs/state.svg';
      case 'city':
        return 'assets/svgs/city.svg';
      case 'education':
        return 'assets/svgs/education.svg';
      default:
        return 'assets/svgs/default.svg';
    }
  }

  Widget _buildCategoriesSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _filterCategoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError || snapshot.data?['error'] != null) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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

        final categoryKey = _selectedCategory.toLowerCase();
        final categoryData = filterCategories.firstWhere(
          (cat) => (cat['slug'] as String?)?.toLowerCase() == categoryKey,
          orElse: () => null,
        );

        if (categoryData == null) {
          return const SizedBox.shrink();
        }

        final subcategories = categoryData['subcategories'] as List? ?? [];

        if (subcategories.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                'No options available',
                style: AppTheme.getBodyStyle(context, color: Colors.white),
              ),
            ),
          );
        }

        var options = subcategories.map((sub) {
          return {
            'key': sub['slug'],
            'name': sub['name'],
            'locked_count': sub['locked_candidates'] ?? 0,
            'unlocked_count': sub['unlocked_candidates'] ?? 0,
            'total_count': sub['total_candidates'] ?? 0,
            'icon': getCategoryIcon(categoryKey),
          };
        }).toList();

        options = options
            .where((subcategory) => _matchSubcategorySearch(subcategory))
            .toList();

        if (options.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/svgs/empty.svg',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No options available'
                        : 'No results found for "$_searchQuery"',
                    style: AppTheme.getHeadlineStyle(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Try a different category'
                        : 'Try a different search term',
                    style: AppTheme.getBodyStyle(
                      context,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return CategoryCardsWidget(
          categories: options,
          isGridLayout: true,
          isCategoryMode: false,
          selectedCards: _selectedCards,
          onCategoryTap: (subcategoryKey) {
            final categoryKey2 = _selectedCategory.toLowerCase();
            _onCategorySelected(categoryKey2, subcategoryKey);
          },
        );
      },
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Filters',
            style: AppTheme.getHeadlineStyle(
              context,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedFilters.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.accentPrimary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${entry.key}: ${entry.value}',
                      style: AppTheme.getBodyStyle(
                        context,
                        fontSize: 12,
                        color: AppTheme.accentPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _clearFilter(entry.key),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: AppTheme.accentPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationPendingWidget() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top_rounded,
              size: 48,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Verification Pending',
            style: AppTheme.getHeadlineStyle(
              context,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your company verification is currently under review. Once approved, you\'ll be able to browse and unlock candidate profiles.',
            style: AppTheme.getBodyStyle(
              context,
              fontSize: 14,
              color: Colors.orange.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.orange.shade600,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This usually takes 24-48 hours. We\'ll notify you once verified.',
                    style: AppTheme.getBodyStyle(
                      context,
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // User can go back or contact support
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
              side: BorderSide(color: Colors.orange.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidatesSection() {
    return Consumer<RecruiterController>(
      builder: (context, recruiterController, child) {
        if (recruiterController.isLoading) {
          return Container(
            padding: const EdgeInsets.all(40),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (recruiterController.error != null) {
          // Check if it's a verification pending error
          final errorLower = recruiterController.error!.toLowerCase();
          final isVerificationPending = errorLower.contains('verification') ||
              errorLower.contains('pending') ||
              errorLower.contains('company') && errorLower.contains('cannot');

          if (isVerificationPending) {
            return _buildVerificationPendingWidget();
          }

          return Container(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Error: ${recruiterController.error}',
                    style: AppTheme.getBodyStyle(context, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCandidates,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        var lockedCandidates = recruiterController.candidates
            .where(
              (candidate) =>
                  !recruiterController.isCandidateUnlocked(candidate['id']) &&
                  (candidate['is_available_for_hiring'] ?? true),
            )
            .toList();

        lockedCandidates = lockedCandidates
            .where((candidate) => _matchCandidateSearch(candidate))
            .toList();

        if (lockedCandidates.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/svgs/empty.svg',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No locked candidates found'
                        : 'No results found for "$_searchQuery"',
                    style: AppTheme.getHeadlineStyle(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Try adjusting your filters to find more candidates'
                        : 'Try a different search term',
                    style: AppTheme.getBodyStyle(context, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Locked Candidates',
                    style: AppTheme.getHeadlineStyle(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${lockedCandidates.length} found',
                      style: AppTheme.getBodyStyle(
                        context,
                        fontSize: 12,
                        color: AppTheme.accentPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 10),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lockedCandidates.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final candidate = lockedCandidates[index];
                  final isUnlocked = recruiterController.isCandidateUnlocked(
                    candidate['id'],
                  );
                  final canAfford = recruiterController.canUnlockCandidate();

                  return CandidateCardWidget(
                    candidate: candidate,
                    isUnlocked: isUnlocked,
                    canAffordUnlock: canAfford,
                    onUnlock: () => _unlockCandidate(
                      context,
                      candidate,
                      recruiterController,
                    ),
                    onViewProfile: () =>
                        _navigateToDetail(context, candidate, isUnlocked),
                  );
                },
              ),
            ],
          ),
        );
      },
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
    RecruiterController recruiterController,
  ) {
    if (!recruiterController.canUnlockCandidate()) {
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
            'You need 10 credits to unlock this profile but you have ${recruiterController.walletBalance} credits.\n\nPlease recharge your wallet first.',
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
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
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
            Icon(Icons.lock_open_outlined, color: AppTheme.primary),
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
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (recruiterController.subscriptionStatus?.hasSubscription ?? false) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.card_membership,
                          color: AppTheme.greenCard,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            recruiterController.subscriptionStatus!.isUnlimited
                                ? 'Subscription: Unlimited Credits'
                                : 'Subscription: ${(recruiterController.subscriptionStatus!.creditsLimit ?? 0) - recruiterController.subscriptionStatus!.creditsUsed} credits left',
                            style: AppTheme.getLabelStyle(
                              context,
                              color: AppTheme.greenCard,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: AppTheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Wallet: ${recruiterController.walletBalance} credits',
                          style: AppTheme.getLabelStyle(
                            context,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
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
              final result = await recruiterController.unlockCandidate(
                candidate['id'].toString(),
              );
              if (!mounted) return;

              if (result != null) {
                await Navigator.of(this.context).push(
                  MaterialPageRoute(
                    builder: (context) => CandidateDetailScreen(
                      candidate: result['candidate'],
                      isAlreadyUnlocked: result['already_unlocked'],
                    ),
                  ),
                );
                if (!result['already_unlocked'] && mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Profile unlocked! ${result['credits_used']} credits deducted.',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else if (recruiterController.error != null && mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      recruiterController.error!,
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
              backgroundColor: AppTheme.primary,
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
}