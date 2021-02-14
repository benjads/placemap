import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placemap/model/session.dart';
import 'package:provider/provider.dart';

class ActivityWrapper extends StatefulWidget {
  final DocumentReference sessionRef;
  final Widget child;

  ActivityWrapper({@required this.sessionRef, @required this.child});

  @override
  _ActivityWrapperState createState() =>
      _ActivityWrapperState();
}

class _ActivityWrapperState extends State<ActivityWrapper> {

  Session _session;
  StreamSubscription<DocumentSnapshot> _sub;

  @override
  void initState() {
    super.initState();

    _sub = widget.sessionRef.snapshots().listen((session) {
      setState(() {
        _session = Session.fromSnapshot(session);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _sub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_session == null) {
      return CircularProgressIndicator();
    }

    return ChangeNotifierProvider.value(
      value: _session,
      child: Stack(
        children: [
          Positioned.fill(
            child: Navigator(
            ),
          ),
          Positioned(
            top: 80,
            left: 20,
            child: Material(
              shape: CircleBorder(),
              color: Color.fromRGBO(163, 237, 244, 1),
              child: Container(
                height: 60.0,
                width: 60.0,
                child: Center(
                  child: Text(
                    _session.participants.length.toString(),
                    style: theme.textTheme.headline5
                        .copyWith(color: Color.fromRGBO(27, 20, 100, 1)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


