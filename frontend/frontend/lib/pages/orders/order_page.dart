import 'package:flutter/material.dart';
import 'package:frontend/api/cars_api.dart';
import 'package:frontend/api/orders_api.dart';
import 'package:frontend/api/workers_api.dart';
import 'package:frontend/pages/orders/order_details_page.dart';
import 'package:frontend/pages/orders/order_edit_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      final data = await OrdersApi.getAll();
      setState(() => orders = data);
    } catch (_) {}
  }

  Future<Map?> loadWorker(int id) async {
    try {
      return await WorkersApi.getById(id);
    } catch (_) {
      return null;
    }
  }

  Future<Map?> loadCar(int id) async {
    try {
      return await CarsApi.getById(id);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteOrder(int id) async {
    try {
      await OrdersApi.delete(id);
    } finally {
      await loadOrders();
    }
  }

  Future<void> openEditOrder(Map order) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderEditPage(orderId: order['order_id']),
      ),
    ).then((_) => loadOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Orders")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderEditPage()),
          ).then((_) => loadOrders());
        },
        child: const Icon(Icons.add),
      ),
      body: orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: orders
                  .map<Widget>((o) => _orderCard(o as Map<String, dynamic>))
                  .toList(),
            ),
    );
  }

  Widget _orderCard(Map order) {
    return FutureBuilder(
      future: Future.wait([
        loadWorker(order["worker_id"]),
        loadCar(order["car_id"]),
      ]),
      builder: (context, snapshot) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: !snapshot.hasData
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: LinearProgressIndicator(),
                )
              : ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            OrderDetailsPage(orderId: order['order_id']),
                      ),
                    );
                  },
                  title: Text(
                    "Order #${order['order_id']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date: ${order['order_date']}"),
                      Text("Status: ${order['status']}"),
                      if (snapshot.data![0] != null)
                        Text(
                          "Worker: ${snapshot.data![0]?['name']} ${snapshot.data![0]?['surname']}",
                        ),
                      if (snapshot.data![1] != null)
                        Text(
                          "Car: ${snapshot.data![1]?['brand']} ${snapshot.data![1]?['model']}",
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => openEditOrder(order),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteOrder(order['order_id']),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
