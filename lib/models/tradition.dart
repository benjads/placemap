import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/tradition_review.dart';
import 'package:placemap/utils.dart';
import 'package:provider/provider.dart';

class Tradition {
  final String name;
  final String origin;
  final String coverImg;
  Image _cachedCoverImg;
  final String ttsDesc;
  final String fullDesc;
  final String videoUri;
  final List<String> photos;
  List<Image> _cachedPhotos;
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
      @required this.allowedFirst})
      : docRef = null;

  Tradition.fromSnapshot(DocumentSnapshot doc)
      : this.fromMap(doc.data(), docRef: doc.reference);

  Tradition.fromMap(Map<String, dynamic> map, {this.docRef})
      : assert(map['name'] != null),
        assert(map['origin'] != null),
        assert(map['coverImg'] != null),
        assert(map['ttsDesc'] != null),
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

  Future<void> cacheImages(BuildContext context) async {
    final coverImgUrl = await FirebaseStorage.instance
        .ref('traditions/$coverImg')
        .getDownloadURL();
    _cachedCoverImg = Image.network(coverImgUrl);
    await precacheImage(_cachedCoverImg.image, context);

    if (photos != null) {
      _cachedPhotos = List<Image>();
      photos.forEach((photo) async {
        var photoUrl = await FirebaseStorage.instance
            .ref('traditions/$photo')
            .getDownloadURL();
        final photoImg = Image.network(photoUrl);
        _cachedPhotos.add(photoImg);
        await precacheImage(photoImg.image, context);
      });
    }
  }

  Image get cachedCoverImg => _cachedCoverImg;

  List<Image> get cachedPhotos => _cachedPhotos;

  static Future<Tradition> random(BuildContext context) async {
    final appData = context.read<AppData>();
    final session = appData.session;

    final reviews = await TraditionReview.allReviews(session);
    final priorTraditions = reviews.map((review) => review.docRef);
    final traditionsSnapshot =
        await FirebaseFirestore.instance.collection('traditions').get();
    final traditions = traditionsSnapshot.docs
        .map((snapshot) => Tradition.fromSnapshot(snapshot))
        .toList();

    final rng = Random();
    final isFirst = reviews.length == 0;

    var idx = rng.nextInt(traditions.length);
    var tradition = traditions[idx];
    while (priorTraditions.contains(tradition.docRef) ||
        (isFirst && !tradition.allowedFirst)) {
      idx = rng.nextInt(traditions.length);
      tradition = traditions[idx];
    }

    return tradition;
  }
}
