import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:promise_client/promise_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'client.dart';
import 'screens/create_promise_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/promise_preparation_screen.dart';
import 'screens/sign_in_screen.dart';
import 'utils/deadline_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupClient();
  runApp(const PromiseApp());
}

class PromiseApp extends StatelessWidget {
  const PromiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6750A4);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );

    final textTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);

    return MaterialApp(
      title: 'Promise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: textTheme,
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.error),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actionsPadding: const EdgeInsets.all(16),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

enum _AuthState { loading, authenticated, unauthenticated }

class _AuthGateState extends State<AuthGate> {
  _AuthState _state = _AuthState.loading;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      await setupClient();
      await client.auth.initialize().timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _state = client.auth.isAuthenticated
            ? _AuthState.authenticated
            : _AuthState.unauthenticated;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = _AuthState.unauthenticated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state == _AuthState.loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting to Promise...'),
            ],
          ),
        ),
      );
    }

    return ValueListenableBuilder(
      valueListenable: client.auth.authInfoListenable,
      builder: (context, authInfo, _) {
        if (!client.auth.isAuthenticated) {
          return const SignInScreen();
        }
        return const DashboardScreen();
      },
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  /// Evaluates the effective commitment type for a promise based on unified v0.4.0 legacy classification policy.
  static String effectiveCommitmentType(Promise p, {String? parentType}) {
    final raw = p.commitmentType?.trim().toLowerCase();

    // 1. Group parent containers: 'freelance' or 'team' (legacy 'personal'/null defaults to 'team')
    if (p.isGroupParent) {
      if (raw == 'freelance') return 'freelance';
      return 'team';
    }

    // 2. Child milestones: inherit parent's effective type if child has legacy 'personal' or null
    if (p.parentPromiseId != null) {
      if (raw == 'freelance' || raw == 'team') return raw!;
      if (parentType != null && parentType.trim().isNotEmpty) {
        final cleanParent = parentType.trim().toLowerCase();
        if (cleanParent == 'freelance' || cleanParent == 'team') {
          return cleanParent;
        }
      }
      return 'team';
    }

    // 3. Standalone 1-on-1 commitments: 'personal', 'freelance', 'team' (default: 'personal')
    if (raw != null &&
        raw.isNotEmpty &&
        ['personal', 'freelance', 'team'].contains(raw)) {
      return raw;
    }
    return 'personal';
  }

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  List<Promise> _promises = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _unreadNotificationCount = 0;
  bool _hasPendingFriends = false;
  Timer? _pollingTimer;

  String _selectedTypeFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();

    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && client.auth.isAuthenticated) {
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
      final isStatusMatch =
          s == 'pending' || s == 'in_progress' || s == 'awaiting_confirmation';
      if (!isStatusMatch) return false;

      if (_selectedTypeFilter != 'all') {
        final type = DashboardScreen.effectiveCommitmentType(p);
        return type == _selectedTypeFilter;
      }
      return true;
    }).toList();
    list.sort(DeadlineUtils.compareDeadlines);
    return list;
  }

  List<Promise> get _completedPromises {
    final list = _promises.where((p) {
      if (p.status.toLowerCase() != 'completed') return false;

      if (_selectedTypeFilter != 'all') {
        final type = DashboardScreen.effectiveCommitmentType(p);
        return type == _selectedTypeFilter;
      }
      return true;
    }).toList();
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

    return Column(
      children: [
        // Commitment Type Filter Chips Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedTypeFilter == 'all',
                  onSelected: (val) {
                    if (val) setState(() => _selectedTypeFilter = 'all');
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  avatar: const Icon(Icons.person_outline, size: 16),
                  label: const Text('Personal'),
                  selected: _selectedTypeFilter == 'personal',
                  onSelected: (val) {
                    if (val) setState(() => _selectedTypeFilter = 'personal');
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  avatar: const Icon(Icons.work_outline, size: 16),
                  label: const Text('Freelance'),
                  selected: _selectedTypeFilter == 'freelance',
                  onSelected: (val) {
                    if (val) setState(() => _selectedTypeFilter = 'freelance');
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  avatar: const Icon(Icons.groups_outlined, size: 16),
                  label: const Text('Team'),
                  selected: _selectedTypeFilter == 'team',
                  onSelected: (val) {
                    if (val) setState(() => _selectedTypeFilter = 'team');
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
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
          ),
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

  Widget _buildTypeBadge(Promise p) {
    final cleanType = DashboardScreen.effectiveCommitmentType(p);
    IconData icon = Icons.person_outline;
    String label = 'Personal';
    Color color = Colors.purple;

    if (cleanType == 'freelance') {
      icon = Icons.work_outline;
      label = 'Freelance';
      color = Colors.blue;
    } else if (cleanType == 'team') {
      icon = Icons.groups_outlined;
      label = 'Team';
      color = Colors.teal;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildTypeBadge(promise),
                            if (promise.milestoneOrder != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                '#${promise.milestoneOrder}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          promise.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                      statusLabel,
                      style: TextStyle(
                        color: statusTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Promised to: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      promise.promisedTo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DeadlineUtils.getIndicatorText(promise),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
