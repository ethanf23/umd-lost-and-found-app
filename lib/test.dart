import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddItemScreen extends StatelessWidget {
  final File imageFile;

  AddItemScreen({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: Column(
        children: [
          Image.file(imageFile),
          ElevatedButton(
            onPressed: () async {
              // Upload the image to Firebase Storage
              String imageUrl = await uploadImageToStorage(imageFile);

              // Navigate back to the home screen
              Navigator.pop(context);

              // Perform further actions with imageUrl if needed
            },
            child: Text('Add Item'),
          ),
        ],
      ),
    );
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.Reference reference =
        firebase_storage.FirebaseStorage.instance.ref().child('images/$fileName');
    firebase_storage.UploadTask uploadTask = reference.putFile(imageFile);
    firebase_storage.TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() {});
    String downloadURL = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadURL;
  }
}
