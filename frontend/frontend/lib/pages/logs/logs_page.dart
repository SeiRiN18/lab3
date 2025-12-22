import 'package:flutter/material.dart';
import 'package:frontend/api/logs_api.dart';
import 'package:frontend/widgets/section_title.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List orderLogs = [];
  List blockedLogs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadLogs();
  }

  Future<void> loadLogs() async {
    try {
      orderLogs = await LogsApi.getOrderLogs();
      blockedLogs = await LogsApi.getBlockedLogs();
    } catch (_) {}

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logs")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionTitle("Order logs"),
                if (orderLogs.isEmpty) const Text("No logs"),
                for (final log in orderLogs) _orderLogCard(log),
                const SizedBox(height: 20),
                const SectionTitle("Blocked order logs"),
                if (blockedLogs.isEmpty) const Text("No logs"),
                for (final log in blockedLogs) _blockedLogCard(log),
              ],
            ),
    );
  }

  Widget _orderLogCard(Map log) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text("Log ID: ${log['log_id']}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order ID: ${log['order_id']}"),
            Text("Time: ${log['time_of_modify']}"),
            if (log['details'] != null) Text("Details: ${log['details']}"),
          ],
        ),
      ),
    );
  }

  Widget _blockedLogCard(Map log) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text("Log ID: ${log['log_id']}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Time: ${log['time_of_attempt']}"),
            if (log['details'] != null) Text("Details: ${log['details']}"),
          ],
        ),
      ),
    );
  }
}
