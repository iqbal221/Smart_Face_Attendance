import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_face_attendance/features/attendance/provider/employee_attendance_details_provider.dart';

class EmployeeAttendanceDetailScreen extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  const EmployeeAttendanceDetailScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  State<EmployeeAttendanceDetailScreen> createState() =>
      _EmployeeAttendanceDetailScreenState();
}

class _EmployeeAttendanceDetailScreenState
    extends State<EmployeeAttendanceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeAttendanceDetailProvider>().load(widget.employeeId);
    });
  }

  String _formatDate(DateTime dt) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeAttendanceDetailProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.employeeName)),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
          ? Center(child: Text(provider.errorMessage!))
          : provider.dateStatuses.isEmpty
          ? const Center(child: Text("No attendance records yet."))
          : Column(
              children: [
                // NEW: Month selector dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Month",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      DropdownButton<MonthKey>(
                        value: provider.selectedMonth,
                        items: provider.availableMonths
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(m.label),
                              ),
                            )
                            .toList(),
                        onChanged: (m) {
                          if (m != null) provider.selectMonth(m);
                        },
                      ),
                    ],
                  ),
                ),

                // Present / Absent counts — now monthly
                Container(
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            "${provider.presentCount}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Text("Present"),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "${provider.absentCount}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const Text("Absent"),
                        ],
                      ),
                    ],
                  ),
                ),

                // List — now filtered to selected month
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.filteredStatuses.length,
                    itemBuilder: (context, index) {
                      final status = provider.filteredStatuses[index];
                      return ListTile(
                        leading: Icon(
                          status.isPresent ? Icons.check_circle : Icons.cancel,
                          color: status.isPresent ? Colors.green : Colors.red,
                        ),
                        title: Text(_formatDate(status.date)),
                        trailing: Text(
                          status.isPresent ? "Present" : "Absent",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: status.isPresent ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
