import 'dart:io';
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

Future<bool> uploadFileForUser(File file) async {
  try {
    final storageRef = FirebaseStorage.instance.ref();
    final fileName = file.path.split("/").last;
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final uploadRef = storageRef.child("images/uploads/$timestamp-$fileName");
    await uploadRef.putFile(file);
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
