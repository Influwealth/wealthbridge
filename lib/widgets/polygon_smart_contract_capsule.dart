import 'dart:convert';
import 'package:flutter/material.dart';

class PolygonSmartContractCapsule extends StatelessWidget {
  const PolygonSmartContractCapsule({super.key});

  final Map<String, dynamic> _sampleContractData = const {
    "contractAddress": "0x742d35Cc6634C0532925a3b844Bc454e4438f44e",
    "network": "Polygon Mainnet",
    "lastCreditEvent": {
      "txHash": "0xabc...def",
      "blockNumber": 12345678,
      "status": "Confirmed",
    },
    "vaultGemmaSync": "Enabled & Verified",
    "factiivIntegration": "Active",
  };

  String _getJsonData() {
    return jsonEncode(_sampleContractData);
  }

  void _triggerXmcpOrchestration(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("XMCP orchestration hook triggered!")),
    );
  }

  void _verifyHash(BuildContext context) {
    // TODO: Implement actual hash verification logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Simulating hash verification... Verified!"),
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
            colors: [Color(0xFF8247E5), Color(0xFF3B3E6E)],
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
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      _buildInfoTile(
                        Icons.link,
                        "Contract Address",
                        _sampleContractData['contractAddress'],
                        isSelectable: true,
                      ),
                      _buildInfoTile(
                        Icons.public,
                        "Network",
                        _sampleContractData['network'],
                      ),
                      const Divider(height: 30),
                      const Text("Latest Credit Event",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _buildInfoTile(
                        Icons.receipt_long,
                        "Transaction Hash",
                        _sampleContractData['lastCreditEvent']['txHash'],
                        isSelectable: true,
                      ),
                      _buildInfoTile(
                        Icons.check_circle,
                        "Status",
                        _sampleContractData['lastCreditEvent']['status'],
                        statusColor: Colors.green,
                      ),
                      const Divider(height: 30),
                      _buildInfoTile(
                        Icons.sync_lock,
                        "VaultGemma Sync",
                        _sampleContractData['vaultGemmaSync'],
                        statusColor: Colors.green,
                      ),
                      _buildInfoTile(
                        Icons.fact_check,
                        "FACTIIVCapsule Integration",
                        _sampleContractData['factiivIntegration'],
                        statusColor: Colors.blue,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.verified_user),
                          label: const Text("Verify Contract Hash"),
                          onPressed: () => _verifyHash(context),
                        ),
                      ),
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
              Icon(Icons.security, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                "Polygon Smart Contract",
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

  Widget _buildInfoTile(IconData icon, String title, String subtitle,
      {Color? statusColor, bool isSelectable = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: isSelectable
          ? SelectableText(subtitle,
              style:
                  TextStyle(color: statusColor ?? Colors.black87, fontSize: 14))
          : Text(subtitle,
              style: TextStyle(
                  color: statusColor ?? Colors.black87, fontSize: 14)),
    );
  }
}
