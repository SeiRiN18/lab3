import 'package:flutter/material.dart';
import 'package:frontend/api/cars_api.dart';
import 'package:frontend/api/clients_api.dart';
import 'package:frontend/api/orders_api.dart';
import 'package:frontend/api/orderservices_api.dart';
import 'package:frontend/api/services_api.dart';
import 'package:frontend/api/workers_api.dart';
import 'package:frontend/widgets/info_card.dart';
import 'package:frontend/widgets/section_title.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;
  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Map? order;
  Map? worker;
  Map? car;
  Map? client;
  List services = [];
  final Map<int, Map> serviceCache = {};

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    await loadOrder();
    await loadWorker();
    await loadCar();
    await loadClient();
    await loadServices();
    setState(() {});
  }

  Future<void> loadOrder() async {
    try {
      order = await OrdersApi.getById(widget.orderId);
    } catch (_) {}
  }

  Future<void> loadWorker() async {
    try {
      worker = await WorkersApi.getById(order!['worker_id']);
    } catch (_) {}
  }

  Future<void> loadCar() async {
    try {
      car = await CarsApi.getById(order!['car_id']);
    } catch (_) {}
  }

  Future<void> loadClient() async {
    if (car == null) return;
    try {
      client = await ClientsApi.getById(car!['client_id']);
    } catch (_) {}
  }

  Future<void> loadServices() async {
    try {
      services = await OrderServicesApi.getByOrder(widget.orderId);
    } catch (_) {}
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
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Order details")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Order #${order!['order_id']}")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle("Order info"),
          const SizedBox(height: 8),
          _infoCard(),
          if (worker != null) ...[
            const SizedBox(height: 20),
            const SectionTitle("Worker info"),
            const SizedBox(height: 8),
            _workerCard(),
          ],
          if (car != null) ...[
            const SizedBox(height: 20),
            const SectionTitle("Car info"),
            const SizedBox(height: 8),
            _carCard(),
          ],
          if (client != null) ...[
            const SizedBox(height: 20),
            const SectionTitle("Client info"),
            const SizedBox(height: 8),
            _clientCard(),
          ],
          const SizedBox(height: 20),
          _servicesCard(),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return InfoCard(
      elevation: 1,
      children: [
        Text("Order ID: ${order!['order_id']}"),
        Text("Date: ${order!['order_date']}"),
        Text("Status: ${order!['status']}"),
        Text("Worker ID: ${order!['worker_id']}"),
        Text("Car ID: ${order!['car_id']}"),
      ],
    );
  }

  Widget _workerCard() {
    return InfoCard(
      elevation: 1,
      children: [
        Text("Worker ID: ${worker!['worker_id']}"),
        Text("Name: ${worker!['name']}"),
        Text("Surname: ${worker!['surname']}"),
        Text("Position: ${worker!['position']}"),
        Text("Phone: ${worker!['phone']}"),
        if (worker!['description'] != null)
          Text("Description: ${worker!['description']}"),
      ],
    );
  }

  Widget _carCard() {
    return InfoCard(
      elevation: 1,
      children: [
        Text("Car ID: ${car!['car_id']}"),
        Text("Brand: ${car!['brand']}"),
        Text("Model: ${car!['model']}"),
        Text("Year: ${car!['year']}"),
        Text("VIN: ${car!['vin_code']}"),
        Text("Client ID: ${car!['client_id']}"),
      ],
    );
  }

  Widget _clientCard() {
    return InfoCard(
      elevation: 1,
      children: [
        Text("Client ID: ${client!['client_id']}"),
        Text("Name: ${client!['name']}"),
        Text("Surname: ${client!['surname']}"),
        Text("Phone: ${client!['phone']}"),
      ],
    );
  }

  Widget _servicesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle("Services"),
            const SizedBox(height: 8),
            if (services.isEmpty) const Text("No services"),
            for (final s in services)
              FutureBuilder(
                future: loadService(s['service_id']),
                builder: (context, snapshot) {
                  final service = snapshot.data;
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
                            Text("Description: ${service['description']}"),
                        ],
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
