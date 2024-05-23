import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

Future<Position> getPosition(BuildContext context) async {
  final hasPermission = await _handlePermission(context);
  if (!hasPermission) {
    throw Exception("Permissions to access location denied");
  }

  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  return position;
}

Future<bool> _handlePermission(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text('Please enable location services to continue.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                if (!Navigator.of(context).mounted) return;
                Navigator.of(context).pop(); // Close the dialog
                _openLocationSettings(); // Open location settings
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                if (!Navigator.of(context).mounted) return;
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
    return false;
  }

  permission = await _geolocatorPlatform.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await _geolocatorPlatform.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Permission Needed"),
            content: const Text(
                "This app needs location permission to function. Please grant the permission."),
            actions: <Widget>[
              TextButton(
                child: const Text('Grant Permission'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _handlePermission(context); // Try requesting permission again
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Permission Denied Forever"),
          content: const Text(
              "This app requires location permissions to function properly. Please enable permissions in your app settings."),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _openLocationSettings(); // Direct user to the app settings
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
    return false;
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return true;
}

Future<void> _openLocationSettings() async {
  final String settingsUrl;
  if (Platform.isAndroid) {
    settingsUrl =
        'package:com.example.umdlostandfound'; // Use your actual package name
  } else if (Platform.isIOS) {
    settingsUrl = 'App-Prefs:root=LOCATION_SERVICES';
  } else {
    throw Exception('Platform not supported');
  }

  Uri settingsUri = Uri.parse(settingsUrl);
  if (await canLaunchUrl(settingsUri)) {
    await launchUrl(settingsUri);
  } else {
    throw 'Could not launch $settingsUrl';
  }
}
