import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:umdlostandfound/pages/add_item_h.dart';
import 'package:umdlostandfound/pages/select_from_map.dart';
import 'package:umdlostandfound/services/expandable_fab.dart';
import 'package:umdlostandfound/services/location_handling.dart';
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
          primary: Color(0xFFFFD700), // UMD Gold
          primaryContainer: Color(0xFFC5A600), // UMD Gold Dark
          secondary: Color(0xFFCE1126), // UMD Red
          secondaryContainer: Color(0xFF8C0D1B), // UMD Red Dark
          surface: Color(0xFFFFFFFF), // White
          background: Color(0xFFFFFFFF), // White
          error: Color(0xFFB00020), // Red
          onPrimary: Color(0xFF000000), // Black
          onSecondary: Color(0xFFFFFFFF), // White
          onSurface: Color(0xFF000000), // Black
          onBackground: Color(0xFF000000), // Black
          onError: Color(0xFFFFFFFF), // White
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home'),
      routes: {
        '/add_item_h': (context) => AddItemH(
            location: ModalRoute.of(context)!.settings.arguments as String),
      },
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
    super.initState();
    // loadMarkers();
  }

  void _add() {
    print("Adding");
    getPosition(context).then((value) {
      position = value;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddItemH(
                    location:
                        '${position.latitude.toString()}, ${position.longitude.toString()}',
                  )));
    });
  }

  void _addFromSelect() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SelectFromMap()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<Marker>>(
          stream: getCoordinatesFromFirestore(context),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            return Center(
              child: Stack(
                children: [
                  FlutterMap(
                      mapController: MapController(),
                      options: options,
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'dev.fleaflet.flutter_map.example',
                        ),
                        MarkerLayer(markers: snapshot.data!),
                      ])
                ],
              ),
            );
          }),
      floatingActionButton: SafeArea(
        child: ExpandableFab(initialOpen: false, distance: 75, children: [
          ActionButton(
            onPressed: _add,
            icon: const Icon(Icons.add_location_alt_sharp),
            label: 'Use My Location',
          ),
          ActionButton(
            onPressed: _addFromSelect,
            icon: const Icon(Icons.map),
            label: 'Select on Map',
          )
        ]),
      ),
    );
  }
}
