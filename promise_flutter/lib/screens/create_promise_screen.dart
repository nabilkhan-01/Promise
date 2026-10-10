import 'package:flutter/material.dart';
import 'package:promise_client/promise_client.dart';
import '../client.dart';
import 'select_friend_screen.dart';

class CreatePromiseScreen extends StatefulWidget {
  const CreatePromiseScreen({super.key});

  @override
  State<CreatePromiseScreen> createState() => _CreatePromiseScreenState();
}

class _CreatePromiseScreenState extends State<CreatePromiseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  UserSearchProfile? _selectedFriend;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String? _friendError;
  String? _dateError;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, $month ${date.day}, ${date.year}';
  }

  Future<void> _selectFriend() async {
    if (_isLoading) return;

    final selected = await Navigator.push<UserSearchProfile?>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectFriendScreen(
          currentSelectedUserId: _selectedFriend?.userId,
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedFriend = selected;
        _friendError = null;
      });
    }
  }

  Future<void> _pickDate() async {
    if (_isLoading) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _pickTime() async {
    if (_isLoading) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _clearTime() {
    if (_isLoading) return;

    setState(() {
      _selectedTime = null;
    });
  }

  Future<void> _createPromise() async {
    if (_isLoading) return;

    final isFormValid = _formKey.currentState!.validate();
    final isFriendValid = _selectedFriend != null;
    final isDateValid = _selectedDate != null;

    if (!isFriendValid) {
      setState(() {
        _friendError = 'Please select a recipient friend.';
      });
    }

    if (!isDateValid) {
      setState(() {
        _dateError = 'Please select a due date.';
      });
    }

    if (!isFormValid || !isFriendValid || !isDateValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final dueDateUtc = DateTime.utc(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );

    DateTime? dueTimeUtc;
    if (_selectedTime != null) {
      dueTimeUtc = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      ).toUtc();
    }

    final recipientDisplayName =
        (_selectedFriend!.userName != null &&
            _selectedFriend!.userName!.trim().isNotEmpty)
        ? _selectedFriend!.userName!
        : _selectedFriend!.email;

    final promiseToCreate = Promise(
      title: _titleController.text.trim(),
      promisedTo: recipientDisplayName,
      recipientUserId: _selectedFriend!.userId,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: dueDateUtc,
      dueTime: dueTimeUtc,
      createdAt: DateTime.now().toUtc(),
      status: 'pending',
    );

    try {
      final createdPromise = await client.promise.createPromise(
        promiseToCreate,
      );

      if (!mounted) return;
      Navigator.pop(context, createdPromise);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('friend')
                ? 'You can only create promises for accepted friends.'
                : 'Could not save promise. Please check your connection.',
          ),
          behavior: SnackBarBehavior.floating,
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
          'Create Promise',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'What are you promising?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add the basic details of your commitment.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),

              // Promise Title
              TextFormField(
                controller: _titleController,
                enabled: !_isLoading,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Promise title *',
                  hintText: 'e.g. Deliver website homepage',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a promise title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Recipient Friend Selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _selectFriend,
                    icon: const Icon(Icons.person_outline),
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedFriend == null
                                ? 'Select Recipient Friend *'
                                : 'Promised to: ${_selectedFriend!.userName ?? _selectedFriend!.email}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _selectedFriend == null
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onSurface,
                              fontWeight: _selectedFriend == null
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: _friendError != null
                          ? BorderSide(color: theme.colorScheme.error)
                          : null,
                    ),
                  ),
                  if (_friendError != null) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        _friendError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),

              // Description (Optional)
              TextFormField(
                controller: _descriptionController,
                enabled: !_isLoading,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add more details about the promise...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Schedule Section Header
              Text(
                'Schedule',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Due Date & Time Pickers Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Picker
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _pickDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            _selectedDate == null
                                ? 'Due date *'
                                : _formatDate(_selectedDate!),
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            side: _dateError != null
                                ? BorderSide(color: theme.colorScheme.error)
                                : null,
                          ),
                        ),
                        if (_dateError != null) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              _dateError!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Time Picker
                  Expanded(
                    child: _selectedTime == null
                        ? OutlinedButton.icon(
                            onPressed: _isLoading ? null : _pickTime,
                            icon: const Icon(Icons.access_time_outlined),
                            label: const Text(
                              'Due time',
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                          )
                        : OutlinedButton.icon(
                            onPressed: _isLoading ? null : _pickTime,
                            icon: const Icon(Icons.access_time_outlined),
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    _selectedTime!.format(context),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: _clearTime,
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Create Promise Button
              FilledButton.icon(
                onPressed: _isLoading ? null : _createPromise,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.handshake_outlined),
                label: Text(
                  _isLoading ? 'Saving Promise...' : 'Create Promise',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
