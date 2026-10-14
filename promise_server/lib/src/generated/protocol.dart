/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:promise_server/src/generated/friends/user_search_profile.dart'
    as _i36a1br3;
import 'package:promise_server/src/generated/notifications/app_notification.dart'
    as _iy76h3a0;
import 'package:promise_server/src/generated/promises/promise.dart'
    as _ipgb4ryh;
import 'package:promise_server/src/generated/promises/promise_activity.dart'
    as _ih1o0d6l;
import 'package:promise_server/src/generated/promises/promise_attachment.dart'
    as _ir9c0j66;
import 'package:promise_server/src/generated/promises/promise_payment_record.dart'
    as _ixrmqdzt;
import 'package:promise_server/src/generated/promises/promise_payment_schedule.dart'
    as _iby9nazs;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'auth/account_not_found_exception.dart' as _i12ji7k4;
import 'friends/friendship.dart' as _ix1l50pg;
import 'friends/user_search_profile.dart' as _i6kf6063;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'notifications/app_notification.dart' as _ih0s0cfq;
import 'promises/attachment_upload_description.dart' as _ipry8xt3;
import 'promises/deadline_reminder_object.dart' as _iqhyy8ir;
import 'promises/group_financial_summary.dart' as _if1nqauc;
import 'promises/parent_project_metadata.dart' as _iegghg43;
import 'promises/promise.dart' as _i9knynp5;
import 'promises/promise_activity.dart' as _itvtbfbt;
import 'promises/promise_attachment.dart' as _i64rwlud;
import 'promises/promise_expiry_object.dart' as _iwkf95uh;
import 'promises/promise_financial_summary.dart' as _ial6qs5u;
import 'promises/promise_financial_terms.dart' as _ihzb06nf;
import 'promises/promise_payment_record.dart' as _imdaekze;
import 'promises/promise_payment_schedule.dart' as _i3vn3kwg;
export 'auth/account_not_found_exception.dart';
export 'friends/friendship.dart';
export 'friends/user_search_profile.dart';
export 'greetings/greeting.dart';
export 'notifications/app_notification.dart';
export 'promises/attachment_upload_description.dart';
export 'promises/deadline_reminder_object.dart';
export 'promises/group_financial_summary.dart';
export 'promises/parent_project_metadata.dart';
export 'promises/promise.dart';
export 'promises/promise_activity.dart';
export 'promises/promise_attachment.dart';
export 'promises/promise_expiry_object.dart';
export 'promises/promise_financial_summary.dart';
export 'promises/promise_financial_terms.dart';
export 'promises/promise_payment_record.dart';
export 'promises/promise_payment_schedule.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'app_notification',
      dartName: 'AppNotification',
      schema: 'public',
      module: 'promise',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'type',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'message',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'promiseId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'friendshipId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'readAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'friendship',
      dartName: 'Friendship',
      schema: 'public',
      module: 'promise',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'senderUserId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'receiverUserId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'promise',
      dartName: 'Promise',
      schema: 'public',
      module: 'promise',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'promisedTo',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'dueDate',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'dueTime',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'creatorConfirmed',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'recipientConfirmed',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'creatorUserId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'recipientUserId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'isGroupParent',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'parentPromiseId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'recipientAccepted',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'recipientAcceptedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'commitmentType',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
          columnDefault: '\'personal\'',
        ),
        _isp.ColumnDefinition(
          name: 'milestoneOrder',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'promise_activity',
      dartName: 'PromiseActivity',
      schema: 'public',
      module: 'promise',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'promiseId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'type',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'message',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'promise_activity_fk_0',
          columns: ['promiseId'],
          referenceTable: 'promise',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'promise_attachment',
      dartName: 'PromiseAttachment',
      schema: 'public',
      module: 'promise',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'promiseId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'uploaderUserId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'storageId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'path',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'fileName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'mimeType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'fileSize',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'approvalStatus',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'reviewedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'reviewerUserId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'rejectionReason',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'promise_financial_terms',
      dartName: 'PromiseFinancialTerms',
      schema: 'public',
      module: 'promise',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'promiseId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'totalAmountMinorUnits',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'currency',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'payerUserId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'payeeUserId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'notes',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'promise_financial_terms_fk_0',
          columns: ['promiseId'],
          referenceTable: 'promise',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'promise_financial_terms_promise_id_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'promiseId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'promise_payment_record',
      dartName: 'PromisePaymentRecord',
      schema: 'public',
      module: 'promise',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'promiseId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'scheduleId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'recordKind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'reversesPaymentRecordId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'recorderUserId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'payerUserId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'payeeUserId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinorUnits',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'currency',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'paymentDate',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'paymentMethod',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'externalReference',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'notes',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'attachmentId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'pending_confirmation\'',
        ),
        _isp.ColumnDefinition(
          name: 'confirmedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'confirmerUserId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'disputedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'disputerUserId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'disputeReason',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'cancelledAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'cancellerUserId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'cancellationReason',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'promise_payment_record_fk_0',
          columns: ['promiseId'],
          referenceTable: 'promise',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'promise_payment_record_fk_1',
          columns: ['scheduleId'],
          referenceTable: 'promise_payment_schedule',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'promise_payment_record_fk_2',
          columns: ['reversesPaymentRecordId'],
          referenceTable: 'promise_payment_record',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'promise_payment_record_fk_3',
          columns: ['attachmentId'],
          referenceTable: 'promise_attachment',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'promise_payment_record_promise_id_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'promiseId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'promise_payment_record_reverses_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'reversesPaymentRecordId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'promise_payment_schedule',
      dartName: 'PromisePaymentSchedule',
      schema: 'public',
      module: 'promise',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'promiseId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'installmentOrder',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinorUnits',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'currency',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'dueDate',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'cancelledAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'cancelledByUserId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'cancellationReason',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'notes',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'promise_payment_schedule_fk_0',
          columns: ['promiseId'],
          referenceTable: 'promise',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'promise_payment_schedule_promise_id_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'promiseId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'promise_payment_schedule_order_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'promiseId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'installmentOrder',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i12ji7k4.AccountNotFoundException) {
      return _i12ji7k4.AccountNotFoundException.fromJson(data) as T;
    }
    if (t == _ix1l50pg.Friendship) {
      return _ix1l50pg.Friendship.fromJson(data) as T;
    }
    if (t == _i6kf6063.UserSearchProfile) {
      return _i6kf6063.UserSearchProfile.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _ih0s0cfq.AppNotification) {
      return _ih0s0cfq.AppNotification.fromJson(data) as T;
    }
    if (t == _ipry8xt3.AttachmentUploadDescription) {
      return _ipry8xt3.AttachmentUploadDescription.fromJson(data) as T;
    }
    if (t == _iqhyy8ir.DeadlineReminderObject) {
      return _iqhyy8ir.DeadlineReminderObject.fromJson(data) as T;
    }
    if (t == _if1nqauc.GroupFinancialSummary) {
      return _if1nqauc.GroupFinancialSummary.fromJson(data) as T;
    }
    if (t == _iegghg43.ParentProjectMetadata) {
      return _iegghg43.ParentProjectMetadata.fromJson(data) as T;
    }
    if (t == _i9knynp5.Promise) {
      return _i9knynp5.Promise.fromJson(data) as T;
    }
    if (t == _itvtbfbt.PromiseActivity) {
      return _itvtbfbt.PromiseActivity.fromJson(data) as T;
    }
    if (t == _i64rwlud.PromiseAttachment) {
      return _i64rwlud.PromiseAttachment.fromJson(data) as T;
    }
    if (t == _iwkf95uh.PromiseExpiryObject) {
      return _iwkf95uh.PromiseExpiryObject.fromJson(data) as T;
    }
    if (t == _ial6qs5u.PromiseFinancialSummary) {
      return _ial6qs5u.PromiseFinancialSummary.fromJson(data) as T;
    }
    if (t == _ihzb06nf.PromiseFinancialTerms) {
      return _ihzb06nf.PromiseFinancialTerms.fromJson(data) as T;
    }
    if (t == _imdaekze.PromisePaymentRecord) {
      return _imdaekze.PromisePaymentRecord.fromJson(data) as T;
    }
    if (t == _i3vn3kwg.PromisePaymentSchedule) {
      return _i3vn3kwg.PromisePaymentSchedule.fromJson(data) as T;
    }
    if (t == _is.getType<_i12ji7k4.AccountNotFoundException?>()) {
      return (data != null
              ? _i12ji7k4.AccountNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ix1l50pg.Friendship?>()) {
      return (data != null ? _ix1l50pg.Friendship.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i6kf6063.UserSearchProfile?>()) {
      return (data != null ? _i6kf6063.UserSearchProfile.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ih0s0cfq.AppNotification?>()) {
      return (data != null ? _ih0s0cfq.AppNotification.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ipry8xt3.AttachmentUploadDescription?>()) {
      return (data != null
              ? _ipry8xt3.AttachmentUploadDescription.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iqhyy8ir.DeadlineReminderObject?>()) {
      return (data != null
              ? _iqhyy8ir.DeadlineReminderObject.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_if1nqauc.GroupFinancialSummary?>()) {
      return (data != null
              ? _if1nqauc.GroupFinancialSummary.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iegghg43.ParentProjectMetadata?>()) {
      return (data != null
              ? _iegghg43.ParentProjectMetadata.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i9knynp5.Promise?>()) {
      return (data != null ? _i9knynp5.Promise.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_itvtbfbt.PromiseActivity?>()) {
      return (data != null ? _itvtbfbt.PromiseActivity.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i64rwlud.PromiseAttachment?>()) {
      return (data != null ? _i64rwlud.PromiseAttachment.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iwkf95uh.PromiseExpiryObject?>()) {
      return (data != null
              ? _iwkf95uh.PromiseExpiryObject.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ial6qs5u.PromiseFinancialSummary?>()) {
      return (data != null
              ? _ial6qs5u.PromiseFinancialSummary.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ihzb06nf.PromiseFinancialTerms?>()) {
      return (data != null
              ? _ihzb06nf.PromiseFinancialTerms.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_imdaekze.PromisePaymentRecord?>()) {
      return (data != null
              ? _imdaekze.PromisePaymentRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i3vn3kwg.PromisePaymentSchedule?>()) {
      return (data != null
              ? _i3vn3kwg.PromisePaymentSchedule.fromJson(data)
              : null)
          as T;
    }
    if (t == List<_ial6qs5u.PromiseFinancialSummary>) {
      return (data as List)
              .map((e) => deserialize<_ial6qs5u.PromiseFinancialSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i36a1br3.UserSearchProfile>) {
      return (data as List)
              .map((e) => deserialize<_i36a1br3.UserSearchProfile>(e))
              .toList()
          as T;
    }
    if (t == List<_iy76h3a0.AppNotification>) {
      return (data as List)
              .map((e) => deserialize<_iy76h3a0.AppNotification>(e))
              .toList()
          as T;
    }
    if (t == List<_ir9c0j66.PromiseAttachment>) {
      return (data as List)
              .map((e) => deserialize<_ir9c0j66.PromiseAttachment>(e))
              .toList()
          as T;
    }
    if (t == List<_iby9nazs.PromisePaymentSchedule>) {
      return (data as List)
              .map((e) => deserialize<_iby9nazs.PromisePaymentSchedule>(e))
              .toList()
          as T;
    }
    if (t == List<_ixrmqdzt.PromisePaymentRecord>) {
      return (data as List)
              .map((e) => deserialize<_ixrmqdzt.PromisePaymentRecord>(e))
              .toList()
          as T;
    }
    if (t == List<_ipgb4ryh.Promise>) {
      return (data as List)
              .map((e) => deserialize<_ipgb4ryh.Promise>(e))
              .toList()
          as T;
    }
    if (t == List<_ih1o0d6l.PromiseActivity>) {
      return (data as List)
              .map((e) => deserialize<_ih1o0d6l.PromiseActivity>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i12ji7k4.AccountNotFoundException => 'AccountNotFoundException',
      _ix1l50pg.Friendship => 'Friendship',
      _i6kf6063.UserSearchProfile => 'UserSearchProfile',
      _izw8z7ou.Greeting => 'Greeting',
      _ih0s0cfq.AppNotification => 'AppNotification',
      _ipry8xt3.AttachmentUploadDescription => 'AttachmentUploadDescription',
      _iqhyy8ir.DeadlineReminderObject => 'DeadlineReminderObject',
      _if1nqauc.GroupFinancialSummary => 'GroupFinancialSummary',
      _iegghg43.ParentProjectMetadata => 'ParentProjectMetadata',
      _i9knynp5.Promise => 'Promise',
      _itvtbfbt.PromiseActivity => 'PromiseActivity',
      _i64rwlud.PromiseAttachment => 'PromiseAttachment',
      _iwkf95uh.PromiseExpiryObject => 'PromiseExpiryObject',
      _ial6qs5u.PromiseFinancialSummary => 'PromiseFinancialSummary',
      _ihzb06nf.PromiseFinancialTerms => 'PromiseFinancialTerms',
      _imdaekze.PromisePaymentRecord => 'PromisePaymentRecord',
      _i3vn3kwg.PromisePaymentSchedule => 'PromisePaymentSchedule',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('promise.', '');
    }

    switch (data) {
      case _i12ji7k4.AccountNotFoundException():
        return 'AccountNotFoundException';
      case _ix1l50pg.Friendship():
        return 'Friendship';
      case _i6kf6063.UserSearchProfile():
        return 'UserSearchProfile';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _ih0s0cfq.AppNotification():
        return 'AppNotification';
      case _ipry8xt3.AttachmentUploadDescription():
        return 'AttachmentUploadDescription';
      case _iqhyy8ir.DeadlineReminderObject():
        return 'DeadlineReminderObject';
      case _if1nqauc.GroupFinancialSummary():
        return 'GroupFinancialSummary';
      case _iegghg43.ParentProjectMetadata():
        return 'ParentProjectMetadata';
      case _i9knynp5.Promise():
        return 'Promise';
      case _itvtbfbt.PromiseActivity():
        return 'PromiseActivity';
      case _i64rwlud.PromiseAttachment():
        return 'PromiseAttachment';
      case _iwkf95uh.PromiseExpiryObject():
        return 'PromiseExpiryObject';
      case _ial6qs5u.PromiseFinancialSummary():
        return 'PromiseFinancialSummary';
      case _ihzb06nf.PromiseFinancialTerms():
        return 'PromiseFinancialTerms';
      case _imdaekze.PromisePaymentRecord():
        return 'PromisePaymentRecord';
      case _i3vn3kwg.PromisePaymentSchedule():
        return 'PromisePaymentSchedule';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AccountNotFoundException') {
      return deserialize<_i12ji7k4.AccountNotFoundException>(data['data']);
    }
    if (dataClassName == 'Friendship') {
      return deserialize<_ix1l50pg.Friendship>(data['data']);
    }
    if (dataClassName == 'UserSearchProfile') {
      return deserialize<_i6kf6063.UserSearchProfile>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'AppNotification') {
      return deserialize<_ih0s0cfq.AppNotification>(data['data']);
    }
    if (dataClassName == 'AttachmentUploadDescription') {
      return deserialize<_ipry8xt3.AttachmentUploadDescription>(data['data']);
    }
    if (dataClassName == 'DeadlineReminderObject') {
      return deserialize<_iqhyy8ir.DeadlineReminderObject>(data['data']);
    }
    if (dataClassName == 'GroupFinancialSummary') {
      return deserialize<_if1nqauc.GroupFinancialSummary>(data['data']);
    }
    if (dataClassName == 'ParentProjectMetadata') {
      return deserialize<_iegghg43.ParentProjectMetadata>(data['data']);
    }
    if (dataClassName == 'Promise') {
      return deserialize<_i9knynp5.Promise>(data['data']);
    }
    if (dataClassName == 'PromiseActivity') {
      return deserialize<_itvtbfbt.PromiseActivity>(data['data']);
    }
    if (dataClassName == 'PromiseAttachment') {
      return deserialize<_i64rwlud.PromiseAttachment>(data['data']);
    }
    if (dataClassName == 'PromiseExpiryObject') {
      return deserialize<_iwkf95uh.PromiseExpiryObject>(data['data']);
    }
    if (dataClassName == 'PromiseFinancialSummary') {
      return deserialize<_ial6qs5u.PromiseFinancialSummary>(data['data']);
    }
    if (dataClassName == 'PromiseFinancialTerms') {
      return deserialize<_ihzb06nf.PromiseFinancialTerms>(data['data']);
    }
    if (dataClassName == 'PromisePaymentRecord') {
      return deserialize<_imdaekze.PromisePaymentRecord>(data['data']);
    }
    if (dataClassName == 'PromisePaymentSchedule') {
      return deserialize<_i3vn3kwg.PromisePaymentSchedule>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('promise', this);
    _iacs.Protocol().registerHostProtocol('promise', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _ix1l50pg.Friendship:
        return _ix1l50pg.Friendship.t;
      case _ih0s0cfq.AppNotification:
        return _ih0s0cfq.AppNotification.t;
      case _i9knynp5.Promise:
        return _i9knynp5.Promise.t;
      case _itvtbfbt.PromiseActivity:
        return _itvtbfbt.PromiseActivity.t;
      case _i64rwlud.PromiseAttachment:
        return _i64rwlud.PromiseAttachment.t;
      case _ihzb06nf.PromiseFinancialTerms:
        return _ihzb06nf.PromiseFinancialTerms.t;
      case _imdaekze.PromisePaymentRecord:
        return _imdaekze.PromisePaymentRecord.t;
      case _i3vn3kwg.PromisePaymentSchedule:
        return _i3vn3kwg.PromisePaymentSchedule.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'promise';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
