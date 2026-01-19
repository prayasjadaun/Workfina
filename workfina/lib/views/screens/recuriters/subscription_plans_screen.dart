import 'package:flutter/material.dart';
import 'package:workfina/models/subscription_model.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  late Future<Map<String, dynamic>> _plansFuture;

  @override
  void initState() {
    super.initState();
    _plansFuture = ApiService.getSubscriptionPlans();
  }

  void _refreshPlans() {
    setState(() {
      _plansFuture = ApiService.getSubscriptionPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        title: Text(
          'Choose Your Plan',
          style: AppTheme.getAppBarTextStyle().copyWith(color: Colors.white),
        ),
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _refreshPlans(),
              color: AppTheme.accentPrimary,
              child: FutureBuilder<Map<String, dynamic>>(
                future: _plansFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: AppTheme.accentPrimary),
                    );
                  }

                  if (snapshot.hasError ||
                      snapshot.data?['error'] != null ||
                      snapshot.data?['plans'] == null) {
                    return _buildErrorState(isDark);
                  }

                  final plans = (snapshot.data!['plans'] as List)
                      .map((p) => SubscriptionPlan.fromJson(p))
                      .toList();

                  if (plans.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      return _PlanCard(plan: plans[index], isDark: isDark);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium,
            size: 48,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(height: 12),
          Text(
            'Unlock Premium Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the perfect plan for your needs',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark ? Colors.white38 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load plans',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshPlans,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: isDark ? Colors.white38 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Plans Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Subscription plans will appear here when available',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isDark;

  const _PlanCard({required this.plan, required this.isDark});

  Color _getPlanColor() {
    switch (plan.planType) {
      case 'MONTHLY':
        return AppTheme.blue;
      case 'QUARTERLY':
        return AppTheme.accentPrimary;
      case 'YEARLY':
        return AppTheme.greenCard;
      default:
        return AppTheme.primary;
    }
  }

  String _getPlanBadge() {
    switch (plan.planType) {
      case 'YEARLY':
        return 'BEST VALUE';
      case 'QUARTERLY':
        return 'POPULAR';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final planColor = _getPlanColor();
    final badge = _getPlanBadge();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardBackground : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: planColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextPrimaryColor(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: planColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              plan.planTypeDisplay,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: planColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              '₹',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: planColor,
                              ),
                            ),
                            Text(
                              plan.price.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: planColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${plan.durationDays} days',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  plan.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.getTextSecondaryColor(context),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFeatures(planColor),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showContactDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: planColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Contact Admin to Subscribe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (badge.isNotEmpty)
            Positioned(
              top: -8,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: planColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: planColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatures(Color color) {
    return Column(
      children: [
        _buildFeature(
          Icons.star_outline,
          plan.isUnlimited
              ? 'Unlimited Profile Unlocks'
              : '${plan.creditsLimit} Profile Unlocks',
          color,
        ),
        const SizedBox(height: 12),
        _buildFeature(
          Icons.access_time_outlined,
          '${plan.durationDays} days validity',
          color,
        ),
        const SizedBox(height: 12),
        _buildFeature(
          Icons.support_agent_outlined,
          '24/7 Customer Support',
          color,
        ),
      ],
    );
  }

  Widget _buildFeature(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              // color: AppTheme.
            ),
          ),
        ),
      ],
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCardBackground : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Contact Administrator',
          style: TextStyle(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'To subscribe to this plan, please contact our administrator. They will activate your subscription after payment verification.',
          style: TextStyle(
            color: AppTheme.getTextSecondaryColor(context),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(
                color: _getPlanColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}