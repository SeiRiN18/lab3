import 'package:flutter/material.dart';
import 'package:frontend/pages/services/service_details_page.dart';
import 'package:frontend/pages/services/service_edit_page.dart';
import 'package:frontend/api/services_api.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List services = [];

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    try {
      final data = await ServicesApi.getAll();
      setState(() => services = data);
    } catch (_) {}
  }

  Future<void> deleteService(int id) async {
    try {
      await ServicesApi.delete(id);
    } finally {
      await loadServices();
    }
  }

  Future<void> openAddService() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServiceEditPage(onSaved: loadServices)),
    );
  }

  Future<void> openEditService(Map service) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceEditPage(service: service, onSaved: loadServices),
      ),
    );
  }

  Widget serviceCard(Map service) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ServiceDetailsPage(serviceId: service['service_id']),
            ),
          ).then((_) => loadServices());
        },
        title: Text(
          service['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Price: ${service['price']}"),
            if (service['description'] != null)
              Text("Description: ${service['description']}"),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => openEditService(service),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteService(service['service_id']),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Services")),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddService,
        child: const Icon(Icons.add),
      ),
      body: services.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: services
                  .map<Widget>((s) => serviceCard(s as Map<String, dynamic>))
                  .toList(),
            ),
    );
  }
}
