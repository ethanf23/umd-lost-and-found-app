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

  db.collection("coordinates").get().then((querySnapshot) {
    for (var docSnapShot in querySnapshot.docs) {
      List<String> nameParts = docSnapShot.id.split(',');

      double latitude = double.parse(nameParts[0]);
      double longitude = double.parse(nameParts[1]);

      coordinates.add(accurateMarker(
        LatLng(latitude, longitude),
      ));
    }
  }, onError: (e) => print("$e"));

  return coordinates;
}

Marker accurateMarker(LatLng latLng) => Marker(
      child: const Icon(Icons.location_pin),
      point: latLng,
    );