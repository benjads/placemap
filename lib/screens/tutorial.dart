import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placemap/models/participant.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/models/tradition.dart';
import 'package:placemap/utils.dart';
import 'package:provider/provider.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/screens/activity_wrapper.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/screens/intro.dart';

class TutorialScreen extends StatefulWidget {
  static final finalDesc =
      "With that, you're all set! We hope you enjoy a mealtime full of fun and cultural surprises.";

  final Widget child;
  final VoidCallback nextFunction;
  final String next;
  final String nextText;

  TutorialScreen(
      {@required this.next,
      this.nextFunction,
      @required this.nextText,
      @required this.child});

  TutorialScreen.end()
      : next = null,
        nextFunction = null,
        nextText = null,
        child = null;

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  bool _loading = false;

  void setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  Future<void> markComplete(AppData appData) async {
    final Participant self = await appData.session.getSelf();
    self.tutorialComplete = true;
    self.update();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.next == null) {
      final appData = context.read<AppData>();
      markComplete(appData);

      return ActivityWrapper(
        child: IntroScreen(
          showTitle: false,
          loading: _loading,
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  TutorialScreen.finalDesc,
                  style: theme.textTheme.headline5,
                ),
                SizedBox(height: 15),
                FinishButton(setLoading),
              ],
            ),
          ),
        ),
      );
    }

    return ActivityWrapper(
      child: IntroScreen(
        showTitle: false,
        footer: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: PlacemapButton(
            onPressed: () {
              widget.nextFunction?.call();
              Navigator.popAndPushNamed(context, widget.next);
            },
            text: widget.nextText,
          ),
        ),
        content: widget.child,
      ),
    );
  }
}

class FinishButton extends StatelessWidget {
  final Function setLoading;

  FinishButton(this.setLoading);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppData appData = context.read<AppData>();
    final CollectionReference participants =
        appData.session.docRef.collection('participants');

    return StreamBuilder<QuerySnapshot>(
        stream: participants.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();

          final bool allReady = snapshot.data.docs.firstWhere(
                  (doc) =>
                      !Participant.fromSnapshot(doc, appData.session.docRef)
                          .tutorialComplete,
                  orElse: () => null) ==
              null;

          if (allReady) {
            return PlacemapButton(
                onPressed: () {
                  setLoading(true);
                  PlacemapUtils.firestoreOp(Scaffold.of(context).widget.key,
                      () async {
                    appData.session.tradRef =
                        (await Tradition.random(appData)).docRef;
                    appData.session.setState(SessionState.trad);
                    await appData.session.update();
                  }, null);
                },
                text: "Let's Go!");
          } else {
            return Text(
              'Please wait for others to finish the tutorial...',
              style: theme.textTheme.bodyText1,
            );
          }
        });
  }
}

class Tutorial1 extends StatelessWidget {
  static final desc =
      "Before we begin, we'd like to propose a social pact: can you commit to keeping this app open throughout the meal and therefore not use your phone for other purposes?";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TutorialScreen(
      next: '/tutorial/2',
      nextText: "Let's Try",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
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
      "You'll notice the circle on the top left of the screen. It signals the amount of active players; that is, the amount of players that have the PlaceMap app open and that, as such, are not using their phones for other purposes.";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppData appData = context.read<AppData>();

    return TutorialScreen(
      next: '/tutorial/3',
      nextFunction: () => appData.demoDecrease = true,
      nextText: "Got It",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Text(
          desc,
          style: theme.textTheme.headline5,
        ),
      ),
    );
  }
}

class Tutorial3 extends StatelessWidget {
  static final desc =
      "If someone closes the app to use another feature of their phone, the circle on the other people's screen will turn red. It will also reflect the decrease in the amount of active players.";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppData appData = context.read<AppData>();

    return TutorialScreen(
      next: '/tutorial/4',
      nextFunction: () {
        appData.demoRecallMenu = true;
      },
      nextText: "I See",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Text(
          desc,
          style: theme.textTheme.headline5,
        ),
      ),
    );
  }
}

class Tutorial4 extends StatelessWidget {
  static final desc =
      "When that happens, a pop-up will open, giving you an opportunity to persuade that person to return to the experience.";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppData appData = context.read<AppData>();

    return TutorialScreen(
      next: '/tutorial/5',
      nextFunction: () {
        appData.demoRecallMenu = false;
        appData.demoDecrease = false;
        appData.demoRecallPopup = true;
      },
      nextText: "Got It",
      child: Padding(
        padding: const EdgeInsets.only(right: 50, left: 50, top: 50),
        child: Text(
          desc,
          style: theme.textTheme.headline5,
        ),
      ),
    );
  }
}

class Tutorial5 extends StatelessWidget {
  static final desc =
      "The person who broke the social pact will then receive a push notification with a meme. It will remind them that they shouldn't isolate themselves from the shared experience.";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppData appData = context.read<AppData>();

    return TutorialScreen(
      next: '/tutorial/6',
      nextFunction: () {
        appData.demoRecallPopup = false;
      },
      nextText: "Okay",
      child: Container(
        padding:
            const EdgeInsets.only(top: 200, right: 50, bottom: 0, left: 50),
        child: Text(
          desc,
          style: theme.textTheme.headline6,
        ),
      ),
    );
  }
}

class Tutorial6 extends StatelessWidget {
  static final desc =
      "This activity involves sound, so please turn your device's volume up. If at any point you'd like to mute yourself, tap the speaker icon on the top-right of the screen.";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TutorialScreen(
      next: '/tutorial/7',
      nextText: "Okay",
      child:  Padding(
        padding: const EdgeInsets.only(right: 50, left: 50, top: 50),
        child: Text(
          desc,
          style: theme.textTheme.headline5,
        ),
      ),
    );
  }
}

class Tutorial7 extends StatelessWidget {
  static final desc =
      "So before we start playing with our collection of playful food traditions from allover the world, we need you to allow PlaceMap to send your push notifications.";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TutorialScreen(
      next: '/tutorial/end',
      nextFunction: () async {
        // var status = await Permission.notification.status;
        // if (status.isUndetermined || status.isDenied) {
        //   Permission.notification.request();
        // } else if (await Permission.notification.isPermanentlyDenied) {
        //   openAppSettings();
        // }

        PlacemapUtils.initializeNotifications();
      },
      nextText: "Done",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Text(
          desc,
          style: theme.textTheme.headline5,
        ),
      ),
    );
  }
}
