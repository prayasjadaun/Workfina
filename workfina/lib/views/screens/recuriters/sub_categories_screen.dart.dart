// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';
// import 'package:workfina/controllers/recuriter_controller.dart';
// import 'package:workfina/services/api_service.dart';
// import 'package:workfina/theme/app_theme.dart';
// import 'package:workfina/views/screens/widgets/category_card_widget.dart';
// import 'package:workfina/views/screens/widgets/candidate_card_widget.dart';

// class SubCategoriesScreen extends StatefulWidget {
//   final String categoryKey;
//   final String categoryName;
//   final String? preSelectedSubcategory;

//   const SubCategoriesScreen({
//     super.key,
//     required this.categoryKey,
//     required this.categoryName,
//     this.preSelectedSubcategory,
//   });

//   @override
//   State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
// }

// class _SubCategoriesScreenState extends State<SubCategoriesScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late final List<String> _tabCategories;
//   late Future<Map<String, dynamic>> _filterOptionsFuture;

//   // Filter states
//   Map<String, String> _selectedFilters = {};
//   Set<String> _selectedCards = {};

//   final List<String> _categories = [
//     'All',
//     'Religion',
//     'Department',
//     'City',
//     'State',
//   ];
//   String _selectedCategory = 'Religion';

//   @override
//   void initState() {
//     super.initState();

//     _tabCategories = _categories
//         .where((c) => c.toLowerCase() != 'all')
//         .toList();

//     _selectedCategory = widget.categoryName;

//     final initialIndex = _tabCategories.indexOf(widget.categoryName);

//     _tabController = TabController(
//       length: _tabCategories.length,
//       vsync: this,
//       initialIndex: initialIndex >= 0 ? initialIndex : 0,
//     );
//     _tabController.addListener(() {
//       if (_tabController.indexIsChanging == false) {
//         setState(() {
//           _selectedCategory = _tabCategories[_tabController.index];
//         });
//       }
//     });
//     _filterOptionsFuture = ApiService.getFilterOptions();

//     // Preselect filter if provided
//     if (widget.preSelectedSubcategory != null) {
//       _selectedFilters[widget.categoryKey.toLowerCase()] = widget.preSelectedSubcategory!;
//       _selectedCards.add(widget.preSelectedSubcategory!);
//     }

//     // Load locked candidates
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadCandidates();
//     });
//   }

//   void _loadCandidates() {
//     final recruiterController = Provider.of<RecruiterController>(
//       context,
//       listen: false,
//     );
//     recruiterController.loadCandidates(
//       role: _selectedFilters['department'],
//       religion: _selectedFilters['religion'],
//       country: _selectedFilters['country'],
//       state: _selectedFilters['state'],
//       city: _selectedFilters['city'],
//     );
//   }

//   void _onCategorySelected(String categoryKey, String categoryValue) {
//     setState(() {
//       _selectedFilters[categoryKey] = categoryValue;
//       // Clear previous selections and add only current selection
//       _selectedCards.clear();
//       _selectedCards.add(categoryValue);
//     });
//     _loadCandidates();
//   }

