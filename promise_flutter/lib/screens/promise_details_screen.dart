import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:promise_client/promise_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../client.dart';
import '../utils/deadline_utils.dart';
import '../widgets/indicator_icon_button.dart';
import 'add_update_screen.dart';

class PromiseDetailsScreen extends StatefulWidget {
  final int promiseId;
  final Promise? initialPromise;
  final List<PromiseActivity>? initialActivities;
  final List<PromiseAttachment>? initialAttachments;

  PromiseDetailsScreen({
    super.key,
    int? promiseId,
    Promise? promise,
    this.initialActivities,
    this.initialAttachments,
  }) : promiseId = promiseId ?? promise?.id ?? 0,
       initialPromise = promise;

  @override
  State<PromiseDetailsScreen> createState() => _PromiseDetailsScreenState();
}

class _PromiseDetailsScreenState extends State<PromiseDetailsScreen> {
  late Promise _currentPromise;
  List<PromiseActivity> _activities = [];
  List<PromiseAttachment> _attachments = [];
  List<Promise> _childPromises = [];
  bool _isLoading = true;
  bool _isUpdatingStatus = false;

  bool _isAcceptingPromise = false;
  bool _isAcceptSuccess = false;

  bool _isUploadingAttachment = false;
  bool _isUploadSuccess = false;
  String? _uploadProgressMessage;

