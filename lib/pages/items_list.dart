import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:umdlostandfound/models/lost_item.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ItemsListScreen extends StatefulWidget {
  const ItemsListScreen({super.key, required this.location});
  final String location;
  
  @override
  State<ItemsListScreen> createState() {
    return _ItemsListScreenState();
  }
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  final storageRef = FirebaseStorage.instance.ref();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  List<LostItem> items = [];
  @override
  void initState() {
    super.initState();
    getItems(widget.location);
  }

 @override
Widget build(BuildContext context) {

  setState(() {

  });
  return Scaffold(
    resizeToAvoidBottomInset: false,
    body: Column(
      children: <Widget>[
        Expanded(
          child: buildItemsList(),
        ),
      ],
    ),
  );
}

Widget buildItemsList() {
  if (items.isEmpty) {
    return const CircularProgressIndicator();
  } else {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        LostItem item = items[index];
        return FutureBuilder(
          future: FirebaseStorage.instance.ref(item.path).getDownloadURL(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            Widget imageWidget;
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              print(item.path);
              imageWidget = Image.network(
                snapshot.data!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              imageWidget = CircularProgressIndicator();
            } else {
              print(snapshot.error);
              print(item.path);
              
              imageWidget = Icon(Icons.error);
            }

            return ListTile(
              title: Text(item.name),
              subtitle: Text(item.description),
              leading: imageWidget,
            );
          },
        );
      },
    );
  }
}

  Future<void> getItems(String latlng) async {
    print("Fetching items for location: $latlng");
    final docRef = FirebaseFirestore.instance.collection("coordinates").doc(latlng);

    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        List<LostItem> fetchedItems = [];
        var itemsArray = docSnapshot.data()?['array'] as List<dynamic>; // Assuming 'items' is the key for the array of maps
        for (var itemMap in itemsArray) {
          fetchedItems.add(LostItem.fromJson(itemMap as Map<String, dynamic>));
        }
        print("Items fetched: ${fetchedItems.length}");

        setState(() {
          items = fetchedItems; // Update the class-level 'items' list
        });
      } else {
        print("No such document!");
      }
    } catch (e) {
      print('Error getting items: $e');
      // Optionally, handle the error by re-throwing or returning an empty list
    }
  }

}

