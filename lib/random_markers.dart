import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Marker>> getCoordinatesFromFirestore() async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Marker> coordinates = [];
  int length = await db.collection("coordinates").snapshots().length;
  print(length);

  db.collection("coordinates").get().then(
    (querySnapshot)  {
      for(var docSnapShot in querySnapshot.docs){

         print(docSnapShot.id);

         List<String> nameParts = docSnapShot.id.split(',');
         double latitude = double.parse(nameParts[0]);

         print(latitude);
         
         double longitude = double.parse(nameParts[1]);

         print(longitude);

        coordinates.add(accurateMarker(LatLng(latitude, longitude),));

      }
    },
    onError: (e) => print("$e")
  );
  // Assuming 'coordinates' is the name of your collection
  //QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('coordinates').get();
  print(coordinates);

  return coordinates;

}


List<Marker> generateMarkers({
  required int length,
  required LatLng center,
}) {
  final random = Random(42);
  return List<Marker>.generate(
    length,
    (_) => accurateMarker(
      LatLng(
        random.nextDouble() / 100 + center.latitude,
        random.nextDouble() / 100 + center.longitude,
      ),
    ),
  );
}

Marker accurateMarker(LatLng latLng) => Marker(
      child: const Icon(Icons.location_pin),
      point: latLng,
    );





