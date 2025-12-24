import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/auth_controller.dart';
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
  if (mounted) {
    await context.read<AuthController>().checkAuthStatus();
    final authController = context.read<AuthController>();

    if (authController.user != null) {
      final userRole = authController.user?['role'];
      
      // Check if user has completed profile setup
      if (userRole == 'candidate') {
        // Check if candidate profile exists
        Navigator.pushReplacementNamed(context, '/candidate-home');
      } else if (userRole == 'hr') {
        // Check if HR profile exists  
        Navigator.pushReplacementNamed(context, '/hr-home');
      } else {
        // User exists but role not properly set, go to role selection
        Navigator.pushReplacementNamed(context, '/role-selection');
      }
    } else {
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
