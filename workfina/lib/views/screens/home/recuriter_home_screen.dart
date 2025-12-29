import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/views/screens/recuriters/recruiter_candidate_screen.dart';
import 'package:workfina/views/screens/recuriters/recruiter_dashboard.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final recruiterController = context.watch<RecruiterController>();
    final fullName = (recruiterController.hrProfile?['full_name'] ?? 'HR')
        .split(' ')
        .take(2)
        .join(' ');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show AppBar only for Dashboard (index 0) and Profile (index 3)
    final showAppBar = _currentIndex == 0 || _currentIndex == 3;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text('HR Dashboard - $fullName'),
              automaticallyImplyLeading: false,
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const RecruiterDashboard(),
          RecruiterCandidate(
            onSwitchToWallet: (index) => setState(() => _currentIndex = index),
          ),
          const RecruiterWalletScreen(),
          const RecruiterProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: isDark
                ? AppTheme.darkSurface
                : AppTheme.lightSurface,
            color: isDark ? Colors.grey : Colors.grey.shade600,
            activeColor: Colors.white,
            tabBackgroundColor: AppTheme.primaryGreen,
            gap: 8,
            padding: const EdgeInsets.all(16),
            selectedIndex: _currentIndex,
            onTabChange: (index) => setState(() => _currentIndex = index),
            tabs: const [
              GButton(icon: Icons.dashboard, text: 'Dashboard'),
              GButton(icon: Icons.people, text: 'Candidates'),
              GButton(icon: Icons.account_balance_wallet, text: 'Wallet'),
              GButton(icon: Icons.person, text: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}