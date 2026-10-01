import 'package:flutter/material.dart';
import 'package:promise_client/promise_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'client.dart';
import 'screens/create_promise_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/promise_preparation_screen.dart';
import 'screens/sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keep Serverpod client initialization.
  await initializeClient();

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
      home: ValueListenableBuilder<AuthSuccess?>(
        valueListenable: client.auth.authInfoListenable,
        builder: (context, authSuccess, child) {
          if (!client.auth.isAuthenticated) {
            return const SignInScreen();
          }
          return const PromiseHomePage();
        },
      ),
    );
  }
}

class PromiseHomePage extends StatefulWidget {
  const PromiseHomePage({super.key});

  @override
  State<PromiseHomePage> createState() => _PromiseHomePageState();
}

class _PromiseHomePageState extends State<PromiseHomePage> {
  List<Promise> _promises = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPromises();
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

  Future<void> _signOut() async {
    await client.auth.signOutAllDevices();
  }

  Future<void> _openFriendsScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FriendsScreen(),
      ),
    );
    if (mounted) {
      _loadPromises();
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
        _loadPromises();
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
      _loadPromises();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          IconButton(
            icon: const Icon(Icons.people_outlined),
            tooltip: 'Friends',
            onPressed: _openFriendsScreen,
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: _buildBody(theme),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePromise,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
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
                onPressed: _loadPromises,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_promises.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your commitments',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep promises clear, trackable, and documented.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
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
                      'No promises yet',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first promise and start\n'
                      'tracking it from start to finish.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _navigateToCreatePromise,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Promise'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPromises,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _promises.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your commitments',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep promises clear, trackable, and documented.',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          final promise = _promises[index - 1];
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
        statusBgColor = Colors.green.withAlpha(38);
        statusTextColor = Colors.green.shade800;
        statusLabel = 'Completed';
        break;
      case 'awaiting_confirmation':
        statusBgColor = Colors.amber.withAlpha(45);
        statusTextColor = Colors.amber.shade900;
        statusLabel = 'Awaiting Conf.';
        break;
      case 'in_progress':
        statusBgColor = Colors.orange.withAlpha(38);
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
