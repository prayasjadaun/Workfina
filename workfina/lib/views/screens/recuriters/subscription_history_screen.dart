import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workfina/models/subscription_model.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';

class SubscriptionHistoryScreen extends StatefulWidget {
  const SubscriptionHistoryScreen({super.key});

  @override
  State<SubscriptionHistoryScreen> createState() =>
      _SubscriptionHistoryScreenState();
}

class _SubscriptionHistoryScreenState extends State<SubscriptionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> _subscriptionsFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _subscriptionsFuture = ApiService.getAllSubscriptions();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshSubscriptions() {
    setState(() {
      _subscriptionsFuture = ApiService.getAllSubscriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        title: Text(
          'Subscription History',
          style: AppTheme.getAppBarTextStyle().copyWith(color: Colors.white),
        ),
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: isDark ? AppTheme.darkSurface : AppTheme.primary,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: AppTheme.accentPrimary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Active'),
                Tab(text: 'Pending'),
                Tab(text: 'Expired'),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _subscriptionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.accentPrimary),
            );
          }

          if (snapshot.hasError ||
              snapshot.data?['error'] != null ||
              snapshot.data?['subscriptions'] == null) {
            return _buildErrorState(isDark);
          }

          final allSubscriptions = (snapshot.data!['subscriptions'] as List)
              .map((s) {
                try {
                  return Subscription.fromJson(s);
                } catch (e) {
                  print('Error parsing subscription: $e');
                  return null;
                }
              })
              .where((s) => s != null)
              .cast<Subscription>()
              .toList();

          final activeSubscriptions =
              allSubscriptions.where((s) => s.status == 'ACTIVE').toList();
          final pendingSubscriptions =
              allSubscriptions.where((s) => s.status == 'PENDING').toList();
          final expiredSubscriptions =
              allSubscriptions.where((s) => s.status == 'EXPIRED').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSubscriptionList(allSubscriptions, isDark),
              _buildSubscriptionList(activeSubscriptions, isDark),
              _buildSubscriptionList(pendingSubscriptions, isDark),
              _buildSubscriptionList(expiredSubscriptions, isDark),
            ],
          );
        },
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
            'Failed to load history',
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
            onPressed: _refreshSubscriptions,
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

  Widget _buildSubscriptionList(List<Subscription> subscriptions, bool isDark) {
    if (subscriptions.isEmpty) {
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
              'No subscriptions found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your subscription history will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _refreshSubscriptions(),
      color: AppTheme.accentPrimary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: subscriptions.length,
        itemBuilder: (context, index) {
          return _SubscriptionCard(
            subscription: subscriptions[index],
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final bool isDark;

  const _SubscriptionCard({
    required this.subscription,
    required this.isDark,
  });

  Color _getStatusColor() {
    switch (subscription.status) {
      case 'ACTIVE':
        return AppTheme.greenCard;
      case 'PENDING':
        return AppTheme.accentPrimary;
      case 'EXPIRED':
        return Colors.red.shade400;
      case 'CANCELLED':
        return Colors.grey.shade500;
      default:
        return AppTheme.primary;
    }
  }

  IconData _getStatusIcon() {
    switch (subscription.status) {
      case 'ACTIVE':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.schedule;
      case 'EXPIRED':
        return Icons.cancel;
      case 'CANCELLED':
        return Icons.block;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    subscription.plan.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextPrimaryColor(context),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(),
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subscription.statusDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                  ? Colors.white.withOpacity(0.05) 
                  : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark 
                    ? Colors.white.withOpacity(0.1) 
                    : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.calendar_today_outlined,
                    'Duration',
                    '${dateFormat.format(subscription.startDate)} - ${dateFormat.format(subscription.endDate)}',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.access_time_outlined,
                    'Days Remaining',
                    subscription.isCurrentlyActive
                        ? '${subscription.daysRemaining} days'
                        : 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    subscription.hasUnlimited 
                      ? Icons.all_inclusive 
                      : Icons.star_outline,
                    'Credits',
                    subscription.hasUnlimited
                        ? 'Unlimited'
                        : '${subscription.creditsUsed} / ${subscription.plan.creditsLimit ?? 0}',
                  ),
                  if (subscription.paymentReference != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.receipt_outlined,
                      'Payment Ref',
                      subscription.paymentReference!,
                    ),
                  ],
                  if (subscription.approvedByName != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.person_outline,
                      'Approved By',
                      subscription.approvedByName!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white60 : Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}