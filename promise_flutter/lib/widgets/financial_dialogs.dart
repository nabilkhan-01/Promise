import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:promise_client/promise_client.dart';
import 'package:promise_currency/promise_currency.dart';

import '../client.dart';
import 'currency_picker_modal.dart';

/// Dialog for setting or updating financial terms.
class SetFinancialTermsDialog extends StatefulWidget {
  final int promiseId;
  final String creatorUserId;
  final String recipientUserId;
  final PromiseFinancialTerms? initialTerms;

  const SetFinancialTermsDialog({
    super.key,
    required this.promiseId,
    required this.creatorUserId,
    required this.recipientUserId,
    this.initialTerms,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int promiseId,
    required String creatorUserId,
    required String recipientUserId,
    PromiseFinancialTerms? initialTerms,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SetFinancialTermsDialog(
        promiseId: promiseId,
        creatorUserId: creatorUserId,
        recipientUserId: recipientUserId,
        initialTerms: initialTerms,
      ),
    );
  }

  @override
  State<SetFinancialTermsDialog> createState() =>
      _SetFinancialTermsDialogState();
}

class _SetFinancialTermsDialogState extends State<SetFinancialTermsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late IsoCurrency _selectedCurrency;
  late String _payerUserId;
  late String _payeeUserId;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialTerms != null) {
      final t = widget.initialTerms!;
      _selectedCurrency =
          IsoCurrencyCatalogue.findByCode(t.currency) ??
          IsoCurrencyCatalogue.findByCode('USD')!;
      _amountController.text = CurrencyUtils.formatMajorUnits(
        t.totalAmountMinorUnits,
        _selectedCurrency,
      );
      _notesController.text = t.notes ?? '';
      _payerUserId = t.payerUserId;
      _payeeUserId = t.payeeUserId;
    } else {
      _selectedCurrency = IsoCurrencyCatalogue.findByCode('USD')!;
      _payerUserId = widget.creatorUserId;
      _payeeUserId = widget.recipientUserId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final minorUnits = CurrencyUtils.parseToMinorUnits(
        _amountController.text,
        _selectedCurrency,
      );

      await client.financial.setFinancialTerms(
        widget.promiseId,
        minorUnits,
        _selectedCurrency.code,
        _payerUserId,
        _payeeUserId,
        _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Configure Financial Terms'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Currency Selector
              Text(
                'Currency',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _isLoading
                    ? null
                    : () async {
                        final picked = await CurrencyPickerModal.show(
                          context,
                          initialCurrency: _selectedCurrency,
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedCurrency = picked;
                          });
                        }
                      },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${_selectedCurrency.code} (${_selectedCurrency.symbol})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedCurrency.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Amount Input
              TextFormField(
                controller: _amountController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Agreed Contract Amount *',
                  hintText: 'e.g. 1500.00',
                  prefixText: '${_selectedCurrency.symbol} ',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter contract amount';
                  }
                  try {
                    CurrencyUtils.parseToMinorUnits(
                      value,
                      _selectedCurrency,
                    );
                    return null;
                  } catch (e) {
                    return e.toString().replaceAll('ArgumentError: ', '');
                  }
                },
              ),
              const SizedBox(height: 16),

              // Payer / Payee Assignment
              Text(
                'Payment Roles',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'creator_pays',
                    label: Text('Creator Pays'),
                  ),
                  ButtonSegment(
                    value: 'recipient_pays',
                    label: Text('Recipient Pays'),
                  ),
                ],
                selected: {
                  _payerUserId == widget.creatorUserId
                      ? 'creator_pays'
                      : 'recipient_pays',
                },
                onSelectionChanged: _isLoading
                    ? null
                    : (selection) {
                        setState(() {
                          if (selection.first == 'creator_pays') {
                            _payerUserId = widget.creatorUserId;
                            _payeeUserId = widget.recipientUserId;
                          } else {
                            _payerUserId = widget.recipientUserId;
                            _payeeUserId = widget.creatorUserId;
                          }
                        });
                      },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                enabled: !_isLoading,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes or Payment Terms (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Terms'),
        ),
      ],
    );
  }
}

/// Dialog for recording an offline payment or refund.
class RecordPaymentDialog extends StatefulWidget {
  final int promiseId;
  final String currency;
  final String recordKind; // 'payment' or 'refund'
  final int? originalPaymentRecordId;
  final List<PromisePaymentSchedule>? schedules;

  const RecordPaymentDialog({
    super.key,
    required this.promiseId,
    required this.currency,
    this.recordKind = 'payment',
    this.originalPaymentRecordId,
    this.schedules,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int promiseId,
    required String currency,
    String recordKind = 'payment',
    int? originalPaymentRecordId,
    List<PromisePaymentSchedule>? schedules,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RecordPaymentDialog(
        promiseId: promiseId,
        currency: currency,
        recordKind: recordKind,
        originalPaymentRecordId: originalPaymentRecordId,
        schedules: schedules,
      ),
    );
  }

  @override
  State<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  late IsoCurrency _currency;
  String _paymentMethod = 'bank_transfer';
  int? _selectedScheduleId;
  DateTime _paymentDate = DateTime.now();

