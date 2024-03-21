import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gallery_picker/gallery_picker.dart';



Future<File?> getImageFromGallery(BuildContext context) async {
  try {
    List<MediaFile>? singleMedia =
        await GalleryPicker.pickMedia(context: context, singleMedia: true);
    return singleMedia?.first.getFile();
  } catch (e) {
    print(e);
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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final storageRef = FirebaseStorage.instance.ref();
    final uploadsRefs = storageRef.child("$userId/uploads");
    final uploads = await uploadsRefs.listAll();
    return uploads.items;
  } catch (e) {
    print(e);
  }
}
