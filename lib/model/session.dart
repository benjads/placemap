import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:placemap/model/participant.dart';
import 'package:placemap/utils.dart';

class Session {
  final String id;
  final SessionState state;
  final List<Participant> participants;
  DocumentReference docRef;

  Session.fromSnapshot(DocumentSnapshot doc)
      : this.fromMap(doc.data(), docRef: doc.reference);

  Session.fromMap(Map<String, dynamic> map, {this.docRef})
      : assert(map['id'] != null),
        assert(map['state'] != null),
        assert(map['participants'] != null),
        id = map['id'],
        state = SessionState.values
            .firstWhere((state) => (state.toString() == map['state'])),
        participants = (map['participants'] as List<dynamic>)
            .map((participant) =>
                Participant.fromMap(PlacemapUtils.toMap(participant)))
            .toList();

  Session.initialize(this.id, this.participants) : state = SessionState.waiting;

  Map<String, dynamic> get map => {
        'id': id,
        'state': state.toString(),
        'participants':
            participants.map((participant) => participant.map).toList()
      };
}

enum SessionState { waiting, inGame }
