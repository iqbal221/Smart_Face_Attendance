import 'dart:io';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  late final FaceDetector _faceDetector;

  FaceDetectionService() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableContours: true,
        enableClassification: true,
        enableLandmarks: true,
        enableTracking: true,
      ),
    );
  }

  Future<List<Face>> detectFaces(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);

    final faces = await _faceDetector.processImage(inputImage);

    return faces;
  }

  Future<void> dispose() async {
    await _faceDetector.close();
  }
}
