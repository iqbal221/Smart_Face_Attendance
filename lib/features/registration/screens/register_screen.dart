import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_face_attendance/features/attendance/screens/attendance_screen.dart';
import 'package:smart_face_attendance/features/core/screens/main_nav_screen.dart';
import 'package:smart_face_attendance/features/registration/provider/registration_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String name = "/register_screen";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegisterProvider>().initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterProvider>();

    final isLoading = provider.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text("Register Employee")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: provider.nameController,
                    decoration: const InputDecoration(
                      labelText: "Employee Name",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: provider.employeeIdController,
                    decoration: const InputDecoration(
                      labelText: "Employee ID",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (provider.cameraService.controller != null &&
                      provider.cameraService.controller!.value.isInitialized)
                    Stack(
                      children: [
                        Container(
                          height: 350,
                          width: double.infinity,
                          color: Colors.black,
                          child: CameraPreview(
                            provider.cameraService.controller!,
                          ),
                        ),
                        if (provider.cameraService.hasMultipleCameras)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: CircleAvatar(
                              backgroundColor: Colors.black45,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.cameraswitch,
                                  color: Colors.white,
                                ),
                                onPressed: provider.switchCamera,
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    const SizedBox(
                      height: 350,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: provider.captureFace,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Capture Face"),
                  ),

                  const SizedBox(height: 20),

                  if (provider.capturedImage != null)
                    Column(
                      children: [
                        const Text(
                          "Captured Face",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            provider.capturedImage!,
                            height: 250,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  Column(
                    spacing: 4,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await provider.registerEmployee();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Face detected successfully."),
                              ),
                            );
                            Navigator.pushNamed(
                              context,
                              AttendanceCheckInScreen.name,
                            );
                          } catch (e) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },

                        child: const Text("Register Employee"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
