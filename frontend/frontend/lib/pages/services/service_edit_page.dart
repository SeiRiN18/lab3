import 'package:flutter/material.dart';
import 'package:frontend/api/services_api.dart';

class ServiceEditPage extends StatefulWidget {
  final Map? service;
  final VoidCallback onSaved;

  const ServiceEditPage({super.key, this.service, required this.onSaved});

  @override
  State<ServiceEditPage> createState() => _ServiceEditPageState();
}

class _ServiceEditPageState extends State<ServiceEditPage> {
  late TextEditingController nameC;
  late TextEditingController priceC;
  late TextEditingController descriptionC;

  @override
  void initState() {
    super.initState();
    final s = widget.service;

    nameC = TextEditingController(text: s?['name'] ?? '');
    priceC = TextEditingController(text: s?['price']?.toString() ?? '');
    descriptionC = TextEditingController(text: s?['description'] ?? '');
  }

  Future<void> saveService() async {
    final priceValue = double.tryParse(priceC.text);
    if (priceValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid price')),
      );
      return;
    }

    final body = {
      "name": nameC.text,
      "price": priceValue,
      "description": descriptionC.text,
    };

    if (widget.service == null) {
      await ServicesApi.create(body);
    } else {
      await ServicesApi.update(widget.service!['service_id'], body);
    }

    widget.onSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.service != null;

    return Scaffold(
      appBar: AppBar(title: Text(editing ? "Edit Service" : "Add Service")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: priceC,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Price"),
            ),
            TextField(
              controller: descriptionC,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveService,
              child: Text(editing ? "Save Changes" : "Create Service"),
            ),
          ],
        ),
      ),
    );
  }
}
