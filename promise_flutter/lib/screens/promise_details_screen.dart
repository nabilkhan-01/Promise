import 'package:flutter/material.dart';
import 'package:promise_client/promise_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../client.dart';
import 'add_update_screen.dart';
import 'request_changes_screen.dart';

class PromiseDetailsScreen extends StatefulWidget {
  final Promise promise;
  final List<PromiseActivity>? initialActivities;

  const PromiseDetailsScreen({
    super.key,
    required this.promise,
    this.initialActivities,
  });

  @override
  State<PromiseDetailsScreen> createState() => _PromiseDetailsScreenState();
}

class _PromiseDetailsScreenState extends State<PromiseDetailsScreen> {
  late Promise _currentPromise;
  List<PromiseActivity> _activities = [];
  bool _isLoadingActivities = false;
  bool _isUpdatingStatus = false;
  String? _activityError;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _currentPromise = widget.promise;
    if (widget.initialActivities != null) {
      _activities = widget.initialActivities!;
      _isLoadingActivities = false;
    } else {
      _loadData(showLoading: true);
    }
  }

  Future<void> _loadData({bool showLoading = false}) async {
    if (showLoading) {
      setState(() {
        _isLoadingActivities = true;
        _activityError = null;
      });
    }

    try {
      final promiseId = _currentPromise.id!;
      final updatedPromise = await client.promise.getPromise(promiseId);
      final activities = await client.promise.getActivities(promiseId);

      if (!mounted) return;

      setState(() {
        if (updatedPromise != null) {
          _currentPromise = updatedPromise;
        }
        _activities = activities;
        _isLoadingActivities = false;
        _activityError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingActivities = false;
        _activityError =
            'Unable to load activity history. Please check your connection.';
      });
    }
  }

  Future<void> _confirmCompletion(String role) async {
    if (_isUpdatingStatus || _currentPromise.status == 'completed') return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final updatedPromise = await client.promise.confirmPromiseCompletion(
        _currentPromise.id!,
        role,
      );

      if (!mounted) return;

      setState(() {
        _currentPromise = updatedPromise;
        _isUpdatingStatus = false;
        _hasChanges = true;
      });

      _loadData(showLoading: false);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUpdatingStatus = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not confirm completion. Please check your connection.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _changeOverallStatus(String newStatus) async {
    if (_isUpdatingStatus ||
        _currentPromise.status == 'completed' ||
        newStatus == _currentPromise.status) {
      return;
    }

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final updatedPromise = await client.promise.updatePromiseStatus(
        _currentPromise.id!,
        newStatus,
      );

      if (!mounted) return;

      setState(() {
        _currentPromise = updatedPromise;
        _isUpdatingStatus = false;
        _hasChanges = true;
      });

      _loadData(showLoading: false);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUpdatingStatus = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('both parties')
                ? 'Cannot set Completed until both parties confirm completion.'
                : 'Could not update status. Please check connection.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String _formatStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      case 'awaiting_confirmation':
        return 'Awaiting Confirmation';
      case 'completed':
        return 'Completed';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'awaiting_confirmation':
        return Colors.amber.shade800;
      case 'in_progress':
        return Colors.orange;
      case 'pending':
      default:
        return colorScheme.primary;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final localDate = date.toLocal();
    final weekday = weekdays[localDate.weekday - 1];
    final month = months[localDate.month - 1];
    return '$weekday, $month ${localDate.day}, ${localDate.year}';
  }

  String _formatTime(DateTime time) {
    final localTime = time.toLocal();
    final hour = localTime.hour == 0 || localTime.hour == 12
        ? 12
        : localTime.hour % 12;
    final period = localTime.hour >= 12 ? 'PM' : 'AM';
    final minute = localTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatDateTimeShort(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[local.month - 1];
    final timeStr = _formatTime(local);
    return '$month ${local.day}, ${local.year} · $timeStr';
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'created':
        return Icons.add_circle_outline;
      case 'confirmation':
        return Icons.verified_outlined;
      case 'status_change':
        return Icons.published_with_changes_outlined;
      case 'request_changes':
        return Icons.assignment_return_outlined;
      case 'update':
      default:
        return Icons.notes_outlined;
    }
  }

  Future<void> _openAddUpdateScreen() async {
    if (_currentPromise.status == 'completed') return;

    final didUpdate = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (context) => AddUpdateScreen(
          promiseId: _currentPromise.id!,
        ),
      ),
    );

    if (didUpdate == true && mounted) {
      _hasChanges = true;
      _loadData(showLoading: false);
    }
  }

  Future<void> _openRequestChangesScreen() async {
    if (_currentPromise.status == 'completed') return;

    final didUpdate = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (context) => RequestChangesScreen(
          promiseId: _currentPromise.id!,
        ),
      ),
    );

    if (didUpdate == true && mounted) {
      _hasChanges = true;
      _loadData(showLoading: false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes requested successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = _currentPromise.status == 'completed';
    final statusColor = _getStatusColor(_currentPromise.status, colorScheme);
    final isBothConfirmed =
        _currentPromise.creatorConfirmed && _currentPromise.recipientConfirmed;

    final currentAuthUserId = client.auth.authInfo?.authUserId.toString();
    final isUserCreator =
        _currentPromise.creatorUserId == null ||
        _currentPromise.creatorUserId == currentAuthUserId;
    final isUserRecipient =
        _currentPromise.recipientUserId == null ||
        _currentPromise.recipientUserId == currentAuthUserId;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _hasChanges);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Promise Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => _loadData(showLoading: false),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Details Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _currentPromise.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _formatStatusLabel(
                                _currentPromise.status,
                              ).toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Promised To
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Promised to ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _currentPromise.promisedTo,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      if (_currentPromise.description != null &&
                          _currentPromise.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _currentPromise.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Due Schedule
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Due: ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatDate(_currentPromise.dueDate),
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (_currentPromise.dueTime != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              'at ${_formatTime(_currentPromise.dueTime!)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Created Date
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Created: ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            _formatDateTimeShort(_currentPromise.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Responsive Promise Status Progression
                      Text(
                        'Overall Promise Status',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      PromiseStatusProgressWidget(
                        currentStatus: _currentPromise.status,
                        isBothConfirmed: isBothConfirmed,
                        isUpdatingStatus: _isUpdatingStatus,
                        onStatusSelected: (selectedStatus) {
                          if (selectedStatus != 'awaiting_confirmation') {
                            _changeOverallStatus(selectedStatus);
                          }
                        },
                      ),

                      if (isCompleted) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Promise Completed — This promise is final and no further changes can be made.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Two-Party Completion Confirmation Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Completion Confirmation (Two-Party)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Both parties must confirm before overall status becomes Completed.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Creator Confirmation Item
                      _buildConfirmationItem(
                        title: 'Creator',
                        isConfirmed: _currentPromise.creatorConfirmed,
                        canConfirm:
                            !isCompleted && !_isUpdatingStatus && isUserCreator,
                        onConfirm: () => _confirmCompletion('creator'),
                        theme: theme,
                        colorScheme: colorScheme,
                      ),

                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Recipient Confirmation Item
                      _buildConfirmationItem(
                        title: 'Recipient',
                        isConfirmed: _currentPromise.recipientConfirmed,
                        canConfirm:
                            !isCompleted &&
                            !_isUpdatingStatus &&
                            isUserRecipient,
                        onConfirm: () => _confirmCompletion('recipient'),
                        theme: theme,
                        colorScheme: colorScheme,
                      ),

                      if (!isCompleted) ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Request Changes Action Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isUpdatingStatus
                                ? null
                                : _openRequestChangesScreen,
                            icon: const Icon(
                              Icons.assignment_return_outlined,
                              size: 18,
                            ),
                            label: const Text('Request Changes'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Activity Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Activity History',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isCompleted)
                    OutlinedButton.icon(
                      onPressed: _openAddUpdateScreen,
                      icon: const Icon(Icons.add_comment_outlined, size: 18),
                      label: const Text('Add Update'),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Activities Timeline Content
              _buildActivityTimeline(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTimeline(ThemeData theme) {
    if (_isLoadingActivities) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Loading timeline...'),
            ],
          ),
        ),
      );
    }

    if (_activityError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                _activityError!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _loadData(showLoading: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text('No activity recorded yet.'),
        ),
      );
    }

    final colorScheme = theme.colorScheme;

    return Column(
      children: List.generate(_activities.length, (index) {
        final activity = _activities[index];
        final isLast = index == _activities.length - 1;
        final actStatus = activity.status;

        Color? badgeBgColor;
        Color? badgeTextColor;
        if (actStatus != null) {
          badgeBgColor = _getStatusColor(
            actStatus,
            colorScheme,
          ).withValues(alpha: 0.15);
          badgeTextColor = _getStatusColor(actStatus, colorScheme);
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline icon & line
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getActivityIcon(activity.type),
                      size: 20,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Activity details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              activity.message,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (actStatus != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _formatStatusLabel(actStatus).toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: badgeTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTimeShort(activity.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildConfirmationItem({
    required String title,
    required bool isConfirmed,
    required bool canConfirm,
    required VoidCallback onConfirm,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 340;
        final infoRow = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isConfirmed ? Icons.check_circle : Icons.hourglass_empty_outlined,
              color: isConfirmed ? Colors.green : colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '$title: ',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isConfirmed ? 'Confirmed' : 'Awaiting',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isConfirmed
                    ? Colors.green
                    : colorScheme.onSurfaceVariant,
                fontWeight: isConfirmed ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );

        final actionWidget = isConfirmed
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '✓ Confirmed',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : FilledButton.tonal(
                onPressed: canConfirm ? onConfirm : null,
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: Text('Confirm ($title)'),
              );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              infoRow,
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: actionWidget),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            infoRow,
            actionWidget,
          ],
        );
      },
    );
  }
}

class PromiseStatusProgressWidget extends StatelessWidget {
  final String currentStatus;
  final bool isBothConfirmed;
  final bool isUpdatingStatus;
  final ValueChanged<String> onStatusSelected;

  const PromiseStatusProgressWidget({
    super.key,
    required this.currentStatus,
    required this.isBothConfirmed,
    required this.isUpdatingStatus,
    required this.onStatusSelected,
  });

  int get _currentIndex {
    switch (currentStatus.toLowerCase()) {
      case 'completed':
        return 3;
      case 'awaiting_confirmation':
        return 2;
      case 'in_progress':
        return 1;
      case 'pending':
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 480) {
          return _buildHorizontalLayout(context);
        } else {
          return _buildVerticalLayout(context);
        }
      },
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = currentStatus.toLowerCase() == 'completed';

    final steps = [
      _StepData('pending', 'Pending', Icons.hourglass_top_outlined),
      _StepData('in_progress', 'In Progress', Icons.run_circle_outlined),
      _StepData(
        'awaiting_confirmation',
        'Awaiting Conf.',
        Icons.fact_check_outlined,
      ),
      _StepData('completed', 'Completed', Icons.check_circle_outlined),
    ];

    final currentIndex = _currentIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isCurrent = index == currentIndex;
          final isPast = index < currentIndex;
          final isClickable =
              !isCompleted &&
              !isUpdatingStatus &&
              (step.key == 'pending' ||
                  step.key == 'in_progress' ||
                  (step.key == 'completed' && isBothConfirmed));

          Color circleColor;
          Color textColor;
          if (isCurrent) {
            circleColor = isCompleted ? Colors.green : colorScheme.primary;
            textColor = isCompleted
                ? Colors.green.shade800
                : colorScheme.primary;
          } else if (isPast) {
            circleColor = Colors.green;
            textColor = colorScheme.onSurface;
          } else {
            circleColor = colorScheme.outlineVariant;
            textColor = colorScheme.onSurfaceVariant;
          }

          return Expanded(
            child: InkWell(
              onTap: isClickable ? () => onStatusSelected(step.key) : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (index > 0)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: isPast || isCurrent
                                  ? Colors.green
                                  : colorScheme.outlineVariant,
                            ),
                          ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? circleColor
                                : (isPast
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : colorScheme.surface),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: circleColor,
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: Icon(
                            isPast ? Icons.check : step.icon,
                            size: 16,
                            color: isCurrent
                                ? Colors.white
                                : (isPast
                                      ? Colors.green.shade800
                                      : colorScheme.onSurfaceVariant),
                          ),
                        ),
                        if (index < steps.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: isPast
                                  ? Colors.green
                                  : colorScheme.outlineVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: textColor,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = currentStatus.toLowerCase() == 'completed';

    final steps = [
      _StepData('pending', 'Pending', Icons.hourglass_top_outlined),
      _StepData('in_progress', 'In Progress', Icons.run_circle_outlined),
      _StepData(
        'awaiting_confirmation',
        'Awaiting Confirmation',
        Icons.fact_check_outlined,
      ),
      _StepData('completed', 'Completed', Icons.check_circle_outlined),
    ];

    final currentIndex = _currentIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isCurrent = index == currentIndex;
          final isPast = index < currentIndex;
          final isLast = index == steps.length - 1;

          final isClickable =
              !isCompleted &&
              !isUpdatingStatus &&
              (step.key == 'pending' ||
                  step.key == 'in_progress' ||
                  (step.key == 'completed' && isBothConfirmed));

          Color stepColor;
          if (isCurrent) {
            stepColor = isCompleted ? Colors.green : colorScheme.primary;
          } else if (isPast) {
            stepColor = Colors.green;
          } else {
            stepColor = colorScheme.outlineVariant;
          }

          return InkWell(
            onTap: isClickable ? () => onStatusSelected(step.key) : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Indicator Circle + Vertical Connector Line
                    SizedBox(
                      width: 36,
                      child: Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? stepColor
                                  : (isPast
                                        ? Colors.green.withValues(alpha: 0.15)
                                        : colorScheme.surfaceContainerHighest
                                              .withValues(alpha: 0.4)),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: stepColor,
                                width: isCurrent ? 2.5 : 1.5,
                              ),
                            ),
                            child: Icon(
                              isPast ? Icons.check : step.icon,
                              size: 16,
                              color: isCurrent
                                  ? Colors.white
                                  : (isPast
                                        ? Colors.green.shade800
                                        : colorScheme.onSurfaceVariant),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                color: isPast
                                    ? Colors.green
                                    : colorScheme.outlineVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Label & Status Tag
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                step.label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isCurrent
                                      ? (isCompleted
                                            ? Colors.green.shade800
                                            : colorScheme.primary)
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: stepColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'CURRENT',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: stepColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    if (isClickable)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.touch_app_outlined,
                          size: 18,
                          color: colorScheme.primary.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StepData {
  final String key;
  final String label;
  final IconData icon;

  _StepData(this.key, this.label, this.icon);
}
