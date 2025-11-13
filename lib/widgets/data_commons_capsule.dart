import 'dart:convert';
import 'package:flutter/material.dart';

class DataCommonsCapsule extends StatelessWidget {
  const DataCommonsCapsule({super.key});

  // Sample data for Data Commons
  final Map<String, dynamic> _sampleData = const {
    "datasets": [
      {"name": "IRS Publication 501", "status": "Cached", "size": "1.2 MB"},
      {"name": "US Census 2020", "status": "Cached", "size": "15.8 GB"},
      {"name": "World Bank GDP Data", "status": "Live", "size": "N/A"},
      {
        "name": "IMF Global Financial Stability Report",
        "status": "Live",
        "size": "N/A"
      },
    ],
    "tensorSimulation": {
      "model": "TensorFlow-v2.15",
      "status": "Idle",
      "lastRun": "2025-11-12T09:30:00Z"
    },
    "mindmaxSync": "Active"
  };

  String _getJsonData() {
    return jsonEncode(_sampleData);
  }

  void _triggerXmcpOrchestration(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("XMCP orchestration for Data Commons triggered!")),
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
            colors: [Colors.green.shade700, Colors.lightGreen.shade700],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildCard("Public Datasets", _buildDatasetsList()),
                  const SizedBox(height: 16),
                  _buildCard("Tensor Simulation", _buildTensorSimulation()),
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
              Icon(Icons.dataset, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                "Data Commons",
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

  Widget _buildDatasetsList() {
    return Column(
      children: (_sampleData['datasets'] as List).map((dataset) {
        return ListTile(
          leading: const Icon(Icons.description),
          title: Text(dataset['name']),
          subtitle: Text("Status: ${dataset['status']}"),
          trailing: Text(dataset['size']),
        );
      }).toList(),
    );
  }

  Widget _buildTensorSimulation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Model: ${_sampleData['tensorSimulation']['model']}"),
        const SizedBox(height: 8),
        Text("Status: ${_sampleData['tensorSimulation']['status']}"),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text("Run Simulation"),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildIntegrations() {
    return ListTile(
      leading: const Icon(Icons.sync, color: Colors.blue),
      title: const Text("MindMaxSimulationCapsule Sync"),
      subtitle: Text(_sampleData['mindmaxSync']),
    );
  }
}
