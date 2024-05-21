import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
      'description': description,
      'path': path,
      'createdOn': Timestamp.now(),
    };
  }
}
