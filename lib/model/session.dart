import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placemap/model/participant.dart';
import 'package:placemap/utils.dart';

class Session extends ChangeNotifier {
  final String id;
  SessionState _state;
  final List<Participant> participants;
  DocumentReference docRef;

  Session.fromSnapshot(DocumentSnapshot doc)
      : this.fromMap(doc.data(), docRef: doc.reference);

  Session.fromMap(Map<String, dynamic> map, {this.docRef})
      : assert(map['id'] != null),
        assert(map['state'] != null),
        assert(map['participants'] != null),
        id = map['id'],
        _state = SessionState.values
            .firstWhere((state) => (state.toString() == map['state'])),
        participants = (map['participants'] as List<dynamic>)
            .map((participant) =>
                Participant.fromMap(PlacemapUtils.toMap(participant)))
            .toList();

  Session.initialize(this.id, this.participants) : _state = SessionState.waiting;

  Map<String, dynamic> get map => {
        'id': id,
        'state': _state.toString(),
        'participants':
            participants.map((participant) => participant.map).toList()
      };

  SessionState get state => _state;

  set state(SessionState state) {
    _state = state;
    docRef.update(map);
    notifyListeners();
  }


}

enum SessionState { waiting, tutorial, showingTrad }
