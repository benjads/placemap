import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:placemap/view/common/common.dart';

class LandingScreen extends StatefulWidget {
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool showTitle;
  Widget child;

  @override
  void initState() {
    super.initState();
    showTitle = true;
    child = _landingButttons();
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
                if (showTitle) _title(),
                child,
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

  Widget _landingButttons() => Column(
        children: [
          PlacemapButton(onPressed: () => {}, text: 'Start'),
          SizedBox(
            height: 30,
          ),
          PlacemapButton(onPressed: () => {}, text: 'About'),
        ],
      );
}
