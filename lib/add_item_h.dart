import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'utils.dart';

class AddItemH extends StatefulWidget {
  const AddItemH({super.key});

  @override
  State<AddItemH> createState() => _AddItemHState();
}

class _AddItemHState extends State<AddItemH> {
  List<Reference> _uploadedFiles = [];

  @override
  void initState() {
    super.initState();
    getUploadedFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Firebase Storage",
        ),
        centerTitle: true,
      ),
      body: _buildUI(),
      floatingActionButton: _uploadMediaButton(context),
    );
  }

  Widget _uploadMediaButton(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        File? selectedImage = await getImageFromGallery(context);
        if (selectedImage != null) {
          bool success = await uploadFileForUser(selectedImage);
          if (success) {
            print("Success");
            getUploadedFiles();
          }
        }
      },
      child: const Icon(
        Icons.upload,
      ),
    );
  }

  Widget _buildUI() {
    if (_uploadedFiles.isEmpty) {
      return const Center(
        child: Text("No files uploaded yet."),
      );
    }
    return ListView.builder(
      itemCount: _uploadedFiles.length,
      itemBuilder: (context, index) {
        Reference ref = _uploadedFiles[index];
        return FutureBuilder(
          future: ref.getDownloadURL(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListTile(
                leading: Image.network(snapshot.data!),
                title: Text(
                  ref.name,
                ),
              );
            }
            return Container();
          },
        );
      },
    );
  }

  void getUploadedFiles() async {
    List<Reference>? result = await getUsersUplodedFiles();
    if (result != null) {
      setState(
        () {
          _uploadedFiles = result;
        },
      );
    }
  }
}
