import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class Session {
  final String id;
  DocumentReference docRef;

  Session.fromSnapshot(DocumentSnapshot doc)
      : this.fromMap(doc.data(), docRef: doc.reference);

  Session.fromMap(Map<String, dynamic> map, {this.docRef})
      : assert(map['id'] != null),
        id = map['id'];

  Session.initialize(this.id);

  Map<String, dynamic> get map => {
        'id': id,
      };
}
