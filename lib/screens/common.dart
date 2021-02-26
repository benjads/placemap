import 'package:flutter/material.dart';
import 'package:placemap/models/app_data.dart';
import 'package:provider/provider.dart';

class PlacemapButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const PlacemapButton({Key key, @required this.onPressed, @required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
        style: TextButton.styleFrom(
          primary: theme.textTheme.bodyText1.color,
          backgroundColor: theme.primaryColor,
          textStyle: theme.textTheme.headline4,
          shape: BeveledRectangleBorder(),
        ),
        onPressed: onPressed,
        child: Text(
          text.toUpperCase(),
          style: theme.textTheme.headline5,
          textAlign: TextAlign.center,
        ));
  }
}

class DividerText extends StatelessWidget {
  final String text;

  DividerText({Key key, @required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Divider(
              thickness: 2,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          Flexible(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              text,
              style: theme.textTheme.bodyText1,
            ),
          )),
          Flexible(
            child: Divider(
              thickness: 2,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class ParticipantBubbles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AppData>(
      builder: (context, appData, _) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 0; i < appData.session.participantCount; i++)
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Material(
                  shape: CircleBorder(),
                  color: theme.colorScheme.onPrimary,
                  child: Container(
                    height: 60,
                    width: 60,
                    child: Center(
                      child: Text(
                        i == 0 ? 'You' : 'P${i + 1}',
                        style: theme.textTheme.headline5
                            .copyWith(color: theme.colorScheme.primaryVariant),
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
