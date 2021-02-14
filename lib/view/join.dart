import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placemap/model/session.dart';
import 'package:placemap/repo/session_repo.dart';
import 'package:placemap/view/common/common.dart';
import 'package:placemap/view/common/intro.dart';
import 'package:placemap/view/tutorial.dart';

class JoinScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntroScreen(
      showTitle: false,
      footer: null,
      content: Container(
        padding: EdgeInsets.only(top: 40),
        child: Column(
          children: [
            CreateSection(),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Divider(
                      thickness: 2,
                      color: Color.fromRGBO(163, 237, 244, 1),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'or',
                        style: theme.textTheme.bodyText1,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Divider(
                      thickness: 2,
                      color: Color.fromRGBO(163, 237, 244, 1),
                    ),
                  )
                ],
              ),
            ),
            ExistingSection(),
          ],
        ),
      ),
    );
  }
}

class CreateSection extends StatefulWidget {
  @override
  _CreateSectionState createState() => _CreateSectionState();
}

class _CreateSectionState extends State<CreateSection> {
  Session _session;
  StreamSubscription<DocumentSnapshot> _sub;
  bool _retain;

  @override
  void initState() {
    super.initState();
    _retain = false;

    SessionRepo().createSession().then((session) => {
          setState(() {
            _session = session;

            _sub = _session.docRef.snapshots().listen((snapshot) {
              setState(() {
                _session = Session.fromSnapshot(snapshot);
              });
            });
          })
        });
  }

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();

    if (!_retain) {
      SessionRepo().destroySession(_session);
      // TODO: Host closes app
    }
  }

  void _start() {
    _retain = true;
    _session.state = SessionState.tutorial;
    SessionRepo().updateSession(_session);
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                Tutorial1(_session.docRef),
            transitionDuration: Duration(seconds: 0)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_session == null) {
      return CircularProgressIndicator();
    }

    return Column(
      children: [
        Text(
          'SHARE THIS CODE',
          style: theme.textTheme.headline4,
        ),
        SizedBox(height: 10),
        Text(
          _session.id,
          style:
              theme.textTheme.headline2.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        participantBubbles(theme, _session),
        SizedBox(height: 20),
        Text(
          'AND PRESS',
          style: theme.textTheme.headline4,
        ),
        SizedBox(height: 10),
        PlacemapButton(onPressed: _start, text: "WE'RE READY!"),
      ],
    );
  }
}

class ExistingSection extends StatefulWidget {
  @override
  _ExistingSectionState createState() => _ExistingSectionState();
}

class _ExistingSectionState extends State<ExistingSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController idController = TextEditingController();

  void _join() async {
    final id = idController.value.text.toUpperCase();

    if (!await SessionRepo().sessionExists(id)) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Cannot find game for $id')));
      return;
    }

    final Session session = await SessionRepo().getSession(id);
    if (await SessionRepo().self(session) == null) {
      await SessionRepo().addSelf(session);
    }

    Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                WaitScreen(session),
            transitionDuration: Duration(seconds: 0)));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: TextFormField(
              controller: idController,
              decoration: InputDecoration(
                hintText: 'enter a code here',
                filled: true,
                fillColor: Color.fromRGBO(169, 237, 244, 1),
                border: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(0, 113, 168, 1))),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a game code';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: PlacemapButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _join();
                }
              },
              text: 'Submit',
            ),
          ),
        ],
      ),
    );
  }
}

class WaitScreen extends StatefulWidget {
  final Session session;

  WaitScreen(this.session);

  @override
  _WaitScreenState createState() => _WaitScreenState(session);
}

class _WaitScreenState extends State<WaitScreen> {
  Session session;
  StreamSubscription<DocumentSnapshot> _sub;

  _WaitScreenState(this.session);

  @override
  void initState() {
    super.initState();
    _sub = session.docRef.snapshots().listen((snapshot) {
      setState(() {
        session = Session.fromSnapshot(snapshot);

        if (session.state != SessionState.waiting) {
          Navigator.pop(context);
          Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      Tutorial1(session.docRef),
                  transitionDuration: Duration(seconds: 0)));
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();
    SessionRepo().removeSelf(session);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntroScreen(
      showTitle: false,
      footer: null,
      content: Container(
        padding: EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Text(
              session.id,
              style: theme.textTheme.headline2
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            participantBubbles(theme, session),
            SizedBox(height: 20),
            PlacemapButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                text: "GO BACK"),
          ],
        ),
      ),
    );
  }
}

Widget participantBubbles(ThemeData theme, Session session) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 30),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: session.participants
          .asMap()
          .keys
          .map(
            (idx) => Padding(
              padding: EdgeInsets.only(right: 10),
              child: Material(
                shape: CircleBorder(),
                color: Color.fromRGBO(163, 237, 244, 1),
                child: Container(
                  height: 60.0,
                  width: 60.0,
                  child: Center(
                    child: Text(
                      idx == 0 ? 'You' : 'P${idx + 1}',
                      style: theme.textTheme.headline5
                          .copyWith(color: Color.fromRGBO(27, 20, 100, 1)),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    ),
  );
}
