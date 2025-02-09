import 'dart:typed_data';

abstract class StorageRepo {
  //upload profile images on mobile

  Future<String?> uploadProfileImageMobile(String path, String fileName);

  //upload profile images on web platforms
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName);

  //upload post images on web platforms
  Future<String?> uploadPostImageMobile(String path, String fileName);

  //upload post images on web platforms
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName);
}
