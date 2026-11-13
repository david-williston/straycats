import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_providers.g.dart';

/// The Firebase SDK instances. Tests override these (or the repositories
/// built on them), so no Firebase plugin is loaded in tests.
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) => FirebaseFirestore.instance;

/// The uploader owns the retries (the outbox), so the SDK gives up after a
/// minute instead of retrying for ten.
@Riverpod(keepAlive: true)
FirebaseStorage firebaseStorage(Ref ref) =>
    FirebaseStorage.instance..setMaxUploadRetryTime(const Duration(minutes: 1));
