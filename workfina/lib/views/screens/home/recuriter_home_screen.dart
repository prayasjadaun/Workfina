import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/views/screens/recuriters/recruiter_candidate_screen.dart';
import 'package:workfina/views/screens/recuriters/recruiter_dashboard.dart';
import 'package:workfina/views/screens/recuriters/recruiter_filter_screen.dart';
import 'package:workfina/views/screens/recuriters/recruiter_profile_screen.dart';
import 'package:workfina/views/screens/recuriters/recruiter_wallet_screen.dart';

class RecruiterHomeScreen extends StatefulWidget {
  const RecruiterHomeScreen({super.key});

  @override
  State<RecruiterHomeScreen> createState() => _RecruiterHomeScreenState();
}

class _RecruiterHomeScreenState extends State<RecruiterHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<RecruiterController>();
      controller.loadHRProfile();
      controller.loadWalletBalance();
      controller.loadUnlockedCandidates();
      controller.loadCandidates();
    });
  }

  @override
  Widget build(BuildContext context) {
    // final recruiterController = context.watch<RecruiterController>();
    // final fullName = (recruiterController.hrProfile?['full_name'] ?? 'HR')
    //     .split(' ')
    //     .take(2)
    //     .join(' ');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // appBar: showAppBar
      //     ? AppBar(
      //         title: Text('HR Dashboard - $fullName',
      //             style: AppTheme.getAppBarTextStyle()),
      //         automaticallyImplyLeading: false,
      //       )
      //     : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          RecruiterDashboard(
            onNavigateToUnlocked: () => setState(() => _currentIndex = 2),
          ),
          const RecruiterFilterScreen(showUnlockedOnly: false),
          RecruiterCandidate(
            onSwitchToWallet: (index) =>
                setState(() => _currentIndex = 3), 
            showOnlyUnlocked: true,
          ),
          const RecruiterWalletScreen(),
          const RecruiterProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCustomTab('assets/svg/home.svg', 'Home', 0, isDark),
            _buildCustomTab('assets/svg/filter.svg', 'Filters', 1, isDark),
            _buildCustomTab('assets/svg/unlock.svg', 'Unlocked', 2, isDark),
            _buildCustomTab('assets/svg/wallet.svg', 'Wallet', 3, isDark),
            _buildCustomTab('assets/svg/profile.svg', 'Profile', 4, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTab(String svgPath, String text, int index, bool isDark) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () {
        if (_currentIndex != index) {
          HapticFeedback.mediumImpact();
          setState(() => _currentIndex = index);
        }
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 12 : 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : AppTheme.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 22,
              height: 20,
              colorFilter: ColorFilter.mode(
                isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white : Colors.black),
                BlendMode.srcIn,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: isDark ? Colors.black : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
