import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  final bool showTitle;
  final Widget footer;
  final Widget content;

  const IntroScreen(
      {Key key, this.showTitle = true, this.footer, @required this.content})
      : super(key: key);

  Widget _title() => Container(
        padding: EdgeInsets.fromLTRB(0, 40, 0, 100),
        child: SizedBox(
          height: 80,
          child: Image(
            image: AssetImage('graphics/placemap_logo.png'),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        padding: EdgeInsets.only(top: 40),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryVariant
          ],
        )),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            footer == null
                ? Positioned(
                    height: 450,
                    bottom: -200,
                    child: Image(
                      image: AssetImage('graphics/globe.png'),
                    ),
                  )
                : Positioned(
                    bottom: 0,
                    child: footer,
                  ),
            Positioned.fill(
              child: Column(
                children: [if (showTitle) _title(), content],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
