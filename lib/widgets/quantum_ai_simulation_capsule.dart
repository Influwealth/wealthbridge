import 'dart:convert';
import 'package:flutter/material.dart';

class QuantumAISimulationCapsule extends StatelessWidget {
  const QuantumAISimulationCapsule({super.key});

  // Sample data for quantum AI simulation
  final Map<String, dynamic> _sampleData = const {
    "financialModel": {
      "name": "Quantum-Inspired Monte Carlo",
      "parameters": {"simulations": 100000, "time_horizon": "5Y"},
      "prediction": {"market_outlook": "Optimistic", "confidence": 0.85}
    },
    "creditPrediction": {
      "borrower_id": "C-12345",
      "default_probability": 0.12,
      "tensor_network_model": "TN-v2.1"
    },
    "fundingMatch": {
      "project_id": "P-67890",
      "funding_source": "Venture Capital Fund 'QuantumLeap'",
      "match_probability": 0.92
    },
    "mindmaxIntegration": "Active"
  };

  String _getJsonData() {
    return jsonEncode(_sampleData);
  }

  void _triggerXmcpOrchestration(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text("XMCP orchestration for quantum simulation triggered!")),
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
            colors: [Colors.blueGrey.shade900, Colors.teal.shade800],
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
                      "Quantum Financial Modeling", _buildFinancialModeling()),
                  const SizedBox(height: 16),
                  _buildCard("Tensor Network Credit Prediction",
                      _buildCreditPrediction()),
                  const SizedBox(height: 16),
                  _buildCard("Funding Match Probability", _buildFundingMatch()),
                  const SizedBox(height: 16),
                  _buildCard(
                      "MindMaxCapsule Integration", _buildMindMaxIntegration()),
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
              Icon(Icons.memory, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                "Quantum AI Simulation",
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
      color: Colors.blueGrey.shade800,
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

  Widget _buildFinancialModeling() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Running 'Quantum-Inspired Monte Carlo' simulation...",
            style: TextStyle(color: Colors.white70)),
        SizedBox(height: 10),
        LinearProgressIndicator(),
        SizedBox(height: 10),
        Text("Prediction: Market outlook is 'Optimistic' with 85% confidence.",
            style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildCreditPrediction() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Analyzing borrower C-12345 using Tensor Network model...",
            style: TextStyle(color: Colors.white70)),
        SizedBox(height: 10),
        Text("Predicted Default Probability: 12%",
            style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFundingMatch() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Calculating match probability for Project P-67890...",
            style: TextStyle(color: Colors.white70)),
        SizedBox(height: 10),
        Text("Best Match: 'Venture Capital Fund QuantumLeap'",
            style: TextStyle(color: Colors.white)),
        Text("Match Probability: 92%",
            style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMindMaxIntegration() {
    return const Row(
      children: [
        Icon(Icons.check_circle, color: Colors.greenAccent),
        SizedBox(width: 10),
        Text("MindMaxCapsule integration is active.",
            style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
