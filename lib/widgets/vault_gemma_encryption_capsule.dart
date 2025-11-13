import 'dart:convert';
import 'package:flutter/material.dart';

class VaultGemmaEncryptionCapsule extends StatelessWidget {
  const VaultGemmaEncryptionCapsule({super.key});

  // Sample data for demonstration
  final Map<String, dynamic> _sampleData = const {
    "file_name": "2023_tax_return.pdf",
    "file_size": "2.3 MB",
    "encryption_status": "Encrypted",
    "encryption_algorithm": "RSA-4096",
    "last_accessed": "2023-10-27 10:00 AM",
  };

  String _getJsonData() {
    return jsonEncode(_sampleData);
  }

  void _triggerXmcpOrchestration(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              "XMCP orchestration hook triggered for secure key exchange!")),
    );
  }

  void _exportSecureData(BuildContext context) {
    // TODO: Implement secure data export logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Secure export initiated... (simulation)")),
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
            colors: [Colors.indigo.shade700, Colors.purple.shade800],
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Secure Data Vault",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoTile(Icons.file_present, "File Name",
                          _sampleData['file_name']),
                      _buildInfoTile(Icons.sd_storage, "File Size",
                          _sampleData['file_size']),
                      _buildInfoTile(Icons.lock_outline, "Encryption Status",
                          _sampleData['encryption_status'],
                          statusColor: Colors.green),
                      _buildInfoTile(Icons.vpn_key, "Algorithm",
                          _sampleData['encryption_algorithm']),
                      _buildInfoTile(Icons.access_time, "Last Accessed",
                          _sampleData['last_accessed']),
                      const Spacer(),
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.download_for_offline),
                          label: const Text("Export Encrypted Data"),
                          onPressed: () => _exportSecureData(context),
                        ),
                      ),
                      const SizedBox(height: 20),
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
              Icon(Icons.shield, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                "VaultGemma Encryption",
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
      {Color? statusColor}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle,
          style: TextStyle(color: statusColor ?? Colors.black87, fontSize: 14)),
    );
  }
}
