import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/screens/intro.dart';
import 'package:provider/provider.dart';

class WaitScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntroScreen(
      showTitle: false,
      footer: null,
      content: Consumer<AppData>(builder: (context, appData, _) {
        log('Building Wait Screen for ${appData.sessionId}');
        if (appData.session.state != SessionState.waiting) {
          Future.microtask(() =>
              Navigator.popAndPushNamed(context, appData.session.state.route));
        }

        return Padding(
          padding: EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Text(
                appData.sessionId,
                style: theme.textTheme.headline2
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ParticipantBubbles(),
              SizedBox(height: 30),
              Text(
                'Please wait for the host to start the mealtime experience...',
                style: theme.textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60),
              Text(
                'Alternatively, you can leave this room',
                style: theme.textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              PlacemapButton(
                  onPressed: () async {
                    await appData.session.removeSelf();
                    await appData.createSession();
                    Navigator.popAndPushNamed(context, '/join');
                  },
                  text: 'LEAVE ROOM'),
            ],
          ),
        );
      }),
    );
  }
}
