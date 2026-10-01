import 'package:flutter/material.dart';
import '../client.dart';

class RequestChangesScreen extends StatefulWidget {
  final int promiseId;

  const RequestChangesScreen({
    super.key,
    required this.promiseId,
  });

  @override
  State<RequestChangesScreen> createState() => _RequestChangesScreenState();
}

class _RequestChangesScreenState extends State<RequestChangesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRequestChanges() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final reasonText = _reasonController.text.trim();
    if (reasonText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reason for requesting changes.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await client.promise.requestChanges(
        widget.promiseId,
        'participant',
        reasonText,
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
            'Could not request changes. Please check your connection.',
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
          'Request Changes',
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
                'Request Commitment Changes',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Requesting changes will reset confirmations and set the overall promise status back to In Progress.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Reason Text Field
              TextFormField(
                controller: _reasonController,
                readOnly: _isSaving,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Reason *',
                  hintText: 'Explain what needs to be changed...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment_return_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reason for requesting changes.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 36),

              // Submit Button
              FilledButton.icon(
                onPressed: _isSaving ? null : _submitRequestChanges,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.assignment_return_outlined),
                label: Text(
                  _isSaving ? 'Submitting Request...' : 'Request Changes',
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
