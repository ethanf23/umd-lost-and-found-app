import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';

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
