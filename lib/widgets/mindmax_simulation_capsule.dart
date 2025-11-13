import 'package:flutter/material.dart';
import 'dart:convert';

// Data Models
class FundingSimulation {
  final String simulationId;
  final String businessName;
  final double targetFunding;
  final String fundingType;
  final double successProbability;
  final double estimatedTaxBenefit;
  final double projectedRefund;
  final List<String> deductionsList;
  final DateTime createdAt;

  FundingSimulation({
    required this.simulationId,
    required this.businessName,
    required this.targetFunding,
    required this.fundingType,
    required this.successProbability,
    required this.estimatedTaxBenefit,
    required this.projectedRefund,
    required this.deductionsList,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'simulationId': simulationId,
        'businessName': businessName,
        'targetFunding': targetFunding,
        'fundingType': fundingType,
        'successProbability': successProbability,
        'estimatedTaxBenefit': estimatedTaxBenefit,
        'projectedRefund': projectedRefund,
        'deductionsList': deductionsList,
        'createdAt': createdAt.toIso8601String(),
      };
}

class MindMaxSimulationCapsule extends StatefulWidget {
  const MindMaxSimulationCapsule({super.key});

  @override
  State<MindMaxSimulationCapsule> createState() =>
      _MindMaxSimulationCapsuleState();
}

class _MindMaxSimulationCapsuleState extends State<MindMaxSimulationCapsule> {
  late List<FundingSimulation> simulations;
  String selectedSimulationId = '';

  @override
  void initState() {
    super.initState();
    _initializeSimulations();
  }

  void _initializeSimulations() {
    simulations = [
      FundingSimulation(
        simulationId: 'SIM-001',
        businessName: 'TechStartup Inc',
        targetFunding: 500000,
        fundingType: 'Venture Capital',
        successProbability: 0.78,
        estimatedTaxBenefit: 125000,
        projectedRefund: 89500,
        deductionsList: [
          'R&D Equipment: \$45,000',
          'Software Licenses: \$18,000',
          'Employee Training: \$12,500',
          'Office Equipment: \$8,200',
          'Professional Services: \$5,800',
        ],
        createdAt: DateTime(2025, 11, 01),
      ),
      FundingSimulation(
        simulationId: 'SIM-002',
        businessName: 'Green Energy LLC',
        targetFunding: 250000,
        fundingType: 'Small Business Loan',
        successProbability: 0.92,
        estimatedTaxBenefit: 67500,
        projectedRefund: 48200,
        deductionsList: [
          'Solar Equipment: \$120,000',
          'Installation: \$50,000',
          'Permits & Licenses: \$8,500',
          'Marketing: \$6,200',
        ],
        createdAt: DateTime(2025, 11, 05),
      ),
    ];
    if (simulations.isNotEmpty) {
      selectedSimulationId = simulations.first.simulationId;
    }
  }

  void _runDeductionOptimizer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Deduction Optimizer running...'),
          backgroundColor: Colors.green),
    );
  }

  void _calculateRefundEstimate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Refund estimation calculated'),
          backgroundColor: Colors.blue),
    );
  }

  void _runCreditSimulation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Credit score simulation running...'),
          backgroundColor: Colors.purple),
    );
  }

  void _exportSimulation() {
    final selected =
        simulations.firstWhere((s) => s.simulationId == selectedSimulationId);
    final json = jsonEncode(selected.toJson());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Simulation exported (${(json.length / 1024).toStringAsFixed(2)} KB)')),
    );
  }

  Color _getSuccessColor(double probability) {
    if (probability > 0.85) return Colors.green;
    if (probability > 0.70) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final selected = simulations.firstWhere(
      (s) => s.simulationId == selectedSimulationId,
      orElse: () => simulations.first,
    );

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7E57C2), Color(0xFFBA68C8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('🧠 MindMax Simulation'),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Predictive Modeling & Financial Optimization',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Funding success • Tax optimization • Outreach impact • Credit simulation',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Simulation Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Simulation:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedSimulationId,
                      isExpanded: true,
                      items: simulations
                          .map((s) => DropdownMenuItem(
                                value: s.simulationId,
                                child: Text(
                                    '${s.businessName} - \$${s.targetFunding.toStringAsFixed(0)}'),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedSimulationId = value ?? ''),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Simulation Details
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected.businessName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Target: \$${selected.targetFunding.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text('Type: ${selected.fundingType}',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getSuccessColor(selected.successProbability)
                                .withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: _getSuccessColor(
                                    selected.successProbability)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${(selected.successProbability * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getSuccessColor(
                                      selected.successProbability),
                                ),
                              ),
                              Text('Success Rate',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Financial Projections
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Financial Projections',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildProjectionRow(
                        'Tax Benefit',
                        '\$${selected.estimatedTaxBenefit.toStringAsFixed(0)}',
                        Colors.green),
                    _buildProjectionRow(
                        'Projected Refund',
                        '\$${selected.projectedRefund.toStringAsFixed(0)}',
                        Colors.blue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _runDeductionOptimizer,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Optimize Deductions'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: _calculateRefundEstimate,
                  icon: const Icon(Icons.money),
                  label: const Text('Estimate Refund'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: _runCreditSimulation,
                  icon: const Icon(Icons.trending_up),
                  label: const Text('Simulate Credit'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                ),
                ElevatedButton.icon(
                  onPressed: _exportSimulation,
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Deductions List
            const Text('Optimized Deductions',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...selected.deductionsList.map((deduction) {
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(deduction,
                              style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectionRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color),
            ),
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
