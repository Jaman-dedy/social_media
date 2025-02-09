import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media/features/storage/domain/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo {
  final FirebaseStorage storage = FirebaseStorage.instance;

  /*

    PROFILE PICTURES - Upload images to storage

  */

  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, 'profile_images');
  }

  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes, fileName, 'profile_images');
  }

  /*

    PROFILE PICTURES - Upload images to storage

  */

  @override
  Future<String?> uploadPostImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, 'post_images');
  }

  @override
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes, fileName, 'post_images');
  }

  /*

    HELPER METHODS - upload files to storage

  */

  // mobile platforms (file)
  Future<String?> _uploadFile(
      String path, String fileName, String folder) async {
    try {
      // get file from device
      final file = File(path);

      // find place to store the file
      final storageRef = storage.ref().child('$folder/$fileName');

      //upload the file
      final uploadTask = await storageRef.putFile(file);

      //Get download image url
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  // web platforms (bytes)
  Future<String?> _uploadFileBytes(
      Uint8List fileBytes, String fileName, String folder) async {
    try {
      // find place to store the file
      final storageRef = storage.ref().child('$folder/$fileName');

      //upload the file
      final uploadTask = await storageRef.putData(fileBytes);

      //Get download image url
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}
