import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class PromiseEndpoint extends Endpoint {
  /// Creates a new promise after validating input and setting server-side metadata.
  Future<Promise> createPromise(Session session, Promise promise) async {
    if (promise.title.trim().isEmpty) {
      throw ArgumentError('Promise title cannot be empty.');
    }
    if (promise.promisedTo.trim().isEmpty) {
      throw ArgumentError('Promised to cannot be empty.');
    }

    final promiseToInsert = promise.copyWith(
      title: promise.title.trim(),
      promisedTo: promise.promisedTo.trim(),
      description: promise.description?.trim(),
      createdAt: DateTime.now().toUtc(),
      status: promise.status.trim().isEmpty ? 'pending' : promise.status.trim(),
    );

    return await Promise.db.insertRow(session, promiseToInsert);
  }

  /// Retrieves all promises ordered newest-created first.
  Future<List<Promise>> getPromises(Session session) async {
    return await Promise.db.find(
      session,
      orderBy: (t) => t.createdAt.desc(),
    );
  }
}
