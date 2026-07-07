import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class FaceCropService {
  /// Crops the detected face from the original image file
  /// and returns a new cropped image file.
  static Future<File> cropFace({
    required File imageFile,
    required Face face,
  }) async {
    // Read and decode the original image
    final bytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      throw Exception("Failed to decode image for cropping.");
    }

    // Get face bounding box
    final boundingBox = face.boundingBox;

    // Add some padding around the face (10% of width/height)
    final paddingX = (boundingBox.width * 0.1).round();
    final paddingY = (boundingBox.height * 0.1).round();

    int left = (boundingBox.left - paddingX).round();
    int top = (boundingBox.top - paddingY).round();
    int width = (boundingBox.width + paddingX * 2).round();
    int height = (boundingBox.height + paddingY * 2).round();

    // Clamp values so the crop rect stays inside the image bounds
    left = left.clamp(0, originalImage.width - 1);
    top = top.clamp(0, originalImage.height - 1);
    width = width.clamp(1, originalImage.width - left);
    height = height.clamp(1, originalImage.height - top);

    // Crop the face region
    final croppedImage = img.copyCrop(
      originalImage,
      x: left,
      y: top,
      width: width,
      height: height,
    );

    // Resize to a standard size (helps consistency for embedding model later)
    final resizedImage = img.copyResize(croppedImage, width: 160, height: 160);

    // Save cropped image to a new file
    final tempDir = await getTemporaryDirectory();
    final croppedPath =
        '${tempDir.path}/cropped_face_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final croppedFile = File(croppedPath)
      ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 90));

    return croppedFile;
  }
}
