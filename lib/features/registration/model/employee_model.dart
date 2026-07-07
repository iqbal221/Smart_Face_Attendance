class Employee {
  final String employeeId;
  final String name;
  final String imageUrl;
  final List<double> embedding;
  final DateTime createdAt;

  Employee({
    required this.employeeId,
    required this.name,
    required this.imageUrl,
    required this.embedding,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'name': name,
      'imageUrl': imageUrl,
      'embedding': embedding,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      employeeId: map['employeeId'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      embedding: (map['embedding'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
