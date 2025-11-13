import 'dart:convert';
import 'package:flutter/material.dart';

class MultiTenantCapsule extends StatelessWidget {
  const MultiTenantCapsule({super.key});

  // Sample data for multi-tenancy
  final Map<String, dynamic> _sampleData = const {
    "roles": [
      {"role": "Admin", "permissions": "All"},
      {"role": "Manager", "permissions": "Team-level"},
      {"role": "User", "permissions": "Individual-level"},
    ],
    "teams": [
      {"name": "Team Alpha", "members": 5},
      {"name": "Team Beta", "members": 8},
    ],
    "capsuleIsolation": true,
    "auditTrail": [
      {
        "timestamp": "2025-11-12T10:00:00Z",
        "user": "admin@example.com",
        "action": "Created Team Gamma"
      },
      {
        "timestamp": "2025-11-12T10:05:00Z",
        "user": "manager@example.com",
        "action": "Updated capsule settings for Team Beta"
      },
    ]
  };

  String _getJsonData() {
    return jsonEncode(_sampleData);
  }

  void _triggerXmcpOrchestration(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text("XMCP orchestration hook for multi-tenancy triggered!")),
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
            colors: [Colors.indigo.shade800, Colors.purple.shade800],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildCard("Role-Based Access Control", _buildRolesTable()),
                  const SizedBox(height: 16),
                  _buildCard("Team Segmentation", _buildTeamsList()),
                  const SizedBox(height: 16),
                  _buildCard("Capsule Isolation & Admin Controls",
                      _buildAdminControls()),
                  const SizedBox(height: 16),
                  _buildCard("Audit Trail", _buildAuditTrail()),
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
              Icon(Icons.people, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                "Multi-Tenant Management",
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

  Widget _buildRolesTable() {
    final List<DataRow> rows = (_sampleData['roles'] as List).map((data) {
      return DataRow(cells: [
        DataCell(Text(data['role'])),
        DataCell(Text(data['permissions'])),
      ]);
    }).toList();

    return DataTable(
      columns: const [
        DataColumn(label: Text("Role")),
        DataColumn(label: Text("Permissions")),
      ],
      rows: rows,
    );
  }

  Widget _buildTeamsList() {
    final List<Widget> teamTiles = (_sampleData['teams'] as List).map((team) {
      return ListTile(
        leading: const Icon(Icons.group_work),
        title: Text(team['name']),
        subtitle: Text("${team['members']} members"),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      );
    }).toList();
    return Column(children: teamTiles);
  }

  Widget _buildAdminControls() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text("Capsule Isolation"),
          subtitle: const Text("Isolate capsule data between teams"),
          value: _sampleData['capsuleIsolation'],
          onChanged: (bool value) {
            // State management would go here
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.admin_panel_settings_outlined),
          label: const Text("Admin Override"),
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildAuditTrail() {
    final List<Widget> auditLogs =
        (_sampleData['auditTrail'] as List).map((log) {
      return ListTile(
        leading: const Icon(Icons.history),
        title: Text(log['action']),
        subtitle: Text("${log['user']} at ${log['timestamp']}"),
      );
    }).toList();
    return Column(
      children: [
        const Text("Placeholder for a filterable, paginated audit log view."),
        const SizedBox(height: 10),
        ...auditLogs,
      ],
    );
  }
}
