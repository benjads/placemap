import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:placemap/model/session.dart';

class SessionRepo {
  SessionRepo._();

  static SessionRepo _instance;

  factory SessionRepo() {
    _instance ??= SessionRepo._();
    return _instance;
  }

  Future<Session> createSession() async {
    CollectionReference sessions =
        FirebaseFirestore.instance.collection('sessions');

    String id = _getSessionCode();
    while (await _docExists(sessions, id)) id = _getSessionCode();

    Session session = Session.initialize(id);

    await sessions.doc(id).set(session.map);
    return session;
  }

  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  Random _rnd = Random();

  String _getSessionCode() => String.fromCharCodes(Iterable.generate(
      5, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<bool> _docExists(CollectionReference colRef, String id) async {
    DocumentSnapshot snapshot = await colRef.doc(id).get();
    return snapshot.exists;
  }
}
