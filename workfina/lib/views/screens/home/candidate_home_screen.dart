import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/auth_controller.dart';
import 'package:workfina/controllers/theme_controller.dart';
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
      appBar: AppBar(
        title: Text('Welcome, ${user?['email']?.split('@')[0] ?? 'Candidate'}'),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<ThemeController>(
            builder: (context, themeController, child) {
              return IconButton(
                icon: Icon(
                  themeController.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () => themeController.toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(),
          _buildProfileTab(),
          _buildApplicationsTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Container(
      decoration: AppTheme.getGradientDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [AppTheme.getCardShadow(context)],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 60,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Profile Complete!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your profile is now visible to recruiters',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Dashboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Profile Views',
                    '24',
                    Icons.visibility,
                    AppTheme.secondaryBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Profile Unlocks',
                    '8',
                    Icons.lock_open,
                    AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => Card(
                  color: AppTheme.getCardColor(context),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen,
                      child: const Icon(Icons.business, color: Colors.white),
                    ),
                    title: const Text('Tech Corp viewed your profile'),
                    subtitle: Text(
                      '${index + 1} hour${index == 0 ? '' : 's'} ago',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    final user = context.watch<AuthController>().user;
    
    return Container(
      decoration: AppTheme.getGradientDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [AppTheme.getCardShadow(context)],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryGreen,
                    child: Text(
                      (user?['email']?.split('@')[0]?[0] ?? 'C').toUpperCase(),
                      style: const TextStyle(fontSize: 36, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?['username'] ?? user?['email']?.split('@')[0] ?? 'Candidate',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?['email'] ?? 'No email',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Profile Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppTheme.getCardColor(context),
              child: const ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Profile'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
            Card(
              color: AppTheme.getCardColor(context),
              child: const ListTile(
                leading: Icon(Icons.description),
                title: Text('Resume'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
            Card(
              color: AppTheme.getCardColor(context),
              child: const ListTile(
                leading: Icon(Icons.work_history),
                title: Text('Experience'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsTab() {
    return Container(
      decoration: AppTheme.getGradientDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Applications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Applied',
                    '12',
                    Icons.send,
                    AppTheme.secondaryBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Interviews',
                    '3',
                    Icons.calendar_today,
                    AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Applications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => Card(
                  color: AppTheme.getCardColor(context),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen,
                      child: const Icon(Icons.business, color: Colors.white),
                    ),
                    title: Text('Frontend Developer - Company ${index + 1}'),
                    subtitle: Text('Applied ${index + 1} days ago'),
                    trailing: Chip(
                      label: Text(index == 0 ? 'Under Review' : 'Applied'),
                      backgroundColor: index == 0 
                          ? AppTheme.accentOrange.withOpacity(0.2)
                          : AppTheme.primaryGreen.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Container(
      decoration: AppTheme.getGradientDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppTheme.getCardColor(context),
              child: const ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notifications'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
            Card(
              color: AppTheme.getCardColor(context),
              child: const ListTile(
                leading: Icon(Icons.privacy_tip),
                title: Text('Privacy'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
            Card(
              color: AppTheme.getCardColor(context),
              child: const ListTile(
                leading: Icon(Icons.help),
                title: Text('Help & Support'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
            Card(
              color: AppTheme.getCardColor(context),
              child: const ListTile(
                leading: Icon(Icons.info),
                title: Text('About'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Logout', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
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