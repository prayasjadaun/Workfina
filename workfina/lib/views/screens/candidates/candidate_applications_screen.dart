import 'package:flutter/material.dart';
import 'package:workfina/theme/app_theme.dart';

class CandidateApplicationsScreen extends StatelessWidget {
  const CandidateApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.getGradientDecoration(context),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppTheme.primaryGreen,
            title: const Text('My Applications'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildApplicationCard(context, index),
                childCount: 5, // Replace with actual application count
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, int index) {
    // Sample statuses
    final statuses = ['Applied', 'Under Review', 'Shortlisted', 'Interview', 'Rejected'];
    final statusColors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.green,
      Colors.red,
    ];
    
    final status = statuses[index % statuses.length];
    final statusColor = statusColors[index % statusColors.length];

    return Card(
      color: AppTheme.getCardColor(context),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Flutter Developer',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ABC Technologies Pvt Ltd',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Applied on Dec 20, 2024',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: View details
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryGreen),
                    ),
                  ),
                ),
                if (status == 'Applied' || status == 'Under Review') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Withdraw application
                      },
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Withdraw'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}