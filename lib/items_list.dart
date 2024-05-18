import 'package:flutter/material.dart';
import 'package:umdlostandfound/lost_item.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ItemsListScreen extends StatelessWidget {
  // Requiring the list of items.
  const ItemsListScreen({super.key, required this.items});

  final List<LostItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
      ),
      //passing in the ListView.builder
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index].name),
            
          );
        },
      ),
    );
  }
}
