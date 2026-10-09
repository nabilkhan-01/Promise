import 'package:flutter/material.dart';
import 'package:promise_client/promise_client.dart';
import '../client.dart';
import 'friends_screen.dart';
import 'promise_preparation_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await client.notification.getNotifications(limit: 50);
      if (!mounted) return;
      setState(() {
        _notifications = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to load notifications. Please check connection.';
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await client.notification.markAllNotificationsRead();
      if (!mounted) return;
      _loadNotifications();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not mark all notifications as read.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    if (notification.readAt == null && notification.id != null) {
      try {
        await client.notification.markNotificationRead(notification.id!);
      } catch (_) {}
    }

    if (!mounted) return;

    if (notification.promiseId != null) {
      final dummyPromise = Promise(
        id: notification.promiseId,
        title: notification.title,
        promisedTo: '',
        dueDate: DateTime.now(),
        createdAt: notification.createdAt,
        status: 'pending',
      );
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PromisePreparationScreen(
            initialPromise: dummyPromise,
          ),
        ),
      );
      if (mounted) {
        _loadNotifications();
      }
    } else if (notification.friendshipId != null ||
        notification.type.startsWith('friend')) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FriendsScreen(),
        ),
      );
      if (mounted) {
        _loadNotifications();
      }
    } else {
      _loadNotifications();
    }
  }

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    final local = dt.toLocal();
    return now.year == local.year &&
        now.month == local.month &&
        now.day == local.day;
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final local = dt.toLocal();
    return '${local.month}/${local.day}/${local.year}';
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'friend_request':
        return Icons.person_add_outlined;
      case 'friend_request_accepted':
        return Icons.person_outline;
      case 'promise_created':
        return Icons.handshake_outlined;
      case 'change_requested':
        return Icons.assignment_return_outlined;
      case 'confirmation_requested':
        return Icons.fact_check_outlined;
      case 'promise_completed':
        return Icons.check_circle_outline;
      case 'promise_status_changed':
        return Icons.published_with_changes_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getIconColor(String type, ColorScheme colorScheme) {
    switch (type.toLowerCase()) {
      case 'friend_request':
        return colorScheme.primary;
      case 'friend_request_accepted':
      case 'promise_completed':
        return Colors.green;
      case 'change_requested':
        return Colors.orange;
      case 'confirmation_requested':
        return Colors.amber.shade800;
      case 'promise_created':
      case 'promise_status_changed':
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasUnread = _notifications.any((n) => n.readAt == null);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (hasUnread)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Mark all read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _buildBody(theme, colorScheme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading notifications...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Connection Error',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none_outlined,
                size: 72,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 20),
              Text(
                'No notifications yet.',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Updates regarding promises and friends will appear here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final todayList = _notifications
        .where((n) => _isToday(n.createdAt))
        .toList();
    final earlierList = _notifications
        .where((n) => !_isToday(n.createdAt))
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      children: [
        if (todayList.isNotEmpty) ...[
          _buildSectionHeader('TODAY', theme),
          ...todayList.map(
            (n) => _buildNotificationTile(n, theme, colorScheme),
          ),
          const SizedBox(height: 16),
        ],
        if (earlierList.isNotEmpty) ...[
          _buildSectionHeader('EARLIER', theme),
          ...earlierList.map(
            (n) => _buildNotificationTile(n, theme, colorScheme),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    AppNotification notification,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isUnread = notification.readAt == null;
    final iconColor = _getIconColor(notification.type, colorScheme);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isUnread
          ? colorScheme.primaryContainer.withValues(alpha: 0.25)
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUnread
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatRelativeTime(notification.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnread) ...[
                const SizedBox(width: 8),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
