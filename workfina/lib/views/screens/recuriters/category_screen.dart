import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/views/screens/widgets/category_card_widget.dart';
import 'package:workfina/views/screens/widgets/candidate_card_widget.dart';

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
  late Future<Map<String, dynamic>> _filterOptionsFuture;

  // State for subcategory mode
  bool _isSubcategoryMode = false;
  String? _selectedCategoryKey;
  late TabController _tabController;

  Map<String, String> _selectedFilters = {};
  Set<String> _selectedCards = {};
  List<String> _tabCategories = [];
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _filterCategoriesFuture = ApiService.getFilterCategories();
    _filterOptionsFuture = ApiService.getFilterOptions();
    _selectedCategory = widget.categoryName;
    _tabController = TabController(length: 1, vsync: this);
    _initializeTabController();
  }

  void _initializeTabController() async {
    try {
      final response = await _filterCategoriesFuture;
      final filterCategories = response['filter_categories'] as List? ?? [];

      final availableCategories = filterCategories
          .where((cat) => (cat['inner_filter'] ?? 0) != 0)
          .take(5)
          .map((cat) => cat['name'] as String)
          .toList();

      if (mounted) {
        final newCategories = availableCategories.cast<String>();
        _tabController.dispose();
        setState(() {
          _tabCategories = newCategories;
          _tabController = TabController(
            length: _tabCategories.length,
            vsync: this,
          );
          final initialIndex = _tabCategories.indexOf(widget.categoryName);
          _tabController.animateTo(initialIndex >= 0 ? initialIndex : 0);
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
    setState(() {
      _selectedFilters[categoryKey] = categoryValue;
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

  void _onCategoryTap(String subcategoryKey) {
    setState(() {
      _isSubcategoryMode = true;
      _selectedCategoryKey = subcategoryKey;
      // Set the selected category for tab controller
      _selectedCategory = widget.categoryName;
      final tabIndex = _tabCategories.indexOf(widget.categoryName);
      if (tabIndex >= 0) {
        _tabController.animateTo(tabIndex);
      }
      // Pre-select the category that was clicked
      _selectedFilters[widget.categoryKey.toLowerCase()] = subcategoryKey;
      _selectedCards.clear();
      _selectedCards.add(subcategoryKey);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCandidates();
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
                                'Search in $_selectedCategory...',
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
                    // Tab Bar
                    const SizedBox(height: 20),
                    if (_tabCategories.isNotEmpty)
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
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
                            setState(() {
                              _selectedCategory = _tabCategories[index];
                            });
                          },
                          tabs: _tabCategories
                              .map(
                                (category) => Tab(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    child: Text(category),
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
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Container(
                color: AppTheme.primary,
                padding: const EdgeInsets.only(bottom: 0),
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
                                'Search in ${widget.categoryName}...',
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
      title: Text(
        _isSubcategoryMode ? _selectedCategory : widget.categoryName,
        style: AppTheme.getTitleStyle(
          context,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSubcategoriesSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _filterOptionsFuture,
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

        final results = snapshot.data?['results'] ?? {};
        final all = results['all'] as Map<String, dynamic>?;

        if (all == null) {
          return const SizedBox.shrink();
        }

        final subcategories = all['subcategories'] as Map<String, dynamic>?;
        if (subcategories == null) {
          return const SizedBox.shrink();
        }

        final categoryKey = widget.categoryKey.toLowerCase();
        print('DEBUG: Looking for categoryKey: $categoryKey');
        print('DEBUG: Available subcategories keys: ${subcategories.keys}');

        final categoryData =
            subcategories[categoryKey] as Map<String, dynamic>?;

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

        final categoryOptions =
            categoryData['options'] as Map<String, dynamic>?;
        if (categoryOptions == null || categoryOptions.isEmpty) {
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

        final options = <Map<String, dynamic>>[];
        categoryOptions.forEach((key, value) {
          final optionData = value as Map<String, dynamic>;
          options.add({
            'key': key,
            'name': optionData['name'] ?? key,
            'locked_count': optionData['locked_count'] ?? 0,
            'icon': getCategoryIcon(categoryKey),
          });
        });

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
      future: _filterOptionsFuture,
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

        final results = snapshot.data?['results'] ?? {};
        final all = results['all'] as Map<String, dynamic>?;

        if (all == null) {
          return const SizedBox.shrink();
        }

        final subcategories = all['subcategories'] as Map<String, dynamic>?;
        if (subcategories == null) {
          return const SizedBox.shrink();
        }

        final categoryKey = _selectedCategory.toLowerCase();
        final categoryData =
            subcategories[categoryKey] as Map<String, dynamic>?;

        if (categoryData == null) {
          return const SizedBox.shrink();
        }

        final categoryOptions =
            categoryData['options'] as Map<String, dynamic>?;
        if (categoryOptions == null || categoryOptions.isEmpty) {
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

        final options = <Map<String, dynamic>>[];
        categoryOptions.forEach((key, value) {
          final optionData = value as Map<String, dynamic>;
          options.add({
            'key': key,
            'name': optionData['name'] ?? key,
            'locked_count': optionData['locked_count'] ?? 0,
            'icon': getCategoryIcon(categoryKey),
          });
        });

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
                    GestureDetector(
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
          return Container(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Error: \${recruiterController.error}',
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

        final lockedCandidates = recruiterController.candidates
            .where(
              (candidate) =>
                  !recruiterController.isCandidateUnlocked(candidate['id']),
            )
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
                    'No locked candidates found',
                    style: AppTheme.getHeadlineStyle(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters to find more candidates',
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
                    onUnlock: () async {
                      final result = await recruiterController.unlockCandidate(
                        candidate['id'],
                      );
                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Profile unlocked successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _loadCandidates();
                      }
                    },
                    onViewProfile: () {
                      print('View profile: ${candidate['id']}');
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
