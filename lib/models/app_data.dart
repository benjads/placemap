import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placemap/models/participant.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/utils.dart';

class AppData extends ChangeNotifier {
  String _sessionId;
  Session _session;
  StreamSubscription _sessionSub;
  bool _host = false;

  Session get session => _session;
  String get sessionId => _sessionId;
  bool get host => _host;

  Future<Session> getOrCreateSession() async {
    if (_session != null && _host)
      return _session;

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
        _session = Session.fromSnapshot(doc);

        notifyListeners();
      });

      _host = false;
    }

    notifyListeners();
  }
}
