import 'package:flutter/material.dart';
import 'package:frontend/api/workers_api.dart';

class WorkerEditPage extends StatefulWidget {
  final Map? worker;
  final VoidCallback onSaved;

  const WorkerEditPage({super.key, this.worker, required this.onSaved});

  @override
  State<WorkerEditPage> createState() => _WorkerEditPageState();
}

class _WorkerEditPageState extends State<WorkerEditPage> {
  late TextEditingController nameC;
  late TextEditingController surnameC;
  late TextEditingController positionC;
  late TextEditingController phoneC;
  late TextEditingController descriptionC;

  @override
  void initState() {
    super.initState();
    final w = widget.worker;

    nameC = TextEditingController(text: w?['name'] ?? '');
    surnameC = TextEditingController(text: w?['surname'] ?? '');
    positionC = TextEditingController(text: w?['position'] ?? '');
    phoneC = TextEditingController(text: w?['phone'] ?? '');
    descriptionC = TextEditingController(text: w?['description'] ?? '');
  }

  Future<void> saveWorker() async {
    final body = {
      "name": nameC.text,
      "surname": surnameC.text,
      "position": positionC.text,
      "phone": phoneC.text,
      "description": descriptionC.text,
    };

    if (widget.worker == null) {
      await WorkersApi.create(body);
    } else {
      await WorkersApi.update(widget.worker!['worker_id'], body);
    }

    widget.onSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.worker != null;

    return Scaffold(
      appBar: AppBar(title: Text(editing ? "Edit Worker" : "Add Worker")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: surnameC,
              decoration: const InputDecoration(labelText: "Surname"),
            ),
            TextField(
              controller: positionC,
              decoration: const InputDecoration(labelText: "Position"),
            ),
            TextField(
              controller: phoneC,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
            TextField(
              controller: descriptionC,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveWorker,
              child: Text(editing ? "Save Changes" : "Create Worker"),
            ),
          ],
        ),
      ),
    );
  }
}
