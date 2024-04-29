import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class LostItem {
  String name;
  String description;
  String path;
  Timestamp? createdOn;

  LostItem(
      {required this.name,
      required this.description,
      required this.path,
      required this.createdOn});

  Map<String, Object> toJson() {
    return {
      'name': name,
      'description': name,
      'path': path,
      'createdOn': Timestamp.now(),
    };
  }
}
