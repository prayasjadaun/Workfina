import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:workfina/views/screens/recuriters/recruiter_candidate_details_screen.dart';
import 'package:workfina/views/screens/widgets/candidate_card_widget.dart';

class FilteredCandidatesScreen extends StatefulWidget {
  final String filterType;
  final String filterValue;
  final bool showUnlockedOnly;

  const FilteredCandidatesScreen({
    super.key,
    required this.filterType,
    required this.filterValue,
    this.showUnlockedOnly = false,
  });

  @override
  State<FilteredCandidatesScreen> createState() =>
      _FilteredCandidatesScreenState();
}

class _FilteredCandidatesScreenState extends State<FilteredCandidatesScreen> {
  List<dynamic> _filteredCandidates = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFilteredCandidates();
    });
  }

  Future<void> _loadFilteredCandidates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Map<String, dynamic> response;

      switch (widget.filterType.toLowerCase()) {
        case 'department':
          response = await ApiService.getFilteredCandidates(
            role: widget.filterValue,
          );
          break;
        case 'religion':
          response = await ApiService.getFilteredCandidates(
            religion: widget.filterValue,
          );
          break;
        case 'city':
          response = await ApiService.getFilteredCandidates(
            city: widget.filterValue,
          );
          break;
        case 'state':
          response = await ApiService.getFilteredCandidates(
            state: widget.filterValue,
          );
          break;
        case 'country':
          response = await ApiService.getFilteredCandidates(
            country: widget.filterValue,
          );
          break;
        default:
          response = {'candidates': []};
      }

      if (response.containsKey('error')) {
        setState(() {
          _error = response['error'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _filteredCandidates = response['candidates'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkBackground
          : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.showUnlockedOnly
              ? "${widget.filterValue} (Unlocked)"
              : widget.filterValue,
          style: AppTheme.getAppBarTextStyle(),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<RecruiterController>(
        builder: (context, hrController, child) {
          if (_isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Colors.white : Colors.black,
                ),
              ),
            );
          }

          if (_error != null) {
            return _buildErrorState(isDark);
          }

          final lockedCandidates = widget.showUnlockedOnly
              ? _filteredCandidates
                    .where(
                      (c) =>
                          hrController.isCandidateUnlocked(c['id'].toString()),
                    )
                    .toList()
              : _filteredCandidates
                    .where(
                      (c) =>
                          !hrController.isCandidateUnlocked(c['id'].toString()),
                    )
                    .toList();

          if (lockedCandidates.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lockedCandidates.length,
            itemBuilder: (context, index) {
              final candidate = lockedCandidates[index];
              return CandidateCardWidget(
                candidate: candidate,
                isUnlocked: widget.showUnlockedOnly,
                canAffordUnlock: hrController.canUnlockCandidate(),
                onUnlock: widget.showUnlockedOnly
                    ? null
                    : () => _unlockCandidate(context, candidate, hrController),
                onViewProfile: widget.showUnlockedOnly
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CandidateDetailScreen(
                            candidate: candidate,
                            isAlreadyUnlocked: true,
                          ),
                        ),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/svgs/alert.svg',
                  width: 40,
                  height: 40,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: AppTheme.getTitleStyle(
                context,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Please try again later',
              textAlign: TextAlign.center,
              style: AppTheme.getBodyStyle(
                context,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButton(
              text: 'Retry',
              onPressed: _loadFilteredCandidates,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/svgs/users.svg',
                  width: 40,
                  height: 40,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No candidates found',
              style: AppTheme.getTitleStyle(
                context,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No candidates match your filter criteria for "${widget.filterValue}".',
              textAlign: TextAlign.center,
              style: AppTheme.getBodyStyle(
                context,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButton(
              text: 'Try different filter',
              onPressed: () => Navigator.pop(context),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      constraints: const BoxConstraints(maxWidth: 200),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.black,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: AppTheme.getLabelStyle(
            context,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  void _unlockCandidate(
    BuildContext context,
    Map<String, dynamic> candidate,
    RecruiterController hrController,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!hrController.canUnlockCandidate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCardBackground : Colors.white,
          title: Text(
            'Insufficient Credits',
            style: AppTheme.getTitleStyle(
              context,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            'You need 10 credits to unlock this profile but you have ${hrController.walletBalance} credits.\n\nPlease recharge your wallet first.',
            style: AppTheme.getBodyStyle(
              context,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: AppTheme.getLabelStyle(
                  context,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCardBackground : Colors.white,
        title: Text(
          'Unlock Profile',
          style: AppTheme.getTitleStyle(
            context,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Unlock ${candidate['masked_name']} for 10 credits?\n\nYour current balance: ${hrController.walletBalance} credits',
          style: AppTheme.getBodyStyle(
            context,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.getLabelStyle(
                context,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await hrController.unlockCandidate(
                candidate['id'],
              );
              if (result != null && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CandidateDetailScreen(
                      candidate: result['candidate'],
                      isAlreadyUnlocked: result['already_unlocked'],
                    ),
                  ),
                );
                if (!result['already_unlocked']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Profile unlocked! ${result['credits_used']} credits deducted.',
                      ),
                      backgroundColor: isDark ? Colors.white : Colors.black,
                    ),
                  );
                }
              } else if (hrController.error != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(hrController.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            child: Text('Unlock'),
          ),
        ],
      ),
    );
  }
}
