import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:placemap/view/common/common.dart';
import 'package:placemap/view/create.dart';

class LandingScreen extends StatefulWidget {
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _showTitle;
  Widget _child;

  @override
  void initState() {
    super.initState();
    _showTitle = true;
    _child = _landingButttons();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(top: 60),
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.primaryColor,
          Color.fromRGBO(5, 56, 79, 1),
        ],
      )),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_showTitle) _title(),
                _child,
                SizedBox(
                  height: 300,
                )
              ],
            ),
          ),
          Positioned(
            height: 500,
            bottom: -200,
            child: Image(
              image: AssetImage('graphics/globe.png'),
            ),
          )
        ],
      ),
    );
  }

  Widget _title() => Container(
        padding: EdgeInsets.only(top: 40),
        child: SizedBox(
          height: 80,
          child: Image(
            image: AssetImage('graphics/placemap_logo.png'),
          ),
        ),
      );

  void _back() {
    setState(() {
      _child = _landingButttons();
    });
  }

  void _onStart() {
    setState(() {
      _showTitle = false;
      _child = CreateScreen();
    });
  }

  void _onAbout() {
    setState(() {
      _child = AboutScreen(_back);
    });
  }

  Widget _landingButttons() => Column(
        children: [
          PlacemapButton(onPressed: _onStart, text: 'Start'),
          SizedBox(height: 30),
          PlacemapButton(onPressed: _onAbout, text: 'About'),
        ],
      );
}

class AboutScreen extends StatelessWidget {
  static const desc = "PlaceMap is an app designed to support playful and social interaction at mealtime. It was designed by a team of researchers at UC Santa Cruz. If you'd like to know more about the project, please reach out to faltarri@ucsc.edu";

  final VoidCallback back;

  AboutScreen(this.back);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          child: Text(
            desc,
            style: theme.textTheme.bodyText1,
            textAlign: TextAlign.center,
          ),
        ),
        PlacemapButton(onPressed: back, text: 'Back'),
      ],
    );
  }
}
