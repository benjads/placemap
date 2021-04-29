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
  StreamSubscription _sessionSub;

  bool _host = false;

  bool dirtyScreen = false;
  bool routeChange = false;
  bool _recallAck = false;
  bool _selfDistracted = false;

  bool _demoDecrease = false;
  bool _demoRecallMenu = false;
  bool _demoRecallPopup = false;

  Tradition _tradition;
  TraditionReview _review;
  bool cachedAssets = false;

  Session get session => _session;
  String get sessionId => _sessionId;
  bool get host => _host;
  Tradition get tradition => _tradition;
  TraditionReview get review => _review;
  bool get recallAck => _recallAck;
  bool get selfDistracted => _selfDistracted;
  bool get demoRecallPopup => _demoRecallPopup;
  bool get demoRecallMenu => _demoRecallMenu;
  bool get demoDecrease => _demoDecrease;

  set recallAck(bool acknowledged) {
    _recallAck = acknowledged;
    notifyListeners();
  }

  set selfDistracted(bool distracted) {
    _selfDistracted = distracted;
    notifyListeners();
  }

  set demoDecrease(bool demoDecrease) {
    _demoDecrease = demoDecrease;
    notifyListeners();
  }

  set demoRecallMenu(bool demoRecallMenu) {
    _demoRecallMenu = demoRecallMenu;
    notifyListeners();
  }

  set demoRecallPopup(bool demoRecallPopup) {
    _demoRecallPopup = demoRecallPopup;
    notifyListeners();
  }

  Future<Session> createSession() async {
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

    await setSessionId(_sessionId);
    _host = true;
    notifyListeners();

    return _session;
  }

  Future<void> destroySession() async {
    assert(_session != null);

    await _sessionSub?.cancel();
    await _session.docRef.delete();
    _session = null;
    _sessionId = null;
    _sessionSub = null;
    _review = null;
    _host = false;
    notifyListeners();
  }

  Future<void> setSessionId(String sessionId) async {
    log('Changing app session to: $sessionId');
    _sessionId = sessionId;
    _sessionSub?.cancel();

    if (_sessionId != null) {
      _host = false;

      final Stream<DocumentSnapshot> sessionStream = FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .snapshots();

      await _updateSession(await sessionStream.first);
      _sessionSub = sessionStream.listen((doc) {
        _updateSession(doc);
      });
    }

    notifyListeners();
  }

  Future<void> _updateSession(DocumentSnapshot doc) async {
    log('An updated Placemap session ($_sessionId) was received by the remote');
    final newSession = Session.fromSnapshot(doc);
    final oldState = _session?.state;

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

    if (oldState != null && (_session.state != oldState || routeChange)) {
      dirtyScreen = true;
      routeChange = false;
    }

    if (_session.distractedCount() > 0) {
      final self = await _session.getSelf();
      if (self.distracted && _session.recallMsg != null) {
        PlacemapUtils.showNotification('Hey, come back!', _session.recallMsg);
      }
    } else {
      recallAck = false;
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
