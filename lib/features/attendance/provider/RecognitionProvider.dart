import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_face_attendance/features/attendance/services/attendance_service.dart';
import 'package:smart_face_attendance/features/registration/model/employee_model.dart';
import 'package:smart_face_attendance/features/registration/services/camera_service.dart';
import 'package:smart_face_attendance/features/registration/services/face_crop_service.dart';
import 'package:smart_face_attendance/features/registration/services/face_detection_service.dart';
import 'package:smart_face_attendance/features/registration/services/face_embedding_service.dart';
import 'package:smart_face_attendance/features/attendance/services/face_matching_service.dart';

import 'package:smart_face_attendance/features/registration/services/firestore_service.dart';

class RecognitionProvider extends ChangeNotifier {
  final CameraService _cameraService = CameraService();
  final FaceDetectionService _faceDetectionService = FaceDetectionService();
  final FaceEmbeddingService _embeddingService = FaceEmbeddingService();
  final FirestoreService _firestoreService = FirestoreService();
  final AttendanceService _attendanceService = AttendanceService();

  CameraService get cameraService => _cameraService;

  bool isLoading = false;
  bool _modelLoaded = false;

  File? capturedImage;
  Employee? matchedEmployee;
  double? matchScore;
  String? errorMessage;

  RecognitionProvider() {
    _loadEmbeddingModel();
  }

  Future<void> _loadEmbeddingModel() async {
    try {
      await _embeddingService.loadModel();
      _modelLoaded = true;
    } catch (e) {
      debugPrint("❌ Failed to load embedding model: $e");
    }
  }

  Future<void> initializeCamera() async {
    if (_cameraService.controller?.value.isInitialized == true) return;
    isLoading = true;
    notifyListeners();
    try {
      await _cameraService.initialize();
    } catch (e) {
      debugPrint("Camera Initialize Error: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> captureFace() async {
    final image = await _cameraService.captureImage();
    if (image != null) {
      capturedImage = image;
      notifyListeners();
    }
  }

  /// -----------------------------
  /// switch camera
  /// -----------------------------

  Future<void> switchCamera() async {
    isLoading = true;
    notifyListeners();

    try {
      await _cameraService.switchCamera();
    } catch (e) {
      debugPrint("Switch Camera Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// -----------------------------
  /// Recognize captured face
  /// -----------------------------
  Future<void> recognizeFace() async {
    matchedEmployee = null;
    matchScore = null;
    errorMessage = null;

    if (capturedImage == null) {
      throw Exception("Please capture a face first.");
    }

    if (!_modelLoaded) {
      await _loadEmbeddingModel();
      if (!_modelLoaded) {
        throw Exception("Face recognition model failed to load.");
      }
    }

    isLoading = true;
    notifyListeners();

    try {
      // ---- Detect Face ----
      final faces = await _faceDetectionService.detectFaces(capturedImage!);

      if (faces.isEmpty) {
        throw Exception("No face detected. Try again.");
      }
      if (faces.length > 1) {
        throw Exception("Multiple faces detected. Only one person at a time.");
      }

      // ---- Crop Face ----
      final croppedFile = await FaceCropService.cropFace(
        imageFile: capturedImage!,
        face: faces.first,
      );

      // ---- Generate Embedding ----
      final capturedEmbedding = await _embeddingService.getEmbedding(
        croppedFile,
      );

      // ---- Fetch all employees ----
      final employees = await _firestoreService.getAllEmployees();

      if (employees.isEmpty) {
        throw Exception("No registered employees found.");
      }

      // ---- Find best match ----
      Employee? bestEmployee;
      double bestScore = -1.0;

      for (final employee in employees) {
        final score = FaceMatchingService.cosineSimilarity(
          capturedEmbedding,
          employee.embedding,
        );
        if (score > bestScore) {
          bestScore = score;
          bestEmployee = employee;
        }
      }

      if (bestEmployee == null ||
          bestScore < FaceMatchingService.matchThreshold) {
        errorMessage = "Face not recognized.";
        matchedEmployee = null;
        matchScore = bestScore;
      } else {
        matchedEmployee = bestEmployee;
        matchScore = bestScore;
        debugPrint("✅ Matched: ${bestEmployee.name} (score: $bestScore)");
        await _attendanceService.markAttendance(
          employeeId: bestEmployee.employeeId,
          name: bestEmployee.name,
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    capturedImage = null;
    matchedEmployee = null;
    matchScore = null;
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _faceDetectionService.dispose();
    _embeddingService.dispose();
    super.dispose();
  }
}
