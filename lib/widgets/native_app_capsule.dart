import 'dart:convert';
import 'package:flutter/material.dart';

class NativeAppCapsule extends StatelessWidget {
  const NativeAppCapsule({super.key});

  // Sample data for the capsule
  final Map<String, dynamic> _sampleData = const {
    "metadata": {
      "name": "NativeAppCapsule",
      "route": "/native-app",
      "category": "Mobile",
      "icon": "smartphone",
      "color": "deepPurple"
    },
    "buildTargets": {
      "ios": {"enabled": true, "version": "1.0.0", "buildNumber": "1"},
      "android": {"enabled": true, "version": "1.0.0", "versionCode": "1"}
    },
    "routeMap": [
      {"path": "/home", "component": "HomePage"},
      {"path": "/profile", "component": "ProfilePage"},
      {"path": "/settings", "component": "SettingsPage"}
    ]
  };

  String _getJsonData() {
    return jsonEncode(_sampleData);
  }

  void _triggerXmcpOrchestration(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("XMCP orchestration hook for native build triggered!")),
    );
  }

  void _triggerGeminiCliAgent(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text("Gemini CLI Agent: 'flutter build apk' hook triggered.")),
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
            colors: [Colors.deepPurple.shade800, Colors.indigo.shade800],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildCard("Build Targets", _buildBuildTargets(context)),
                  const SizedBox(height: 16),
                  _buildCard("Route Mapping", _buildRouteMap()),
                  const SizedBox(height: 16),
                  _buildCard("Gemini CLI Agent", _buildCliAgent(context)),
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
              Icon(Icons.smartphone, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                "Native App Scaffold",
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

  Widget _buildBuildTargets(BuildContext context) {
    final ios = _sampleData["buildTargets"]["ios"];
    final android = _sampleData["buildTargets"]["android"];
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.apple, color: Colors.black),
          title: const Text("iOS"),
          subtitle: Text("Version: ${ios["version"]} (${ios["buildNumber"]})"),
          trailing: Switch(value: ios["enabled"], onChanged: null),
        ),
        ListTile(
          leading: const Icon(Icons.android, color: Colors.green),
          title: const Text("Android"),
          subtitle: Text(
              "Version: ${android["version"]} (${android["versionCode"]})"),
          trailing: Switch(value: android["enabled"], onChanged: null),
        ),
      ],
    );
  }

  Widget _buildRouteMap() {
    final routes = _sampleData["routeMap"] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: routes.map((route) {
        return Text("${route['path']} -> ${route['component']}");
      }).toList(),
    );
  }

  Widget _buildCliAgent(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.build),
        label: const Text("Trigger Native Compilation"),
        onPressed: () => _triggerGeminiCliAgent(context),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.indigo,
        ),
      ),
    );
  }
}
