import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceEmbeddingService {
  Interpreter? _interpreter;

  static const int inputSize = 112; // MobileFaceNet expects 112x112
  static const int embeddingSize = 192; // output embedding length

  /// Load the model once (call this during app/provider init)
  Future<void> loadModel() async {
    _interpreter ??= await Interpreter.fromAsset(
      'assets/models/mobilefacenet.tflite',
    );
  }

  Future<List<double>> getEmbedding(File croppedFaceImage) async {
    if (_interpreter == null) {
      throw Exception("Model not loaded. Call loadModel() first.");
    }

    final bytes = await croppedFaceImage.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("Failed to decode cropped face image.");
    }

    final resized = img.copyResize(image, width: inputSize, height: inputSize);

    final input = _imageToByteListFloat32(
      resized,
    ); // now a nested List, not Float32List

    final output = List.generate(1, (_) => List.filled(embeddingSize, 0.0));

    _interpreter!.run(input, output);

    return List<double>.from(output[0]);
  }

  List _imageToByteListFloat32(img.Image image) {
    final convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    final buffer = Float32List.view(convertedBytes.buffer);

    int pixelIndex = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);

        buffer[pixelIndex++] = (pixel.r - 127.5) / 127.5;
        buffer[pixelIndex++] = (pixel.g - 127.5) / 127.5;
        buffer[pixelIndex++] = (pixel.b - 127.5) / 127.5;
      }
    }

    // Return nested list directly — no cast to Float32List
    return convertedBytes.reshape([1, inputSize, inputSize, 3]);
  }

  void dispose() {
    _interpreter?.close();
  }
}
