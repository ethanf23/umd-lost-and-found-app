import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gallery_picker/gallery_picker.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key, required this.title});

  final String title;

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  File? selectedImage;
  UploadTask? uploadTask;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            if (selectedImage != null)
              Expanded(
                  child: Container(
                      child: Center(
                          child: Image.file(
                File(selectedImage!.path!),
                width: double.infinity,
                fit: BoxFit.cover,
              )))),
            const SizedBox(height: 32),
            MaterialButton(
                color: Colors.blue,
                child: const Text("Select Picture",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                onPressed: () {
                  _pickImageFromGallery();
                }),
            MaterialButton(
                color: Colors.red,
                child: const Text("Upload Picture",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                onPressed: () {
                  uploadPicture();
                }),
            const SizedBox(
              height: 32,
            ),
            buildProgress(),
            selectedImage != null
                ? Image.file(selectedImage!)
                : const Text("Please select an image")
          ],
        ),
      ),
    );
  }

  Future _pickImageFromGallery() async {
    final returnedImage = await FilePicker.platform.pickFiles();
    if (returnedImage == null) return;
    setState(() {
      selectedImage = returnedImage.files.first as File?;
    });
  }

  Future uploadPicture() async {
    final returnedImage = File(selectedImage!.path);
    final path = 'files/${selectedImage!.path!}';

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(returnedImage);
    });

    final snapshot = await uploadTask!.whenComplete(() => {});

    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');

    setState(() {
      uploadTask = null;
    });
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.green,
                ),
                Center(
                    child: Text(
                  '${(100 * progress).roundToDouble()}%',
                  style: const TextStyle(color: Colors.white),
                ))
              ],
            ),
          );
        } else {
          return const SizedBox(height: 50);
        }
      });
}
