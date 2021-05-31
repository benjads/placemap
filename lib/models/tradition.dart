import 'dart:developer';
import 'dart:math' show Random;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/tradition_review.dart';
import 'package:placemap/utils.dart';

class Tradition {
  final String name;
  final String origin;
  final String coverImg;
  String _cachedCoverUrl;
  Image _cachedCoverImg;
  final String ttsDesc;
  final String fullDesc;
  final String videoUri;
  String _cachedVideoUrl;
  final List<String> photos;
  Map<String, Image> _cachedPhotos;
  final List<String> keywords;
  final bool allowedFirst;
  final DocumentReference docRef;

  Tradition(
      {@required this.name,
      @required this.origin,
      @required this.coverImg,
      @required this.ttsDesc,
      @required this.fullDesc,
      @required this.videoUri,
      @required this.photos,
      @required this.keywords,
      @required this.allowedFirst,
      @required this.docRef});

  Tradition.fromSnapshot(DocumentSnapshot doc)
      : this.fromMap(doc.data(), docRef: doc.reference);

  Tradition.fromMap(Map<String, dynamic> map, {this.docRef})
      : assert(map['name'] != null),
        assert(map['origin'] != null),
        assert(map['coverImg'] != null),
        assert(map['fullDesc'] != null),
        assert(map['keywords'] != null),
        assert(map['allowedFirst'] != null),
        name = map['name'],
        origin = map['origin'],
        coverImg = map['coverImg'],
        ttsDesc = map['ttsDesc'],
        fullDesc = map['fullDesc'],
        videoUri = map['videoUri'],
        photos = map['photos'] != null
            ? PlacemapUtils.toStringList(map['photos'])
            : null,
        keywords = PlacemapUtils.toStringList(map['keywords']),
        allowedFirst = map['allowedFirst'];

  Future<void> cacheImages(BuildContext context, bool includePhotos) async {
    if (_cachedCoverImg == null) {
      _cachedCoverUrl = await FirebaseStorage.instance
          .ref('traditions/$coverImg')
          .getDownloadURL();
      _cachedCoverImg = Image.network(_cachedCoverUrl);
      await precacheImage(_cachedCoverImg.image, context);
    }

    if (photos != null && includePhotos && _cachedPhotos == null) {
      _cachedPhotos = Map<String, Image>();
      photos.forEach((photo) async {
        var photoUrl = await FirebaseStorage.instance
            .ref('traditions/$photo')
            .getDownloadURL();
        final photoImg = Image.network(photoUrl);
        _cachedPhotos[photoUrl] = photoImg;
        await precacheImage(photoImg.image, context);
      });
    }

    if (videoUri != null && _cachedVideoUrl == null) {
      _cachedVideoUrl = await FirebaseStorage.instance.ref('videos/$videoUri').getDownloadURL();
    }
  }


  String get cachedCoverUrl => _cachedCoverUrl;

  String get cachedVideoUrl => _cachedVideoUrl;

  Image get cachedCoverImg => _cachedCoverImg;

  Map<String, Image> get cachedPhotos => _cachedPhotos;

  @override
  bool operator ==(Object other) => other is Tradition && docRef.id == other.docRef.id;

  @override
  int get hashCode => docRef.id.hashCode;

  static Future<List<Tradition>> allTraditions() async {
    final traditionsSnapshot =
        await FirebaseFirestore.instance.collection('traditions').get();
    return traditionsSnapshot.docs
        .map((snapshot) => Tradition.fromSnapshot(snapshot))
        .toList();
  }

  static Future<Tradition> random(AppData appData) async {
    final List<Tradition> traditions = await allTraditions();
    final List<TraditionReview> reviews =
        await TraditionReview.allReviews(appData.session);

    final rng = Random();
    final isFirst = reviews.length == 0;

    var idx = rng.nextInt(traditions.length);
    var tradition = traditions[idx];
    while (reviews
            .map((review) => review.tradRef)
            .toList()
            .contains(tradition.docRef) ||
        (isFirst && !tradition.allowedFirst)) {
      idx = rng.nextInt(traditions.length);
      tradition = traditions[idx];
    }

    return tradition;
  }

  static Future<List<Tradition>> randomList(
      AppData appData, int count, String keyword) async {
    List<Tradition> traditions = await allTraditions();
    log('Starting with ${traditions.length} traditions');

    final List<TraditionReview> reviews =
        await TraditionReview.allReviews(appData.session);
    log('Loaded ${reviews.length} reviews');
    reviews.forEach((review) {
      final Tradition tradition = traditions.firstWhere((tradition) => tradition.docRef == review.tradRef);
      traditions.remove(tradition);
    });
    log('After removing prior reviews, left with ${traditions.length} traditions');

    traditions.remove(traditions.firstWhere((tradition) => tradition == appData.tradition, orElse: () => null));
    log('After removing just prior, left with ${traditions.length} traditions');

    final List<Tradition> traditionsAlt = List.of(traditions);
    if (keyword != null) {
      traditions = traditions
          .where((tradition) => tradition.keywords.contains(keyword))
          .toList();
    }
    log('After keyword, left with ${traditions.length} traditions');

    final seed = appData.session.id.codeUnitAt(0) * reviews.length;
    final rng = Random(seed);

    final List<Tradition> results = List<Tradition>();

    while (results.length < count && traditions.isNotEmpty) {
      var idx = rng.nextInt(traditions.length);
      var tradition = traditions[idx];
      results.add(tradition);
      traditions.remove(tradition);
      traditionsAlt.remove(tradition);
      log('Adding regular tradition ${tradition.name}');
    }

    while (results.length < count && traditionsAlt.isNotEmpty) {
      var idx = rng.nextInt(traditionsAlt.length);
      var tradition = traditionsAlt[idx];
      results.add(tradition);
      traditions.remove(tradition);
      traditionsAlt.remove(tradition);
      log('Adding alternate tradition ${tradition.name}');
    }

    return results;
  }

  static String randomKeyword(Tradition tradition) {
    final Random rng = Random();
    return tradition.keywords[rng.nextInt(tradition.keywords.length)];
  }
}
