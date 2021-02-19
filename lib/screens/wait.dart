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
        if (appData.session.state != SessionState.waiting) {
          Future.microtask(() => Navigator.popAndPushNamed(context, appData.session.state.route));
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
              SizedBox(height: 20),
              PlacemapButton(
                  onPressed: () => Navigator.pop(context), text: 'GO BACK'),
            ],
          ),
        );
      }),
    );
  }
}
