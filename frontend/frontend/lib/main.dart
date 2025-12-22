import 'package:flutter/material.dart';
import 'package:frontend/pages/logs/logs_page.dart';
import 'package:frontend/pages/orders/order_page.dart';
import 'package:frontend/pages/services/services_page.dart';
import 'package:frontend/pages/workers/workers_page.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Car Service", home: MainMenu());
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Car Service App")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Workers"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => WorkersPage()),
            ),
          ),
          ListTile(
            title: Text("Orders"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OrdersPage()),
            ),
          ),
          ListTile(
            title: Text("Services"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ServicesPage()),
            ),
          ),
          ListTile(
            title: Text("Logs"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LogsPage()),
            ),
          ),
        ],
      ),
    );
  }
}
