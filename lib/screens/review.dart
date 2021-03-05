import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/tradition_review.dart';
import 'package:placemap/screens/activity_wrapper.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/screens/intro.dart';
import 'package:provider/provider.dart';

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _results = false;

  void submitVote() {
    setState(() {
      _results = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ActivityWrapper(
      child: IntroScreen(
        showTitle: false,
        footer: SizedBox.shrink(),
        content: _results ? ReviewResultsView() : ReviewSelectView(submitVote),
      ),
    );
  }
}

class ReviewSelectView extends StatelessWidget {
  final VoidCallback submitVote;

  ReviewSelectView(this.submitVote);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppData appData = context.read<AppData>();

    return Padding(
      padding: EdgeInsets.fromLTRB(40, 40, 40, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'PlaceMap',
            style: GoogleFonts.nanumBrushScript(
                textStyle: theme.textTheme.headline3),
          ),
          SizedBox(height: 30),
          Text(
            "CHOOSE A FACE THAT DESCRIBES HOW MUCH YOU "
            "LIKED \"${appData.tradition.name.toUpperCase()}\"",
            style: theme.textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          FaceSelect('😍', 5, null, submitVote),
          FaceSelect('😀', 4, null, submitVote),
          FaceSelect('🙄', 3, null, submitVote),
          FaceSelect('😵', 2, null, submitVote),
          FaceSelect('🤮', 1, null, submitVote),
        ],
      ),
    );
  }
}

class ReviewResultsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(40, 40, 40, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'PlaceMap',
            style: GoogleFonts.nanumBrushScript(
                textStyle: theme.textTheme.headline3),
          ),
          SizedBox(height: 30),
          Text(
            "HERE'S HOW THE REST OF THE GROUP LIKED IT. "
                "DO YOU AGREE?",
            style: theme.textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          PlacemapButton(onPressed: () {}, text: 'BACK TO SEARCH'),
          SizedBox(height: 30),
          ReviewResultsInner(),
        ],
      ),
    );
  }
}

class ReviewResultsInner extends StatefulWidget {
  @override
  _ReviewResultsInnerState createState() => _ReviewResultsInnerState();
}

class _ReviewResultsInnerState extends State<ReviewResultsInner> {
  TraditionReview _review;
  StreamSubscription<DocumentSnapshot> _sub;

  @override
  void initState() {
    super.initState();

    final AppData appData = context.read<AppData>();
    _sub = appData.review.docRef.snapshots().listen((snapshot) {
      setState(() {
        _review = TraditionReview.fromSnapshot(snapshot);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();
  }

  int count(int rating) {
    if (_review == null)
      return 0;

    return _review.ratingsMap()[rating];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            FaceSelect('😍', 5, count(5), null),
            FaceSelect('😀', 4, count(4), null),
            FaceSelect('🙄', 3, count(3), null),
            FaceSelect('😵', 2, count(2), null),
            FaceSelect('🤮', 1, count(1), null),
          ],
        ),
        RatingBar(_review?.avgRating() ?? 0),
      ],
    );
  }
}

class FaceSelect extends StatelessWidget {
  final String emoji;
  final int rating;
  final int count;
  final VoidCallback submit;

  FaceSelect(this.emoji, this.rating, this.count, this.submit);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: GestureDetector(
          onTap: () async {
            if (submit == null) return;

            final AppData appData = context.read<AppData>();
            await appData.review.addReview(rating);
            submit();
          },
          child: Stack(
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: 60),
              ),
              if (count != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Text(
                    count.toString(),
                    style: theme.textTheme.bodyText1,
                  ),
                )
            ],
          ),
        ));
  }
}

class RatingBar extends StatelessWidget {
  final avgRating;

  RatingBar(this.avgRating);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        height: 450,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 10,
              width: 150,
              color: Colors.white,
            ),
            AnimatedContainer(
              duration: Duration(seconds: 2),
              height: (avgRating / 5) * 400,
              width: 150,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.6),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
