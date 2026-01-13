import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/services/notification_service.dart';
import 'package:workfina/views/screens/splash_screen.dart';
import 'controllers/theme_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/candidate_controller.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiService.initialize();

  await NotificationService.initializeWithoutPermissions();

  // Get FCM token on app start
  final fcmToken = await NotificationService.getToken();
  final hasPermissions = await NotificationService.checkPermissions();
  await NotificationService.requestPermissionsLater();

  runApp(const WorkfinaApp());
}

class WorkfinaApp extends StatelessWidget {
  const WorkfinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CandidateController()),
        ChangeNotifierProvider(create: (_) => RecruiterController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Workfina',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            home: const SplashScreen(),
            routes: AppRoutes.getRoutes(),
          );
        },
      ),
    );
  }
}
