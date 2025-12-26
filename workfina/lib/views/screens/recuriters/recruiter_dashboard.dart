import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/theme/app_theme.dart';





class RecruiterDashboard extends StatelessWidget {
  const RecruiterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
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
                    '450',
                    Icons.account_balance_wallet,
                    AppTheme.accentOrange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Unlocked',
                    '23',
                    Icons.lock_open,
                    AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Unlocks',
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
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen,
                      child: Text('C${index + 1}'),
                    ),
                    title: Text('Software Developer'),
                    subtitle: Text('3 years experience - Mumbai'),
                    trailing: Text('-10 credits'),
                  ),
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
}



class RecruiterWalletScreen extends StatefulWidget {
  const RecruiterWalletScreen({super.key});

  @override
  State<RecruiterWalletScreen> createState() => _RecruiterWalletScreenState();
}

class _RecruiterWalletScreenState extends State<RecruiterWalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hrController = context.read<RecruiterController>();
      hrController.loadWalletBalance();
      hrController.loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.getGradientDecoration(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<RecruiterController>(
          builder: (context, hrController, child) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryGreen,
                        AppTheme.primaryGreenDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Available Credits',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${hrController.wallet?['balance'] ?? 0}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryGreen,
                        ),
                        onPressed: () =>
                            _showRechargeDialog(context, hrController),
                        child: const Text('Add Credits'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Transaction History',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (hrController.transactions.isEmpty)
                  const Text('No transactions yet')
                else
                  ...hrController.transactions.map(
                    (transaction) => Card(
                      color: AppTheme.getCardColor(context),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              transaction['transaction_type'] == 'RECHARGE'
                              ? AppTheme.primaryGreen
                              : Colors.red,
                          child: Icon(
                            transaction['transaction_type'] == 'RECHARGE'
                                ? Icons.add
                                : Icons.remove,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          transaction['transaction_type'] == 'RECHARGE'
                              ? 'Credits Added'
                              : 'Profile Unlocked',
                        ),
                        subtitle: Text(
                          transaction['created_at'] ?? 'Unknown date',
                        ),
                        trailing: Text(
                          transaction['transaction_type'] == 'RECHARGE'
                              ? '+${transaction['credits_added']}'
                              : '-${transaction['credits_used']}',
                          style: TextStyle(
                            color: transaction['transaction_type'] == 'RECHARGE'
                                ? AppTheme.primaryGreen
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showRechargeDialog(BuildContext context, RecruiterController hrController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Credits'),
        content: const Text(
          'Select credit package:\n\n100 Credits - â‚¹100\n500 Credits - â‚¹500\n1000 Credits - â‚¹1000',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await hrController.rechargeWallet(
                credits: 100,
                paymentReference:
                    'TEST_${DateTime.now().millisecondsSinceEpoch}',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Credits added successfully!')),
              );
            },
            child: const Text('Add 100 Credits'),
          ),
        ],
      ),
    );
  }
}
