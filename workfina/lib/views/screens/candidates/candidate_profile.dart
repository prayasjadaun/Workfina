import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/auth_controller.dart';
import 'package:workfina/theme/app_theme.dart';

class CandidateProfileScreen extends StatelessWidget {
  const CandidateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    return Container(
      decoration: AppTheme.getGradientDecoration(context),
      child: SingleChildScrollView(
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
              Card(
                color: AppTheme.getCardColor(context),
                child: const ListTile(
                  leading: Icon(Icons.school),
                  title: Text('Education'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
              Card(
                color: AppTheme.getCardColor(context),
                child: const ListTile(
                  leading: Icon(Icons.computer_rounded),
                  title: Text('Skills'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}