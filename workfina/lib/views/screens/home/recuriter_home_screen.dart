import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/auth_controller.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/controllers/theme_controller.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/views/screens/recuriters/recruiter_candidate_details_screen.dart';

class HRHomeScreen extends StatefulWidget {
  const HRHomeScreen({super.key});

  @override
  State<HRHomeScreen> createState() => _HRHomeScreenState();
}

class _HRHomeScreenState extends State<HRHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    return ChangeNotifierProvider(
      create: (_) => HRController(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'HR Dashboard - ${user?['email']?.split('@')[0] ?? 'HR'}',
          ),
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
            const HRDashboardTab(),
            HRCandidatesTab(
              onSwitchToWallet: (index) =>
                  setState(() => _currentIndex = index),
            ),
            const HRWalletTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Candidates',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
          ],
        ),
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

class HRDashboardTab extends StatelessWidget {
  const HRDashboardTab({super.key});

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

class HRCandidatesTab extends StatefulWidget {
  final ValueChanged<int>? onSwitchToWallet;
  const HRCandidatesTab({super.key, this.onSwitchToWallet});

  @override
  State<HRCandidatesTab> createState() => _HRCandidatesTabState();
}

class _HRCandidatesTabState extends State<HRCandidatesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hrController = context.read<HRController>();
      hrController.loadUnlockedCandidates(); // Add this line
      hrController.loadCandidates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.getGradientDecoration(context),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.getCardColor(context),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search skills...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => _filterCandidates(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: ['All', 'IT', 'HR', 'SALES', 'MARKETING']
                      .map(
                        (role) =>
                            DropdownMenuItem(value: role, child: Text(role)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedRole = value!);
                    _filterCandidates();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<HRController>(
              builder: (context, hrController, child) {
                if (hrController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (hrController.candidates.isEmpty) {
                  return const Center(child: Text('No candidates found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: hrController.candidates.length,
                  itemBuilder: (context, index) {
                    final candidate = hrController.candidates[index];
                    return _buildCandidateCard(
                      context,
                      candidate,
                      hrController,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(
    BuildContext context,
    Map<String, dynamic> candidate,
    HRController hrController,
  ) {
    final isUnlocked = hrController.isCandidateUnlocked(candidate['id']);
    final canAffordUnlock = hrController.canUnlockCandidate();

    return Card(
      color: AppTheme.getCardColor(context),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isUnlocked
                      ? AppTheme.primaryGreen
                      : Colors.grey,
                  child: Text(candidate['masked_name']?.substring(0, 1) ?? 'C'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isUnlocked
                                  ? (candidate['full_name'] ??
                                        candidate['masked_name'] ??
                                        'Unknown')
                                  : (candidate['masked_name'] ?? 'Unknown'),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (isUnlocked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'UNLOCKED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(candidate['role'] ?? 'N/A'),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${candidate['experience_years']} years',
                    style: TextStyle(color: AppTheme.primaryGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                Text(' ${candidate['city']}'),
                const SizedBox(width: 16),
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                Text(' ${candidate['age']} years'),
                if (isUnlocked && candidate['phone'] != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  Text(' ${candidate['phone']}'),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (candidate['skills'] != null)
              Wrap(
                spacing: 8,
                children: candidate['skills']
                    .split(',')
                    .take(3)
                    .map<Widget>(
                      (skill) => Chip(
                        label: Text(skill.trim()),
                        backgroundColor: AppTheme.secondaryBlue.withOpacity(
                          0.1,
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isUnlocked)
                  Text(
                    '10 credits to unlock',
                    style: TextStyle(
                      color: canAffordUnlock
                          ? AppTheme.accentOrange
                          : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    'Profile unlocked',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ElevatedButton(
                  onPressed: isUnlocked
                      ? () {
                          final result = hrController.unlockCandidate(
                            candidate['id'],
                          );
                          result.then((res) {
                            if (res != null && context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CandidateDetailScreen(
                                    candidate: res['candidate'],
                                    isAlreadyUnlocked: true,
                                  ),
                                ),
                              );
                            }
                          });
                        }
                      : canAffordUnlock
                      ? () => _unlockCandidate(context, candidate, hrController)
                      : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUnlocked
                        ? AppTheme.secondaryBlue
                        : canAffordUnlock
                        ? AppTheme.primaryGreen
                        : Colors.grey,
                  ),
                  child: Text(isUnlocked ? 'View Profile' : 'Unlock Profile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  void _navigateToDetail(
    BuildContext context,
    Map<String, dynamic> candidate,
    bool isAlreadyUnlocked,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidateDetailScreen(
          candidate: candidate,
          isAlreadyUnlocked: isAlreadyUnlocked,
        ),
      ),
    );
  }

  void _unlockCandidate(
    BuildContext context,
    Map<String, dynamic> candidate,
    HRController hrController,
  ) {
    // Check wallet balance first
    if (!hrController.canUnlockCandidate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Insufficient Credits'),
          content: Text(
            'You need 10 credits to unlock this profile but you have ${hrController.walletBalance} credits.\n\nPlease recharge your wallet first.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Request parent to switch to wallet tab via callback
                if (widget.onSwitchToWallet != null) {
                  widget.onSwitchToWallet!(2);
                }
              },
              child: const Text('Recharge'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlock Profile'),
        content: Text(
          'Unlock ${candidate['masked_name']} for 10 credits?\n\nYour current balance: ${hrController.walletBalance} credits',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await hrController.unlockCandidate(
                candidate['id'],
              );
              if (result != null) {
                _navigateToDetail(
                  context,
                  result['candidate'],
                  result['already_unlocked'],
                );
                if (!result['already_unlocked']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Profile unlocked! ${result['credits_used']} credits deducted.',
                      ),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                }
              } else if (hrController.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(hrController.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  void _filterCandidates() {
    final hrController = context.read<HRController>();
    hrController.loadCandidates(
      role: _selectedRole == 'All' ? null : _selectedRole,
      skills: _searchController.text.isEmpty ? null : _searchController.text,
    );
  }
}

class HRWalletTab extends StatefulWidget {
  const HRWalletTab({super.key});

  @override
  State<HRWalletTab> createState() => _HRWalletTabState();
}

class _HRWalletTabState extends State<HRWalletTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hrController = context.read<HRController>();
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
        child: Consumer<HRController>(
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

  void _showRechargeDialog(BuildContext context, HRController hrController) {
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
