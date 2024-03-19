import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:umdlostandfound/items_list.dart';
import 'package:umdlostandfound/random_markers.dart';
import 'package:umdlostandfound/lost_item.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  runApp(const MyApp());

  // Required to connect to Firebase Cloud Storage
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

  late Position position;

  Future<void> getPosition() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _add() {
    getPosition();
    print('${position.latitude.toString()}, ${position.longitude.toString()}');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Placeholder()));
  }

  final lostItems = List.generate(
    20,
    (i) => LostItem('Item $i',
        'A description of what needs to be done for Todo $i', 'sample/path'),
  );

  // Connect storage to FirebaseStorage instance
  // final storage = FirebaseStorage.instance;

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
                                builder: (context) =>
                                    ItemsListScreen(items: lostItems)));
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
