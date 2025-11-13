import 'dart:convert';
import 'package:flutter/material.dart';

class RLUSDRoutingCapsule extends StatelessWidget {
  const RLUSDRoutingCapsule({super.key});

  // Sample data for RLUSD Routing
  final Map<String, dynamic> _sampleData = const {
    "deposit": {
      "amount": 10000.0,
      "currency": "RLUSD",
      "timestamp": "2025-11-12T11:00:00Z"
    },
    "routing_plan": [
      {"destination": "CreditCapsule", "amount": 5000.0},
      {"destination": "PayoutCapsule", "amount": 3000.0},
      {"destination": "FundingCapsule", "amount": 2000.0},
    ],
    "vaultGemmaSync": "Active",
    "xmcpStatus": "Ready"
  };

  String _getJsonData() {
    return jsonEncode(_sampleData);
  }

  void _triggerXmcpOrchestration(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("XMCP orchestration for RLUSD routing triggered!")),
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
            colors: [Colors.teal.shade700, Colors.cyan.shade700],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildCard("RLUSD Deposit & Routing", _buildRoutingDetails()),
                  const SizedBox(height: 16),
                  _buildCard("Integrations", _buildIntegrations()),
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
              Icon(Icons.currency_exchange, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                "RLUSD Routing",
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildRoutingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Incoming Deposit: 10,000 RLUSD",
            style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        const Text("Routing Plan:",
            style: TextStyle(fontWeight: FontWeight.bold)),
        ...(_sampleData['routing_plan'] as List).map((route) {
          return ListTile(
            leading: const Icon(Icons.arrow_forward),
            title: Text(route['destination']),
            trailing: Text("${route['amount']} RLUSD"),
          );
        }),
      ],
    );
  }

  Widget _buildIntegrations() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.sync_lock, color: Colors.green),
          title: const Text("VaultGemma Sync"),
          subtitle: Text(_sampleData['vaultGemmaSync']),
        ),
        ListTile(
          leading: const Icon(Icons.cloud_queue, color: Colors.blue),
          title: const Text("XMCP Orchestration"),
          subtitle: Text(_sampleData['xmcpStatus']),
        ),
      ],
    );
  }
}
