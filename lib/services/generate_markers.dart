import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/items_list.dart';

Future<List<Marker>> getCoordinatesFromFirestore(BuildContext context) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Marker> markers = [];

  var querySnapshot = await db.collection("coordinates").get();
  for (var docSnapShot in querySnapshot.docs) {
    List<String> nameParts = docSnapShot.id.split(',');

    double latitude = double.parse(nameParts[0]);
    double longitude = double.parse(nameParts[1]);

    Marker marker = Marker(
      width: 80.0,
      height: 80.0,
      point: LatLng(latitude, longitude),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemsListScreen(location: docSnapShot.id),
            ),
          );
        },
        child: const Icon(Icons.location_on, size: 40.0),
      ),
    );
    markers.add(marker);
  }

  return markers;
}
