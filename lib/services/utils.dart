import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:umdlostandfound/models/lost_item.dart';

Future<File?> getImageFromGallery() async {
  try {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      return File(pickedImage.path);
    }
    // No image selected
    return null;
  } catch (e) {
    print('Error picking image: $e');
    // Handle the error as needed
    return null;
  }
}

Future<bool> uploadInfo(File file, LostItem item, String coords) async {
  try {
    FirebaseFirestore db = FirebaseFirestore.instance;

    final fileName = file.path.split("/").last;
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child("uploads/$coords/$fileName");
    item.path = "uploads/$coords/$fileName";
    db
        .collection("coordinates")
        .doc(coords)
        .set({
          'items': FieldValue.arrayUnion([item.toJson()])
        }, SetOptions(merge: true))
        .then((value) => print("Document successfully written!"))
        .catchError((error) => print("Error writing document: $error"));

    // Upload the text bytes to Firebase Storage
    await imageRef.putFile(file);

    return true;
  } catch (e) {
    print(e);
  }
  return false;
}

Future<List<Reference>?> getUsersUplodedFiles(String location) async {
  try {
    final storageRef = FirebaseStorage.instance.ref();
    final uploadsRefs = storageRef.child("/images/uploads/$location");
    final uploads = await uploadsRefs.listAll();
    print("balls");
    return uploads.items;
  } catch (e) {
    print(e);
  }
}

