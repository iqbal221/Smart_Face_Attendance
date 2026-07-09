import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_face_attendance/features/attendance/provider/employee_attendance_details_provider.dart';
import 'package:smart_face_attendance/features/attendance/screens/employee_attendance_details.dart';
import '../model/attendance_record.dart';
import '../provider/attendance_report_provider.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceReportProvider>().loadRecords();
    });
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $period";
  }

  void _openEmployeeDetail(AttendanceRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => EmployeeAttendanceDetailProvider(),
          child: EmployeeAttendanceDetailScreen(
            employeeId: record.employeeId,
            employeeName: record.name,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceReportProvider>();
    final grouped = provider.groupedByDate;
    final dateKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    print("data: $dateKeys");

    // Flatten into a single ordered list so serial numbers stay correct.
    final List<Widget> items = [];
    int serial = 0;

    for (final dateKey in dateKeys) {
      items.add(
        Container(
          width: double.infinity,
          color: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            dateKey,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      );

      for (final record in grouped[dateKey]!) {
        serial++;
        items.add(
          ListTile(
            leading: CircleAvatar(child: Text("$serial")),
            title: InkWell(
              onTap: () => _openEmployeeDetail(record),
              child: Text(
                record.name,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            subtitle: Text("ID: ${record.employeeId}"),
            trailing: Text(
              _formatTime(record.timestamp),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Report"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadRecords(),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
          ? Center(child: Text(provider.errorMessage!))
          : provider.records.isEmpty
          ? const Center(child: Text("No attendance records yet."))
          : RefreshIndicator(
              onRefresh: () => provider.loadRecords(),
              child: ListView(children: items),
            ),
    );
  }
}
