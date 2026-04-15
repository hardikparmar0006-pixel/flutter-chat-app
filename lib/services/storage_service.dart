import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final storage = FirebaseStorage.instance;

  Future<String> uploadImage(File file) async {
    final ref = storage.ref().child("chat_images/${DateTime.now()}");
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}

// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
//
// class StorageService {
//   final _storage = FirebaseStorage.instance;
//
//   Future<String> uploadImage(File file) async {
//     final ref = _storage.ref().child("chat/${DateTime.now()}");
//     await ref.putFile(file);
//     return await ref.getDownloadURL();
//   }
// }