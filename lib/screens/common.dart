import 'package:flutter/material.dart';

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
