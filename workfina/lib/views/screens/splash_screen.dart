import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/auth_controller.dart';
import 'package:workfina/controllers/candidate_controller.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animationController.forward();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    try {
      await context.read<AuthController>().checkAuthStatus();
      final authController = context.read<AuthController>();

      if (authController.user == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final userRole = authController.user?['role'];
      print('[DEBUG] User role from stored data: $userRole');

      if (userRole == 'candidate') {
        final candidateController = CandidateController();
        final hasProfile = await candidateController.checkProfileExists();

        // If backend rejects, data is corrupt - logout
        if (!hasProfile &&
            candidateController.error != null &&
            candidateController.error!.contains('Only candidates')) {
          print('[DEBUG] Role mismatch detected - logging out');
          await authController.logout();
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
          return;
        }

        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            hasProfile ? '/candidate-home' : '/candidate-setup',
          );
        }
      } else if (userRole == 'hr') {
        if (mounted) {
          final recruiterController = RecruiterController();
          final hasProfile = await recruiterController.loadHRProfile();

          Navigator.pushReplacementNamed(
            context,
            hasProfile ? '/hr-home' : '/hr-setup',
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/role-selection');
        }
      }
    } catch (e) {
      print('[DEBUG] Splash error: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.getGradientDecoration(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.work, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 30),
              Text(
                'Workfina',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
