import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/auth_controller.dart';
import 'package:workfina/theme/app_theme.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_pin, size: 80),
              const SizedBox(height: 32),
              Text(
                'Welcome',
                style: AppTheme.getAuthTitleStyle(
                  context,
                ).copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you a candidate or an HR recruiter?',
                style: AppTheme.getAuthSubtitleStyle(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildRoleCard(
                context,
                'candidate',
                'I am a Candidate',
                'Looking for job opportunities',
                Icons.person_search,
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                'hr',
                'I am an HR Recruiter',
                'Looking to hire candidates',
                Icons.business,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedRole == null
                      ? null
                      : () async {
                          final authController = context.read<AuthController>();
                          await authController.updateUserRole(_selectedRole!);

                          if (_selectedRole == 'candidate') {
                            Navigator.pushNamed(context, '/candidate-setup');
                          } else {
                            Navigator.pushNamed(context, '/hr-setup');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.blue,
                    disabledBackgroundColor: AppTheme.getDividerColor(context),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _selectedRole == null
                          ? Colors.grey[600]
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedRole == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.blue
                : AppTheme.getDividerColor(context),
            width: 2,
          ),
          boxShadow: [AppTheme.getCardShadow(context)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.blue
                    : AppTheme.getInputFillColor(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : AppTheme.getInputIconColor(context),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppTheme.blue
                          : AppTheme.getTextPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.blue, size: 24),
          ],
        ),
      ),
    );
  }
}
