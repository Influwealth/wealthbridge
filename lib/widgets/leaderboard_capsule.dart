import 'dart:convert';
import 'package:flutter/material.dart';

class LeaderboardCapsule extends StatefulWidget {
  const LeaderboardCapsule({super.key});

  @override
  LeaderboardCapsuleState createState() => LeaderboardCapsuleState();
}

class LeaderboardCapsuleState extends State<LeaderboardCapsule> {
  bool _isPublicView = true;

  final List<Map<String, dynamic>> _leaderboardData = [
    {
      "rank": 1,
      "name": "CryptoKing",
      "earnings": 12500.0,
      "activations": 250,
      "tier": "Platinum"
    },
    {
      "rank": 2,
      "name": "AffiliateAce",
      "earnings": 11800.0,
      "activations": 230,
      "tier": "Platinum"
    },
    {
      "rank": 3,
      "name": "CashFlowPro",
      "earnings": 9800.0,
      "activations": 195,
      "tier": "Gold"
    },
    {
      "rank": 4,
      "name": "BizBuilder",
      "earnings": 8200.0,
      "activations": 160,
      "tier": "Gold"
    },
    {
      "rank": 5,
      "name": "SideHustler",
      "earnings": 6500.0,
      "activations": 130,
      "tier": "Silver"
    },
    {
      "rank": 6,
      "name": "NewbieNick",
      "earnings": 4200.0,
      "activations": 85,
      "tier": "Silver"
    },
    {
      "rank": 7,
      "name": "GrowthGuru",
      "earnings": 2100.0,
      "activations": 42,
      "tier": "Bronze"
    },
    {
      "rank": 8,
      "name": "StarterSam",
      "earnings": 950.0,
      "activations": 19,
      "tier": "Bronze"
    },
  ];

  String _getJsonData() {
    return jsonEncode({"leaderboard": _leaderboardData});
  }

  void _triggerXmcpOrchestration() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("XMCP orchestration hook triggered!")),
    );
  }

  Icon _getTierIcon(String tier) {
    switch (tier) {
      case "Platinum":
        return const Icon(Icons.shield, color: Colors.cyan);
      case "Gold":
        return const Icon(Icons.star, color: Colors.amber);
      case "Silver":
        return const Icon(Icons.verified, color: Colors.grey);
      case "Bronze":
        return const Icon(Icons.military_tech, color: Colors.brown);
      default:
        return const Icon(Icons.person, color: Colors.transparent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepOrange.shade700, Colors.amber.shade700],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Card(
                margin: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                elevation: 8,
                child: _buildLeaderboardList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.leaderboard, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                "Affiliate Leaderboard",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
          Row(
            children: [
              Switch(
                value: _isPublicView,
                onChanged: (val) => setState(() => _isPublicView = val),
                activeTrackColor: Colors.lightGreenAccent,
                activeThumbColor: Colors.green,
              ),
              IconButton(
                icon: const Icon(Icons.cloud_upload_outlined,
                    color: Colors.white),
                onPressed: _triggerXmcpOrchestration,
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

  Widget _buildLeaderboardList() {
    return ListView.builder(
      itemCount: _leaderboardData.length,
      itemBuilder: (context, index) {
        final affiliate = _leaderboardData[index];
        final name =
            _isPublicView ? affiliate['name'] : "User #${affiliate['rank']}";
        return ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "#${affiliate['rank']}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          title:
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Activations: ${affiliate['activations']}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _getTierIcon(affiliate['tier']),
              const SizedBox(width: 8),
              Text(
                "\$${(affiliate['earnings'] as double).toStringAsFixed(0)}",
                style: const TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
