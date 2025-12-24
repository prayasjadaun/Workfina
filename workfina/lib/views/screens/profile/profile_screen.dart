import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final themeController = context.watch<ThemeController>();
    final user = authController.user;

    return Container(
      decoration: AppTheme.getGradientDecoration(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [AppTheme.getCardShadow(context)],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryGreen,
                    child: Text(
                      user?['email']?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?['email'] ?? 'User',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user?['role']?.toUpperCase() ?? 'COMPANY',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSettingsSection(context, 'Account Settings', [
              _buildSettingsItem(
                context,
                Icons.person_outline,
                'Edit Profile',
                () {},
              ),
              _buildSettingsItem(
                context,
                Icons.notifications_outlined,
                'Notifications',
                () {},
              ),
              _buildSettingsItem(context, Icons.security, 'Security', () {}),
            ]),
            const SizedBox(height: 16),
            _buildSettingsSection(context, 'App Settings', [
              ListTile(
                leading: Icon(
                  themeController.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                title: const Text('Theme'),
                subtitle: Text(themeController.currentThemeName),
                trailing: Switch(
                  value: themeController.isDarkMode,
                  onChanged: (_) => themeController.toggleTheme(),
                ),
              ),
              _buildSettingsItem(context, Icons.language, 'Language', () {}),
            ]),
            const SizedBox(height: 16),
            _buildSettingsSection(context, 'Support', [
              _buildSettingsItem(
                context,
                Icons.help_outline,
                'Help & Support',
                () {},
              ),
              _buildSettingsItem(
                context,
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                () {},
              ),
              _buildSettingsItem(
                context,
                Icons.description_outlined,
                'Terms of Service',
                () {},
              ),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => _showLogoutDialog(context, authController),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
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
              await authController.logoutWithToken();
              if (authController.error != null) {
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(authController.error!),
                    backgroundColor: Colors.red,
                  ),
                );
                authController.clearError();
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/email',
                  (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
