import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:placemap/model/participant.dart';
import 'package:placemap/model/session.dart';

class SessionRepo {
  CollectionReference _sessions;

  SessionRepo._()
      : _sessions = FirebaseFirestore.instance.collection('sessions');

  static SessionRepo _instance;

  factory SessionRepo() {
    _instance ??= SessionRepo._();
    return _instance;
  }

  Future<Session> createSession() async {
    String id = _getSessionCode();
    while (await _docExists(_sessions, id)) id = _getSessionCode();

    final Participant currentParticipant =
        await ParticipantRepo().createParticipant();

    final Session session = Session.initialize(id, [currentParticipant]);
    final DocumentReference docRef = _sessions.doc(id);
    session.docRef = docRef;

    await docRef.set(session.map);
    return session;
  }

  Future<void> destroySession(Session session) async {
    return await session.docRef.delete();
  }

  Future<Session> getSession(String id) async {
    final DocumentSnapshot doc = await _sessions.doc(id).get();
    return Session.fromSnapshot(doc);
  }

  Future<void> updateSession(Session session) async {
    return await session.docRef.update(session.map);
  }

  Future<bool> sessionExists(String id) {
    return _docExists(_sessions, id);
  }

  Future<void> addSelf(Session session) async {
    final Participant self = await ParticipantRepo().createParticipant();
    session.participants.add(self);
    await session.docRef.update(session.map);
  }

  Future<Participant> self(Session session) async {
    final String self = await ParticipantRepo().currentDeviceId();
    return session.participants.firstWhere(
        (participant) => participant.deviceId == self,
        orElse: () => null);
  }

  Future<void> removeSelf(Session session) async {
    final Participant self = await this.self(session);
    if (self == null) return;

    session.participants.remove(self);
    await session.docRef.update(session.map);
  }

  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final Random _rnd = Random();

  String _getSessionCode() => String.fromCharCodes(Iterable.generate(
      5, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<bool> _docExists(CollectionReference colRef, String id) async {
    DocumentSnapshot snapshot = await colRef.doc(id).get();
    return snapshot.exists;
  }
}

class ParticipantRepo {
  final DeviceInfoPlugin _deviceInfoPlugin;

  ParticipantRepo._() : _deviceInfoPlugin = DeviceInfoPlugin();

  static ParticipantRepo _instance;

  factory ParticipantRepo() {
    _instance ??= ParticipantRepo._();
    return _instance;
  }

  Future<Participant> createParticipant() async {
    final String deviceId = await currentDeviceId();
    final Participant participant = Participant.initialize(deviceId);
    return participant;
  }

  Future<String> currentDeviceId() async {
    if (Platform.isAndroid) {
      return (await _deviceInfoPlugin.androidInfo).id;
    } else if (Platform.isIOS) {
      return (await _deviceInfoPlugin.iosInfo).identifierForVendor;
    }

    return null;
  }
}
