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
  String recallImg;
  String recallMsg;
  final List<Participant> _participants;
  final DocumentReference docRef;

  Session.fromSnapshot(DocumentSnapshot doc)
      : this.fromMap(doc.data(), docRef: doc.reference);

  Session.fromMap(Map<String, dynamic> map, {this.docRef})
      : assert(map['id'] != null),
        assert(map['state'] != null),
        assert(map['participants'] != null),
        id = map['id'],
        _state = SessionState.values
            .firstWhere((state) => (state.toString() == map['state'])),
        _tradRef = map['tradRef'],
        _tradReviewRef = map['tradReviewRef'],
        recallImg = map['recallImg'],
        recallMsg = map['recallMsg'],
        _participants = (map['participants'] as List<dynamic>)
            .map((participant) =>
                Participant.fromMap(PlacemapUtils.toMap(participant)))
            .toList();

  Map<String, dynamic> get map => {
        'id': id,
        'state': _state.toString(),
        'tradRef': _tradRef ?? null,
        'tradReviewRef': _tradReviewRef ?? null,
        'recallImg': recallImg,
        'recallMsg': recallMsg,
        'participants':
            _participants.map((participant) => participant.map).toList()
      };

  Session.initialize(this.id, this._participants)
      : _state = SessionState.waiting,
        docRef = FirebaseFirestore.instance.collection('sessions').doc(id);

  SessionState get state => _state;

  void setState(SessionState state, bool refresh) {
    _state = state;
    if (refresh) update();
  }

  Participant getParticipant(String deviceId) => _participants.firstWhere(
      (participant) => participant.deviceId == deviceId,
      orElse: () => null);

  Future<Participant> getSelf() async {
    final String deviceId = await PlacemapUtils.currentDeviceId();

    return _participants.firstWhere(
        (participant) => participant.deviceId == deviceId,
        orElse: () => null);
  }

  Future<void> addSelf() async {
    final String deviceId = await PlacemapUtils.currentDeviceId();

    if (_participants.firstWhere(
            (participant) => participant.deviceId == deviceId,
            orElse: () => null) !=
        null) return;

    final participant = Participant.initialize(deviceId);

    _participants.add(participant);
    return update();
  }

  Future<void> setSelfTutorial(bool complete) async {
    final self = await getSelf();
    self.tutorialComplete = complete;
    update();
  }

  Future<void> setSelfQuit(bool quit) async {
    final self = await getSelf();
    self.quit = quit;
    update();
  }

  Future<void> setSelCamera(bool camera) async {
    final self = await getSelf();
    self.camera = camera;
    update();
  }

  Future<void> setSelfDistracted(bool distracted) async {
    final self = await getSelf();
    self.distracted = distracted;
    update();
  }

  bool ready() {
    return _participants.firstWhere(
            (participant) => !participant.tutorialComplete,
            orElse: () => null) ==
        null;
  }

  bool allQuit() {
    return _participants.firstWhere(
            (participant) => !participant.quit && !participant.distracted,
            orElse: () => null) ==
        null;
  }

  int distractedCount() {
    return _participants
        .where((participant) => participant.distracted && !participant.camera)
        .length;
  }

  int get participantCount => _participants.length;

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