  int? _reviewingAttachmentId;
  String? _reviewingAction;
  int? _reviewedSuccessAttachmentId;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPromise != null) {
      _currentPromise = widget.initialPromise!;
      _activities = widget.initialActivities ?? [];
      _attachments = widget.initialAttachments ?? [];
      _isLoading = false;
      _loadChildPromisesAndRefresh();
    } else {
      _loadData();
    }
  }

  Future<void> _loadChildPromisesAndRefresh() async {
    try {
      if (_currentPromise.isGroupParent) {
        final children = await client.promise.getChildPromises(
          widget.promiseId,
        );
        if (mounted) {
          setState(() {
            _childPromises = children;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final promise = await client.promise.getPromise(widget.promiseId);
      if (promise == null) {
        if (!mounted) return;
        Navigator.pop(context);
        return;
      }

      final activities = await client.promise.getActivities(widget.promiseId);
      final attachments = await client.attachment.getAttachments(
        widget.promiseId,
      );

      List<Promise> children = [];
      if (promise.isGroupParent) {
        children = await client.promise.getChildPromises(widget.promiseId);
      }

      if (!mounted) return;
      setState(() {
        _currentPromise = promise;
        _activities = activities;
        _attachments = attachments;
        _childPromises = children;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to load details. Check connection and try again.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _acceptPromise() async {
    if (_isUpdatingStatus || _isAcceptingPromise) return;

    setState(() {
      _isUpdatingStatus = true;
      _isAcceptingPromise = true;
      _isAcceptSuccess = false;
    });

    try {
      final updated = await client.promise.acceptPromise(_currentPromise.id!);
      if (!mounted) return;
      setState(() {
        _currentPromise = updated;
        _isAcceptingPromise = false;
        _isAcceptSuccess = true;
        _hasChanges = true;
      });
      _loadData(showLoading: false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Promise invitation accepted!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isAcceptSuccess = false;
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAcceptingPromise = false;
        _isAcceptSuccess = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not accept promise invitation.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _confirmCompletion(String partyRole) async {
    if (_currentPromise.status == 'completed' || _isUpdatingStatus) return;

    if (_currentPromise.recipientUserId != null &&
        !_currentPromise.recipientAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Cannot confirm completion on an unaccepted promise invitation.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final updated = await client.promise.confirmPromiseCompletion(
        _currentPromise.id!,
        partyRole,
      );

      _hasChanges = true;
      _loadData(showLoading: false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.status == 'completed'
                ? 'Promise completed successfully!'
                : 'Confirmation recorded. Awaiting other party.',
          ),
          backgroundColor: updated.status == 'completed'
              ? Colors.green
              : Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
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
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _uploadAttachment() async {
    if (_currentPromise.status == 'completed' ||
        _isUpdatingStatus ||
        _isUploadingAttachment) {
      return;
    }

    if (_currentPromise.recipientUserId != null &&
        !_currentPromise.recipientAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Cannot upload attachments before the promise is accepted.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (files.isEmpty) return;

      final file = files.first;
      if (file.path == null) {
        throw Exception('File path is unavailable on this device.');
      }

      final fileSize = File(file.path!).lengthSync();
      if (fileSize > 10 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Couldn\'t upload this file. Check your connection and ensure it is under 10 MB, then try again.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      setState(() {
        _isUpdatingStatus = true;
        _isUploadingAttachment = true;
        _isUploadSuccess = false;
        _uploadProgressMessage = 'Preparing upload...';
      });

      final uploadData = await client.attachment.getUploadDescription(
        _currentPromise.id!,
        file.name,
        fileSize,
      );

      if (uploadData == null) {
        throw Exception('Failed to retrieve upload description from server.');
      }

      setState(() {
        _uploadProgressMessage = 'Uploading ${file.name}...';
      });

      final fileObj = File(file.path!);
      final stream = fileObj.openRead();

      final uploader = FileUploader(uploadData.uploadDescription);
      final uploadSuccess = await uploader.upload(stream, fileSize);

      if (!uploadSuccess) {
        throw Exception('Physical byte upload to storage failed.');
      }

      setState(() {
        _uploadProgressMessage = 'Verifying attachment...';
      });

      String mimeType = 'application/octet-stream';
      final ext = file.extension?.toLowerCase();
      if (ext == 'pdf') mimeType = 'application/pdf';
      if (ext == 'png') mimeType = 'image/png';
      if (ext == 'jpg' || ext == 'jpeg') mimeType = 'image/jpeg';

      await client.attachment.verifyAttachment(
        _currentPromise.id!,
        uploadData.path,
        file.name,
        fileSize,
        mimeType,
      );

      setState(() {
        _isUploadingAttachment = false;
        _isUploadSuccess = true;
        _uploadProgressMessage = 'Upload complete';
      });

      _hasChanges = true;
      _loadData(showLoading: false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload complete'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isUploadSuccess = false;
            _uploadProgressMessage = null;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString();
        String displayMsg =
            'Couldn\'t upload this file. Check your connection and ensure it is under 10 MB, then try again.';
        if (errorStr.contains('ArgumentError:')) {
          displayMsg = errorStr.replaceFirst('ArgumentError:', '').trim();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(displayMsg),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
          _isUploadingAttachment = false;
        });
      }
    }
  }

  Future<void> _downloadAttachment(int attachmentId) async {
    try {
      final url = await client.attachment.getDownloadUrl(attachmentId);
      if (url != null) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not download file.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _reviewAttachment(int attachmentId, String action) async {
    if (_isUpdatingStatus || _reviewingAttachmentId != null) return;

    String? reason;
    if (action == 'rejected') {
      reason = await _showRejectionDialog();
      if (reason == null) return;
    }

    setState(() {
      _isUpdatingStatus = true;
      _reviewingAttachmentId = attachmentId;
      _reviewingAction = action;
      _reviewedSuccessAttachmentId = null;
    });

    try {
      await client.attachment.reviewAttachment(
        attachmentId,
        action,
        rejectionReason: reason,
      );
      setState(() {
        _reviewedSuccessAttachmentId = attachmentId;
      });
      _hasChanges = true;
      _loadData(showLoading: false);

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _reviewedSuccessAttachmentId = null;
            _reviewingAttachmentId = null;
            _reviewingAction = null;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _reviewingAttachmentId = null;
          _reviewingAction = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('uploader cannot review')
                  ? 'You cannot review your own attachment.'
                  : 'Failed to update review status.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<String?> _showRejectionDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Evidence'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter reason for rejection...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRequestChangesDialog() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Changes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Requesting changes will reset existing completions and return this promise to In Progress.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Reason for change request...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final currentAuthUserId = client.auth.authInfo?.authUserId.toString();
      final isUserCreator =
          _currentPromise.creatorUserId == null ||
          _currentPromise.creatorUserId == currentAuthUserId;

      await client.promise.requestChanges(
        _currentPromise.id!,
        isUserCreator ? 'creator' : 'recipient',
        reason,
      );
      _hasChanges = true;
      _loadData(showLoading: false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Change request submitted.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not submit change request.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'awaiting_confirmation':
        return colorScheme.primary;
      case 'in_progress':
        return Colors.orange;
      case 'pending':
      default:
        return colorScheme.outline;
    }
  }

  String _formatStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'awaiting_confirmation':
        return 'Awaiting Confirmation';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Promise Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isCompleted = _currentPromise.status == 'completed';
    final statusColor = _getStatusColor(_currentPromise.status, colorScheme);

    final currentAuthUserId = client.auth.authInfo?.authUserId.toString();
    final isUserCreator =
        _currentPromise.creatorUserId == null ||
        _currentPromise.creatorUserId == currentAuthUserId;
    final isUserRecipient =
        _currentPromise.recipientUserId == null ||
        _currentPromise.recipientUserId == currentAuthUserId;

    final isUnaccepted =
        _currentPromise.recipientUserId != null &&
        !_currentPromise.recipientAccepted;

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
            style: TextStyle(fontWeight: FontWeight.bold),
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
                            DeadlineUtils.getIndicatorText(_currentPromise),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      if (isUnaccepted) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.mark_email_unread_outlined,
                                    color: colorScheme.onTertiaryContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isUserRecipient
                                          ? 'You have been invited to this promise.'
                                          : 'Awaiting acceptance by ${_currentPromise.promisedTo}.',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                colorScheme.onTertiaryContainer,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isUserRecipient
                                    ? 'Accept this promise invitation to start tracking progress.'
                                    : 'Progress updates and confirmation will unlock once the recipient accepts.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onTertiaryContainer,
                                ),
                              ),
                              if (isUserRecipient) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: IndicatorIconButton(
                                    onPressed: _isUpdatingStatus
                                        ? null
                                        : _acceptPromise,
                                    icon: const Icon(
                                      Icons.check_circle_outline,
                                    ),
                                    label: const Text('Accept Promise'),
                                    isLoading: _isAcceptingPromise,
                                    showSuccessIndicator: _isAcceptSuccess,
                                    tooltip: 'Accept Promise Invitation',
                                    style: IconButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (_uploadProgressMessage != null) ...[
                LinearProgressIndicator(color: colorScheme.primary),
                const SizedBox(height: 6),
                Text(
                  _uploadProgressMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Group Sub-Promises Card
              if (_currentPromise.isGroupParent &&
                  _childPromises.isNotEmpty) ...[
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Group Commitments (${_childPromises.length})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._childPromises.map(
                          (child) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              child.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text('To: ${child.promisedTo}'),
                            trailing: Chip(
                              label: Text(
                                _formatStatusLabel(child.status),
                                style: const TextStyle(fontSize: 11),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Evidence & Receipts Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Evidence & Receipts',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isCompleted && !isUnaccepted)
                            IndicatorIconButton(
                              onPressed: _isUpdatingStatus
                                  ? null
                                  : _uploadAttachment,
                              icon: const Icon(Icons.upload_file),
                              tooltip: 'Upload Evidence',
                              isLoading: _isUploadingAttachment,
                              showSuccessIndicator: _isUploadSuccess,
                            ),
                        ],
                      ),
                      if (_attachments.isEmpty)
                        Text(
                          'No evidence uploaded yet.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      else
                        ..._attachments.map((att) {
                          final isUploader =
                              att.uploaderUserId == currentAuthUserId;
                          final isApproveLoading =
                              _reviewingAttachmentId == att.id &&
                              _reviewingAction == 'approved';
                          final isApproveSuccess =
                              _reviewedSuccessAttachmentId == att.id &&
                              _reviewingAction == 'approved';

                          final isRejectLoading =
                              _reviewingAttachmentId == att.id &&
                              _reviewingAction == 'rejected';
                          final isRejectSuccess =
                              _reviewedSuccessAttachmentId == att.id &&
                              _reviewingAction == 'rejected';

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(
                                  att.mimeType.contains('pdf')
                                      ? Icons.picture_as_pdf
                                      : Icons.image,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        att.fileName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Status: ${att.approvalStatus}${att.rejectionReason != null ? " (${att.rejectionReason})" : ""}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.download),
                                  onPressed: () => _downloadAttachment(att.id!),
                                ),
                                if (!isUploader &&
                                    att.approvalStatus == 'pending' &&
                                    !isCompleted &&
                                    !isUnaccepted) ...[
                                  IndicatorIconButton(
                                    onPressed: _isUpdatingStatus
                                        ? null
                                        : () => _reviewAttachment(
                                            att.id!,
                                            'approved',
                                          ),
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    tooltip: 'Approve Evidence',
                                    isLoading: isApproveLoading,
                                    showSuccessIndicator: isApproveSuccess,
                                  ),
                                  IndicatorIconButton(
                                    onPressed: _isUpdatingStatus
                                        ? null
                                        : () => _reviewAttachment(
                                            att.id!,
                                            'rejected',
                                          ),
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Reject Evidence',
                                    isLoading: isRejectLoading,
                                    showSuccessIndicator: isRejectSuccess,
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Two-Party Confirmation Actions
              if (!isCompleted &&
                  !_currentPromise.isGroupParent &&
                  !isUnaccepted) ...[
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Two-Party Confirmation',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your Role: ${isUserCreator ? "Creator" : "Recipient"}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _isUpdatingStatus
                                    ? null
                                    : () => _confirmCompletion(
                                        isUserCreator ? 'creator' : 'recipient',
                                      ),
                                icon: const Icon(Icons.check_circle),
                                label: Text(
                                  (isUserCreator &&
                                              _currentPromise
                                                  .creatorConfirmed) ||
                                          (isUserRecipient &&
                                              _currentPromise
                                                  .recipientConfirmed)
                                      ? 'Confirmed'
                                      : 'Confirm Completion',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: _isUpdatingStatus
                                  ? null
                                  : _showRequestChangesDialog,
                              icon: const Icon(Icons.edit),
                              label: const Text('Request Changes'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Activity Timeline
              Text(
                'Activity History',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_activities.isEmpty)
                const Text('No activity history yet.')
              else
                ..._activities.map(
                  (act) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.history,
                        color: colorScheme.onPrimaryContainer,
                        size: 18,
                      ),
                    ),
                    title: Text(act.message),
                    subtitle: Text(
                      'Status: ${act.status} • ${act.createdAt.toLocal().toString().split('.')[0]}',
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: (!isCompleted && !isUnaccepted)
            ? FloatingActionButton.extended(
                onPressed: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddUpdateScreen(
                        promiseId: _currentPromise.id!,
                      ),
                    ),
                  );
                  if (updated == true) {
                    _hasChanges = true;
                    _loadData(showLoading: false);
                  }
                },
                icon: const Icon(Icons.add_comment),
                label: const Text('Add Update'),
              )
            : null,
      ),
    );
  }
}
