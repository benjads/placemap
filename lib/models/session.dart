import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placemap/models/participant.dart';
import 'package:placemap/utils.dart';

class Session extends ChangeNotifier {
  final String id;
  SessionState _state;
  DocumentReference _tradRef;
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
        _participants = (map['participants'] as List<dynamic>)
            .map((participant) =>
                Participant.fromMap(PlacemapUtils.toMap(participant)))
            .toList();

  Map<String, dynamic> get map => {
        'id': id,
        'state': _state.toString(),
        'tradRef': _tradRef ?? null,
        'participants':
            _participants.map((participant) => participant.map).toList()
      };

  Session.initialize(this.id, this._participants)
      : _state = SessionState.waiting,
        docRef = FirebaseFirestore.instance.collection('sessions').doc(id);

  SessionState get state => _state;

  set state(SessionState state) {
    _state = state;
    update();
  }

  Participant getParticipant(String deviceId) => _participants.firstWhere(
      (participant) => participant.deviceId == deviceId,
      orElse: () => null);

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
    final String deviceId = await PlacemapUtils.currentDeviceId();
    _participants
        .firstWhere((participant) => participant.deviceId == deviceId)
        .tutorialComplete = true;
    update();
  }

  bool ready() {
    return _participants.firstWhere(
            (participant) => !participant.tutorialComplete,
            orElse: () => null) ==
        null;
  }

  int get participantCount => _participants.length;

  DocumentReference get tradRef => _tradRef;

  set tradRef(DocumentReference value) {
    _tradRef = value;
    update();
  }

  Future<void> update() async {
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

enum SessionState { waiting, tutorial, trad, postTrade }

extension StateExtension on SessionState {
  String get route {
    switch (this) {
      case SessionState.waiting:
        return '/';
      case SessionState.tutorial:
        return '/tutorial/1';
      case SessionState.trad:
        return '/tradition';
      case SessionState.postTrade:
        // todo
        return '/';
      default:
        return '/';
    }
  }
}
