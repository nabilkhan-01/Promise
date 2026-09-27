import 'package:flutter/material.dart';
import 'package:promise_client/promise_client.dart';
import '../client.dart';
import 'promise_details_screen.dart';

class PromisePreparationScreen extends StatefulWidget {
  final Promise initialPromise;

  const PromisePreparationScreen({
    super.key,
    required this.initialPromise,
  });

  @override
  State<PromisePreparationScreen> createState() =>
      _PromisePreparationScreenState();
}

class _PromisePreparationScreenState extends State<PromisePreparationScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _preparePromise();
  }

  Future<void> _preparePromise() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final promiseId = widget.initialPromise.id!;
      final loadPromiseFuture = client.promise.getPromise(promiseId);
      final loadActivitiesFuture = client.promise.getActivities(promiseId);

      final results = await Future.wait([
        loadPromiseFuture,
        loadActivitiesFuture,
      ]);

      final loadedPromise = results[0] as Promise?;
      final loadedActivities = results[1] as List<PromiseActivity>;

      if (!mounted) return;

      final finalPromise = loadedPromise ?? widget.initialPromise;

      Navigator.pushReplacement<bool?, void>(
        context,
        MaterialPageRoute(
          builder: (context) => PromiseDetailsScreen(
            promise: finalPromise,
            initialActivities: loadedActivities,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Could not load promise details. Please check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Promise Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: !_isLoading,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _isLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      Text(
                        'Preparing Promise...',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Loading details & activity history',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                : Column(
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
                        onPressed: _preparePromise,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
