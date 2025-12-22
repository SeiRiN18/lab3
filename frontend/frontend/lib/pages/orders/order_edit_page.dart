import 'package:flutter/material.dart';
import 'package:frontend/api/cars_api.dart';
import 'package:frontend/api/logs_api.dart';
import 'package:frontend/api/orders_api.dart';
import 'package:frontend/api/workers_api.dart';

class OrderEditPage extends StatefulWidget {
  final int? orderId;
  const OrderEditPage({super.key, this.orderId});

  @override
  State<OrderEditPage> createState() => _OrderEditPageState();
}

class _OrderEditPageState extends State<OrderEditPage> {
  Map? order;
  List workers = [];
  List cars = [];

  bool loading = true;

  String? status;
  int? workerId;
  int? carId;

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    if (widget.orderId != null) {
      await loadOrder();
    } else {
      status = "new";
    }
    await loadWorkers();
    await loadCars();

    setState(() => loading = false);
  }

  Future<void> loadOrder() async {
    if (widget.orderId == null) return;
    try {
      order = await OrdersApi.getById(widget.orderId!);
      status = order!["status"];
      workerId = order!["worker_id"];
      carId = order!["car_id"];
    } catch (_) {}
  }

  Future<void> loadWorkers() async {
    try {
      workers = await WorkersApi.getAll();
    } catch (_) {}
  }

  Future<void> loadCars() async {
    try {
      cars = await CarsApi.getAll();
    } catch (_) {}
  }

  Future<void> save() async {
    if (workerId == null || carId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select worker and car")));
      return;
    }

    final body = {"status": status, "worker_id": workerId, "car_id": carId};

    String message = "Failed to save order";
    try {
      if (widget.orderId == null) {
        await OrdersApi.create(body);
      } else {
        await OrdersApi.update(widget.orderId!, body);
      }
      if (!mounted) return;
      Navigator.pop(context);
      return;
    } catch (e) {
      message = e.toString();
    }

    try {
      final logs = await LogsApi.getBlockedLogs();
      if (logs.isNotEmpty) {
        final details = logs.first['details'];
        if (details != null) message = details.toString();
      }
    } catch (_) {}

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.orderId == null ? "Add Order" : "Edit Order"),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderId == null ? "Add Order" : "Edit Order"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: status,
            decoration: const InputDecoration(labelText: "Status"),
            items: [
              "new",
              "in_progress",
              "completed",
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => status = v),
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<int>(
            initialValue: workerId,
            decoration: const InputDecoration(labelText: "Worker"),
            items: workers
                .map<DropdownMenuItem<int>>(
                  (w) => DropdownMenuItem(
                    value: w["worker_id"],
                    child: Text("${w['name']} ${w['surname']}"),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => workerId = v),
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<int>(
            initialValue: carId,
            decoration: const InputDecoration(labelText: "Car"),
            items: cars
                .map<DropdownMenuItem<int>>(
                  (c) => DropdownMenuItem(
                    value: c["car_id"],
                    child: Text("${c['brand']} ${c['model']}"),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => carId = v),
          ),

          const SizedBox(height: 20),

          ElevatedButton(onPressed: save, child: const Text("Save")),
        ],
      ),
    );
  }
}
