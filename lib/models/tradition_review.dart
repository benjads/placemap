import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:placemap/utils.dart';

class TraditionReview {
  final DocumentReference sessionRef;
  final DocumentReference tradRef;
  final Map<String, int> _ratings;
  final DocumentReference docRef;

  TraditionReview(this.sessionRef, this.tradRef)
      : _ratings = <String, int>{},
        docRef = sessionRef.collection('reviews').doc(tradRef.id);

  TraditionReview.fromSnapshot(DocumentSnapshot doc)
      : this.fromMap(doc.data(), docRef: doc.reference);

  TraditionReview.fromMap(Map<String, dynamic> map, {this.docRef})
      : assert(map['tradRef'] != null),
        sessionRef = docRef.parent.parent,
        tradRef = map['tradRef'],
        _ratings = PlacemapUtils.toStringIntMap(map['ratings']);

  Map<String, dynamic> get map => {
        'tradRef': tradRef,
        'ratings': _ratings,
      };

  Future<void> update() async {
    await docRef.set(map);
  }

  Future<void> addReview(int rating) async {
    final doc = await docRef.get();
    _ratings.addAll(PlacemapUtils.toStringIntMap(doc.data()['ratings']));

    final String deviceId = await PlacemapUtils.currentDeviceId();

    _ratings[deviceId] = rating;
    return update();
  }

  Map<int, int> ratingsMap() {
    final results = {
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
    };

    _ratings.forEach((key, value) => results[value]++);
    return results;
  }

  double avgRating() {
    int total = 0;
    _ratings.forEach((key, value) => total += value);
    return total / _ratings.length;
  }
}
