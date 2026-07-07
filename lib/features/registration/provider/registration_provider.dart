import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:smart_face_attendance/features/registration/model/employee_model.dart';
import 'package:smart_face_attendance/features/registration/services/face_crop_service.dart';
import 'package:smart_face_attendance/features/registration/services/face_embedding_service.dart';
import 'package:smart_face_attendance/features/registration/services/firestore_service.dart';
import 'package:smart_face_attendance/features/registration/services/storage_service.dart';

import '../services/camera_service.dart';
import '../services/face_detection_service.dart';

class RegisterProvider extends ChangeNotifier {
  final CameraService _cameraService = CameraService();
  final FaceDetectionService _faceDetectionService = FaceDetectionService();
  final FaceEmbeddingService _embeddingService = FaceEmbeddingService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();

  RegisterProvider() {
    _loadEmbeddingModel(); // preload model when provider is created
  }

  bool isLoading = false;
  File? capturedImage;
  File? croppedFaceImage;
  List<double>? faceEmbedding; // add this
  String? uploadedImageUrl;

  List<Face> detectedFaces = [];

  CameraService get cameraService => _cameraService;

  bool _modelLoaded = false;

  Future<void> _loadEmbeddingModel() async {
    try {
      await _embeddingService.loadModel();
      _modelLoaded = true;
      debugPrint("✅ MobileFaceNet model loaded");
    } catch (e) {
      debugPrint("❌ Failed to load embedding model: $e");
    }
  }

  /// -----------------------------
  /// Initialize Camera
  /// -----------------------------
  bool _isCameraInitializing = false;

  Future<void> initializeCamera() async {
    if (_isCameraInitializing ||
        _cameraService.controller?.value.isInitialized == true) {
      return;
    }
    _isCameraInitializing = true;
    isLoading = true;
    notifyListeners();

    try {
      await _cameraService.initialize();
    } catch (e) {
      debugPrint("Camera Initialize Error: $e");
    }

    _isCameraInitializing = false;
    isLoading = false;
    notifyListeners();
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
  /// Capture Face
  /// -----------------------------
  Future<void> captureFace() async {
    final image = await _cameraService.captureImage();

    if (image != null) {
      capturedImage = image;
      notifyListeners();
    }
  }

  /// -----------------------------
  /// Detect Face using ML Kit
  /// -----------------------------
  Future<bool> detectFace() async {
    if (capturedImage == null) {
      throw Exception("Please capture a face.");
    }

    detectedFaces = await _faceDetectionService.detectFaces(capturedImage!);

    notifyListeners();

    if (detectedFaces.isEmpty) {
      throw Exception("No face detected.");
    }

    if (detectedFaces.length > 1) {
      throw Exception("Only one face is allowed.");
    }

    return true;
  }

  /// -----------------------------
  /// Register Employee
  /// -----------------------------
  Future<void> registerEmployee() async {
    final name = nameController.text.trim();
    final employeeId = employeeIdController.text.trim();

    if (name.isEmpty) {
      throw Exception("Please enter employee name.");
    }

    if (employeeId.isEmpty) {
      throw Exception("Please enter employee ID.");
    }

    if (capturedImage == null) {
      throw Exception("Please capture employee face.");
    }

    // Wait for model if not ready yet
    if (!_modelLoaded) {
      await _loadEmbeddingModel();
      if (!_modelLoaded) {
        throw Exception(
          "Face recognition model failed to load. Please restart the app.",
        );
      }
    }

    isLoading = true;
    notifyListeners();

    try {
      /// Detect Face
      await detectFace();

      // ---- Crop Face ----
      croppedFaceImage = await FaceCropService.cropFace(
        imageFile: capturedImage!,
        face: detectedFaces.first,
      );
      // ---- Generate Embedding ----
      faceEmbedding = await _embeddingService.getEmbedding(croppedFaceImage!);

      // inside registerEmployee(), after embedding generation:
      uploadedImageUrl = await _storageService.uploadFaceImage(
        imageFile: capturedImage!,
        employeeId: employeeId,
      );

      // ---- Save Firestore ----
      final employee = Employee(
        employeeId: employeeId,
        name: name,
        imageUrl: uploadedImageUrl!,
        embedding: faceEmbedding!,
        createdAt: DateTime.now(),
      );

      await _firestoreService.saveEmployee(employee);

      debugPrint("===============");
      debugPrint("✅ Employee registered successfully");
      debugPrint("Employee Name : $name");
      debugPrint("Employee ID   : $employeeId");
      debugPrint("Image URL     : $uploadedImageUrl");
      debugPrint("===============");

      // ------------------------------------
      // NEXT STEP
      //
      // Crop Face
      // MobileFaceNet
      // Generate Embedding
      // Upload Image
      // Save Firestore
      // ------------------------------------
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// -----------------------------
  /// Clear Form
  /// -----------------------------
  void clearForm() {
    nameController.clear();
    employeeIdController.clear();
    capturedImage = null;
    croppedFaceImage = null;
    faceEmbedding = null;
    uploadedImageUrl = null;
    detectedFaces.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    employeeIdController.dispose();

    _cameraService.dispose();
    _faceDetectionService.dispose();
    _embeddingService.dispose(); // add this

    super.dispose();
  }
}
