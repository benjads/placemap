import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/participant.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/screens/activity_wrapper.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/screens/intro.dart';
import 'package:placemap/utils.dart';
import 'package:provider/provider.dart';

class ExitScreen extends StatefulWidget {
  static const exitMsg =
      'This is a group experience, so all the party should be OK with ending it. '
      'Let’s wait for everyone to decide.';

  static const codeMsg = 'As a reminder, your session code was:';

  @override
  _ExitScreenState createState() => _ExitScreenState();
}

class _ExitScreenState extends State<ExitScreen> {
  bool _loading = false;

  void setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppData appData = context.read<AppData>();

    return ActivityWrapper(
      child: IntroScreen(
        showTitle: false,
        simpleLogo: true,
        footer: SizedBox.shrink(),
        footerPadding: false,
        loading: _loading,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                ExitScreen.exitMsg,
                style: theme.textTheme.headline5,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding:  const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                ExitScreen.codeMsg,
                style: theme.textTheme.headline5,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            Text(
              appData.session.id,
              style: theme.textTheme.headline2
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ReturnButton(setLoading),
            ExitButton()
          ],
        ),
      ),
    );
  }
}

class ReturnButton extends StatelessWidget {
  final Function setLoading;

  ReturnButton(this.setLoading);

  Future<void> back(BuildContext context, AppData appData) async {
    PlacemapUtils.firestoreOp(Scaffold.of(context).widget.key, () async {
      appData.clearReview();
      final Participant self = await appData.session.getSelf();
      self.quit = false;
      await self.update();
      appData.routeChange = true;
      appData.session.setState(SessionState.search);
      await appData.session.update();
    }, null);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, _) {
        if (appData.session.state == SessionState.ended) {
          return SizedBox.shrink();
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: PlacemapButton(
                onPressed: () => back(context, appData), text: 'Go Back'),
          );
        }
      },
    );
  }
}

class ExitButton extends StatelessWidget {
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

          final bool allQuit = snapshot.data.docs.firstWhere(
                  (doc) =>
                      !Participant.fromSnapshot(doc, appData.session.docRef)
                          .quit,
                  orElse: () => null) ==
              null;

          if (allQuit) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: PlacemapButton(
                  onPressed: () async {
                    final AppData appData = context.read<AppData>();
                    appData.session.setState(SessionState.ended);
                    appData.session.setEndTime();
                    await appData.session.update();
                    Future.microtask(() => RestartWidget.restartApp(context));
                  },
                  text: 'Exit'),
            );
          } else {
            return Text(
              'Waiting for others to exit...',
              style: theme.textTheme.bodyText1,
            );
          }
        });
  }
}
