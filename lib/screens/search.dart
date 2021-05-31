import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/models/tradition.dart';
import 'package:placemap/screens/common.dart';
import 'package:provider/provider.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/screens/activity_wrapper.dart';
import 'package:placemap/screens/intro.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ActivityWrapper(
      child: IntroScreen(
        showTitle: false,
        simpleLogo: true,
        footer: SizedBox.shrink(),
        content: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SearchScreenInner(),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchScreenInner extends StatefulWidget {
  @override
  _SearchScreenInnerState createState() => _SearchScreenInnerState();
}

class _SearchScreenInnerState extends State<SearchScreenInner> {
  List<Tradition> _results;

  @override
  void initState() {
    super.initState();

    final appData = context.read<AppData>();
    Tradition.randomList(appData, 3, appData.review?.nextKeyword).then(
      (traditions) => setState(() {
        _results = traditions;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_results == null) {
      return CircularProgressIndicator();
    }

    final theme = Theme.of(context);
    if (_results.isEmpty)
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Wow!', style: theme.textTheme.headline2),
          SizedBox(height: 30),
          Text("Thanks for participating. If you'd like to redo the traditions, feel free to create a new room",
              style: theme.textTheme.headline5, textAlign: TextAlign.center),
          SizedBox(height: 20),
          PlacemapButton(
              onPressed: () async {
                final AppData appData = context.read<AppData>();
                appData.session.setState(SessionState.ended);
                await appData.session.update();
                SystemNavigator.pop();
                exit(0);
              },
              text: 'Exit'),
        ],
      );

    return Column(
      children: _results.map((result) => SearchResult(result)).toList(),
    );
  }
}

class SearchResult extends StatefulWidget {
  final Tradition tradition;

  SearchResult(this.tradition);

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult>
    with SingleTickerProviderStateMixin {
  bool _cached = false;

  AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animController.repeat(reverse: true);
    widget.tradition.cacheImages(context, true).whenComplete(() {
      if (!this.mounted)
        return;

      setState(() {
        _cached = true;
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _select() {
    final appData = context.read<AppData>();
    appData.routeChange = true;
    appData.clearReview();
    appData.session.setState(SessionState.trad);
    appData.session.tradRef = widget.tradition.docRef;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: _select,
        child: SizedBox(
          height: 150,
          child: Stack(
            children: [
              FadeTransition(
                opacity: _animController,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('graphics/globe_simple.png'),
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: _cached ? 1 : 0,
                duration: Duration(seconds: 2),
                child: Container(
                  decoration: _cached
                      ? BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: widget.tradition.cachedCoverImg.image))
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                          ),
                          padding: EdgeInsets.all(6),
                          child: Text(
                            widget.tradition.name.toUpperCase(),
                            style: theme.textTheme.headline5
                                .copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                          ),
                          padding: EdgeInsets.all(6),
                          child: Text(
                            '(${widget.tradition.origin})',
                            style: theme.textTheme.headline6
                                .copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
