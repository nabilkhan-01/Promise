import 'dart:async';

import 'package:flutter/material.dart';
import 'package:promise_client/promise_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'client.dart';
import 'screens/create_promise_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/promise_preparation_screen.dart';
import 'screens/sign_in_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('MAIN: App starting, calling runApp()...');
  runApp(const PromiseApp());
}

class PromiseApp extends StatelessWidget {
  const PromiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Promise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const StartupGate(),
    );
  }
}

enum StartupState {
  loading,
  authenticated,
  unauthenticated,
  error,
}

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  StartupState _state = StartupState.loading;
  String? _errorMessage;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    if (_isInitializing) return;
    _isInitializing = true;

    debugPrint('APP: Rendering startup gate...');
    setState(() {
      _state = StartupState.loading;
      _errorMessage = null;
    });

    try {
      debugPrint('CLIENT: Setting up Serverpod client...');
      await setupClient();

      debugPrint('AUTH: Initialize starting...');
      await client.auth.initialize().timeout(const Duration(seconds: 10));

      debugPrint('AUTH: Initialize completed.');
      debugPrint('AUTH: authenticated = ${client.auth.isAuthenticated}');

      if (!mounted) return;

      setState(() {
        _state = client.auth.isAuthenticated
            ? StartupState.authenticated
            : StartupState.unauthenticated;
      });
    } catch (e, stack) {
      debugPrint('AUTH INIT EXCEPTION: $e');
      debugPrint(stack.toString());

      if (!mounted) return;

      setState(() {
        _state = StartupState.error;
        _errorMessage = e is TimeoutException
            ? 'Server connection timed out. Please verify that the Promise server is running.'
            : 'Unable to connect to Promise server. Please check your connection and try again.';
      });
    } finally {
      _isInitializing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (_state) {
      case StartupState.loading:
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.handshake_outlined,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Promise',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep commitments clear, trackable, and documented.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 36),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Connecting to server...',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      case StartupState.error:
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Unable to Connect',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage ??
                          'Unable to connect to Promise server. Make sure the server is running.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: _initApp,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      case StartupState.authenticated:
      case StartupState.unauthenticated:
        return ValueListenableBuilder<AuthSuccess?>(
          valueListenable: client.auth.authInfoListenable,
          builder: (context, authSuccess, child) {
            if (!client.auth.isAuthenticated) {
              return const SignInScreen();
            }
            return const PromiseHomePage();
          },
        );
    }
  }
}

class PromiseHomePage extends StatefulWidget {
  const PromiseHomePage({super.key});

  @override
  State<PromiseHomePage> createState() => _PromiseHomePageState();
}

