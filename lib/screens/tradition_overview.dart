import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/preferences.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/models/tradition.dart';
import 'package:placemap/screens/activity_wrapper.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/speech_service.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TraditionView extends StatefulWidget {
  @override
  _TraditionViewState createState() => _TraditionViewState();
}

class _TraditionViewState extends State<TraditionView> {
  bool _cached = false;

  @override
  void initState() {
    super.initState();
    final SpeechService speechService = context.read<SpeechService>();
    final AppData appData = context.read<AppData>();
    final Preferences prefs = context.read<Preferences>();
    appData.tradition.cacheImages(context, true).whenComplete(() {
      setState(() {
        _cached = true;
      });

      if (prefs.sound && appData.tradition.ttsDesc != null)
        speechService.speak(appData.tradition.ttsDesc);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_cached) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: ActivityWrapper(
          child: Stack(
            children: [
              Positioned.fill(child: TraditionContent()),
              Positioned(top: 50, right: 30, child: TtsButton()),
            ],
          ),
        ),
      ),
    );
  }
}

class TtsButton extends StatefulWidget {
  @override
  _TtsButtonState createState() => _TtsButtonState();
}

class _TtsButtonState extends State<TtsButton> {
  void _soundTap() {
    final SpeechService speechService = context.read<SpeechService>();
    final AppData appData = context.read<AppData>();
    final Preferences prefs = context.read<Preferences>();

    setState(() {
      if (speechService.playing) {
        speechService.stop();
        prefs.sound = false;
      } else {
        if (prefs.sound) {
          if (appData.tradition.ttsDesc != null) {
            speechService.speak(appData.tradition.ttsDesc);
          }
        } else
          prefs.sound = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Preferences prefs = context.read<Preferences>();

    return GestureDetector(
      onTap: _soundTap,
      child: Icon(
        prefs.sound ? Icons.volume_up_sharp : Icons.volume_off,
        size: 40,
        color: prefs.sound ? Colors.white : Colors.red,
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
  SpeechService speechService;

  @override
  void initState() {
    super.initState();
    speechService = context.read<SpeechService>();
  }

  void _openExtended() {
    setState(() {
      _traditionState = TraditionState.extended;
    });
  }

  void _end() {
    speechService.stop();
    setState(() {
      _traditionState = TraditionState.post;
    });
  }

  void _navigate(SessionState newState) async {
    final AppData appData = context.read<AppData>();
    await appData.createReview();
    appData.routeChange = true;
    appData.session.setState(newState, true);
  }

  void _review() {
    _navigate(SessionState.review);
  }

  void _search() {
    _navigate(SessionState.search);
  }

  void _pause() {
    _navigate(SessionState.pause);
  }

  @override
  Widget build(BuildContext context) {
    switch (_traditionState) {
      case TraditionState.overview:
        return TraditionOverview(_openExtended, _end);
      case TraditionState.extended:
        return TraditionExtended(_end);
      case TraditionState.post:
        return TraditionPost(_review, _search, _pause);
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
          image: appData.tradition.cachedCoverImg.image,
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 240,
                  child: StrokeText(
                    appData.tradition.name,
                    style: theme.textTheme.headline3,
                    color: Colors.white,
                    strokeColor: theme.colorScheme.primaryVariant,
                    strokeWidth: 1,
                  ),
                ),
                SizedBox(height: 10),
                StrokeText(
                  '(${appData.tradition.origin})',
                  style: theme.textTheme.headline6,
                  color: Colors.white,
                  strokeColor: theme.colorScheme.primaryVariant,
                  strokeWidth: 1,
                ),
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
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                alignment: Alignment.center,
                width: 240,
                child: Text(
                  appData.tradition.name,
                  style: theme.textTheme.headline4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    TraditionMedia(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                      child: Text(appData.tradition.fullDesc,
                          style: theme.textTheme.bodyText1.copyWith(fontSize: 20, height: 1.5)
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: PlacemapButton(onPressed: end, text: 'GOT IT!'),
          ),
        ],
      ),
    );
  }
}

class TraditionMedia extends StatefulWidget {
  @override
  _TraditionMediaState createState() => _TraditionMediaState();
}

class _TraditionMediaState extends State<TraditionMedia> {
  YoutubePlayerController _ytController;

  List<Widget> _generateMedia(Tradition tradition) {
    final media = List<Widget>();

    if (tradition.videoUri != null) {
      _ytController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(tradition.videoUri),
        flags: YoutubePlayerFlags(
          autoPlay: false,
          disableDragSeek: true,
          mute: false,
          enableCaption: false,
        ),
      );

      media.add(YoutubePlayer(
        controller: _ytController,
        showVideoProgressIndicator: true,
        bottomActions: [
          const SizedBox(width: 14),
          CurrentPosition(),
          const SizedBox(width: 8),
          ProgressBar(
            isExpanded: true,
          ),
          RemainingDuration(),
        ],
      ));
    }

    if (tradition.photos != null) {
      tradition.cachedPhotos.forEach((url, image) {
        media.add(Image(
          image: image.image,
        ));
      });
    }

    return media;
  }

  @override
  Widget build(BuildContext context) {
    final AppData appData = context.read<AppData>();

    final items = _generateMedia(appData.tradition);

    if (items.isEmpty) return SizedBox.shrink();

    return CarouselSlider(
      options: CarouselOptions(
          enableInfiniteScroll: items.length != 1,
          height: 200,
          onPageChanged: (idx, _) {
            if (_ytController != null && _ytController.value.isPlaying)
              _ytController.pause();
          }),
      items: _generateMedia(appData.tradition),
    );
  }
}

class TraditionPost extends StatelessWidget {
  final VoidCallback review;
  final VoidCallback search;
  final VoidCallback pause;

  TraditionPost(this.review, this.search, this.pause);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppData appData = context.read<AppData>();

    return Container(
        padding: EdgeInsets.only(top: 50),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: appData.tradition.cachedCoverImg.image,
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
          padding: EdgeInsets.symmetric(horizontal: 30),
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
                'TRY IT OUT!',
                style: theme.textTheme.headline3
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Text(
                'WHEN YOU FEEL YOU WANT TO',
                style: theme.textTheme.bodyText1,
              ),
              SizedBox(height: 10),
              PlacemapButton(onPressed: search, text: 'SEARCH AGAIN'),
              SizedBox(height: 10),
              Text(
                'PRESS THIS BUTTON TO FIND SIMILAR TRADITIONS, YOU CAN ALSO',
                style: theme.textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              PlacemapButton(onPressed: pause, text: 'TAKE A BREAK'),
              SizedBox(height: 10),
              Text(
                'AND DO ANOTHER SEARCH LATER',
                style: theme.textTheme.bodyText1,
              ),
              SizedBox(height: 30),
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
