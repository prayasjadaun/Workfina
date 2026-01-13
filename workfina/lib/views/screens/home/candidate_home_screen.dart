import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/auth_controller.dart';
import 'package:workfina/controllers/candidate_controller.dart';
import 'package:workfina/views/screens/candidates/candidate_dashboard.dart';
import 'package:workfina/views/screens/candidates/candidate_jobs_screen.dart';
import 'package:workfina/views/screens/candidates/candidate_applications_screen.dart';
import 'package:workfina/views/screens/candidates/candidate_profile.dart';
import 'package:workfina/theme/app_theme.dart';

class CandidateHomeScreen extends StatefulWidget {
  const CandidateHomeScreen({super.key});

  @override
  State<CandidateHomeScreen> createState() => _CandidateHomeScreenState();
}

class _CandidateHomeScreenState extends State<CandidateHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    return Scaffold(
      appBar: _currentIndex == 1 || _currentIndex == 2
          ? AppBar(
              title: Consumer<CandidateController>(
                builder: (context, candidateController, _) {
                  String displayName = 'Candidate';

                  if (candidateController.candidateProfile != null) {
                    final firstName = (candidateController.candidateProfile!['first_name'] ?? '').trim();
        final lastName = (candidateController.candidateProfile!['last_name'] ?? '').trim();

                    if (firstName.isNotEmpty) {
                      // Show first name and last name if both available
                      displayName = lastName.isNotEmpty
                          ? '$firstName $lastName'
                          : firstName;
                    }
                  }

                  return Text('Welcome, $displayName');
                },
              ),
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          CandidateDashboard(),
          // CandidateJobsScreen(),
          // CandidateApplicationsScreen(),
          CandidateProfileScreen(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,

        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/home.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SvgPicture.asset(
                'assets/svg/home.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  AppTheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: 'Dashboard',
          ),

          // BottomNavigationBarItem(
          //   icon: SvgPicture.asset(
          //     'assets/svg/work.svg',
          //     width: 24,
          //     height: 24,
          //     colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          //   ),
          //   activeIcon: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          //     decoration: BoxDecoration(
          //       color: AppTheme.primary.withOpacity(0.12),
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //     child: SvgPicture.asset(
          //       'assets/svg/work.svg',
          //       width: 22,
          //       height: 22,
          //       colorFilter: ColorFilter.mode(
          //         AppTheme.primary,
          //         BlendMode.srcIn,
          //       ),
          //     ),
          //   ),
          //   label: 'Jobs',
          // ),

          // BottomNavigationBarItem(
          //   icon: SvgPicture.asset(
          //     'assets/svg/docs.svg',
          //     width: 24,
          //     height: 24,
          //     colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          //   ),
          //   activeIcon: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          //     decoration: BoxDecoration(
          //       color: AppTheme.primary.withOpacity(0.12),
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //     child: SvgPicture.asset(
          //       'assets/svg/docs.svg',
          //       width: 22,
          //       height: 22,
          //       colorFilter: ColorFilter.mode(
          //         AppTheme.primary,
          //         BlendMode.srcIn,
          //       ),
          //     ),
          //   ),
          //   label: 'Applications',
          // ),

          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/profile.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SvgPicture.asset(
                'assets/svg/profile.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  AppTheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<AuthController>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/email',
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
