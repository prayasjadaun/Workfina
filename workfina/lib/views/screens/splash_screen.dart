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

        try {
          final hasProfile = await candidateController.checkProfileExists();

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
        } catch (e) {
          print('[DEBUG] Candidate profile check failed: $e');
          // Check if it's an auth error (401/404 means user deleted from backend)
          if (e.toString().contains('401') ||
              e.toString().contains('404') ||
              candidateController.error?.contains('Failed to load profile') == true) {
            print('[DEBUG] Authentication failed - clearing tokens and redirecting to login');
            await authController.logout();
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
            return;
          }
          if (mounted) {
            _showNetworkErrorDialog('Failed to load candidate profile');
          }
        }
      } else if (userRole == 'hr') {
        if (mounted) {
          final recruiterController = RecruiterController();

          try {
            final hasProfile = await recruiterController.loadHRProfile();

            Navigator.pushReplacementNamed(
              context,
              hasProfile ? '/hr-home' : '/hr-setup',
            );
          } catch (e) {
            print('[DEBUG] HR profile check failed: $e');
            // Check if it's an auth error (401/404 means user deleted from backend)
            if (e.toString().contains('401') || e.toString().contains('404')) {
              print('[DEBUG] Authentication failed - clearing tokens and redirecting to login');
              await authController.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
              return;
            }
            if (mounted) {
              _showNetworkErrorDialog('Failed to load HR profile');
            }
          }
        }
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/role-selection');
        }
      }
    } catch (e) {
      print('[DEBUG] Splash error: $e');
      if (mounted) {
        _showNetworkErrorDialog('Unable to connect to server');
      }
    }
  }

  void _showNetworkErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.wifi_off, size: 48, color: Colors.red.shade400),
        title: const Text('Connection Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text(
              'Please check your internet connection and try again.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Go to Login'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _checkAuthStatus();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
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
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.work, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 30),
              Text(
                'Workfina',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
