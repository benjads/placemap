import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:placemap/models/participant.dart';

class TraditionReview {
  final DocumentReference sessionRef;
  final DocumentReference tradRef;
  final Map<Participant, int> _ratings;
  final DocumentReference docRef;

  TraditionReview(this.sessionRef, this.tradRef)
      : _ratings = {},
        docRef = sessionRef.collection('reviews').doc(tradRef.id);

  TraditionReview.fromSnapshot(DocumentSnapshot doc)
      : this.fromMap(doc.data(), docRef: doc.reference);

  TraditionReview.fromMap(Map<String, dynamic> map, {this.docRef})
      : assert(map['tradRef'] != null),
        sessionRef = docRef.parent.parent,
        tradRef = map['tradRef'],
        _ratings = map['ratings'] ?? {};
}
