import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

Future<bool> uploadInfo(File file, String text, String path) async {
  try {
    Uint8List textBytes = Uint8List.fromList(utf8.encode(text));

    final storageRef = FirebaseStorage.instance.ref();
    final fileName = file.path.split("/").last;
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final imageRef = storageRef.child("$path/$timestamp-$fileName");
    final textRef = storageRef.child("$path/$fileName-info.txt");

    // Upload the text bytes to Firebase Storage
    await imageRef.putFile(file);
    await textRef.putData(textBytes);
    return true;
  } catch (e) {
    print(e);
  }
  return false;
}

Future<List<Reference>?> getUsersUplodedFiles() async {
  try {
    final storageRef = FirebaseStorage.instance.ref();
    final uploadsRefs = storageRef.child("/images/uploads");
    final uploads = await uploadsRefs.listAll();
    print("balls");
    return uploads.items;
  } catch (e) {
    print(e);
  }
}
