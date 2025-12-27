import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/controllers/recuriter_controller.dart';

class RecruiterDashboard extends StatefulWidget {
  const RecruiterDashboard({super.key});

  @override
  State<RecruiterDashboard> createState() => _RecruiterDashboardState();
}

class _RecruiterDashboardState extends State<RecruiterDashboard> {
 

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<RecruiterController>().loadCandidates();
  });
}

  @override
  Widget build(BuildContext context) {
    return Consumer<RecruiterController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.hrProfile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = controller.hrProfile;
        final wallet = controller.wallet;
        final balance = wallet?['balance'] ?? 0;
        final totalSpent = profile?['total_spent'] ?? 0;
        final unlockedCount = controller.unlockedCandidateIds.length;

        return Container(
          decoration: AppTheme.getGradientDecoration(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Credits',
                        balance.toString(),
                        Icons.account_balance_wallet,
                        AppTheme.accentOrange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Unlocked',
                        unlockedCount.toString(),
                        Icons.lock_open,
                        AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Total Spent',
                        totalSpent.toString(),
                        Icons.payments,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Total Candidates',
                        controller.candidates.length.toString(),
                        Icons.people,
                        AppTheme.secondaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Unlocks',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: controller.unlockedCandidateIds.isEmpty
                      ? Center(
                          child: Text(
                            'No unlocked candidates yet',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : FutureBuilder<Map<String, dynamic>>(
                          future: _fetchUnlockedCandidates(controller),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final unlockedCandidates =
                                snapshot.data?['unlocked_candidates']
                                    as List? ??
                                [];

                            return ListView.builder(
                              itemCount: unlockedCandidates.length,
                              itemBuilder: (context, index) {
                                final candidate = unlockedCandidates[index];
                                return Card(
                                  color: AppTheme.getCardColor(context),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppTheme.primaryGreen,
                                      child: Text(
                                        (candidate['full_name'] ?? 'C')[0]
                                            .toUpperCase(),
                                      ),
                                    ),
                                    title: Text(
                                      candidate['full_name'] ?? 'Unknown',
                                    ),
                                    subtitle: Text(
                                      '${candidate['experience_years'] ?? 0} years - ${candidate['city'] ?? 'N/A'}',
                                    ),
                                    trailing: Text(
                                      '-${candidate['credits_used'] ?? 10} credits',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchUnlockedCandidates(
    RecruiterController controller,
  ) async {
    final response = await ApiService.getUnlockedCandidates();
    return response;
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
