import 'package:flutter/material.dart';
import 'package:frontend/api/functions_api.dart';
import 'package:frontend/api/orders_api.dart';
import 'package:frontend/api/orderservices_api.dart';
import 'package:frontend/api/procedures_api.dart';
import 'package:frontend/api/services_api.dart';
import 'package:frontend/widgets/info_card.dart';
import 'package:frontend/widgets/section_title.dart';

class ServiceDetailsPage extends StatefulWidget {
  final int serviceId;

  const ServiceDetailsPage({super.key, required this.serviceId});

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  Map? service;
  List orderServices = [];
  final Map<int, Map> orderCache = {};
  late final TextEditingController discountC;
  bool applyingDiscount = false;
  num? totalRevenue;

  @override
  void initState() {
    super.initState();
    discountC = TextEditingController();
    loadData();
  }

  @override
  void dispose() {
    discountC.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    await loadService();
    await loadRevenue();
    await loadOrderServices();
  }

  Future<void> loadService() async {
    try {
      final data = await ServicesApi.getById(widget.serviceId);
      setState(() => service = data);
    } catch (_) {}
  }

  Future<void> loadOrderServices() async {
    try {
      final data = await OrderServicesApi.getByService(widget.serviceId);
      setState(() => orderServices = data);
    } catch (_) {}
  }

  Future<void> loadRevenue() async {
    try {
      final data = await FunctionsApi.getServiceRevenue(widget.serviceId);
      final value = data['total_revenue'];
      setState(() => totalRevenue = _toNum(value));
    } catch (_) {}
  }

  Future<Map?> loadOrder(int id) async {
    if (orderCache.containsKey(id)) return orderCache[id];
    try {
      final data = await OrdersApi.getById(id);
      orderCache[id] = data;
      return data;
    } catch (_) {}
    return null;
  }

  Future<void> applyDiscount() async {
    final serviceName = service?['name'];
    if (serviceName == null) return;

    final percent = int.tryParse(discountC.text);
    if (percent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid percent (0-100)")),
      );
      return;
    }

    setState(() => applyingDiscount = true);
    try {
      final body = await ProceduresApi.applyDiscount(
        serviceName: serviceName,
        percent: percent,
      );
      final message = body['message'] ?? body['error'] ?? "Unknown response";
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message.toString())));

      await loadService();
      setState(() {});
    } finally {
      if (mounted) setState(() => applyingDiscount = false);
    }
  }

  num? computeTotal(Map item) {
    final total = _toNum(item['total_price']);
    if (total != null) return total;
    final quantity = _toNum(item['quantity']);
    final unitPrice = _toNum(item['unit_price']);
    if (quantity == null || unitPrice == null) return null;
    return quantity * unitPrice;
  }

  num? _toNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Service details")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(service!['name'])),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle("Service info"),
          const SizedBox(height: 8),
          _buildServiceCard(),
          const SizedBox(height: 20),
          const SectionTitle("Apply discount"),
          const SizedBox(height: 8),
          _buildDiscountCard(),
          const SizedBox(height: 20),
          const SectionTitle("Total revenue"),
          const SizedBox(height: 8),
          _buildRevenueCard(),
          const SizedBox(height: 20),
          const SectionTitle("Orders with this service"),
          const SizedBox(height: 8),
          _buildOrdersList(),
        ],
      ),
    );
  }

  Widget _buildDiscountCard() {
    return InfoCard(
      elevation: 3,
      children: [
        TextField(
          controller: discountC,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Discount percent",
            hintText: "0-100",
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: applyingDiscount ? null : applyDiscount,
          child: Text(applyingDiscount ? "Applying..." : "Apply discount"),
        ),
      ],
    );
  }

  Widget _buildRevenueCard() {
    return InfoCard(
      elevation: 3,
      children: [
        totalRevenue == null
            ? const Text("No revenue data")
            : Text("Total revenue: $totalRevenue"),
      ],
    );
  }

  Widget _buildServiceCard() {
    return InfoCard(
      elevation: 3,
      children: [
        Text("Service ID: ${service!['service_id']}"),
        Text("Name: ${service!['name']}"),
        Text(
          "Price: ${service!['price']}",
          style: const TextStyle(fontSize: 18),
        ),
        if (service!['description'] != null)
          Text("Description: ${service!['description']}"),
      ],
    );
  }

  Widget _buildOrdersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in orderServices)
          Card(
            child: FutureBuilder(
              future: loadOrder(item['order_id']),
              builder: (context, snapshot) {
                final order = snapshot.data;
                return ListTile(
                  title: Text("Order #${item['order_id']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order != null) ...[
                        Text("Order ID: ${order['order_id']}"),
                        Text("Date: ${order['order_date']}"),
                        Text("Status: ${order['status']}"),
                        Text("Worker ID: ${order['worker_id']}"),
                        Text("Car ID: ${order['car_id']}"),
                        const SizedBox(height: 6),
                      ],
                      Text("OrderService ID: ${item['order_services_id']}"),
                      Text("Service ID: ${item['service_id']}"),
                      Text("Quantity: ${item['quantity']}"),
                      Text("Unit price: ${item['unit_price']}"),
                      Text("Total price: ${item['total_price']}"),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
