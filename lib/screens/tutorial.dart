import 'package:flutter/material.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/models/tradition.dart';
import 'package:provider/provider.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/screens/activity_wrapper.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/screens/intro.dart';

class TutorialScreen extends StatelessWidget {
  static final finalDesc =
      "With that, you're all set! We hope you enjoy a mealtime full of fun and cultural surprises.";

  final Widget child;
  final String next;
  final String nextText;

  TutorialScreen(
      {@required this.next, @required this.nextText, @required this.child});

  TutorialScreen.end()
      : next = null,
        nextText = null,
        child = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (next == null) {
      final appData = context.read<AppData>();
      appData.session.setSelfTutorial(true);

      return ActivityWrapper(
        child: IntroScreen(
          showTitle: false,
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  finalDesc,
                  style: theme.textTheme.headline5,
                ),
                SizedBox(height: 15),
                FinishButton(),
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
            onPressed: () => Navigator.pushNamed(context, next),
            text: nextText,
          ),
        ),
        content: child,
      ),
    );
  }
}

class FinishButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AppData>(
      builder: (context, appData, _) {
        if (appData.session.ready()) {
          return PlacemapButton(
              onPressed: () async {
                appData.session.tradRef =
                    (await Tradition.random(appData)).docRef;
                appData.session.setState(SessionState.trad, true);
              },
              text: "Let's Go!");
        } else {
          return Text(
            'Please wait for others to finish the tutorial...',
            style: theme.textTheme.bodyText1,
          );
        }
      },
    );
  }
}

class Tutorial1 extends StatelessWidget {
  static final desc =
      "Before we begin, we'd like to proposal a social pact: can you commit to keeping this app open throughout the meal and therefore not use your phone for other purposes?";

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
      "You'll notice the circle on the top left of the screen. It signals the amount of activate players; that is, the amount of players that have the Placemap app open and that, as such, are not using their phones for other purposes.";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TutorialScreen(
      next: '/tutorial/end',
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
