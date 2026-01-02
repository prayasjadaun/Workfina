import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/views/screens/recuriters/filter_candidate_screen.dart';

class RecruiterFilterScreen extends StatefulWidget {
  const RecruiterFilterScreen({super.key});

  @override
  State<RecruiterFilterScreen> createState() => _RecruiterFilterScreenState();
}

class _RecruiterFilterScreenState extends State<RecruiterFilterScreen> {
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
      final response = await ApiService.getFilterOptions();
      if (response.containsKey('error')) {
        setState(() {
          _error = response['error'];
          _isLoading = false;
        });
      } else {
        // API response has 'results' wrapper
        setState(() {
          _filterOverview = response['results'] ?? {};
          _isLoading = false;
        });
      }
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      appBar: AppBar(
        title: Text(
          _selectedFilterType ?? 'Filter Candidates',
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
                      _currentFilterData = [];
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
    // Build categories dynamically from API response
    final categories = _filterOverview.entries
        .where((entry) => ((entry.value as Map<String, dynamic>)['locked_count'] ?? 0) > 0)
        .map((entry) {
      return {
        'key': entry.key,
        'title': _getDisplayName(entry.key),
        'svg': _getSvgPath(entry.key),
        'count': (entry.value as Map<String, dynamic>)['locked_count'] ?? 0,
      };
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Categories',
            style: AppTheme.getHeadlineStyle(
              context,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a category to filter candidates',
            style: AppTheme.getBodyStyle(context, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final count = category['count'] ?? 0;

                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCardBackground : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          _onFilterCategoryTap(category['title'] as String),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              category['svg'] as String,
                              width: 32,
                              height: 32,
                              colorFilter: ColorFilter.mode(
                                isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              category['title'] as String,
                              style: AppTheme.getTitleStyle(
                                context,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$count options',
                              style: AppTheme.getBodyStyle(
                                context,
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubFilters(bool isDark) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardBackground : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: AppTheme.getBodyStyle(
                context,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Search ${_selectedFilterType?.toLowerCase()}...',
                hintStyle: AppTheme.getBodyStyle(
                  context,
                  color: Colors.grey.shade500,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    'assets/svgs/search.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      Colors.grey.shade500,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: SvgPicture.asset(
                          'assets/svgs/close.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            Colors.grey.shade500,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: _performSearch,
            ),
          ),
        ),

        // Filter results
        Expanded(
          child: _currentFilterData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/svgs/empty.svg',
                        width: 80,
                        height: 80,
                        colorFilter: ColorFilter.mode(
                          Colors.grey.shade400,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: AppTheme.getBodyStyle(
                          context,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent &&
                        _hasMore &&
                        !_isLoadingMore) {
                      _loadNextPage();
                    }
                    return false;
                  },
                  child: Builder(
                    builder: (context) {
                      // Filter out options with zero locked_count
                      final filteredData = _currentFilterData.where((option) => (option['locked_count'] ?? 0) > 0).toList();
                      
                      if (filteredData.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/svgs/empty.svg',
                                width: 80,
                                height: 80,
                                colorFilter: ColorFilter.mode(
                                  Colors.grey.shade400,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No locked candidates found',
                                style: AppTheme.getBodyStyle(
                                  context,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 2.0,
                              ),
                          itemCount:
                              filteredData.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == filteredData.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            final option = filteredData[index];
                            final isSelected =
                                _selectedSubFilter == option['value'];

                            return Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade100)
                                    : (isDark
                                          ? AppTheme.darkCardBackground
                                          : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark
                                            ? Colors.white
                                            : Colors.grey.shade400)
                                      : (isDark
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade200),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _onSubFilterTap(option['value']),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          option['label'],
                                          style: AppTheme.getBodyStyle(
                                            context,
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? (isDark
                                                      ? Colors.white
                                                      : Colors.black87)
                                                : (isDark
                                                      ? Colors.grey.shade300
                                                      : Colors.grey.shade700),
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (option['locked_count'] != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '${option['locked_count']} candidates',
                                            style: AppTheme.getBodyStyle(
                                              context,
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
        ),
        const SizedBox(height: 20),
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