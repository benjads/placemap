import 'package:flutter/material.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/screens/intro.dart';
import 'package:provider/provider.dart';

class JoinScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroScreen(
      showTitle: false,
      footer: null,
      content: Padding(
        padding: EdgeInsets.only(top: 40),
        child: Column(
          children: [
            CreateSection(),
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AppData>(
        builder: (context, appData, _) => StreamBuilder(
              stream: appData.createSession().asStream(),
              builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
                if (!snapshot.hasData) {
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
                      snapshot.data.id,
                      style: theme.textTheme.headline2
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ));
  }
}
