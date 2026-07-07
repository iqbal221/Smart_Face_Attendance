import 'dart:io';
import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  CameraDescription? get currentCamera =>
      _cameras.isNotEmpty ? _cameras[_currentCameraIndex] : null;

  bool get hasMultipleCameras => _cameras.length > 1;

  Future<void> initialize({int cameraIndex = 0}) async {
    print("📷 Getting available cameras...");
    _cameras = await availableCameras();

    if (_cameras.isEmpty) {
      throw Exception("No cameras found on this device.");
    }

    // Prefer front camera by default for face registration, fallback to first
    _currentCameraIndex = cameraIndex < _cameras.length ? cameraIndex : 0;

    print("📷 Selected camera: $_currentCameraIndex");
    await _initController(_cameras[_currentCameraIndex]);
  }

  Future<void> _initController(CameraDescription description) async {
    // Dispose old controller before creating a new one
    await controller?.dispose();

    controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    print("📷 Initializing controller...");
    await controller!.initialize();
    print("✅ Camera initialized successfully");
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return; // only one camera, nothing to switch

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _initController(_cameras[_currentCameraIndex]);
  }

  Future<File?> captureImage() async {
    if (controller == null || !controller!.value.isInitialized) return null;
    final file = await controller!.takePicture();
    return File(file.path);
  }

  void dispose() {
    controller?.dispose();
  }
}
