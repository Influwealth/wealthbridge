import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:charts_flutter/flutter.dart' as charts; // Placeholder for charts

class AnalyticsCapsule extends StatelessWidget {
  const AnalyticsCapsule({super.key});

  // Sample data for analytics
  final Map<String, dynamic> _sampleData = const {
    "capsuleUsage": [
      {"name": "AP2Capsule", "activations": 1500, "color": Colors.cyan},
      {"name": "FACTIIVCapsule", "activations": 950, "color": Colors.orange},
      {"name": "TradelineIntake", "activations": 1200, "color": Colors.teal},
      {"name": "Others", "activations": 2500, "color": Colors.grey},
    ],
    "affiliatePerformance": [
      {"name": "Affiliate A", "earnings": 5250.0, "signups": 105},
      {"name": "Affiliate B", "earnings": 4800.0, "signups": 96},
      {"name": "Affiliate C", "earnings": 3500.0, "signups": 70},
    ],
    "fundingSuccessRate": 0.78, // 78%
  };

  String _getJsonData() {
    // In a real app, color would be handled differently or omitted.
    return jsonEncode({
      "capsuleUsage": _sampleData["capsuleUsage"]
          .map((d) => {"name": d["name"], "activations": d["activations"]})
          .toList(),
      "affiliatePerformance": _sampleData["affiliatePerformance"],
      "fundingSuccessRate": _sampleData["fundingSuccessRate"],
    });
  }

  void _triggerXmcpOrchestration(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("XMCP orchestration hook triggered!")),
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
            colors: [Colors.green.shade800, Colors.blue.shade800],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildCard(
                      "Capsule Usage Metrics", _buildUsageChart(context)),
                  const SizedBox(height: 16),
                  _buildCard("Affiliate Performance", _buildAffiliateTable()),
                  const SizedBox(height: 16),
                  _buildCard(
                      "Funding Success Rate", _buildFundingRate(context)),
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
              Icon(Icons.analytics, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                "Analytics Dashboard",
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

  Widget _buildUsageChart(BuildContext context) {
    // TODO: Replace with a real charting library like 'charts_flutter'
    // This is a simplified visual representation.
    final List<Widget> bars = (_sampleData['capsuleUsage'] as List).map((data) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Container(width: 10, height: 10, color: data['color']),
            const SizedBox(width: 8),
            Text("${data['name']}: ${data['activations']}"),
          ],
        ),
      );
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            "Placeholder for Bar Chart. TODO: Integrate a charting library."),
        const SizedBox(height: 10),
        ...bars,
        const SizedBox(height: 10),
        const Text("Data powered by Firestore/PostgreSQL.")
      ],
    );
  }

  Widget _buildAffiliateTable() {
    final List<DataRow> rows =
        (_sampleData['affiliatePerformance'] as List).map((data) {
      return DataRow(cells: [
        DataCell(Text(data['name'])),
        DataCell(Text("\$${data['earnings'].toStringAsFixed(2)}")),
        DataCell(Text(data['signups'].toString())),
      ]);
    }).toList();

    return DataTable(
      columns: const [
        DataColumn(label: Text("Affiliate")),
        DataColumn(label: Text("Earnings")),
        DataColumn(label: Text("Signups")),
      ],
      rows: rows,
    );
  }

  Widget _buildFundingRate(BuildContext context) {
    final rate = _sampleData['fundingSuccessRate'] as double;
    return Column(
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: rate,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              Center(
                child: Text(
                  "${(rate * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text("Export Report"),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Export functionality not implemented.")),
            );
          },
        ),
      ],
    );
  }
}
