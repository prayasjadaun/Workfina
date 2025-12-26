import 'package:flutter/material.dart';
import 'package:workfina/views/screens/auth/email_screen.dart';
import 'package:workfina/views/screens/auth/login_screen.dart';
import 'package:workfina/views/screens/auth/otp_screen.dart';
import 'package:workfina/views/screens/auth/create_account_screen.dart';
import 'package:workfina/views/screens/candidates/candidate_setup_screen.dart';
import 'package:workfina/views/screens/home/candidate_home_screen.dart';
import 'package:workfina/views/screens/home/recuriter_home_screen.dart';
import 'package:workfina/views/screens/recuriters/recuriter_setup_screen.dart';
import 'package:workfina/views/screens/splash_screen.dart';
import 'package:workfina/views/screens/role/role_selection_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String email = '/email';
  static const String otp = '/otp';
  static const String createAccount = '/create-account';
  static const String login = '/login';
  static const String home = '/home';
  static const String roleSelection = '/role-selection';
  static const String candidateSetup = '/candidate-setup';
  static const String hrSetup = '/hr-setup';
  static const String candidateHome = '/candidate-home';
  static const String hrHome = '/hr-home';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      email: (context) => const EmailScreen(),
      otp: (context) => const OTPScreen(),
      createAccount: (context) => const CreateAccountScreen(),
      login: (context) => const LoginScreen(),
      roleSelection: (context) => const RoleSelectionScreen(),
      candidateSetup: (context) => const CandidateSetupScreen(),
      hrSetup: (context) => const RecruiterSetupScreen(),
      candidateHome: (context) => const CandidateHomeScreen(),
      hrHome: (context) => const RecruiterHomeScreen(),
    };
  }
}