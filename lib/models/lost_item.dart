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

 factory LostItem.fromJson(Map<String, Object?> json) {
    return LostItem(
      name: json['name'] as String? ?? 'Default Name',
      description: json['description'] as String? ?? 'No description provided',
      path: json['path'] as String? ?? 'No path provided',
      createdOn: json['createdOn'] as Timestamp? ?? Timestamp.now(),
    );
  }

}
