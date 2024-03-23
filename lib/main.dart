import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:umdlostandfound/add_item_h.dart';
import 'package:umdlostandfound/location_handling.dart';
import 'package:umdlostandfound/random_markers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Required to connect to Firebase Cloud Storage

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Default map to center at the University of Maryland
  static const _initialCenter = LatLng(38.9869, -76.9426);
  MapOptions options = const MapOptions(initialCenter: _initialCenter);
  late Position position = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0);

  void _add() {
    print("Adding");
    getPosition().then((value) => position = value);
    print('${position.latitude.toString()}, ${position.longitude.toString()}');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AddItemH()));
  }

  // Connect storage to FirebaseStorage instance
  final storage = FirebaseStorage.instance;

  // Generate random markers for testing
  List<Marker> randomMarkers =
      generateMarkers(length: 7, center: _initialCenter);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Map recommended to be stored in stack
        child: Stack(
          children: <Widget>[
            // FLutterMap Widget with TileLayer, GestureDetector children
            FlutterMap(
                mapController: MapController(),
                options: options,
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  // GestureDetector wraps markers so they are clickable
                  GestureDetector(
                      //onTap send to page containing all lost items at LatLng point
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Placeholder()));
                      },
                      child: MarkerLayer(markers: randomMarkers))
                ])
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        tooltip: 'Add New Item',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
