import 'package:flutter/material.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/screens/intro.dart';
import 'package:provider/provider.dart';

class JoinScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroScreen(
      showTitle: false,
      footer: null,
      footerPadding: false,
      content: Padding(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CreateSection(),
            DividerText(text: 'or'),
            ExistingSection(),
          ],
        ),
      ),
    );
  }
}

class CreateSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appData = context.read<AppData>();

    return StreamBuilder(
      stream: appData.getOrCreateSession().asStream(),
      builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final Session session = snapshot.data;

        return Column(
          children: [
            Text(
              'SHARE THIS CODE',
              style: theme.textTheme.headline4,
            ),
            SizedBox(height: 10),
            Text(
              session.id,
              style: theme.textTheme.headline2
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ParticipantBubbles(),
            SizedBox(height: 10),
            Text(
              'AND PRESS',
              style: theme.textTheme.headline5,
            ),
            SizedBox(height: 10),
            PlacemapButton(
                onPressed: () {
                  appData.session.setState(SessionState.tutorial, true);
                  Navigator.popAndPushNamed(context, '/tutorial/1');
                },
                text: "WE'RE READY"),
          ],
        );
      },
    );
  }
}

class ExistingSection extends StatefulWidget {
  @override
  _ExistingSectionState createState() => _ExistingSectionState();
}

class _ExistingSectionState extends State<ExistingSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();

  void _submit() async {
    final id = _idController.value.text.toUpperCase();
    final Session session = await Session.load(id);

    if (session == null) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Cannot find room for $id')));
      return;
    }

    await session.addSelf();

    final appData = context.read<AppData>();
    appData.sessionId = id;

    Navigator.pushNamed(context, '/join/wait');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: TextFormField(
              controller: _idController,
              decoration: InputDecoration(
                hintText: 'enter a code here',
                filled: true,
                fillColor: theme.colorScheme.onPrimary,
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: theme.colorScheme.primaryVariant)),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a game code.';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: PlacemapButton(
              onPressed: () {
                if (_formKey.currentState.validate()) _submit();
              },
              text: 'Join another room',
            ),
          )
        ],
      ),
    );
  }
}
