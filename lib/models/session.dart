import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placemap/models/participant.dart';
import 'package:placemap/utils.dart';

class Session extends ChangeNotifier {
  final String id;
  SessionState _state;
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
        _participants = (map['participants'] as List<dynamic>)
            .map((participant) =>
                Participant.fromMap(PlacemapUtils.toMap(participant)))
            .toList();

  Map<String, dynamic> get map => {
        'id': id,
        'state': _state.toString(),
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

  Future<void> update() async {
    await docRef.set(map);
    notifyListeners();
  }
}

enum SessionState { waiting, tutorial, trad, postTrade }
