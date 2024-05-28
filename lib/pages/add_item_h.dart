import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:umdlostandfound/models/lost_item.dart';
import '../services/utils.dart';

class AddItemH extends StatefulWidget {
  const AddItemH({super.key, required this.location});
  final String location;

  @override
  State<AddItemH> createState() => _AddItemHState();
}

class _AddItemHState extends State<AddItemH> {
  File? _uploadedFile;
  late final String location;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final LostItem item = LostItem(
      name: "", description: "", path: "location", createdOn: Timestamp.now());

  @override
  void initState() {
    super.initState();
    location = widget.location;
    item.path = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Item", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: _buildUI(),
        ),
      ),
      backgroundColor: Colors.grey[900],
    );
  }

  Widget _buildUI() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _uploadedFile == null
              ? const Center(
                  child: Text("No files uploaded yet.",
                      style: TextStyle(color: Colors.white)))
              : Center(child: Image(image: FileImage(_uploadedFile!))),
          const SizedBox(height: 20),
          _textField(
              "Item Name", _nameController, "Enter the name of the item"),
          const SizedBox(height: 10),
          _textField("Description", _descController, "Enter a description"),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _selectMediaButton(),
              _submitButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textField(
      String label, TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Color(0xFFFFD700)), // Gold color in hex
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red)),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.black,
      ),
    );
  }

  Widget _selectMediaButton() {
    return ElevatedButton(
      onPressed: () async {
        File? selectedImage = await getImageFromGallery();
        if (selectedImage != null) {
          setState(() {
            _uploadedFile = selectedImage;
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Text("Select Image", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () => _handleSubmit(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFD700), // Gold color in hex
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Submit", style: TextStyle(color: Colors.black)),
          Icon(Icons.upload, color: Colors.black),
        ],
      ),
    );
  }

  void _handleSubmit(BuildContext context) {
    item.name = _nameController.text;
    item.description = _descController.text;
    _uploadMedia(item, location);
  }

  void _uploadMedia(LostItem item, String location) async {
    if (_uploadedFile != null &&
        item.name.isNotEmpty &&
        item.description.isNotEmpty) {
      bool success = await uploadInfo(_uploadedFile!, item, location);
      if (success) {
        _showSnackBar(
            context, "Item uploaded successfully, returning to home!");
        setState(() {
          _uploadedFile = null;
          _nameController.clear();
          _descController.clear();
        });
        await Future.delayed(const Duration(seconds: 4));
        Navigator.popUntil(context, ModalRoute.withName('/'));
      } else {
        _showSnackBar(context, "Failed to upload item.");
      }
    } else {
      _showSnackBar(context, "Please fill all fields and select an image.");
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
