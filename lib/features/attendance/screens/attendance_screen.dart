import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:smart_face_attendance/features/attendance/provider/RecognitionProvider.dart';

class AttendanceCheckInScreen extends StatefulWidget {
  const AttendanceCheckInScreen({super.key});

  static const String name = "/attendance_checkin_screen";

  @override
  State<AttendanceCheckInScreen> createState() =>
      _AttendanceCheckInScreenState();
}

class _AttendanceCheckInScreenState extends State<AttendanceCheckInScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecognitionProvider>().initializeCamera();
    });
  }

  Future<void> _scanFace(RecognitionProvider provider) async {
    try {
      await provider.captureFace();
      await provider.recognizeFace();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecognitionProvider>();
    final controller = provider.cameraService.controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Check-In"),
        actions: [
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => provider.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: controller != null && controller.value.isInitialized
                ? CameraPreview(controller)
                : const Center(child: CircularProgressIndicator()),
          ),
          if (provider.matchedEmployee != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.green.withOpacity(0.1),
              child: Column(
                children: [
                  Text(
                    "✅ Welcome, ${provider.matchedEmployee!.name}",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "ID: ${provider.matchedEmployee!.employeeId}  •  Score: ${provider.matchScore!.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          if (provider.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red.withOpacity(0.1),
              child: Text(
                "❌ ${provider.errorMessage}",
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.face_retouching_natural),
                label: Text(provider.isLoading ? "Processing..." : "Scan Face"),
                onPressed: provider.isLoading
                    ? null
                    : () {
                        provider.reset();
                        _scanFace(provider);
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
