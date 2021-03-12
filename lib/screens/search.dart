import 'dart:developer';

import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    final AppData appData = context.read<AppData>();

    return ActivityWrapper(
      child: IntroScreen(
        showTitle: false,
        footer: SizedBox.shrink(),
        content: Padding(
          padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LogoText(),
              SizedBox(height: 30),
              if (appData.review != null)
                Text(
                  'Results for "${appData.review.nextKeyword}"',
                  style: theme.textTheme.headline4,
                  textAlign: TextAlign.center,
                ),
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

class _SearchResultState extends State<SearchResult> {
  bool _cached = false;

  @override
  void initState() {
    super.initState();
    widget.tradition.cacheImages(context, true).whenComplete(() {
      setState(() {
        _cached = true;
      });
    });
  }

  void _select() {
    final appData = context.read<AppData>();
    appData.routeChange = true;
    appData.clearReview();
    appData.session.setState(SessionState.trad, false);
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
          height: 160,
          child: AnimatedOpacity(
            opacity: _cached ? 1 : 0,
            duration: Duration(seconds: 2),
            child: Container(
              decoration: _cached
                  ? BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.6), BlendMode.dstATop),
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
                        style:
                            theme.textTheme.headline4.copyWith(color: Colors.white),
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
                        style:
                            theme.textTheme.headline6.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
