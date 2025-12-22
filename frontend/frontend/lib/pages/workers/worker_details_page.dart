import 'package:flutter/material.dart';
import 'package:frontend/api/functions_api.dart';
import 'package:frontend/api/orders_api.dart';
import 'package:frontend/api/orderservices_api.dart';
import 'package:frontend/api/services_api.dart';
import 'package:frontend/api/workers_api.dart';
import 'package:frontend/widgets/info_card.dart';
import 'package:frontend/widgets/section_title.dart';

class WorkerDetailsPage extends StatefulWidget {
  final int workerId;

  const WorkerDetailsPage({super.key, required this.workerId});

  @override
  State<WorkerDetailsPage> createState() => _WorkerDetailsPageState();
}

class _WorkerDetailsPageState extends State<WorkerDetailsPage> {
  Map? worker;
  List orders = [];
  Map? popularService;
  final Map<int, Map> serviceCache = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await loadWorker();
    await loadOrders();
    await loadPopularService();
  }

  Future<void> loadWorker() async {
    try {
      final data = await WorkersApi.getById(widget.workerId);
      setState(() => worker = data);
    } catch (_) {}
  }

  Future<void> loadOrders() async {
    try {
      final data = await OrdersApi.getByWorker(widget.workerId);
      setState(() => orders = data);
    } catch (_) {}
  }

  Future<void> loadPopularService() async {
    if (worker == null) return;

    final name = worker!['name'];
    final surname = worker!['surname'];

    try {
      final list = await FunctionsApi.getPopularService(name, surname);
      if (list.isNotEmpty) setState(() => popularService = list[0]);
    } catch (_) {}
  }

  Future<List> loadOrderServices(int orderId) async {
    try {
      return await OrderServicesApi.getByOrder(orderId);
    } catch (_) {
      return [];
    }
  }

  Future<Map?> loadService(int id) async {
    if (serviceCache.containsKey(id)) return serviceCache[id];
    try {
      final data = await ServicesApi.getById(id);
      serviceCache[id] = data;
      return data;
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (worker == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Worker details")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("${worker!['name']} ${worker!['surname']}")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle("Worker info"),
          const SizedBox(height: 8),
          _buildWorkerCard(),
          const SizedBox(height: 20),
          const SectionTitle("Popular service"),
          const SizedBox(height: 8),
          _buildPopularServiceCard(),
          const SizedBox(height: 20),
          const SectionTitle("Orders and services"),
          const SizedBox(height: 8),
          _buildOrdersList(),
        ],
      ),
    );
  }

  Widget _buildWorkerCard() {
    return InfoCard(
      elevation: 3,
      children: [
        Text("Worker ID: ${worker!['worker_id']}"),
        Text("Name: ${worker!['name']}"),
        Text("Surname: ${worker!['surname']}"),
        Text(
          "Position: ${worker!['position']}",
          style: const TextStyle(fontSize: 18),
        ),
        Text("Phone: ${worker!['phone']}"),
        if (worker!['description'] != null)
          Text("Note: ${worker!['description']}"),
      ],
    );
  }

  Widget _buildPopularServiceCard() {
    return InfoCard(
      elevation: 3,
      children: [
        if (popularService == null)
          const Text("No popular service found")
        else ...[
          const Text(
            "Most Popular Service:",
            style: TextStyle(fontSize: 18),
          ),
          Text("Service: ${popularService!['service_name']}"),
          Text("Used: ${popularService!['counter']} times"),
        ],
      ],
    );
  }

  Widget _buildOrdersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final order in orders)
          FutureBuilder(
            future: loadOrderServices(order['order_id']),
            builder: (context, snapshot) {
              final services = snapshot.data ?? [];

              return Card(
                child: ExpansionTile(
                  title: Text(
                    "Order #${order['order_id']} | ${order['status']}",
                  ),
                  subtitle: Text("Date: ${order['order_date']}"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Order ID: ${order['order_id']}"),
                          Text("Date: ${order['order_date']}"),
                          Text("Status: ${order['status']}"),
                          Text("Worker ID: ${order['worker_id']}"),
                          Text("Car ID: ${order['car_id']}"),
                        ],
                      ),
                    ),
                    for (final s in services)
                      FutureBuilder(
                        future: loadService(s['service_id']),
                        builder: (context, serviceSnapshot) {
                          final service = serviceSnapshot.data;
                          final title = service == null
                              ? "Service ID: ${s['service_id']}"
                              : "Service: ${service['name']}";
                          return ListTile(
                            title: Text(title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "OrderService ID: ${s['order_services_id']}",
                                ),
                                Text("Service ID: ${s['service_id']}"),
                                Text("Quantity: ${s['quantity']}"),
                                Text("Unit price: ${s['unit_price']}"),
                                Text("Total price: ${s['total_price']}"),
                                if (service != null) ...[
                                  const SizedBox(height: 6),
                                  Text("Service ID: ${service['service_id']}"),
                                  Text("Name: ${service['name']}"),
                                  Text("Price: ${service['price']}"),
                                  if (service['description'] != null)
                                    Text(
                                      "Description: ${service['description']}",
                                    ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

