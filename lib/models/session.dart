import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placemap/models/participant.dart';
import 'package:placemap/utils.dart';

class Session extends ChangeNotifier {
  final String id;
  SessionState _state;
  DocumentReference _tradRef;
  DocumentReference _tradReviewRef;
  final DocumentReference docRef;

  Session.fromSnapshot(DocumentSnapshot doc)
      : this.fromMap(doc.data(), docRef: doc.reference);

  Session.fromMap(Map<String, dynamic> map, {this.docRef})
      : assert(map['id'] != null),
        assert(map['state'] != null),
        id = map['id'],
        _state = SessionState.values
            .firstWhere((state) => (state.toString() == map['state'])),
        _tradRef = map['tradRef'],
        _tradReviewRef = map['tradReviewRef'];

  Map<String, dynamic> get map => {
        'id': id,
        'state': _state.toString(),
        'tradRef': _tradRef ?? null,
        'tradReviewRef': _tradReviewRef ?? null
      };

  Session.initialize(this.id)
      : _state = SessionState.waiting,
        docRef = FirebaseFirestore.instance.collection('sessions').doc(id);

  SessionState get state => _state;

  void setState(SessionState state, bool refresh) {
    _state = state;
    if (refresh) update();
  }

  Future<Participant> getParticipant(String deviceId) async {
    final participantDoc =
        await docRef.collection('participants').doc(deviceId).get();
    if (!participantDoc.exists) return null;

    return Participant.fromSnapshot(participantDoc, this.docRef);
  }

  Future<Participant> getSelf() async {
    final String deviceId = await PlacemapUtils.currentDeviceId();
    return getParticipant(deviceId);
  }

  Future<void> addSelf() async {
    final String deviceId = await PlacemapUtils.currentDeviceId();

    if (await getSelf() != null) return;

    final participant = Participant.initialize(deviceId, this.docRef);
    participant.update();
  }

  Future<void> removeSelf() async {
    final self = await getSelf();
    return self.docRef.delete();
  }

  DocumentReference get tradRef => _tradRef;

  set tradRef(DocumentReference value) {
    _tradRef = value;
    update();
  }

  DocumentReference get tradReviewRef => _tradReviewRef;

  void setTradReviewRef(DocumentReference tradReviewRef, bool refresh) {
    _tradReviewRef = tradReviewRef;
    if (refresh) update();
  }

  Future<void> update() async {
    log('Pushing Session instance update to remote');
    await docRef.set(map);
    notifyListeners();
  }

  static Future<Session> load(String sessionId) async {
    final doc = await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .get();

    return doc.exists ? Session.fromSnapshot(doc) : null;
  }
}

enum SessionState { waiting, tutorial, trad, review, search, pause, ended }

extension StateExtension on SessionState {
  String get route {
    switch (this) {
      case SessionState.waiting:
        return '/';
      case SessionState.tutorial:
        return '/tutorial/1';
      case SessionState.trad:
        return '/tradition';
      case SessionState.review:
        return '/review';
      case SessionState.search:
        return '/search';
      case SessionState.pause:
        return '/pause';
      default:
        return '/';
    }
  }
}
