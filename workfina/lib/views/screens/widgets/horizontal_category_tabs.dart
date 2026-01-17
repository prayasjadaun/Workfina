import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:workfina/theme/app_theme.dart';

class HorizontalCategoryTabs extends StatefulWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onCategoryTap;

  const HorizontalCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryTap,
  });

  @override
  State<HorizontalCategoryTabs> createState() => _HorizontalCategoryTabsState();
}

String _getCategoryIcon(String category) {
  final key = category.toLowerCase();
  switch (key) {
    case 'department':
      return 'assets/svgs/department.svg';
    case 'religion':
      return 'assets/svgs/users.svg';
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

class _HorizontalCategoryTabsState extends State<HorizontalCategoryTabs>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _categoryKeys = [];
  @override
  void initState() {
    super.initState();

    // Initialize keys for each category
    _categoryKeys.addAll(
      List.generate(widget.categories.length, (_) => GlobalKey()),
    );

    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Right to left slide animation
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Start from right
          end: Offset.zero, // End at original position
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / 4; // Show 4 tabs on screen

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: 68,
        color: AppTheme.primary,
        child: widget.categories.length <= 4
            ? Row(
                children: List.generate(widget.categories.length, (index) {
                  final isSelected = widget.selectedIndex == index;
                  final category = widget.categories[index];

                  return Expanded(
                    child: _buildTabItem(category, isSelected, isDark, index),
                  );
                }),
              )
            : ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.categories.length,
                itemBuilder: (context, index) {
                  final isSelected = widget.selectedIndex == index;
                  final category = widget.categories[index];

                  return SizedBox(
                    width: tabWidth,
                    child: _buildTabItem(category, isSelected, isDark, index),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTabItem(
    String category,
    bool isSelected,
    bool isDark,
    int index,
  ) {
    return GestureDetector(
      key: _categoryKeys[index],
      onTap: () => widget.onCategoryTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8,
        //  horizontal: 15
         ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // Icon
            SvgPicture.asset(
              _getCategoryIcon(category),
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : Colors.grey.shade400,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            // Category Text
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Bottom indicator line
            Container(
              height: 4,
              width: 45,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.white : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isSelected ? 10 : 0),
                  topRight: Radius.circular(isSelected ? 10 : 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
