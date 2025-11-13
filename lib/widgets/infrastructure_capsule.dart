import 'dart:convert';
import 'package:flutter/material.dart';

class InfrastructureCapsule extends StatelessWidget {
  const InfrastructureCapsule({super.key});

  // Sample data for infrastructure status
  final Map<String, dynamic> _sampleData = const {
    "frontend": {"framework": "Flutter Web + Native", "status": "Operational"},
    "backend": {"services": "Cloud Run, Lambda", "status": "Operational"},
    "database": {"type": "Firestore + PostgreSQL", "sync_status": "Active"},
    "encryption": {"provider": "VaultGemma + RSA-4096", "status": "Active"},
    "blockchain": {"network": "Polygon Mainnet", "hooks": "Active"},
    "cdn": {"provider": "Cloudflare", "status": "Active"},
    "monitoring": {"services": "Sentry, DataDog", "triggers": "Active"}
  };

  String _getJsonData() {
    return jsonEncode(_sampleData);
  }

  void _triggerXmcpOrchestration(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              "XMCP orchestration for infrastructure management triggered!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade800, Colors.blueGrey.shade700],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildCard("Infrastructure Status", _buildStatusDashboard()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.layers, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                "Infrastructure Overview",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.cloud_upload_outlined,
                    color: Colors.white),
                onPressed: () => _triggerXmcpOrchestration(context),
                tooltip: "XMCP Orchestration",
              ),
              IconButton(
                icon: const Icon(Icons.code, color: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("JSON Export"),
                      content:
                          SingleChildScrollView(child: Text(_getJsonData())),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Close"),
                        )
                      ],
                    ),
                  );
                },
                tooltip: "Export as JSON",
              ),
              const Icon(
                Icons.shield_sharp,
                color: Colors.greenAccent,
                size: 20,
                semanticLabel: "VaultGemma Encrypted",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, Widget content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 8,
      color: Colors.blueGrey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDashboard() {
    return Column(
      children: [
        _buildStatusRow("Frontend", _sampleData["frontend"]["framework"],
            _sampleData["frontend"]["status"]),
        _buildStatusRow("Backend", _sampleData["backend"]["services"],
            _sampleData["backend"]["status"]),
        _buildStatusRow("Database", _sampleData["database"]["type"],
            _sampleData["database"]["sync_status"]),
        _buildStatusRow("Encryption", _sampleData["encryption"]["provider"],
            _sampleData["encryption"]["status"]),
        _buildStatusRow("Blockchain", _sampleData["blockchain"]["network"],
            _sampleData["blockchain"]["hooks"]),
        _buildStatusRow("CDN", _sampleData["cdn"]["provider"],
            _sampleData["cdn"]["status"]),
        _buildStatusRow("Monitoring", _sampleData["monitoring"]["services"],
            _sampleData["monitoring"]["triggers"]),
      ],
    );
  }

  Widget _buildStatusRow(String component, String details, String status) {
    return ListTile(
      leading: Icon(_getIconForComponent(component), color: Colors.white),
      title: Text(component,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(details, style: const TextStyle(color: Colors.white70)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.toLowerCase() == 'active' ||
                    status.toLowerCase() == 'operational'
                ? Icons.check_circle
                : Icons.warning,
            color: status.toLowerCase() == 'active' ||
                    status.toLowerCase() == 'operational'
                ? Colors.greenAccent
                : Colors.orangeAccent,
          ),
          const SizedBox(width: 8),
          Text(status, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  IconData _getIconForComponent(String component) {
    switch (component) {
      case "Frontend":
        return Icons.web;
      case "Backend":
        return Icons.dns;
      case "Database":
        return Icons.storage;
      case "Encryption":
        return Icons.security;
      case "Blockchain":
        return Icons.link;
      case "CDN":
        return Icons.public;
      case "Monitoring":
        return Icons.monitor_heart;
      default:
        return Icons.layers;
    }
  }
}