//   void _clearFilter(String filterKey) {
//     setState(() {
//       final removedValue = _selectedFilters.remove(filterKey);
//       if (removedValue != null) {
//         _selectedCards.remove(removedValue);
//       }
//     });
//     _loadCandidates();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: NestedScrollView(
//         headerSliverBuilder: (context, innerBoxIsScrolled) => [
//           _buildSliverHeader(context),
//         ],
//         body: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
//                 color: AppTheme.primary,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Categories Section
//                     SizedBox(child: _buildCategoriesSection()),
//                   ],
//                 ),
//               ),
//               // Active Filters Section
//               if (_selectedFilters.isNotEmpty) _buildActiveFilters(),
//               // Candidates Section
//               _buildCandidatesSection(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSliverHeader(BuildContext context) {
//     return SliverAppBar(
//       backgroundColor: AppTheme.primary,
//       expandedHeight: 180,
//       floating: false,
//       pinned: true,
//       elevation: 0,
//       leading: IconButton(
//         onPressed: () => Navigator.pop(context),
//         icon: Icon(Icons.arrow_back_ios),
//       ),
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(110),
//         child: Container(
//           color: AppTheme.primary,
//           padding: const EdgeInsets.only(bottom: 20),
//           child: Column(
//             children: [
//               // Search Bar
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: Container(
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(25),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.2),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       const SizedBox(width: 20),
//                       SvgPicture.asset(
//                         'assets/svgs/search.svg',
//                         width: 20,
//                         height: 20,
//                         colorFilter: const ColorFilter.mode(
//                           Colors.white,
//                           BlendMode.srcIn,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           'Search in $_selectedCategory...',
//                           style: AppTheme.getBodyStyle(
//                             context,
//                             color: Colors.white.withOpacity(0.8),
//                             fontSize: 15,
//                           ),
//                         ),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.only(right: 8),
//                         padding: const EdgeInsets.all(8),
//                         child: SvgPicture.asset(
//                           'assets/svgs/filter.svg',
//                           width: 16,
//                           height: 16,
//                           colorFilter: const ColorFilter.mode(
//                             Colors.white,
//                             BlendMode.srcIn,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Tab Bar
//               const SizedBox(height: 20),
//               Container(
//                 height: 40,
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: TabBar(
//                   controller: _tabController,
//                   isScrollable: true,
//                   tabAlignment: TabAlignment.start,
//                   indicator: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   indicatorPadding: const EdgeInsets.symmetric(
//                     horizontal: 2,
//                     vertical: 4,
//                   ),
//                   indicatorSize: TabBarIndicatorSize.tab,
//                   dividerColor: Colors.transparent,
//                   labelColor: AppTheme.primary,
//                   unselectedLabelColor: Colors.white.withOpacity(0.8),
//                   labelStyle: AppTheme.getBodyStyle(
//                     context,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                   ),
//                   unselectedLabelStyle: AppTheme.getBodyStyle(
//                     context,
//                     fontWeight: FontWeight.w500,
//                     fontSize: 13,
//                   ),
//                   onTap: (index) {
//                     setState(() {
//                       _selectedCategory = _tabCategories[index];
//                     });
//                   },

//                   tabs: _tabCategories
//                       .map(
//                         (category) => Tab(
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 6,
//                             ),
//                             child: Text(category),
//                           ),
//                         ),
//                       )
//                       .toList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       title: Text(
//         _selectedCategory,
//         style: AppTheme.getTitleStyle(
//           context,
//           color: Colors.white,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoriesSection() {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _filterOptionsFuture,

//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SizedBox.shrink();
//         }

//         if (snapshot.hasError || snapshot.data?['error'] != null) {
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Center(
//               child: Text(
//                 'Error loading categories',
//                 style: AppTheme.getBodyStyle(context, color: Colors.white),
//               ),
//             ),
//           );
//         }

//         final results = snapshot.data?['results'] ?? {};
//         final all = results['all'] as Map<String, dynamic>?;

//         if (all == null) {
//           return const SizedBox.shrink();
//         }

//         final subcategories = all['subcategories'] as Map<String, dynamic>?;
//         if (subcategories == null) {
//           return const SizedBox.shrink();
//         }

//         final categoryKey = _selectedCategory.toLowerCase();

//         if (categoryKey == 'all') {
//           final options = <Map<String, dynamic>>[];
//           subcategories.forEach((key, value) {
//             final categoryData = value as Map<String, dynamic>;
//             options.add({
//               'key': key,
//               'name': categoryData['name'] ?? key,
//               'locked_count': categoryData['locked_count'] ?? 0,
//               'icon': getCategoryIcon(key),
//             });
//           });

//           return CategoryCardsWidget(
//             categories: options,
//             isGridLayout: true,
//             selectedCards: _selectedCards,
//             onCategoryTap: (categoryKey) {
//               _onCategorySelected(categoryKey, categoryKey);
//             },
//           );
//         }

//         final categoryData =
//             subcategories[categoryKey] as Map<String, dynamic>?;
//         if (categoryData == null) {
//           return const SizedBox.shrink();
//         }

//         final categoryOptions =
//             categoryData['options'] as Map<String, dynamic>?;
//         if (categoryOptions == null || categoryOptions.isEmpty) {
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Center(
//               child: Text(
//                 'No options available',
//                 style: AppTheme.getBodyStyle(context, color: Colors.white),
//               ),
//             ),
//           );
//         }

//         final options = <Map<String, dynamic>>[];
//         categoryOptions.forEach((key, value) {
//           final optionData = value as Map<String, dynamic>;
//           options.add({
//             'key': key,
//             'name': optionData['name'] ?? key,
//             'locked_count': optionData['locked_count'] ?? 0,
//             'icon': getCategoryIcon(categoryKey),
//           });
//         });

//         return CategoryCardsWidget(
//           categories: options,
//           isGridLayout: true,
//           selectedCards: _selectedCards,
//           onCategoryTap: (subcategoryKey) {
//             _onCategorySelected(categoryKey, subcategoryKey);
//           },
//         );
//       },
//     );
//   }

//   String getCategoryIcon(String key) {
//     switch (key) {
//       case 'department':
//         return 'assets/svg/work.svg';
//       case 'religion':
//         return 'assets/svgs/religion.svg';
//       case 'country':
//         return 'assets/svgs/country.svg';
//       case 'state':
//         return 'assets/svgs/state.svg';
//       case 'city':
//         return 'assets/svgs/city.svg';
//       case 'education':
//         return 'assets/svgs/education.svg';
//       default:
//         return 'assets/svgs/default.svg';
//     }
//   }

//   Widget _buildActiveFilters() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Active Filters',
//             style: AppTheme.getHeadlineStyle(
//               context,
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: _selectedFilters.entries.map((entry) {
//               return Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppTheme.accentPrimary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: AppTheme.accentPrimary.withOpacity(0.3),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       '${entry.key}: ${entry.value}',
//                       style: AppTheme.getBodyStyle(
//                         context,
//                         fontSize: 12,
//                         color: AppTheme.accentPrimary,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(width: 4),
//                     GestureDetector(
//                       onTap: () => _clearFilter(entry.key),
//                       child: Icon(
//                         Icons.close,
//                         size: 16,
//                         color: AppTheme.accentPrimary,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCandidatesSection() {
//     return Consumer<RecruiterController>(
//       builder: (context, recruiterController, child) {
//         if (recruiterController.isLoading) {
//           return Container(
//             padding: const EdgeInsets.all(40),
//             child: const Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (recruiterController.error != null) {
//           return Container(
//             padding: const EdgeInsets.all(16),
//             child: Center(
//               child: Column(
//                 children: [
//                   Text(
//                     'Error: ${recruiterController.error}',
//                     style: AppTheme.getBodyStyle(context, color: Colors.red),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: _loadCandidates,
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         // Only show locked (non-unlocked) candidates
//         final lockedCandidates = recruiterController.candidates
//             .where(
//               (candidate) =>
//                   !recruiterController.isCandidateUnlocked(candidate['id']),
//             )
//             .toList();

//         if (lockedCandidates.isEmpty) {
//           return Container(
//             padding: const EdgeInsets.all(40),
//             child: Center(
//               child: Column(
//                 children: [
//                   SvgPicture.asset(
//                     'assets/svgs/empty.svg',
//                     width: 80,
//                     height: 80,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No locked candidates found',
//                     style: AppTheme.getHeadlineStyle(
//                       context,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Try adjusting your filters to find more candidates',
//                     style: AppTheme.getBodyStyle(context, color: Colors.grey),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Locked Candidates',
//                     style: AppTheme.getHeadlineStyle(
//                       context,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppTheme.accentPrimary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       '${lockedCandidates.length} found',
//                       style: AppTheme.getBodyStyle(
//                         context,
//                         fontSize: 12,
//                         color: AppTheme.accentPrimary,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               ListView.separated(
//                 shrinkWrap: true,
//                 padding: EdgeInsets.symmetric(vertical: 10),
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: lockedCandidates.length,
//                 separatorBuilder: (context, index) =>
//                     const SizedBox(height: 16),
//                 itemBuilder: (context, index) {
//                   final candidate = lockedCandidates[index];
//                   final isUnlocked = recruiterController.isCandidateUnlocked(
//                     candidate['id'],
//                   );
//                   final canAfford = recruiterController.canUnlockCandidate();

//                   return CandidateCardWidget(
//                     candidate: candidate,
//                     isUnlocked: isUnlocked,
//                     canAffordUnlock: canAfford,
//                     onUnlock: () async {
//                       final result = await recruiterController.unlockCandidate(
//                         candidate['id'],
//                       );
//                       if (result != null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('Profile unlocked successfully!'),
//                             backgroundColor: Colors.green,
//                           ),
//                         );
//                         // Refresh the list to remove this candidate from locked list
//                         _loadCandidates();
//                       }
//                     },
//                     onViewProfile: () {
//                       // Navigate to detailed profile view
//                       print('View profile: ${candidate['id']}');
//                     },
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }