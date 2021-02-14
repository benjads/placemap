import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placemap/model/session.dart';
import 'package:placemap/repo/session_repo.dart';
import 'package:placemap/view/common/activity_wrapper.dart';
import 'package:placemap/view/common/common.dart';
import 'package:placemap/view/common/intro.dart';

class TutorialScreen extends StatelessWidget {
  static final finalDesc =
      "With that, you're all set! We hope you enjoy a mealtime full of fun and cultural surprises.";

  final DocumentReference sessionRef;
  final Widget child;
  final Widget next;
  final String nextText;

  TutorialScreen(
      {@required this.sessionRef,
      @required this.next,
      @required this.nextText,
      @required this.child});

  TutorialScreen.end(this.sessionRef)
      : next = null,
        nextText = null,
        child = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (next == null) {
      return ActivityWrapper(
        sessionRef: sessionRef,
        child: IntroScreen(
          showTitle: false,
          content: Padding(
            padding: const EdgeInsets.only(
              top: 120,
              left: 50,
              right: 50,
            ),
            child: Column(
              children: [
                Text(
                  finalDesc,
                  style: theme.textTheme.headline5,
                ),
                SizedBox(height: 15),
                PlacemapButton(
                  onPressed: null,
                  text: "Let's Go",
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ActivityWrapper(
      sessionRef: sessionRef,
      child: IntroScreen(
        showTitle: false,
        footer: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: PlacemapButton(
            onPressed: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => next,
                      transitionDuration: Duration(seconds: 0)));
            },
            text: nextText,
          ),
        ),
        content: child,
      ),
    );
  }
}

class FinishButton extends StatefulWidget {
  final Session session;

  FinishButton(this.session);

  @override
  _FinishButtonState createState() => _FinishButtonState();
}

class _FinishButtonState extends State<FinishButton> {
  @override
  void initState() {
    super.initState();
    SessionRepo()
        .self(widget.session)
        .then((participant) => participant.tutorialComplete = true);
    SessionRepo().updateSession(widget.session);
  }

  bool _isReady() {
    return widget.session.participants.firstWhere(
            (participant) => !participant.tutorialComplete,
            orElse: () => null) ==
        null;
  }

  void _finishTutorial() {
    widget.session.state = SessionState.showingTrad;
    SessionRepo().updateSession(widget.session);
    Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                IntroScreen(content: null),
            transitionDuration: Duration(seconds: 0)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isReady()) {
      return PlacemapButton(onPressed: _finishTutorial, text: "Let's Go!");
    } else {
      return Text(
        'Please wait for others to finish the tutorial...',
        style: theme.textTheme.bodyText1,
      );
    }
  }
}

class Tutorial1 extends StatelessWidget {
  static final desc =
      "Before we begin, we'd like to proposal a social pact: can you commit to keeping this app open throughout the meal and therefore not use your phone for other purposes?";

  final DocumentReference sessionRef;

  Tutorial1(this.sessionRef);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TutorialScreen(
      sessionRef: sessionRef,
      next: Tutorial2(sessionRef),
      nextText: "Let's Try",
      child: Padding(
        padding: const EdgeInsets.only(
          top: 120,
          left: 50,
          right: 50,
        ),
        child: Text(
          desc,
          style: theme.textTheme.headline5,
        ),
      ),
    );
  }
}

class Tutorial2 extends StatelessWidget {
  static final desc =
      "You'll notice the circle on the top left of the screen. It signals the amount of activate players; that is, the amount of players that have the Placemap app open and that, as such, are not using their phones for other purposes.";

  final DocumentReference sessionRef;

  Tutorial2(this.sessionRef);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TutorialScreen(
      sessionRef: sessionRef,
      next: TutorialScreen.end(sessionRef),
      nextText: "Got It",
      child: Padding(
        padding: const EdgeInsets.only(
          top: 120,
          left: 50,
          right: 50,
        ),
        child: Text(
          desc,
          style: theme.textTheme.headline5,
        ),
      ),
    );
  }
}
