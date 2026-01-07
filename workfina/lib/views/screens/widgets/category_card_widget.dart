import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:workfina/theme/app_theme.dart';

class CategoryCardsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final Function(String)? onCategoryTap;
  final bool isGridLayout;
  final Set<String> selectedCards;
  final bool isCategoryMode;

  const CategoryCardsWidget({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.isGridLayout = false,
    this.isCategoryMode = false,
    this.selectedCards = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    if (isCategoryMode) {
      return _buildCategoryGrid(context);
    }

    return isGridLayout ? _buildGridLayout() : _buildDashboardLayout();
  }

  Widget _buildDashboardLayout() {
    final mainCategory = categories[0];
    final otherCategories = categories.skip(1).take(4).toList();

    const double totalHeight = 220;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: totalHeight,
        child: Row(
          children: [
            /// ================= LEFT BIG CARD =================
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => onCategoryTap?.call(mainCategory['key']),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.greenCardStart, AppTheme.greenCardEnd],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final iconSize = constraints.maxHeight * 0.22;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            mainCategory['icon'] ??
                                getCategoryIcon(mainCategory['key']),
                            height: 80,
                            width: iconSize,
                            color: Colors.black,
                          ),

                          const SizedBox(height: 10),
                          Column(
                            children: [
                              Text(
                                mainCategory['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.getHeadlineStyle(
                                  context,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _CountChip(
                                text:
                                    '${mainCategory['locked_count']} candidates',
                                dark: true,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            /// ================= RIGHT 2x2 SMALL CARDS =================
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _SmallCategoryCard(
                            otherCategories[0],
                            onCategoryTap,
                            isSelected: selectedCards.contains(
                              otherCategories[0]['key'],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SmallCategoryCard(
                            otherCategories[1],
                            onCategoryTap,
                            isSelected: selectedCards.contains(
                              otherCategories[1]['key'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _SmallCategoryCard(
                            otherCategories[2],
                            onCategoryTap,
                            isSelected: selectedCards.contains(
                              otherCategories[2]['key'],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SmallCategoryCard(
                            otherCategories[3],
                            onCategoryTap,
                            isSelected: selectedCards.contains(
                              otherCategories[3]['key'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Builder(
          builder: (context) => Row(
            children: categories.map((category) {
              final isSelected = selectedCards.contains(category['key']);
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => onCategoryTap?.call(category['key']),
                  child: Container(
                    width: 120,
                    height: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.greenCardSolid,
                      // color: Colors.red,
                      borderRadius: BorderRadius.circular(22),
                      border: isSelected
                          ? Border.all(color: AppTheme.greenCard, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          category['icon'] ?? getCategoryIcon(category['key']),
                          width: 24,
                          height: 24,
                          color: Colors.black,
                        ),

                        const SizedBox(height: 8),
                        Text(
                          category['name'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTheme.getBodyStyle(
                            context,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${category['locked_count'] ?? 0} candidates',
                          style: AppTheme.getLabelStyle(
                            context,
                            fontSize: 10,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: GridView.builder(
        padding: EdgeInsets.all(5),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, 
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1, // card size same feel
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCards.contains(category['key']);

          return GestureDetector(
            onTap: () => onCategoryTap?.call(category['key']),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.greenCardSolid,
                borderRadius: BorderRadius.circular(22),
                border: isSelected
                    ? Border.all(color: AppTheme.greenCard, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    category['icon'] ?? getCategoryIcon(category['key']),
                    width: 24,
                    height: 24,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name'] ?? '',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.getBodyStyle(
                      context,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category['locked_count'] ?? 0} candidates',
                    style: AppTheme.getLabelStyle(
                      context,
                      fontSize: 10,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ================= ICON MAPPER =================
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
}

/// ================= SMALL CARD =================
class _SmallCategoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(String)? onTap;
  final bool isSelected;

  const _SmallCategoryCard(this.data, this.onTap, {this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(data['key']),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFCDEDAA),
          borderRadius: BorderRadius.circular(22),
          border: isSelected ? Border.all(color: Colors.red, width: 2) : null,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final iconSize = constraints.maxHeight * 0.3;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  data['icon'] ?? _icon(data['key']),
                  height: iconSize,
                  width: iconSize,
                  color: Colors.black,
                ),

                const Spacer(),

                Text(
                  data['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getBodyStyle(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${data['locked_count']} candidates',
                  style: AppTheme.getLabelStyle(
                    context,
                    fontSize: 10,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _icon(String key) {
    switch (key) {
      case 'department':
        return 'assets/svgs/department.svg';
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
}

/// ================= COUNT CHIP =================
class _CountChip extends StatelessWidget {
  final String text;
  final bool dark;

  const _CountChip({required this.text, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: dark ? Colors.black.withOpacity(0.55) : Colors.orange,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTheme.getBodyStyle(
          context,
          fontSize: dark ? 10 : 14,
          fontWeight: FontWeight.w700,
          color: dark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
