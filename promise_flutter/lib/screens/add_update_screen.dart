import 'package:flutter/material.dart';
import '../client.dart';

class AddUpdateScreen extends StatefulWidget {
  final int promiseId;

  const AddUpdateScreen({
    super.key,
    required this.promiseId,
  });

  @override
  State<AddUpdateScreen> createState() => _AddUpdateScreenState();
}

class _AddUpdateScreenState extends State<AddUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String _selectedActivityStatus = 'in_progress';
  bool _isSaving = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _saveUpdate() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final text = _messageController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an update message.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await client.promise.addActivity(
        widget.promiseId,
        'update',
        text,
        activityStatus: _selectedActivityStatus,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not save update. Please check your connection.',
          ),
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
          'Add Progress Update',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Text(
                'Log Progress or Milestone',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Document progress updates for this commitment.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),

              // Update Message Field
              TextFormField(
                controller: _messageController,
                readOnly: _isSaving,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Update message *',
                  hintText: 'e.g. Backend implementation completed',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an update message.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Activity Status Selector Header
              Text(
                'Activity Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Status for this specific progress update.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              // Activity Status SegmentedButton
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'pending',
                      label: Text('Pending'),
                    ),
                    ButtonSegment<String>(
                      value: 'in_progress',
                      label: Text('In Progress'),
                    ),
                    ButtonSegment<String>(
                      value: 'completed',
                      label: Text('Completed'),
                    ),
                  ],
                  selected: {_selectedActivityStatus},
                  onSelectionChanged: _isSaving
                      ? null
                      : (newSelection) {
                          if (newSelection.isNotEmpty) {
                            setState(() {
                              _selectedActivityStatus = newSelection.first;
                            });
                          }
                        },
                ),
              ),
              const SizedBox(height: 36),

              // Save Button
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveUpdate,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(
                  _isSaving ? 'Saving Update...' : 'Save Update',
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
