import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/views/screens/recuriters/recruiter_candidate_details_screen.dart';
import 'package:workfina/views/screens/recuriters/recruiter_filter_screen.dart';
import 'package:workfina/views/screens/widgets/candidate_card_widget.dart';

class RecruiterCandidate extends StatefulWidget {
  final ValueChanged<int>? onSwitchToWallet;
  final bool showOnlyUnlocked;
  const RecruiterCandidate({
    super.key,
    this.onSwitchToWallet,
    this.showOnlyUnlocked = false,
  });

  @override
  State<RecruiterCandidate> createState() => _RecruiterCandidateState();
}

class _RecruiterCandidateState extends State<RecruiterCandidate>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'All';
  String _selectedLocation = 'All';
  String _selectedExperience = 'All';
  String _selectedEducation = 'All';
  String _selectedReligion = 'All';
  late TabController _tabController;

  Map<String, dynamic> _appliedFilters = {};

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
      // backgroundColor: Theme.of(context).colorScheme.background,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkBackground
          : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primary,
        title: Row(
          children: [
            Text(
              widget.showOnlyUnlocked ? 'Unlocked Profiles' : 'Candidates',
              style: AppTheme.getAppBarTextStyle(),
            ),
            if (_hasActiveFilters()) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Filtered',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
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
                builder: (context) => RecruiterFilterScreen(
                  showUnlockedOnly: widget.showOnlyUnlocked,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: !widget.showOnlyUnlocked
            ? PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  color: AppTheme.primary,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    indicatorColor: Colors.white,
                    indicatorWeight: 2,
                    labelStyle: AppTheme.getTabBarTextStyle(context, true),
                    unselectedLabelStyle: AppTheme.getTabBarTextStyle(
                      context,
                      false,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Available'),
                      Tab(text: 'Unlocked'),
                    ],
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          if (!widget.showOnlyUnlocked) _buildFilterBanner(),
          Expanded(
            child: widget.showOnlyUnlocked
                ? _buildUnlockedCandidatesScreen()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLockedCandidatesTab(),
                      _buildUnlockedCandidatesTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedCandidatesTab() {
    return Consumer<RecruiterController>(
      builder: (context, hrController, child) {
        if (hrController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        final isVerified = hrController.hrProfile?['is_verified'] ?? false;
        if (!isVerified) {
          return _buildVerificationPending(context);
        }

        final lockedCandidates = _getFilteredCandidates(
          hrController.candidates
              .where(
                (c) => !hrController.isCandidateUnlocked(c['id'].toString()),
              )
              .toList(),
        );

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
          padding: const EdgeInsets.all(16),
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
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        final unlockedCandidates = _getFilteredCandidates(
          hrController.candidates
              .where((c) => hrController.isCandidateUnlocked(c['id']))
              .toList(),
        );

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
          padding: const EdgeInsets.all(16),
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

  Widget _buildUnlockedCandidatesScreen() {
    return Consumer<RecruiterController>(
      builder: (context, hrController, child) {
        if (hrController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        final unlockedCandidates = _getFilteredCandidates(
          hrController.candidates
              .where((c) => hrController.isCandidateUnlocked(c['id']))
              .toList(),
        );

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
                const SizedBox(height: 8),
                Text(
                  'Visit Filters tab to discover candidates',
                  style: AppTheme.getBodyStyle(
                    context,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
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

  bool _hasActiveFilters() {
    return _selectedRole != 'All' ||
        _selectedLocation != 'All' ||
        _selectedExperience != 'All' ||
        _selectedEducation != 'All' ||
        _selectedReligion != 'All' ||
        _searchController.text.isNotEmpty;
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
                color: AppTheme.accentPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_empty_outlined,
                size: 48,
                color: AppTheme.accentPrimary,
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
                color: AppTheme.accentPrimary,
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
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                    hintText: 'Search by name, skills, role, location...',
                    hintStyle: AppTheme.getBodyStyle(
                      context,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(Icons.search_outlined),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setSheetState(() {});
                            },
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
                  onChanged: (value) => setSheetState(() {}),
                  onSubmitted: (value) {
                    _filterCandidates();
                    Navigator.pop(context);
                  },
                ),
                if (_searchController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Search in:',
                    style: AppTheme.getLabelStyle(
                      context,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSearchCategories(setSheetState),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _filterCandidates();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
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
      ),
    );
  }

  Widget _buildSearchCategories(StateSetter setSheetState) {
    final query = _searchController.text.toLowerCase();
    final categories = <Map<String, dynamic>>[];

    // Check where search term might match
    if (query.isNotEmpty) {
      categories.addAll([
        {
          'label': 'Name',
          'icon': Icons.person_outline,
          'description': 'Search in candidate names',
          'type': 'name',
        },
        {
          'label': 'Role/Position',
          'icon': Icons.work_outline,
          'description': 'Search in job roles',
          'type': 'role',
        },
        {
          'label': 'Skills',
          'icon': Icons.star_outline,
          'description': 'Search in technical skills',
          'type': 'skills',
        },
        {
          'label': 'Location',
          'icon': Icons.location_on_outlined,
          'description': 'Search in cities/states',
          'type': 'location',
        },
        {
          'label': 'Education',
          'icon': Icons.school_outlined,
          'description': 'Search in qualifications',
          'type': 'education',
        },
      ]);
    }

    return Column(
      children: categories.map((category) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800.withOpacity(0.5)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300.withOpacity(0.5)),
          ),
          child: ListTile(
            leading: Icon(category['icon'], color: AppTheme.primary, size: 20),
            title: Text(
              '${category['label']}: "${_searchController.text}"',
              style: AppTheme.getBodyStyle(
                context,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              category['description'],
              style: AppTheme.getLabelStyle(
                context,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
            onTap: () {
              _performCategorySearch(category['type']);
              Navigator.pop(context);
            },
          ),
        );
      }).toList(),
    );
  }

  // Add this after the search bar in the candidates list
  Widget _buildFilterBanner() {
    if (_appliedFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 16, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filters: ${_appliedFilters.values.where((v) => v != null && v.toString().isNotEmpty).join(", ")}',
              style: AppTheme.getBodyStyle(context, color: AppTheme.primary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: _clearFilters,
            icon: Icon(Icons.close, size: 18, color: AppTheme.primary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    _appliedFilters.clear();
    context.read<RecruiterController>().loadCandidates();
  }

  void _performCategorySearch(String categoryType) {
    final query = _searchController.text;
    final hrController = context.read<RecruiterController>();

    switch (categoryType) {
      case 'name':
        hrController.loadCandidates(name: query);
        break;
      case 'role':
        hrController.loadCandidates(role: query);
        break;
      case 'skills':
        hrController.loadCandidates(skills: query);
        break;
      case 'location':
        hrController.loadCandidates(city: query);
        break;
      case 'education':
        hrController.loadCandidates(education: query);
        break;
      default:
        hrController.loadCandidates(skills: query);
    }
  }

  List<Map<String, dynamic>> _getFilteredCandidates(
    List<Map<String, dynamic>> candidates,
  ) {
    return candidates.where((candidate) {
      // Role filter
      if (_selectedRole != 'All' && candidate['role_name'] != _selectedRole) {
        return false;
      }

      // Location filter
      if (_selectedLocation != 'All' &&
          candidate['city'] != _selectedLocation) {
        return false;
      }

      // Education filter
      if (_selectedEducation != 'All' &&
          candidate['education'] != _selectedEducation) {
        return false;
      }

      // Religion filter
      if (_selectedReligion != 'All' &&
          candidate['religion'] != _selectedReligion) {
        return false;
      }

      // Experience filter
      if (_selectedExperience != 'All') {
        final expYears = candidate['experience_years'] ?? 0;
        switch (_selectedExperience) {
          case '0-1 Years':
            if (expYears > 1) return false;
            break;
          case '2-5 Years':
            if (expYears < 2 || expYears > 5) return false;
            break;
          case '5+ Years':
            if (expYears <= 5) return false;
            break;
        }
      }

      // Search filter
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final name = (candidate['masked_name'] ?? '').toLowerCase();
        final role = (candidate['role_name'] ?? '').toLowerCase();
        final skills = (candidate['skills'] ?? '').toLowerCase();
        final education = (candidate['education'] ?? '').toLowerCase();

        if (!name.contains(query) &&
            !role.contains(query) &&
            !skills.contains(query) &&
            !education.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Widget _buildCandidateCard(
    BuildContext context,
    Map<String, dynamic> candidate,
    RecruiterController hrController,
  ) {
    final isUnlocked = hrController.isCandidateUnlocked(candidate['id']);
    final canAffordUnlock = hrController.canUnlockCandidate();

    return CandidateCardWidget(
      candidate: candidate,
      isUnlocked: isUnlocked,
      canAffordUnlock: canAffordUnlock,
      onUnlock: () => _unlockCandidate(context, candidate, hrController),
      onViewProfile: () => _navigateToDetail(context, candidate, true),
    );
  }

  void _filterCandidates() {
    final hrController = context.read<RecruiterController>();
    hrController.loadCandidates(
      role: _selectedRole == 'All' ? null : _selectedRole,
      skills: _searchController.text.isEmpty ? null : _searchController.text,
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
                  widget.onSwitchToWallet!(3); // Updated wallet index
                }
              },
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
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: AppTheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Current balance: ${hrController.walletBalance} credits',
                    style: AppTheme.getLabelStyle(
                      context,
                      color: AppTheme.primary,
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
                      backgroundColor: AppTheme.primary,
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
              // backgroundColor: AppTheme.primary,
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

  // bool _hasActiveFilters() {
  //   return _selectedRole != 'All' ||
  //          _selectedLocation != 'All' ||
  //          _selectedExperience != 'All' ||
  //          _searchController.text.isNotEmpty;
  // }
}
