import 'package:flutter/material.dart';

class AdminDashboardCapsule extends StatefulWidget {
  const AdminDashboardCapsule({super.key});

  @override
  State<AdminDashboardCapsule> createState() => _AdminDashboardCapsuleState();
}

class _AdminDashboardCapsuleState extends State<AdminDashboardCapsule> {
  int activeUsers = 1247;
  double totalVolume = 2450000;
  int pendingDisputes = 12;
  double systemUptime = 99.97;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('⚙️ Admin Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('System Metrics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildMetricCard('Active Users', '$activeUsers', Colors.blue),
                _buildMetricCard(
                    'Total Volume',
                    '\$${(totalVolume / 1000000).toStringAsFixed(1)}M',
                    Colors.green),
                _buildMetricCard(
                    'Pending Disputes', '$pendingDisputes', Colors.orange),
                _buildMetricCard('System Uptime',
                    '${systemUptime.toStringAsFixed(2)}%', Colors.teal),
              ],
            ),
            const SizedBox(height: 24),
            const Text('System Controls',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...[
              ('View Audit Logs', Icons.description),
              ('Manage Capsules', Icons.dashboard),
              ('User Data Export', Icons.download),
              ('Blockchain Transactions', Icons.link),
              ('Payment Processing', Icons.payment),
              ('Dispute Workflows', Icons.gavel),
            ].map((item) {
              final (label, icon) = item;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(icon, color: Colors.blue),
                  title: Text(label),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
