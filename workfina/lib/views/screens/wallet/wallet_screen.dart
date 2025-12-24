import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.getGradientDecoration(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
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
                  const Text(
                    '450',
                    style: TextStyle(
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
                    onPressed: () => _showPurchaseDialog(context),
                    child: const Text('Add Credits'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Credit Packages',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildPackageCard(context, '100 Credits', '₹100', false)),
                const SizedBox(width: 12),
                Expanded(child: _buildPackageCard(context, '500 Credits', '₹500', true)),
                const SizedBox(width: 12),
                Expanded(child: _buildPackageCard(context, '1000 Credits', '₹1000', false)),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Transaction History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppTheme.getCardColor(context),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index % 2 == 0 
                        ? AppTheme.primaryGreen 
                        : Colors.red,
                    child: Icon(
                      index % 2 == 0 ? Icons.add : Icons.remove,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(index % 2 == 0 
                      ? 'Credits Added' 
                      : 'Profile Unlocked'),
                  subtitle: Text('Today, ${index + 8}:${index * 10} AM'),
                  trailing: Text(
                    index % 2 == 0 ? '+500' : '-10',
                    style: TextStyle(
                      color: index % 2 == 0 
                          ? AppTheme.primaryGreen 
                          : Colors.red,
                      fontWeight: FontWeight.bold,
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

  Widget _buildPackageCard(BuildContext context, String credits, String price, bool isPopular) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: isPopular ? Border.all(color: AppTheme.accentOrange, width: 2) : null,
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Popular',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            credits,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Credits'),
        content: const Text('Select a credit package to purchase'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Redirecting to payment...')),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}