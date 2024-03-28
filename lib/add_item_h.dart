import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:umdlostandfound/lost_item.dart';
import 'utils.dart';

class AddItemH extends StatefulWidget {
  const AddItemH({super.key, required this.item});
  final LostItem item;

  @override
  State<AddItemH> createState() => _AddItemHState();
}

class _AddItemHState extends State<AddItemH> {
  File? _uploadedFile;
  late final LostItem item;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    item = widget.item;
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
      body: Center(
          child: Column(children: [
        _buildUI(),
        _selectMediaButton(context),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Item Name',
          ),
        ),
        TextField(
          controller: _descController,
          decoration: const InputDecoration(
            hintText: 'Description',
          ),
        ),
        MaterialButton(
          onPressed: () {
            item.name = _nameController.text;
            item.description = _descController.text;
            _uploadMedia(item);
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Submit"),
              Icon(
                Icons.upload,
              ),
            ],
          ),
        ),
      ])),
    );
  }

  Widget _selectMediaButton(BuildContext context) {
    return MaterialButton(
        onPressed: () async {
          File? selectedImage = await getImageFromGallery();
          if (selectedImage != null) {
            setState(() {
              _uploadedFile = selectedImage;
            });
          }
        },
        child: const Text(
          "Select Image",
        ));
  }

  void _uploadMedia(LostItem item) async {
    if (_uploadedFile != null &&
        item.name.isNotEmpty &&
        item.description.isNotEmpty) {
      bool success = await uploadInfo(
          _uploadedFile!, "${item.name}\n${item.description}", item.path);
      if (success) {
        setState(() {
          _uploadedFile = null;
          // Dispose text box
        });
        print("Success");
      }
    } else if (_uploadedFile != null) {
      //error handle empty text box
    } else {
      // Error handle empty image or both empty
    }
  }

  Widget _buildUI() {
    if (_uploadedFile == null) {
      return const Center(
        child: Text("No files uploaded yet."),
      );
    } else {
      return Center(
        child: Image(
          image: FileImage(_uploadedFile!),
        ),
      );
    }
  }
}
