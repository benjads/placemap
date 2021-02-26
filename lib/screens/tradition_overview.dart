import 'package:flutter/material.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/screens/activity_wrapper.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/speech_service.dart';
import 'package:provider/provider.dart';

class TraditionView extends StatefulWidget {
  @override
  _TraditionViewState createState() => _TraditionViewState();
}

class _TraditionViewState extends State<TraditionView> {
  @override
  void initState() {
    super.initState();
    final SpeechService speechService = context.read<SpeechService>();
    final AppData appData = context.read<AppData>();
    speechService.speak(appData.tradition.ttsDesc);
  }

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

  void _openExtended() {
    setState(() {
      _traditionState = TraditionState.extended;
    });
  }

  void _end() {
    setState(() {
      _traditionState = TraditionState.post;
    });
  }

  void _review() {
    final AppData appData = context.read<AppData>();
    appData.createReview();
    appData.session.state = SessionState.review;
    Navigator.popAndPushNamed(context, '/review');
  }

  @override
  Widget build(BuildContext context) {
    switch (_traditionState) {
      case TraditionState.overview:
        return TraditionOverview(_openExtended, _end);
      case TraditionState.extended:
        return TraditionExtended(_end);
      case TraditionState.post:
        return TraditionPost(_review);
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

class TraditionPost extends StatelessWidget {

  final VoidCallback review;

  TraditionPost(this.review);

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
            colorFilter: ColorFilter.mode(
                theme.colorScheme.primary.withOpacity(0.2), BlendMode.dstATop),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryVariant
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'NOW THAT YOU KNOW ALL ABOUT "${appData.tradition.name.toUpperCase()}", IT\'S TIME FOR YOU TO',
                style: theme.textTheme.headline5,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'TRY IT OUT',
                style: theme.textTheme.headline2
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              Text(
                'WHEN YOU FEEL YOU WANT TO',
                style: theme.textTheme.bodyText1,
              ),
              SizedBox(height: 10),
              PlacemapButton(onPressed: () {}, text: 'SEARCH AGAIN'),
              SizedBox(height: 10),
              Text(
                'PRESS THIS BUTTON TO FIND SIMILAR TRADITIONS, YOU CAN ALSO',
                style: theme.textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              PlacemapButton(onPressed: () {}, text: 'TAKE A BREAK'),
              SizedBox(height: 10),
              Text(
                'AND DO ANOTHER SEARCH LATER',
                style: theme.textTheme.bodyText1,
              ),
              SizedBox(height: 40),
              Text(
                'IF YOU WANT YOU CAN ALSO',
                style: theme.textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              PlacemapButton(onPressed: review, text: 'RATE THIS TRADITION'),
            ],
          ),
        ));
  }
}
