import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

class AddItemH extends StatefulWidget {
  const AddItemH({super.key});

  @override
  State<AddItemH> createState() => _AddItemHState();
}

class _AddItemHState extends State<AddItemH> {
  File? _uploadedFile;
  TextEditingController _textEditingController = TextEditingController();



  @override
  void initState() {
    super.initState();
    //getUploadedFiles();
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
        _selectMediaButton(context),
        _buildUI(),
        _uploadMediaButton(context),
        TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: 'Enter your text here',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                String text = _textEditingController.text;
                if (text.isNotEmpty) {
                  _uploadTextFile(text);
                }
              },
              child: Text('Upload Text File'),
            ),
      ])),
    );

      @override
      void dispose() {
        _textEditingController.dispose();
        super.dispose();
     }
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

  Widget _uploadMediaButton(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        // File? selectedImage = await getImageFromGallery();
        if (_uploadedFile != null) {
          bool success = await uploadFileForUser(_uploadedFile!);
          if (success) {
            setState(() {
              _uploadedFile = null;
            });
            print("Success");
          }
        }
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Upload Image"),
          Icon(
            Icons.upload,
          ),
        ],
      ),
    );
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
    // return ListView.builder(
    //   itemCount: _uploadedFiles.length,
    //   itemBuilder: (context, index) {
    //     Reference ref = _uploadedFiles[index];
    //     return FutureBuilder(
    //       future: ref.getDownloadURL(),
    //       builder: (context, snapshot) {
    //         if (snapshot.hasData) {
    //           return ListTile(
    //             leading: Image.network(snapshot.data!),
    //             title: Text(
    //               ref.name,
    //             ),
    //           );
    //         }
    //         return Container();
    //       },
    //     );
    //   },
    // );
  }

  // void getUploadedFiles() async {
  //   List<Reference>? result = await getUsersUplodedFiles();
  //   if (result != null) {
  //     print(result.toString());
  //     setState(
  //       () {
  //         _uploadedFiles = result;
  //       },
  //     );
  //   }
  // }


    void _uploadTextFile(String text) async {
    try {
      // Encode text to bytes using UTF-8 encoding
      Uint8List textBytes = Uint8List.fromList(utf8.encode(text));
      
      final storageRef = FirebaseStorage.instance.ref();
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final uploadRef = storageRef.child("textfiles/$timestamp.txt");
      
      // Upload the text bytes to Firebase Storage
      await uploadRef.putData(textBytes);

      print('Text file uploaded successfully');
    } catch (e) {
      print('Error uploading text file: $e');
    }
  }

}
