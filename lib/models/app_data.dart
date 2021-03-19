import 'dart:async';
import 'dart:developer';

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
  bool routeChange = false;
  StreamSubscription _sessionSub;
  bool _host = false;
  Tradition _tradition;
  TraditionReview _review;
  bool cachedAssets = false;

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
    _setSessionId(sessionId);
  }

  void _setSessionId(String sessionId) async {
    _sessionId = sessionId;
    _sessionSub?.cancel();

    if (_sessionId != null) {
      _sessionSub = FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .snapshots()
          .listen((doc) async {
        log('An updated Placemap session was received by the remote');
        final newSession = Session.fromSnapshot(doc);
        final oldState = _session.state;

        _session = newSession;

        if (_session.tradRef != null) {
          final traditionSnapshot = await _session.tradRef.get();
          _tradition = Tradition.fromSnapshot(traditionSnapshot);

          if (_session.tradReviewRef != null) {
            final tradReviewSnapshot = await _session.tradReviewRef.get();
            _review = TraditionReview.fromSnapshot(tradReviewSnapshot);
          } else {
            clearReview();
          }
        }

        if (_session.state != oldState || routeChange) {
          dirtyScreen = true;
          routeChange = false;
        }

        notifyListeners();
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
    _review.nextKeyword = Tradition.randomKeyword(_tradition);
    await _review.update();
    _session.setTradReviewRef(_review.docRef, false);
    await _session.update();
    notifyListeners();

    return _review;
  }

  void clearReview() {
    _review = null;
    _session.setTradReviewRef(null, false);
  }
}
