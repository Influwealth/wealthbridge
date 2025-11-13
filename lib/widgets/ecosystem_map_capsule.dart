import 'package:flutter/material.dart';

class EcosystemMapCapsule extends StatelessWidget {
  const EcosystemMapCapsule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('🗺️ Ecosystem Map'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('WealthBridge Sovereign Mesh Architecture',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildArchitectureDiagram(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Phase Roadmap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...[
              (
                'Phase 1',
                'MVP - 23 Capsules',
                'WealthBridge app (web), simulated integrations, demo data',
                Colors.blue
              ),
              (
                'Phase 2',
                'Real APIs',
                'Stripe Connect, Polygon blockchain, VaultGemma encryption, Google Sheets sync',
                Colors.orange
              ),
              (
                'Phase 3',
                'Expansion',
                'Native iOS/Android, tvOS, watchOS, Stablecoin Factory, Crypto Coin, AI agents',
                Colors.green
              ),
              (
                'Phase 4',
                'Enterprise',
                'Multi-tenant support, advanced compliance, quantum AI features, global deployment',
                Colors.purple
              ),
            ].map((phase) {
              final (title, phase2, description, color) = phase;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(phase2,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(description,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 12)),
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

  Widget _buildArchitectureDiagram() {
    return Column(
      children: [
        const Text('InfluWealth Ecosystem',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text('🌐 InfluWealth (Brand Hub)'),
              const SizedBox(height: 12),
              const Text('↓'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('📱 WealthBridge (Phase 1)\n23 Capsules'),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('💰 Stablecoin\nFactory',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('🪙 Crypto\nCoin',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('📈 Tradeline\nBuilder',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
