import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:umdlostandfound/models/lost_item.dart';
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
    setState(() {});
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewing Lost Items',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black, // Keeping the dark theme
        iconTheme: const IconThemeData(
            color: Colors.white), // Makes the back button white
      ),
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
                imageWidget = Image.network(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  height: 300, // Fixed height for each image
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                imageWidget = const CircularProgressIndicator();
              } else {
                imageWidget = const Icon(Icons.error);
              }

              return Container(
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    imageWidget,
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(item.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(item.description,
                          style: const TextStyle(color: Colors.white)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFFFD700), // Gold color
                          textStyle: const TextStyle(
                              color: Colors.black, fontSize: 16),
                        ),
                        onPressed: () => claimItem(item, index),
                        child: const Text('Claim',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  Future<void> getItems(String latlng) async {
    print("Fetching items for location: $latlng");
    final docRef =
        FirebaseFirestore.instance.collection("coordinates").doc(latlng);

    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        List<LostItem> fetchedItems = [];
        var itemsArray = docSnapshot.data()?['items'] as List<
            dynamic>; // Assuming 'items' is the key for the array of maps
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

  Future<void> claimItem(LostItem item, int index) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection("coordinates")
          .doc(widget.location);

      // Fetch the current array from Firestore
      DocumentSnapshot docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> itemsArray = List.from(data['items'] ?? []);

        itemsArray.removeAt(index);  // Remove the item by index

        if (itemsArray.isEmpty) {
          // If it's the last item, delete the whole document
          await docRef.delete();
        } else {
          // Otherwise, update the document with the new array
          await docRef.update({
            'items': itemsArray
          });
        }
      } else {
        print("Document does not exist.");  // Debugging line
      }

      // Update local list and UI
      setState(() {
        items.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Item claimed and removed successfully!"),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      print("Error during claiming item: $e");  // Debugging line
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to claim item: $e"),
        duration: const Duration(seconds: 2),
      ));
    }
  }
}
