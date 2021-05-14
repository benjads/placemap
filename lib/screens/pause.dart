import 'package:flutter/material.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/participant.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/screens/activity_wrapper.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/screens/intro.dart';
import 'package:provider/provider.dart';

class PauseScreen extends StatelessWidget {
  static const readyMsg = 'Are you ready to learn a new play-food tradition?';

  Future<void> quit(BuildContext context) async {
    final AppData appData = context.read<AppData>();
    final Participant self = await appData.session.getSelf();
    self.quit = true;
    await self.update();
    Navigator.popAndPushNamed(context, '/exit');
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActivityWrapper(
      child: IntroScreen(
        showTitle: false,
        simpleLogo: true,
        footer: null,
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  readyMsg,
                  style: theme.textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 30),
              PlacemapButton(
                  onPressed: () {
                    final AppData appData = context.read<AppData>();
                    appData.clearReview();
                    appData.routeChange = true;
                    appData.session.setState(SessionState.search, true);
                  },
                  text: 'Get a Tradition'),
              DividerText(text: 'or'),
              PlacemapButton(
                  onPressed: () => quit(context),
                  text: 'End the Meal'),
            ],
          ),
        ),
      ),
    );
  }

}