class _PromiseHomePageState extends State<PromiseHomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  List<Promise> _promises = [];
  int _unreadNotificationCount = 0;
  bool _hasPendingFriends = false;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _loadCounts();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAllData();
    }
  }

  Future<void> _loadAllData() async {
    _loadPromises();
    _loadCounts();
  }

  Future<void> _loadPromises() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final promises = await client.promise.getPromises();
      if (!mounted) return;
      setState(() {
        _promises = promises;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to connect to the server. Please verify your connection.';
      });
    }
  }

  Future<void> _loadCounts() async {
    try {
      final unreadCount = await client.notification
          .getUnreadNotificationCount();
      final pendingFriends = await client.friend.getPendingFriendRequests();
      if (!mounted) return;
      setState(() {
        _unreadNotificationCount = unreadCount;
        _hasPendingFriends = pendingFriends.isNotEmpty;
      });
    } catch (_) {}
  }

  List<Promise> get _currentPromises {
    final list = _promises.where((p) {
      final s = p.status.toLowerCase();
      return s == 'pending' ||
          s == 'in_progress' ||
          s == 'awaiting_confirmation';
    }).toList();
    list.sort((a, b) {
      final aDue = a.dueTime ?? a.dueDate;
      final bDue = b.dueTime ?? b.dueDate;
      return aDue.compareTo(bDue);
    });
    return list;
  }

  List<Promise> get _completedPromises {
    final list = _promises
        .where((p) => p.status.toLowerCase() == 'completed')
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> _signOut() async {
    await client.auth.signOutAllDevices();
  }

  Future<void> _openNotificationsScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
    if (mounted) {
      _loadAllData();
    }
  }

  Future<void> _openFriendsScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FriendsScreen(),
      ),
    );
    if (mounted) {
      _loadAllData();
    }
  }

  Future<void> _navigateToCreatePromise() async {
    final createdPromise = await Navigator.push<Promise?>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePromiseScreen(),
      ),
    );

    if (createdPromise != null && mounted) {
      _loadPromises();
      final updated = await Navigator.push<bool?>(
        context,
        MaterialPageRoute(
          builder: (context) => PromisePreparationScreen(
            initialPromise: createdPromise,
          ),
        ),
      );
      if (updated == true && mounted) {
        _loadAllData();
      }
    }
  }

  Future<void> _openPromiseDetails(Promise promise) async {
    final updated = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (context) => PromisePreparationScreen(
          initialPromise: promise,
        ),
      ),
    );

    if (updated == true && mounted) {
      _loadAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentList = _currentPromises;
    final completedList = _completedPromises;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Promise',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
                onPressed: _openNotificationsScreen,
              ),
              if (_unreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadNotificationCount > 99
                          ? '99+'
                          : '$_unreadNotificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.people_outlined),
                tooltip: 'Friends',
                onPressed: _openFriendsScreen,
              ),
              if (_hasPendingFriends)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Current (${currentList.length})'),
            Tab(text: 'Completed (${completedList.length})'),
          ],
        ),
      ),
      body: _buildBody(theme, currentList, completedList),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePromise,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    List<Promise> currentList,
    List<Promise> completedList,
  ) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading promises...'),
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
                color: theme.colorScheme.error,
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
                onPressed: _loadAllData,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildPromiseList(
          promises: currentList,
          emptyTitle: 'No active promises yet.',
          emptySubtitle:
              'Create your first promise and keep track of your commitments.',
          theme: theme,
          showCreateButton: true,
        ),
        _buildPromiseList(
          promises: completedList,
          emptyTitle: 'No completed promises yet.',
          emptySubtitle:
              'Completed promises will appear here after mutual confirmation.',
          theme: theme,
          showCreateButton: false,
        ),
      ],
    );
  }

  Widget _buildPromiseList({
    required List<Promise> promises,
    required String emptyTitle,
    required String emptySubtitle,
    required ThemeData theme,
    required bool showCreateButton,
  }) {
    if (promises.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.handshake_outlined,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    emptyTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    emptySubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (showCreateButton) ...[
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _navigateToCreatePromise,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Promise'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: promises.length,
        itemBuilder: (context, index) {
          final promise = promises[index];
          return PromiseCard(
            promise: promise,
            onTap: () => _openPromiseDetails(promise),
          );
        },
      ),
    );
  }
}

class PromiseCard extends StatelessWidget {
  final Promise promise;
  final VoidCallback onTap;

  const PromiseCard({
    super.key,
    required this.promise,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color statusBgColor;
    Color statusTextColor;
    String statusLabel = promise.status;

    switch (promise.status.toLowerCase()) {
      case 'completed':
        statusBgColor = Colors.green.withValues(alpha: 0.15);
        statusTextColor = Colors.green.shade800;
        statusLabel = 'Completed';
        break;
      case 'awaiting_confirmation':
        statusBgColor = Colors.amber.withValues(alpha: 0.18);
        statusTextColor = Colors.amber.shade900;
        statusLabel = 'Awaiting Conf.';
        break;
      case 'in_progress':
        statusBgColor = Colors.orange.withValues(alpha: 0.15);
        statusTextColor = Colors.orange.shade800;
        statusLabel = 'In Progress';
        break;
      case 'pending':
      default:
        statusBgColor = colorScheme.primaryContainer;
        statusTextColor = colorScheme.onPrimaryContainer;
        statusLabel = 'Pending';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      promise.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusTextColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Promised to ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      promise.promisedTo,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (promise.description != null &&
                  promise.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  promise.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(promise.dueDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (promise.dueTime != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(promise.dueTime!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
