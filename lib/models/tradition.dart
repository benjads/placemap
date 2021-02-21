import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// final List<Tradition> traditions = [
//   Tradition(
//     name: 'Cin Cin!',
//     origin: 'Italy',
//     coverImg: 'https://www.fillmurray.com/400/600',
//     ttsDesc:
//         "The Italian word for cheers is either “Salute” or “Cin Cin”. This is usually followed by “alla nostra salute”, which means “to your health”.",
//     fullDesc:
//         "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ultricies lectus nec mauris auctor, a aliquam nibh laoreet. Quisque purus risus, aliquam dapibus egestas vitae, tempus venenatis ante. Sed rutrum mattis quam et eleifend. Sed accumsan pulvinar mollis. Vivamus eu tortor euismod, sollicitudin justo iaculis, finibus neque. Cras et tortor nisi.",
//     videoUri:
//         'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
//   ),
// ];

class Tradition {
  final String name;
  final String origin;
  final String coverImg;
  final String ttsDesc;
  final String fullDesc;
  final String videoUri;
  final DocumentReference docRef;

  const Tradition(
      {@required this.name,
      @required this.origin,
      @required this.coverImg,
      @required this.ttsDesc,
      @required this.fullDesc,
      @required this.videoUri})
      : docRef = null;

  Tradition.fromSnapshot(DocumentSnapshot doc)
      : this.fromMap(doc.data(), docRef: doc.reference);

  Tradition.fromMap(Map<String, dynamic> map, {this.docRef})
      : assert(map['name'] != null),
        assert(map['origin'] != null),
        assert(map['coverImg'] != null),
        assert(map['ttsDesc'] != null),
        assert(map['fullDesc'] != null),
        assert(map['videoUri'] != null),
        name = map['name'],
        origin = map['origin'],
        coverImg = map['coverImg'],
        ttsDesc = map['ttsDesc'],
        fullDesc = map['fullDesc'],
        videoUri = map['videoUri'];

  static Future<Tradition> random() async {
    // todo
    return Tradition.fromSnapshot(await FirebaseFirestore.instance.collection('traditions').doc('cincin').get());
  }
}
