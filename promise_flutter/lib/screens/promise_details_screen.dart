import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:promise_client/promise_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../client.dart';
import '../utils/deadline_utils.dart';
import '../widgets/financial_section.dart';
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
  ParentProjectMetadata? _parentProject;

  PromiseFinancialSummary? _financialSummary;
  GroupFinancialSummary? _groupFinancialSummary;
  PromiseFinancialTerms? _financialTerms;
  List<PromisePaymentSchedule> _paymentSchedules = [];
  List<PromisePaymentRecord> _paymentRecords = [];

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
      if (_currentPromise.parentPromiseId != null) {
        final parent = await client.promise.getParentProjectMetadata(
          _currentPromise.parentPromiseId!,
        );
        if (mounted) {
          setState(() {
            _parentProject = parent;
          });
        }
      }
      _loadFinancialData();
    } catch (_) {}
  }

  Future<void> _loadFinancialData() async {
    try {
      if (_currentPromise.isGroupParent) {
        final groupSummary = await client.financial.getGroupFinancialSummary(
          widget.promiseId,
        );
        if (mounted) {
          setState(() {
            _groupFinancialSummary = groupSummary;
          });
        }
      } else {
        final summary = await client.financial.getFinancialSummary(
          widget.promiseId,
        );
        if (summary.hasFinancials) {
          final terms = await client.financial.getFinancialTerms(
            widget.promiseId,
          );
          final schedules = await client.financial.getPaymentSchedule(
            widget.promiseId,
          );
          final records = await client.financial.getPaymentRecords(
            widget.promiseId,
          );
          if (mounted) {
            setState(() {
              _financialSummary = summary;
              _financialTerms = terms;
              _paymentSchedules = schedules;
              _paymentRecords = records;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _financialSummary = summary;
              _financialTerms = null;
              _paymentSchedules = [];
              _paymentRecords = [];
            });
          }
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

      final currentAuthUserId = client.auth.authInfo?.authUserId.toString();
      final isDirectParticipant =
          promise.creatorUserId == currentAuthUserId ||
          promise.recipientUserId == currentAuthUserId;

      List<PromiseActivity> activities = [];
      List<PromiseAttachment> attachments = [];

      if (isDirectParticipant) {
        try {
          activities = await client.promise.getActivities(widget.promiseId);
          attachments = await client.attachment.getAttachments(
            widget.promiseId,
          );
        } catch (_) {}
      }

      List<Promise> children = [];
      if (promise.isGroupParent) {
        try {
          children = await client.promise.getChildPromises(widget.promiseId);
        } catch (_) {}
      }

      ParentProjectMetadata? parentProject;
      if (promise.parentPromiseId != null) {
        try {
          parentProject = await client.promise.getParentProjectMetadata(
            promise.parentPromiseId!,
          );
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _currentPromise = promise;
        _activities = activities;
        _attachments = attachments;
        _childPromises = children;
        _parentProject = parentProject;
        _isLoading = false;
      });

      _loadFinancialData();
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

  Future<void> _confirmCompletion(String role) async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final updated = await client.promise.confirmPromiseCompletion(
        _currentPromise.id!,
        role,
      );
      if (!mounted) return;
      setState(() {
        _currentPromise = updated;
        _hasChanges = true;
      });
      _loadData(showLoading: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.status == 'completed'
                ? 'Promise completed! Both parties have confirmed.'
                : 'Completion confirmed. Awaiting confirmation from the other party.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not confirm promise completion.'),
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

  Future<void> _showRequestChangesDialog() async {
    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Changes'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Describe the changes needed...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, reasonController.text.trim()),
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      _requestChanges(result);
    }
  }

  Future<void> _requestChanges(String reason) async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final currentAuthUserId = client.auth.authInfo?.authUserId.toString();
      final isCreator = _currentPromise.creatorUserId == currentAuthUserId;
      final role = isCreator ? 'creator' : 'recipient';

      final updated = await client.promise.requestChanges(
        _currentPromise.id!,
        role,
        reason,
      );
      if (!mounted) return;
      setState(() {
        _currentPromise = updated;
        _hasChanges = true;
      });
      _loadData(showLoading: false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Change request submitted.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not request changes.'),
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
    if (_isUploadingAttachment) return;

    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (files.isEmpty) return;
    final file = files.first;
    if (file.path == null) return;

    setState(() {
      _isUploadingAttachment = true;
      _isUploadSuccess = false;
      _uploadProgressMessage = 'Preparing upload...';
    });

    final fileSize = File(file.path!).lengthSync();

    try {
      final uploadDescription = await client.attachment.getUploadDescription(
        _currentPromise.id!,
        file.name,
        fileSize,
      );

      if (uploadDescription == null) {
        throw Exception('Could not get upload description.');
      }

      setState(() {
        _uploadProgressMessage = 'Uploading ${file.name}...';
      });

      final uploader = FileUploader(uploadDescription.uploadDescription);
      final stream = File(file.path!).openRead();
      final success = await uploader.upload(stream, fileSize);

      if (!success) {
        throw Exception('Upload to cloud storage failed.');
      }

      setState(() {
        _uploadProgressMessage = 'Verifying attachment...';
      });

      final ext = file.name.split('.').last.toLowerCase();
      String mimeType = 'application/octet-stream';
      if (ext == 'pdf') mimeType = 'application/pdf';
      if (ext == 'png') mimeType = 'image/png';
      if (ext == 'jpg' || ext == 'jpeg') mimeType = 'image/jpeg';

      await client.attachment.verifyAttachment(
        _currentPromise.id!,
        uploadDescription.path,
        file.name,
        fileSize,
        mimeType,
      );

      if (!mounted) return;
      setState(() {
        _isUploadingAttachment = false;
        _isUploadSuccess = true;
        _uploadProgressMessage = 'Upload complete!';
        _hasChanges = true;
      });

      _loadData(showLoading: false);

      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          setState(() {
            _isUploadSuccess = false;
            _uploadProgressMessage = null;
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploadingAttachment = false;
        _isUploadSuccess = false;
        _uploadProgressMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('10MB')
                ? 'File exceeds 10MB limit.'
                : 'Upload failed. Please try again.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
          content: const Text('Could not open download link.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _reviewAttachment(int attachmentId, String decision) async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
      _reviewingAttachmentId = attachmentId;
      _reviewingAction = decision;
    });

    String? rejectionReason;
    if (decision == 'rejected') {
      final controller = TextEditingController();
      rejectionReason = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reject Evidence'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Reason for rejection...',
            ),
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

      if (rejectionReason == null) {
        setState(() {
          _isUpdatingStatus = false;
          _reviewingAttachmentId = null;
          _reviewingAction = null;
        });
        return;
      }
    }

    try {
      await client.attachment.reviewAttachment(
        attachmentId,
        decision,
        rejectionReason: rejectionReason,
      );
      if (!mounted) return;
      setState(() {
        _reviewedSuccessAttachmentId = attachmentId;
        _hasChanges = true;
      });
      _loadData(showLoading: false);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _reviewedSuccessAttachmentId = null;
          });
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not review evidence.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
          _reviewingAttachmentId = null;
          _reviewingAction = null;
        });
      }
    }
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade700;
      case 'awaiting_confirmation':
        return Colors.orange.shade800;
      case 'in_progress':
        return Colors.blue.shade700;
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

  Widget _buildTypeBadge(
    String? type,
    ThemeData theme, {
    bool isGroupParent = false,
    bool isChild = false,
    String? parentType,
  }) {
    String cleanType = type?.trim().toLowerCase() ?? '';

    if (isGroupParent) {
      if (cleanType != 'freelance') {
        cleanType = 'team';
      }
    } else if (isChild) {
      if (cleanType != 'freelance' && cleanType != 'team') {
        if (parentType != null && parentType.trim().isNotEmpty) {
          final pType = parentType.trim().toLowerCase();
          cleanType = (pType == 'freelance') ? 'freelance' : 'team';
        } else {
          cleanType = 'team';
        }
      }
    } else {
      if (!['personal', 'freelance', 'team'].contains(cleanType)) {
        cleanType = 'personal';
      }
    }

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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
              // Parent Project Context Header Card (if child commitment)
              if (_parentProject != null) ...[
                Card(
                  elevation: 0,
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: colorScheme.secondary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.folder_open_outlined,
                              color: colorScheme.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Parent Project',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            _buildTypeBadge(
                              _parentProject!.commitmentType,
                              theme,
                              isGroupParent: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _parentProject!.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_parentProject!.description?.isNotEmpty ==
                            true) ...[
                          const SizedBox(height: 4),
                          Text(
                            _parentProject!.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Main Details Card
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
                        children: [
                          _buildTypeBadge(
                            _currentPromise.commitmentType,
                            theme,
                            isGroupParent: _currentPromise.isGroupParent,
                            isChild: _currentPromise.parentPromiseId != null,
                            parentType: _parentProject?.commitmentType,
                          ),
                          if (_currentPromise.milestoneOrder != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Milestone #${_currentPromise.milestoneOrder}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
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
                      Text(
                        _currentPromise.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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

              // Embedded Financial Section
              FinancialSection(
                promise: _currentPromise,
                currentUserId: currentAuthUserId ?? '',
                summary: _financialSummary,
                groupSummary: _groupFinancialSummary,
                terms: _financialTerms,
                schedules: _paymentSchedules,
                records: _paymentRecords,
                onRefreshNeeded: () => _loadData(showLoading: false),
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

              // Group Sub-Promises / Milestones Card
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
                          'Sub-Promises / Milestones (${_childPromises.length})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._childPromises.map(
                          (child) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              children: [
                                if (child.milestoneOrder != null) ...[
                                  Text(
                                    '#${child.milestoneOrder} ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                                Expanded(
                                  child: Text(
                                    child.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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
                const Text('No activity history available.')
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
