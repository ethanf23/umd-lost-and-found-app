import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:umdlostandfound/pages/add_item_h.dart';
import 'package:umdlostandfound/services/location_handling.dart';
import 'package:umdlostandfound/models/lost_item.dart';
import 'package:umdlostandfound/pages/items_list.dart';
import 'package:umdlostandfound/pages/loading_screen.dart';
import 'package:umdlostandfound/services/generate_markers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Required to connect to Firebase Cloud Storage

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
  print("Run!");
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
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0x00e21833), // Deep Purple
          primaryContainer: Color(0xffd200), // Deep Purple Dark
          secondary: Color(0xFF03DAC6), // Teal
          secondaryContainer: Color(0xFF018786), // Teal Dark
          surface: Color(0xFFFFFFFF), // White
          background: Color(0xFFFFFFFF), // White
          error: Color(0xFFB00020), // Red
          onPrimary: Color(0xFFFFFFFF), // White
          onSecondary: Color(0xFF000000), // Black
          onSurface: Color(0xFF000000), // Black
          onBackground: Color(0xFF000000), // Black
          onError: Color(0xFFFFFFFF), // White
        ),
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
  MapOptions options =
      const MapOptions(initialCenter: _initialCenter, initialZoom: 14.75);
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

  List<Marker> markers = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    markers = getCoordinatesFromFirestore();
  }

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

  @override
  Widget build(BuildContext context) {
    print(markers);
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
                                  builder: (context) =>
                                      ItemsListScreen(items: lostItems)));
                        },
                        child:
                            MarkerLayer(markers: getCoordinatesFromFirestore()))
                  ])
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
