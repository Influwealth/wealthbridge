import 'dart:convert';
import 'package:flutter/material.dart';

class StripeIntegrationCapsule extends StatelessWidget {
  const StripeIntegrationCapsule({super.key});

  final Map<String, dynamic> _samplePayout = const {
    "recipient": "Affiliate Ace",
    "amount": 11800.00,
    "commission_event": "AP2-XYZ-789",
    "fee_percent": 0.02,
  };

  double get _feeAmount =>
      _samplePayout['amount'] * _samplePayout['fee_percent'];
  double get _netPayout => _samplePayout['amount'] - _feeAmount;

  String _getJsonData() {
    return jsonEncode({
      "payoutDetails": _samplePayout,
      "calculatedFee": _feeAmount,
      "netPayout": _netPayout,
    });
  }

  void _triggerXmcpOrchestration(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("XMCP orchestration hook triggered!")),
    );
  }

  void _processPayout(BuildContext context) {
    // TODO: Implement live Stripe API call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Processing payout of \$${_netPayout.toStringAsFixed(2)} via Stripe... (simulation)"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF635BFF), Color(0xFF00A2FF)],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Card(
                margin: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Payout Processing",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      _buildPayoutDetailRow(
                          "Recipient:", _samplePayout['recipient']),
                      _buildPayoutDetailRow("Gross Amount:",
                          "\$${(_samplePayout['amount'] as double).toStringAsFixed(2)}"),
                      const Divider(height: 24),
                      _buildPayoutDetailRow("Platform Fee (2%):",
                          "-\$${_feeAmount.toStringAsFixed(2)}",
                          color: Colors.red),
                      const Divider(height: 24),
                      _buildPayoutDetailRow(
                          "Net Payout:", "\$${_netPayout.toStringAsFixed(2)}",
                          isBold: true, color: Colors.green),
                      const SizedBox(height: 32),
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text("Process Payout via Stripe"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          onPressed: () => _processPayout(context),
                        ),
                      ),
                      const Spacer(),
                      _buildFooterInfo(),
                    ],
                  ),
                ),
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
              Icon(Icons.credit_card, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                "Stripe Integration",
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

  Widget _buildPayoutDetailRow(String label, String value,
      {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 16, color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Column(
      children: [
        const Divider(),
        ListTile(
          leading: const Icon(Icons.sync_alt, color: Colors.blue),
          title: const Text("AP2Capsule Sync"),
          subtitle:
              Text("Commission Event: ${_samplePayout['commission_event']}"),
        ),
        const ListTile(
          leading: Icon(Icons.security, color: Colors.orange),
          title: Text("Stablecoin Fallback"),
          subtitle: Text("Payouts may be routed to USDC if Stripe fails."),
        ),
      ],
    );
  }
}
