import 'package:flutter/material.dart';
import 'package:promise_client/promise_client.dart';
import '../client.dart';
import 'select_friend_screen.dart';

class CreatePromiseScreen extends StatefulWidget {
  const CreatePromiseScreen({super.key});

  @override
  State<CreatePromiseScreen> createState() => _CreatePromiseScreenState();
}

class _ChildPromiseData {
  String title = '';
  String description = '';
  UserSearchProfile? recipient;
  DateTime? dueDate;
  TimeOfDay? dueTime;
}

class _CreatePromiseScreenState extends State<CreatePromiseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isGroupPromise = false;

  // For single promise
  UserSearchProfile? _selectedFriend;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // For group promise
  final List<_ChildPromiseData> _childPromises = [];

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

  Future<void> _pickChildDate(_ChildPromiseData child) async {
    if (_isLoading) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: child.dueDate ?? today,
      firstDate: today,
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() {
        child.dueDate = picked;
      });
    }
  }

  Future<void> _pickChildTime(_ChildPromiseData child) async {
    if (_isLoading) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: child.dueTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        child.dueTime = picked;
      });
    }
  }

  void _addChildPromise() {
    setState(() {
      _childPromises.add(_ChildPromiseData());
    });
  }

  void _removeChildPromise(int index) {
    setState(() {
      _childPromises.removeAt(index);
    });
  }

  Future<void> _createPromise() async {
    if (_isLoading) return;

    final isFormValid = _formKey.currentState!.validate();
    final isDateValid = _selectedDate != null;

    if (!isDateValid) {
      setState(() {
        _dateError = 'Please select an overall due date.';
      });
    }

    if (!_isGroupPromise) {
      final isFriendValid = _selectedFriend != null;
      if (!isFriendValid) {
        setState(() {
          _friendError = 'Please select a recipient friend.';
        });
      }
      if (!isFormValid || !isFriendValid || !isDateValid) return;
    } else {
      if (_childPromises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Add at least one sub-promise.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      bool childValid = true;
      for (var c in _childPromises) {
        if (c.recipient == null ||
            c.dueDate == null ||
            c.title.trim().isEmpty) {
          childValid = false;
        }
      }
      if (!childValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Please fill out all sub-promise fields completely.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      if (!isFormValid || !isDateValid) return;
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
      dueTimeUtc = DateTime.utc(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    try {
      if (!_isGroupPromise) {
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
          isGroupParent: false,
        );

        final createdPromise = await client.promise.createPromise(
          promiseToCreate,
        );
        if (!mounted) return;
        Navigator.pop(context, createdPromise);
      } else {
        final parentPromise = Promise(
          title: _titleController.text.trim(),
          promisedTo: 'Multiple Recipients',
          recipientUserId: null,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          dueDate: dueDateUtc,
          dueTime: dueTimeUtc,
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
          isGroupParent: true,
        );

        final childrenToCreate = _childPromises.map((c) {
          final cDateUtc = DateTime.utc(
            c.dueDate!.year,
            c.dueDate!.month,
            c.dueDate!.day,
          );
          DateTime? cTimeUtc;
          if (c.dueTime != null) {
            cTimeUtc = DateTime.utc(
              c.dueDate!.year,
              c.dueDate!.month,
              c.dueDate!.day,
              c.dueTime!.hour,
              c.dueTime!.minute,
            );
          }

          return Promise(
            title: c.title.trim(),
            promisedTo: '',
            recipientUserId: c.recipient!.userId,
            description: c.description.trim().isEmpty
                ? null
                : c.description.trim(),
            dueDate: cDateUtc,
            dueTime: cTimeUtc,
            createdAt: DateTime.now().toUtc(),
            status: 'pending',
            isGroupParent: false,
          );
        }).toList();

        final createdGroup = await client.promise.createGroupedPromise(
          parentPromise,
          childrenToCreate,
        );
        if (!mounted) return;
        Navigator.pop(context, createdGroup);
      }
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
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text(
                  'Group Promise',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Assign multiple tasks to different friends.',
                ),
                value: _isGroupPromise,
                onChanged: _isLoading
                    ? null
                    : (val) {
                        setState(() {
                          _isGroupPromise = val;
                          if (val && _childPromises.isEmpty) {
                            _childPromises.add(_ChildPromiseData());
                          }
                        });
                      },
                contentPadding: EdgeInsets.zero,
              ),

              if (!_isGroupPromise) ...[
                const SizedBox(height: 16),
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
              ] else ...[
                const SizedBox(height: 16),
                Text(
                  'Sub-Promises',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(_childPromises.length, (index) {
                  final child = _childPromises[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Task ${index + 1}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _isLoading
                                    ? null
                                    : () => _removeChildPromise(index),
                                tooltip: 'Remove',
                              ),
                            ],
                          ),
                          TextFormField(
                            enabled: !_isLoading,
                            decoration: const InputDecoration(
                              labelText: 'Task Title',
                              filled: true,
                            ),
                            onChanged: (v) => child.title = v,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            enabled: !_isLoading,
                            decoration: const InputDecoration(
                              labelText: 'Task Description (optional)',
                              filled: true,
                            ),
                            onChanged: (v) => child.description = v,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    final selected =
                                        await Navigator.push<
                                          UserSearchProfile?
                                        >(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SelectFriendScreen(
                                                  currentSelectedUserId:
                                                      child.recipient?.userId,
                                                ),
                                          ),
                                        );
                                    if (selected != null) {
                                      setState(
                                        () => child.recipient = selected,
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.person),
                            label: Text(
                              child.recipient != null
                                  ? (child.recipient!.userName?.isNotEmpty ==
                                            true
                                        ? child.recipient!.userName!
                                        : child.recipient!.email)
                                  : 'Assign Friend',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _pickChildDate(child),
                                  icon: const Icon(Icons.calendar_today),
                                  label: Text(
                                    child.dueDate == null
                                        ? 'Due Date'
                                        : _formatDate(child.dueDate!),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _pickChildTime(child),
                                  icon: const Icon(Icons.access_time),
                                  label: Text(
                                    child.dueTime == null
                                        ? 'Time (Opt.)'
                                        : child.dueTime!.format(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _addChildPromise,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Sub-Promise'),
                ),
              ],
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
