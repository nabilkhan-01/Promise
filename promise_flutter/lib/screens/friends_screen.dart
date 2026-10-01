import 'package:flutter/material.dart';
import 'package:promise_client/promise_client.dart';
import '../client.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _searchController = TextEditingController();
  List<UserSearchProfile> _friends = [];
  List<UserSearchProfile> _pendingRequests = [];
  List<UserSearchProfile> _searchResults = [];

  bool _isLoadingFriends = false;
  bool _isLoadingPending = false;
  bool _isSearching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    _loadFriends();
    _loadPendingRequests();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoadingFriends = true;
    });

    try {
      final friends = await client.friend.getFriends();
      if (!mounted) return;
      setState(() {
        _friends = friends;
        _isLoadingFriends = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingFriends = false;
      });
    }
  }

  Future<void> _loadPendingRequests() async {
    setState(() {
      _isLoadingPending = true;
    });

    try {
      final pending = await client.friend.getPendingFriendRequests();
      if (!mounted) return;
      setState(() {
        _pendingRequests = pending;
        _isLoadingPending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingPending = false;
      });
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await client.friend.searchUsers(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _searchError = 'Search failed. Please check connection.';
      });
    }
  }

  Future<void> _sendFriendRequest(String userId) async {
    try {
      await client.friend.sendFriendRequest(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request sent!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _performSearch();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not send friend request: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _acceptRequest(int friendshipId) async {
    try {
      await client.friend.acceptFriendRequest(friendshipId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request accepted!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadAllData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not accept request.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _rejectRequest(int friendshipId) async {
    try {
      await client.friend.rejectFriendRequest(friendshipId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request rejected.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadPendingRequests();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not reject request.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _removeFriend(String friendUserId) async {
    try {
      await client.friend.removeFriend(friendUserId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend removed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadFriends();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not remove friend.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friends',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Friends (${_friends.length})',
              icon: const Icon(Icons.people_outlined),
            ),
            Tab(
              text: 'Pending (${_pendingRequests.length})',
              icon: const Icon(Icons.hourglass_empty_outlined),
            ),
            const Tab(
              text: 'Add Friend',
              icon: Icon(Icons.person_add_outlined),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsTab(theme),
          _buildPendingTab(theme),
          _buildSearchTab(theme),
        ],
      ),
    );
  }

  Widget _buildFriendsTab(ThemeData theme) {
    if (_isLoadingFriends) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_friends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'No Friends Yet',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search for registered users and send a friend request to start creating commitments together.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(2),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Add Friend'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriends,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _friends.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final friend = _friends[index];
          final displayName =
              (friend.userName != null && friend.userName!.trim().isNotEmpty)
              ? friend.userName!
              : friend.email;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            title: Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(friend.email),
            trailing: IconButton(
              icon: const Icon(Icons.person_remove_outlined),
              tooltip: 'Remove Friend',
              onPressed: () => _removeFriend(friend.userId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingTab(ThemeData theme) {
    if (_isLoadingPending) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pendingRequests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'No Pending Requests',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Incoming friend requests will appear here.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingRequests,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _pendingRequests.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final req = _pendingRequests[index];
          final displayName =
              (req.userName != null && req.userName!.trim().isNotEmpty)
              ? req.userName!
              : req.email;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            title: Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(req.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.check),
                  tooltip: 'Accept',
                  onPressed: req.friendshipId != null
                      ? () => _acceptRequest(req.friendshipId!)
                      : null,
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  icon: const Icon(Icons.close),
                  tooltip: 'Reject',
                  onPressed: req.friendshipId != null
                      ? () => _rejectRequest(req.friendshipId!)
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search user by email or name',
                  hintText: 'e.g. rahul@example.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (_) => _performSearch(),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _isSearching ? null : _performSearch,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 52),
              ),
              child: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Search'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_searchError != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _searchError!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        if (_searchResults.isEmpty && !_isSearching)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text('Search by user email to find registered users.'),
            ),
          ),
        ..._searchResults.map((user) {
          final displayName =
              (user.userName != null && user.userName!.trim().isNotEmpty)
              ? user.userName!
              : user.email;

          Widget actionWidget;
          switch (user.friendshipStatus) {
            case 'accepted':
              actionWidget = const Chip(
                label: Text('Friends ✓'),
                visualDensity: VisualDensity.compact,
              );
              break;
            case 'pending_sent':
              actionWidget = const Chip(
                label: Text('Request Sent'),
                visualDensity: VisualDensity.compact,
              );
              break;
            case 'pending_received':
              actionWidget = FilledButton.tonal(
                onPressed: user.friendshipId != null
                    ? () => _acceptRequest(user.friendshipId!)
                    : null,
                child: const Text('Accept Request'),
              );
              break;
            case 'none':
            default:
              actionWidget = FilledButton.icon(
                onPressed: () => _sendFriendRequest(user.userId),
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: const Text('Add Friend'),
              );
              break;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(user.email),
              trailing: actionWidget,
            ),
          );
        }),
      ],
    );
  }
}
