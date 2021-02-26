import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placemap/models/participant.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/models/tradition.dart';
import 'package:placemap/models/tradition_review.dart';
import 'package:placemap/utils.dart';

class AppData extends ChangeNotifier {
  String _sessionId;
  Session _session;
  bool dirtyScreen = false;
  StreamSubscription _sessionSub;
  bool _host = false;
  Tradition _tradition;
  TraditionReview _review;

  Session get session => _session;
  String get sessionId => _sessionId;
  bool get host => _host;
  Tradition get tradition => _tradition;
  TraditionReview get review => _review;

  Future<Session> getOrCreateSession() async {
    if (_session != null && _host) return _session;

    _sessionId = PlacemapUtils.getSessionCode();
    while ((await FirebaseFirestore.instance
            .collection('sessions')
            .doc(_sessionId)
            .get())
        .exists) _sessionId = PlacemapUtils.getSessionCode();

    final participant =
        Participant.initialize(await PlacemapUtils.currentDeviceId());
    _session = Session.initialize(_sessionId, [participant]);
    await _session.update();

    sessionId = _sessionId;
    _host = true;
    notifyListeners();

    return _session;
  }

  Future<void> destroySession() async {
    assert(_session != null);

    await _session.docRef.delete();
    _sessionSub?.cancel();
    _session = null;
    _sessionId = null;
    _sessionSub = null;
    _review = null;
    _host = false;
    notifyListeners();
  }

  set sessionId(String sessionId) {
    _sessionId = sessionId;
    _sessionSub?.cancel();

    if (_sessionId != null) {
      _sessionSub = FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .snapshots()
          .listen((doc) {
        final newSession = Session.fromSnapshot(doc);

        if (newSession.state != _session.state) dirtyScreen = true;

        _session = newSession;

        if (_session.tradRef != null) {
          _session.tradRef.get().then((tradition) {
            _tradition = Tradition.fromSnapshot(tradition);

            if (_session.tradReviewRef != null) {
              _session.tradReviewRef.get().then((review) {
                _review = TraditionReview.fromSnapshot(review);
              });
            }

            notifyListeners();
          });
        } else {
          notifyListeners();
        }
      });

      _host = false;
    }

    notifyListeners();
  }

  Future<TraditionReview> createReview() async {
    if (_review != null && _review.sessionRef == _session.docRef) {
      return _review;
    }

    _review = TraditionReview(_session.docRef, _tradition.docRef);
    await _review.update();
    _session.tradReviewRef = _review.docRef;
    await _session.update();
    notifyListeners();

    return _review;
  }
}
