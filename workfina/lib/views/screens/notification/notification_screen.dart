import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> filteredNotifications = [];
  bool isLoading = true;
  String selectedFilter = 'all';
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.getUserNotifications();
      setState(() {
        notifications =
            response; // Remove List.from() since response is already a List
        unreadCount = notifications.where((n) => !n['is_read']).length;
        _applyFilter();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        notifications = [];
        _applyFilter();
        isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      switch (selectedFilter) {
        case 'unread':
          filteredNotifications = notifications
              .where((n) => !n['is_read'])
              .toList();
          break;
        case 'read':
          filteredNotifications = notifications
              .where((n) => n['is_read'])
              .toList();
          break;
        default:
          filteredNotifications = notifications;
      }
    });
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await ApiService.markNotificationAsRead(notificationId);
      setState(() {
        final index = notifications.indexWhere(
          (n) => n['id'] == notificationId,
        );
        if (index != -1) {
          notifications[index]['is_read'] = true;
          notifications[index]['read_at'] = DateTime.now().toIso8601String();
          unreadCount = (unreadCount > 0) ? unreadCount - 1 : 0;
        }
        _applyFilter();
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await ApiService.markAllNotificationsAsRead();
      setState(() {
        for (var notification in notifications) {
          notification['is_read'] = true;
          notification['read_at'] = DateTime.now().toIso8601String();
        }
        unreadCount = 0;
        _applyFilter();
      });
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: Text(
          'Notifications',
          style: AppTheme.getTitleStyle(
            context,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: AppTheme.getBodyStyle(
                  context,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: AppTheme.primary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              labelStyle: AppTheme.getBodyStyle(
                context,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: AppTheme.getBodyStyle(
                context,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              onTap: (index) {
                setState(() {
                  selectedFilter = index == 0
                      ? 'all'
                      : index == 1
                      ? 'unread'
                      : 'read';
                  _applyFilter();
                });
              },
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('All'),
                      if (notifications.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${notifications.length}',
                            style: AppTheme.getLabelStyle(
                              context,
                              fontSize: 10,
                              color: Colors.white
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Unread'),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: AppTheme.getLabelStyle(
                              context,
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'Read'),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredNotifications.isEmpty
            ? _buildEmptyState()
            : _buildNotificationsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            selectedFilter == 'unread'
                ? 'No unread notifications'
                : selectedFilter == 'read'
                ? 'No read notifications'
                : 'No notifications yet',
            style: AppTheme.getTitleStyle(
              context,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            selectedFilter == 'unread'
                ? 'All caught up!'
                : selectedFilter == 'read'
                ? 'No read notifications found.'
                : 'You\'ll see important updates here.',
            style: AppTheme.getSubtitleStyle(context, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredNotifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRead = notification['is_read'] as bool;
    final status = notification['status'] as String;

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          _markAsRead(notification['id']);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardBackground : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead
                ? Colors.grey.withOpacity(0.2)
                : AppTheme.primary.withOpacity(0.3),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusIcon(status, isRead),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'] ?? 'Notification',
                          style: AppTheme.getBodyStyle(
                            context,
                            fontWeight: isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            fontSize: 15,
                            color: isRead ? Colors.grey[900] : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isRead) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['body'] ?? '',
                    style: AppTheme.getSubtitleStyle(
                      context,
                      fontWeight: FontWeight.w400,
                      color: isRead ? Colors.grey[800] : Colors.grey[700],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Row(
                  //   children: [
                  //     _buildStatusChip(status),
                  //     const Spacer(),
                  //     Text(
                  //       notification['time_ago'] ?? '',
                  //       style: AppTheme.getLabelStyle(
                  //         context,
                  //         color: Colors.grey[500],
                  //         fontSize: 11,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status, bool isRead) {
    Color iconColor;
    IconData icon;

    switch (status) {
      case 'DELIVERED':
        iconColor = Colors.green;
        icon = Icons.check_circle_outlined;
        break;
      case 'FAILED':
        iconColor = Colors.red;
        icon = Icons.error_outline;
        break;
      case 'SENT':
        iconColor = Colors.blue;
        icon = Icons.send_outlined;
        break;
      default:
        iconColor = Colors.orange;
        icon = Icons.schedule_outlined;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: (isRead
            ? iconColor.withOpacity(0.1)
            : iconColor.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 18,
        color: isRead ? iconColor.withOpacity(0.8) : iconColor,
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String displayText;

    switch (status) {
      case 'DELIVERED':
        chipColor = Colors.green;
        displayText = 'Delivered';
        break;
      case 'FAILED':
        chipColor = Colors.red;
        displayText = 'Failed';
        break;
      case 'SENT':
        chipColor = Colors.blue;
        displayText = 'Sent';
        break;
      default:
        chipColor = Colors.orange;
        displayText = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        displayText,
        style: AppTheme.getLabelStyle(
          context,
          color: chipColor,
          fontWeight: FontWeight.w500,
          fontSize: 9,
        ),
      ),
    );
  }
}
