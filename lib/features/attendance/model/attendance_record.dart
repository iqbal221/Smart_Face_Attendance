class AttendanceRecord {
  final String id;
  final String employeeId;
  final String name;
  final DateTime timestamp;

  AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.timestamp,
  });

  factory AttendanceRecord.fromMap(String id, Map<String, dynamic> map) {
    return AttendanceRecord(
      id: id,
      employeeId: map['employeeId'] ?? '',
      name: map['name'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
