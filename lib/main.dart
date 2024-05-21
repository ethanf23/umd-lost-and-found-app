import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:umdlostandfound/add_item_h.dart';
import 'package:umdlostandfound/location_handling.dart';
import 'package:umdlostandfound/lost_item.dart';
import 'package:umdlostandfound/items_list.dart';
import 'package:umdlostandfound/loading_screen.dart';
import 'package:umdlostandfound/generate_markers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Required to connect to Firebase Cloud Storage

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
    // getPosition();
    // print('${position.latitude.toString()}, ${position.longitude.toString()}');
    print("Adding");
    getPosition().then((value) => position = value);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddItemH(
                  location:
                      '${position.latitude.toString()}, ${position.longitude.toString()}',
                )));
  }

  final lostItems = List.generate(
    20,
    (i) => LostItem(
        name: "name",
        description: "description",
        path: "path",
        createdOn: null),
  );

  // Generate random markers for testing

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        // Initialize FlutterFire
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return ErrorWidget(snapshot.connectionState);
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildMapScreen(context);
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return const LoadingScreen();
        });
  }

  Widget _buildMapScreen(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          child: Stack(
            children: [
              FutureBuilder<List<Marker>>(
                  future: getCoordinatesFromFirestore(),
                  builder: (context, AsyncSnapshot<List<Marker>> snapshot) {
                    if (snapshot.hasData) {
                      print(snapshot.data);
                      return FlutterMap(
                          mapController: MapController(),
                          options: options,
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'dev.fleaflet.flutter_map.example',
                            ),
                            // GestureDetector wraps markers so they are clickable
                            GestureDetector(
                                //onTap send to page containing all lost items at LatLng point
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ItemsListScreen(
                                              items: lostItems)));
                                },
                                child: MarkerLayer(markers: snapshot.data!))
                          ]);
                    } else {
                      return const CircularProgressIndicator();
                    }
                  })
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _add,
          tooltip: 'Add New Item',
          child: const Icon(Icons.add),
        ));
  }
}
