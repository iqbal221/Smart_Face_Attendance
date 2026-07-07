import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class StorageService {
  // Replace with your actual Cloudinary cloud name and unsigned preset name
  static const String _cloudName = 'deuky2rb8';
  static const String _uploadPreset = 'chat_app_unsigned';

  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  /// Uploads the cropped face image and returns the secure URL
  Future<String> uploadFaceImage({
    required File imageFile,
    required String employeeId,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'employee_faces',
          publicId: '${employeeId}_${DateTime.now().millisecondsSinceEpoch}',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
  }
}
