import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SelectFromMap extends StatefulWidget {
  const SelectFromMap({super.key});

  @override
  SelectFromMapState createState() => SelectFromMapState();
}

class SelectFromMapState extends State<SelectFromMap> {
  Alignment selectedAlignment = Alignment.topCenter;
  bool counterRotate = false;

  static const alignments = {
    315: Alignment.topLeft,
    0: Alignment.topCenter,
    45: Alignment.topRight,
    270: Alignment.centerLeft,
    null: Alignment.center,
    90: Alignment.centerRight,
    225: Alignment.bottomLeft,
    180: Alignment.bottomCenter,
    135: Alignment.bottomRight,
  };

  late final customMarkers = <Marker>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select from Map')),
      body: Column(
        children: [
          Flexible(
            child: FlutterMap(
              options: MapOptions(
                  initialCenter: const LatLng(38.9869, -76.9426),
                  initialZoom: 14.75,
                  onTap: (_, p) {
                    if (customMarkers.isNotEmpty) {
                      showTopSnackBar(
                          context, 'Only one marker can be placed on the map.');
                    } else {
                      setState(() {
                        customMarkers.add(
                          Marker(
                            point: p,
                            width: 80,
                            height: 80,
                            child: GestureDetector(
                              onTap: () => showTopSnackBar(
                                  context, 'Tapped existing marker'),
                              child: const Icon(Icons.location_pin,
                                  size: 40, color: Colors.black),
                            ),
                          ),
                        );
                      });
                    }
                  }),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                MarkerLayer(
                  markers: customMarkers,
                  rotate: counterRotate,
                  alignment: selectedAlignment,
                ),
              ],
            ),
          ),
          SafeArea(
            child: _buildConfirmationButtons(context),
          ),
        ],
      ),
    );
  }

  void showTopSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 50.0, left: 15.0, right: 15.0),
        duration: const Duration(seconds: 2),
        showCloseIcon: true,
      ),
    );
  }

  Widget _buildConfirmationButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              if (customMarkers.isEmpty) {
                showTopSnackBar(context, 'No location selected.');
              } else {
                setState(() => customMarkers.clear());
              }
            },
            child: const Text(style: TextStyle(color: Colors.black),'Cancel'), 
          ),
          ElevatedButton(
            onPressed: () {
              if (customMarkers.isEmpty) {
                showTopSnackBar(context, 'No location selected.');
              } else {
                Navigator.pushNamed(context, '/add_item_h',
                    arguments:
                        '${customMarkers.first.point.latitude.toString()}, ${customMarkers.first.point.longitude.toString()}');
              }
            },
            child: const Text(style: TextStyle(color: Colors.black),'Confirm'), 
          ),
        ],
      ),
    );
  }
}
