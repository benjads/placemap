import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:placemap/model/session.dart';

class CreateScreen extends StatefulWidget {
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  bool host = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<Session>(
      builder: (context, session, child) {
        if (session == null) {
          return CircularProgressIndicator();
        }

        return Container(
          padding: EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Text(
                'Share this code'.toUpperCase(),
                style: theme.textTheme.headline4,
              ),
              SizedBox(height: 10),
              Text(
                session.id,
                style: theme.textTheme.headline2
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
