import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/views/screens/recuriters/recruiter_candidate_details_screen.dart';

class RecruiterCandidate extends StatefulWidget {
  final ValueChanged<int>? onSwitchToWallet;
  const RecruiterCandidate({super.key, this.onSwitchToWallet});

  @override
  State<RecruiterCandidate> createState() => _RecruiterCandidateState();
}

class _RecruiterCandidateState extends State<RecruiterCandidate> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'All';

  

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
            child: Consumer<RecruiterController>(
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
    RecruiterController hrController,
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
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    Text(' ${candidate['city']}'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    Text(' ${candidate['age']} years'),
                  ],
                ),
                if (isUnlocked) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                      Text(' ${candidate['phone'] ?? 'N/A'}'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.email, size: 16, color: Colors.grey[600]),
                      Flexible(child: Text(' ${candidate['email'] ?? 'N/A'}')),
                    ],
                  ),
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
                          _navigateToDetail(context, candidate, true);
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
    RecruiterController hrController,
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
    final hrController = context.read<RecruiterController>();
    hrController.loadCandidates(
      role: _selectedRole == 'All' ? null : _selectedRole,
      skills: _searchController.text.isEmpty ? null : _searchController.text,
    );
  }
}
