import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<LatLng>> getCoordinatesFromFirestore() async {
  List<LatLng> coordinates = [];

  // Assuming 'coordinates' is the name of your collection
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('coordinates').get();

  querySnapshot.docs.forEach((doc) {
    // Get the latitude and longitude from the document name
    List<String> nameParts = doc.id.split('.');
    double latitude = double.parse(nameParts[0]);
    double longitude = double.parse(nameParts[1]);
    coordinates.add(LatLng(latitude, longitude));
  });

  return coordinates;
}

List<Marker> generateMarkersFromFirestore({
  required int length,
  required LatLng center,
}) {
  final random = Random(42);
  List<Marker> markers = [];

  getCoordinatesFromFirestore().then((coordinates) {
    for (int i = 0; i < length; i++) {
      LatLng randomCoordinate = coordinates[random.nextInt(coordinates.length)];
      markers.add(accurateMarker(
        LatLng(
          randomCoordinate.latitude + center.latitude,
          randomCoordinate.longitude + center.longitude,
        ),
      ));
    }
  });

  return markers;
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





