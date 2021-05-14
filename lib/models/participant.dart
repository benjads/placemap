import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Participant extends ChangeNotifier {
  final DocumentReference sessionRef;
  final String deviceId;
  bool tutorialComplete = false;
  bool quit = false;
  bool camera = false;
  bool distracted = false;
  String recallImg;
  String recallMsg;
  final DocumentReference docRef;

  Participant.fromSnapshot(DocumentSnapshot doc, DocumentReference sessionRef)
      : this.fromMap(doc.data(), sessionRef: sessionRef, docRef: doc.reference);

  Participant.fromMap(Map<String, dynamic> map, {this.sessionRef, this.docRef})
      : assert(map['deviceId'] != null),
        deviceId = map['deviceId'],
        tutorialComplete = map['tutorialComplete'],
        quit = map['quit'],
        camera = map['camera'],
        distracted = map['distracted'],
        recallImg = map['recallImg'],
        recallMsg = map['recallMsg'];

  Participant.initialize(this.deviceId, this.sessionRef)
      : docRef = sessionRef.collection('participants').doc(deviceId);

  Map<String, dynamic> get map => {
        'deviceId': deviceId,
        'tutorialComplete': tutorialComplete,
        'quit': quit,
        'camera': camera,
        'distracted': distracted,
        'recallImg': recallImg,
        'recallMsg': recallMsg
      };

  Future<void> update() async {
    await docRef.set(map);
    notifyListeners();
  }

  bool get shouldCount => !distracted || (distracted && camera);

  bool get left => quit && shouldCount;
}
