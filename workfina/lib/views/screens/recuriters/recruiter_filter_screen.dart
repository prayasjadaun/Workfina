// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/views/screens/recuriters/filter_candidate_screen.dart';
import 'package:workfina/views/screens/widgets/category_card_widget.dart';
import 'package:workfina/views/screens/widgets/search_bar.dart';

class RecruiterFilterScreen extends StatefulWidget {
  final bool showUnlockedOnly;
  const RecruiterFilterScreen({super.key, this.showUnlockedOnly = false});

  @override
  State<RecruiterFilterScreen> createState() => RecruiterFilterScreenState();
}

class RecruiterFilterScreenState extends State<RecruiterFilterScreen> {
  Map<String, dynamic> _filterOverview = {};
  List<Map<String, dynamic>> _currentFilterData = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String? _selectedFilterType;
  String? _selectedSubFilter;
  String? _currentFilterKey;

  // Pagination state
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = false;
  String? _nextUrl;
  String? _searchQuery;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _selectedSubcategories = [];

  @override
  void initState() {
    super.initState();
    _loadFilterOverview();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilterOverview() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getFilterCategories();

      if (response.containsKey('error')) {
        setState(() {
          _error = response['error'];
          _isLoading = false;
        });
        return;
      }

      final List categories = response['filter_categories'] as List? ?? [];

      // 🔥 KEY CHANGE: store list instead of map
      setState(() {
        _filterOverview = {'categories': categories};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Network error. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSpecificFilter(String filterType) async {
    final filterKey = _getFilterKey(filterType);

    setState(() {
      _selectedFilterType = filterType;
      _currentFilterKey = filterKey;
      _currentFilterData = [];
      _currentPage = 1;
      _isLoading = true;
      _error = null;
      _searchQuery = null;
      _searchController.clear();
    });

    await _fetchFilterData();
  }

  Future<void> _fetchFilterData({bool loadMore = false}) async {
    if (loadMore) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final response = await ApiService.getSpecificFilterOptions(
        type: _currentFilterKey!,
        page: _currentPage,
        pageSize: _pageSize,
        search: _searchQuery,
      );

      if (response.containsKey('error')) {
        setState(() {
          _error = response['error'];
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        final results =
            (response['results'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        setState(() {
          if (loadMore) {
            _currentFilterData.addAll(results);
          } else {
            _currentFilterData = results;
          }

          _hasMore = response['next'] != null;
          _nextUrl = response['next'];
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error. Please try again.';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  // ignore: unused_element
  void _loadNextPage() {
    if (!_isLoadingMore && _hasMore) {
      _currentPage++;
      _fetchFilterData(loadMore: true);
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.isEmpty ? null : query;
      _currentPage = 1;
      _currentFilterData = [];
    });

    _fetchFilterData();
  }

  // ignore: unused_element
  void _onFilterCategoryTap(String filterType) {
    _loadSpecificFilter(filterType);
  }

  void _onSubFilterTap(String subFilter) async {
    setState(() {
      _selectedSubFilter = subFilter;
    });

    // Navigate to filtered candidates screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredCandidatesScreen(
          filterType: _selectedFilterType!,
          filterValue: subFilter,
          showUnlockedOnly: widget.showUnlockedOnly,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      // backgroundColor: isDark
      //     ? AppTheme.darkBackground
      //     : AppTheme.lightBackground,
      appBar: AppBar(
        title: Text(
          _selectedFilterType ??
              (widget.showUnlockedOnly
                  ? 'Filter Unlocked Profiles'
                  : 'Filter Candidates'),
          style: AppTheme.getAppBarTextStyle(),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: isDark ? Colors.white : Colors.white,
        elevation: 0,

        actions: _selectedFilterType != null
            ? [
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/svgs/home.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      isDark ? Colors.white : Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedFilterType = null;
                      _currentFilterKey = null;
                      _selectedSubcategories.clear();
                      _searchQuery = null;
                      _searchController.clear();
                    });
                  },
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.grey))
          : _error != null
          ? _buildErrorView(isDark)
          : _selectedFilterType == null
          ? _buildFilterCategories(isDark)
          : _buildSubFilters(isDark),
    );
  }

  Widget _buildErrorView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svgs/error.svg',
              width: 80,
              height: 80,
              colorFilter: ColorFilter.mode(
                Colors.grey.shade400,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _error!,
              style: AppTheme.getBodyStyle(
                context,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _selectedFilterType == null
                      ? _loadFilterOverview
                      : () => _fetchFilterData(),
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Text(
                      'Retry',
                      style: AppTheme.getBodyStyle(
                        context,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCategories(bool isDark) {
    final List<Map<String, dynamic>> categories =
        (_filterOverview['categories'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    final query = _searchQuery?.toLowerCase() ?? '';

    final filteredData = categories
        .map((cat) {
          final List<Map<String, dynamic>> subcategories =
              (cat['subcategories'] as List?)?.cast<Map<String, dynamic>>() ??
              [];

          final filteredSubcategories = subcategories.where((sub) {
            final subName = (sub['name'] ?? '').toString().toLowerCase();
            return query.isEmpty || subName.contains(query);
          }).toList();

          if (filteredSubcategories.isEmpty) return null;

          return {
            'key': cat['slug'],
            'name': cat['name'],
            'icon': _getSvgPath(cat['slug']),
            'locked_count': widget.showUnlockedOnly
                ? filteredSubcategories
                      .where((e) => (e['unlocked_candidates'] ?? 0) > 0)
                      .length
                : filteredSubcategories
                      .where((e) => (e['locked_candidates'] ?? 0) > 0)
                      .length,
            'subcategories': filteredSubcategories,
            'subcategory_count': filteredSubcategories.length,
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();

    return Column(
      children: [
        GlobalSearchBar(
          onSearch: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
        ),
        Expanded(
          child: CategoryCardsWidget(
            categories: filteredData,
            twoColumnLayout: true,
            isCategoryMode: true,
            onCategoryTap: (key) {
              final selectedCategory = categories.firstWhere(
                (c) => c['slug'] == key,
              );

              setState(() {
                _selectedFilterType = selectedCategory['name'];
                _currentFilterKey = selectedCategory['slug'];
                _selectedSubcategories =
                    (selectedCategory['subcategories'] as List?)
                        ?.cast<Map<String, dynamic>>() ??
                    [];
                _searchQuery = null;
                _searchController.clear();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubFilters(bool isDark) {
    final query = _searchQuery?.toLowerCase() ?? '';

    final filteredSubcategories = _selectedSubcategories.where((sub) {
      final name = (sub['name'] ?? '').toString().toLowerCase();
      return query.isEmpty || name.contains(query);
    }).toList();

    return Column(
      children: [
        GlobalSearchBar(
          onSearch: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
        ),

        Expanded(
          child: CategoryCardsWidget(
            isGridLayout: true,
            twoColumnLayout: true,
            categories: filteredSubcategories.map((sub) {
              return {
                'key': sub['slug'],
                'name': sub['name'],
                'icon': _getSvgPath(_currentFilterKey ?? ''),
                'locked_count': widget.showUnlockedOnly
                    ? sub['unlocked_candidates'] ?? 0
                    : sub['locked_candidates'] ?? 0,
              };
            }).toList(),
            onCategoryTap: _onSubFilterTap,
          ),
        ),
      ],
    );
  }

  String _getDisplayName(String key) {
    // Convert API key to display name
    final displayNames = {
      'departments': 'Department',
      'religions': 'Religion',
      'cities': 'City',
      'states': 'State',
      'countries': 'Country',
      'education_options': 'Education',
      // Add more as needed dynamically
    };

    // If key not found, create readable name from key
    return displayNames[key] ??
        key
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
  }

  String _getSvgPath(String key) {
    // Map API keys to SVG icons
    final svgPaths = {
      'department': 'assets/svgs/candidates.svg',
      'religion': 'assets/svgs/profile.svg',
      'city': 'assets/svgs/city.svg',
      'state': 'assets/svgs/state.svg',
      'country': 'assets/svgs/country.svg',
      'education': 'assets/svgs/docs.svg',
      // Add more mappings as needed
    };

    // Default icon for unknown keys
    return svgPaths[key] ?? 'assets/svgs/default.svg';
  }

  String _getFilterKey(String filterType) {
    // Find the matching key from API response
    for (var entry in _filterOverview.entries) {
      if (_getDisplayName(entry.key) == filterType) {
        return entry.key;
      }
    }

    // Fallback: convert display name back to likely API key format
    return filterType.toLowerCase().replaceAll(' ', '_');
  }
}
