import 'dart:math';

class FaceMatchingService {
  static const double matchThreshold = 0.65;

  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw Exception("Embedding length mismatch: ${a.length} vs ${b.length}");
    }
    double dot = 0.0, normA = 0.0, normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA == 0 || normB == 0) return 0.0;
    return dot / (sqrt(normA) * sqrt(normB));
  }
}
