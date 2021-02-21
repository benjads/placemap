import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/screens/activity_wrapper.dart';
import 'package:placemap/screens/common.dart';
import 'package:provider/provider.dart';

class TraditionView extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ActivityWrapper(
        child: Stack(
          children: [
            Positioned.fill(child: TraditionContent()),
            Positioned(
              top: 80,
              right: 40,
              child: Icon(
                Icons.volume_up_sharp,
                size: 40,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TraditionContent extends StatefulWidget {
  @override
  _TraditionContentState createState() => _TraditionContentState();
}

enum TraditionState { overview, extended, post }

class _TraditionContentState extends State<TraditionContent> {
  TraditionState _traditionState = TraditionState.overview;

  void openExtended() {
    setState(() {
      _traditionState = TraditionState.extended;
    });
  }

  void end() {
    setState(() {
      _traditionState = TraditionState.post;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_traditionState) {
      case TraditionState.overview:
        return TraditionOverview(openExtended, end);
      case TraditionState.extended:
        return TraditionExtended(end);
      case TraditionState.post:
      default:
        return Container(child: null);
    }
  }
}

class TraditionOverview extends StatelessWidget {
  final VoidCallback openExtended;
  final VoidCallback end;

  TraditionOverview(this.openExtended, this.end);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppData appData = context.read<AppData>();

    return Container(
      padding: EdgeInsets.only(top: 80),
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage('graphics/cincin.jpg'),
        fit: BoxFit.cover,
      )),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            child: Column(
              children: [
                Text(
                  appData.tradition.name,
                  style:
                      theme.textTheme.headline3.copyWith(color: Colors.white),
                ),
                SizedBox(height: 10),
                Text('(${appData.tradition.origin})',
                    style: theme.textTheme.headline6.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlacemapButton(onPressed: openExtended, text: 'LEARN MORE'),
                SizedBox(width: 10),
                PlacemapButton(onPressed: end, text: 'GOT IT!'),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class TraditionExtended extends StatelessWidget {
  final VoidCallback end;

  TraditionExtended(this.end);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppData appData = context.read<AppData>();

    return Container(
        padding: EdgeInsets.only(top: 80),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.colorScheme.primary, theme.colorScheme.primaryVariant],
        )),
        child: Column(
          children: [
            Text(appData.tradition.name,
                style: theme.textTheme.headline3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(appData.tradition.fullDesc,
                  style: theme.textTheme.bodyText1),
            ),
            SizedBox(height: 20),
            PlacemapButton(onPressed: end, text: 'GOT IT!'),
          ],
        ));
  }
}
