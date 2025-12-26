import 'package:flutter/material.dart';
import 'package:workfina/theme/app_theme.dart';

class CandidateDashboard extends StatelessWidget {
  const CandidateDashboard({super.key});

  @override
  Widget build(BuildContext context) {
 

    return Scaffold(
      
      body: Container(
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                        child: Icon(Icons.business, color: Colors.white),
                      ),
                      title: Text('Tech Corp viewed your profile'),
                      subtitle: Text(
                        '${index + 1} hour${index == 0 ? '' : 's'} ago',
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
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


}