  PlatformFile? _selectedFile;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _methods = [
    'bank_transfer',
    'cash',
    'venmo',
    'paypal',
    'zelle',
    'check',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _currency =
        IsoCurrencyCatalogue.findByCode(widget.currency) ??
        IsoCurrencyCatalogue.findByCode('USD')!;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpeg', 'jpg'],
    );
    if (files.isNotEmpty && files.first.path != null) {
      setState(() {
        _selectedFile = files.first;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final minorUnits = CurrencyUtils.parseToMinorUnits(
        _amountController.text,
        _currency,
      );

      int? uploadedAttachmentId;
      if (_selectedFile != null && _selectedFile!.path != null) {
        final file = File(_selectedFile!.path!);
        final fileSize = file.lengthSync();

        final uploadDescription = await client.attachment.getUploadDescription(
          widget.promiseId,
          _selectedFile!.name,
          fileSize,
        );

        if (uploadDescription != null) {
          final uploader = FileUploader(uploadDescription.uploadDescription);
          final fileStream = file.openRead();
          await uploader.upload(fileStream, fileSize);

          final ext = _selectedFile!.name.split('.').last.toLowerCase();
          String mimeType = 'application/octet-stream';
          if (ext == 'pdf') mimeType = 'application/pdf';
          if (ext == 'png') mimeType = 'image/png';
          if (ext == 'jpg' || ext == 'jpeg') mimeType = 'image/jpeg';

          final verifiedAttachment = await client.attachment.verifyAttachment(
            widget.promiseId,
            uploadDescription.path,
            _selectedFile!.name,
            fileSize,
            mimeType,
          );
          uploadedAttachmentId = verifiedAttachment.id;
        }
      }

      if (widget.recordKind == 'refund') {
        await client.financial.recordRefund(
          widget.promiseId,
          widget.originalPaymentRecordId!,
          minorUnits,
          _paymentDate,
          _paymentMethod,
          _referenceController.text.trim().isEmpty
              ? null
              : _referenceController.text.trim(),
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          uploadedAttachmentId,
        );
      } else {
        await client.financial.recordPayment(
          widget.promiseId,
          _selectedScheduleId,
          minorUnits,
          _paymentDate,
          _paymentMethod,
          _referenceController.text.trim().isEmpty
              ? null
              : _referenceController.text.trim(),
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          uploadedAttachmentId,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleText = widget.recordKind == 'refund'
        ? 'Record Offline Refund'
        : 'Record Offline Payment';

    return AlertDialog(
      title: Text(titleText),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Amount Input
              TextFormField(
                controller: _amountController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: widget.recordKind == 'refund'
                      ? 'Refund Amount *'
                      : 'Payment Amount *',
                  prefixText: '${_currency.symbol} ',
                  suffixText: _currency.code,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter amount';
                  }
                  try {
                    CurrencyUtils.parseToMinorUnits(value, _currency);
                    return null;
                  } catch (e) {
                    return e.toString().replaceAll('ArgumentError: ', '');
                  }
                },
              ),
              const SizedBox(height: 16),

              // Installment selector if payment & schedules present
              if (widget.recordKind == 'payment' &&
                  widget.schedules != null &&
                  widget.schedules!.isNotEmpty) ...[
                DropdownButtonFormField<int?>(
                  initialValue: _selectedScheduleId,
                  decoration: const InputDecoration(
                    labelText: 'Link to Installment (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('None (General Payment)'),
                    ),
                    ...widget.schedules!.map(
                      (s) => DropdownMenuItem<int?>(
                        value: s.id,
                        child: Text(
                          '#${s.installmentOrder} — ${CurrencyUtils.formatMinorUnits(s.amountMinorUnits, _currency)}',
                        ),
                      ),
                    ),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (val) => setState(() => _selectedScheduleId = val),
                ),
                const SizedBox(height: 16),
              ],

              // Payment Method Dropdown
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Channel / Method *',
                  border: OutlineInputBorder(),
                ),
                items: _methods
                    .map(
                      (m) => DropdownMenuItem<String>(
                        value: m,
                        child: Text(m.replaceAll('_', ' ').toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: _isLoading
                    ? null
                    : (val) {
                        if (val != null) setState(() => _paymentMethod = val);
                      },
              ),
              const SizedBox(height: 16),

              // Reference / Transaction ID
              TextFormField(
                controller: _referenceController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'External Reference / Transaction ID (Optional)',
                  hintText: 'e.g. TXN-987654 / Venmo handle',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Attachment Evidence Upload
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: Text(
                        _selectedFile == null
                            ? 'Attach Receipt / Evidence'
                            : _selectedFile!.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (_selectedFile != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _selectedFile = null),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                enabled: !_isLoading,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  widget.recordKind == 'refund'
                      ? 'Submit Refund'
                      : 'Submit Payment',
                ),
        ),
      ],
    );
  }
}

/// Dialog for entering a dispute reason.
class DisputeRecordDialog extends StatefulWidget {
  final int paymentRecordId;

  const DisputeRecordDialog({
    super.key,
    required this.paymentRecordId,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int paymentRecordId,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DisputeRecordDialog(
        paymentRecordId: paymentRecordId,
      ),
    );
  }

  @override
  State<DisputeRecordDialog> createState() => _DisputeRecordDialogState();
}

class _DisputeRecordDialogState extends State<DisputeRecordDialog> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await client.financial.disputePaymentRecord(
        widget.paymentRecordId,
        _reasonController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dispute Record'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _reasonController,
              enabled: !_isLoading,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for dispute *',
                hintText: 'e.g. Money not received in bank account',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Enter dispute reason';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirm Dispute'),
        ),
      ],
    );
  }
}
