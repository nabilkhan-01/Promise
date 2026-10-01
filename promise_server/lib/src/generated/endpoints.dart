/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:promise_server/src/generated/promises/promise.dart'
    as _ipgb4ryh;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../friends/friend_endpoint.dart' as _ib9qa24p;
import '../greetings/greeting_endpoint.dart' as _il624ik7;
import '../promises/promise_endpoint.dart' as _itrz4nk3;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'friend': _ib9qa24p.FriendEndpoint()
        ..initialize(
          server,
          'friend',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'promise': _itrz4nk3.PromiseEndpoint()
        ..initialize(
          server,
          'promise',
          null,
        ),
    };
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['friend'] = _is.EndpointConnector(
      name: 'friend',
      endpoint: endpoints['friend']!,
      methodConnectors: {
        'searchUsers': _is.MethodConnector(
          name: 'searchUsers',
          params: {
            'query': _is.ParameterDescription(
              name: 'query',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['friend'] as _ib9qa24p.FriendEndpoint).searchUsers(
                    session,
                    params['query'],
                  ),
        ),
        'sendFriendRequest': _is.MethodConnector(
          name: 'sendFriendRequest',
          params: {
            'receiverUserId': _is.ParameterDescription(
              name: 'receiverUserId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friend'] as _ib9qa24p.FriendEndpoint)
                  .sendFriendRequest(
                    session,
                    params['receiverUserId'],
                  ),
        ),
        'getPendingFriendRequests': _is.MethodConnector(
          name: 'getPendingFriendRequests',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friend'] as _ib9qa24p.FriendEndpoint)
                  .getPendingFriendRequests(session),
        ),
        'acceptFriendRequest': _is.MethodConnector(
          name: 'acceptFriendRequest',
          params: {
            'friendshipId': _is.ParameterDescription(
              name: 'friendshipId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friend'] as _ib9qa24p.FriendEndpoint)
                  .acceptFriendRequest(
                    session,
                    params['friendshipId'],
                  ),
        ),
        'rejectFriendRequest': _is.MethodConnector(
          name: 'rejectFriendRequest',
          params: {
            'friendshipId': _is.ParameterDescription(
              name: 'friendshipId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friend'] as _ib9qa24p.FriendEndpoint)
                  .rejectFriendRequest(
                    session,
                    params['friendshipId'],
                  ),
        ),
        'getFriends': _is.MethodConnector(
          name: 'getFriends',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friend'] as _ib9qa24p.FriendEndpoint)
                  .getFriends(session),
        ),
        'removeFriend': _is.MethodConnector(
          name: 'removeFriend',
          params: {
            'friendUserId': _is.ParameterDescription(
              name: 'friendUserId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friend'] as _ib9qa24p.FriendEndpoint)
                  .removeFriend(
                    session,
                    params['friendUserId'],
                  ),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    connectors['promise'] = _is.EndpointConnector(
      name: 'promise',
      endpoint: endpoints['promise']!,
      methodConnectors: {
        'createPromise': _is.MethodConnector(
          name: 'createPromise',
          params: {
            'promise': _is.ParameterDescription(
              name: 'promise',
              type: _is.getType<_ipgb4ryh.Promise>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['promise'] as _itrz4nk3.PromiseEndpoint)
                  .createPromise(
                    session,
                    params['promise'],
                  ),
        ),
        'getPromises': _is.MethodConnector(
          name: 'getPromises',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['promise'] as _itrz4nk3.PromiseEndpoint)
                  .getPromises(session),
        ),
        'getPromise': _is.MethodConnector(
          name: 'getPromise',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['promise'] as _itrz4nk3.PromiseEndpoint)
                  .getPromise(
                    session,
                    params['id'],
                  ),
        ),
        'getActivities': _is.MethodConnector(
          name: 'getActivities',
          params: {
            'promiseId': _is.ParameterDescription(
              name: 'promiseId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['promise'] as _itrz4nk3.PromiseEndpoint)
                  .getActivities(
                    session,
                    params['promiseId'],
                  ),
        ),
        'addActivity': _is.MethodConnector(
          name: 'addActivity',
          params: {
            'promiseId': _is.ParameterDescription(
              name: 'promiseId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'type': _is.ParameterDescription(
              name: 'type',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'message': _is.ParameterDescription(
              name: 'message',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'activityStatus': _is.ParameterDescription(
              name: 'activityStatus',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['promise'] as _itrz4nk3.PromiseEndpoint)
                  .addActivity(
                    session,
                    params['promiseId'],
                    params['type'],
                    params['message'],
                    activityStatus: params['activityStatus'],
                  ),
        ),
        'confirmPromiseCompletion': _is.MethodConnector(
          name: 'confirmPromiseCompletion',
          params: {
            'promiseId': _is.ParameterDescription(
              name: 'promiseId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'role': _is.ParameterDescription(
              name: 'role',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['promise'] as _itrz4nk3.PromiseEndpoint)
                  .confirmPromiseCompletion(
                    session,
                    params['promiseId'],
                    params['role'],
                  ),
        ),
        'requestChanges': _is.MethodConnector(
          name: 'requestChanges',
          params: {
            'promiseId': _is.ParameterDescription(
              name: 'promiseId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'role': _is.ParameterDescription(
              name: 'role',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'reason': _is.ParameterDescription(
              name: 'reason',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['promise'] as _itrz4nk3.PromiseEndpoint)
                  .requestChanges(
                    session,
                    params['promiseId'],
                    params['role'],
                    params['reason'],
                  ),
        ),
        'updatePromiseStatus': _is.MethodConnector(
          name: 'updatePromiseStatus',
          params: {
            'promiseId': _is.ParameterDescription(
              name: 'promiseId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'newStatus': _is.ParameterDescription(
              name: 'newStatus',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['promise'] as _itrz4nk3.PromiseEndpoint)
                  .updatePromiseStatus(
                    session,
                    params['promiseId'],
                    params['newStatus'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }
}
