import 'package:flutter/material.dart';
import 'package:frontend/pages/workers/worker_details_page.dart';
import 'package:frontend/pages/workers/worker_edit_page.dart';
import 'package:frontend/api/workers_api.dart';

class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  State<WorkersPage> createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  List workers = [];

  @override
  void initState() {
    super.initState();
    loadWorkers();
  }

  Future<void> loadWorkers() async {
    try {
      final data = await WorkersApi.getAll();
      setState(() => workers = data);
    } catch (_) {}
  }

  Future<void> deleteWorker(int id) async {
    try {
      await WorkersApi.delete(id);
    } finally {
      await loadWorkers();
    }
  }

  Future<void> openAddWorker() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkerEditPage(onSaved: loadWorkers)),
    );
  }

  Future<void> openEditWorker(Map worker) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkerEditPage(worker: worker, onSaved: loadWorkers),
      ),
    );
  }

  Widget workerCard(Map worker) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkerDetailsPage(workerId: worker['worker_id']),
            ),
          );
        },
        title: Text(
          "${worker['name']} ${worker['surname']}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Position: ${worker['position']}"),
            Text("Phone: ${worker['phone']}"),
            if (worker['description'] != null)
              Text("Description: ${worker['description']}"),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => openEditWorker(worker),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteWorker(worker['worker_id']),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Workers")),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddWorker,
        child: const Icon(Icons.add),
      ),
      body: workers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: workers
                  .map<Widget>((w) => workerCard(w as Map<String, dynamic>))
                  .toList(),
            ),
    );
  }
}
