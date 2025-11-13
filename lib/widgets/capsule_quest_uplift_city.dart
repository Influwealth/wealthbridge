import 'package:flutter/material.dart';

class CapsuleQuestUpliftCity extends StatelessWidget {
  const CapsuleQuestUpliftCity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8B4513), Color(0xFFD2B48C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('🎮 CapsuleQuest - UpliftCity'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.games, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('Roblox Mentorship Platform',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Youth onboarding & Team Create integration',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 32),
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Features:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('✅ Team Create logic for collaborative builds'),
                    const Text('✅ Mobile-only access mode'),
                    const Text('✅ Admin control panel'),
                    const Text('✅ SynapzFeed integration'),
                    const Text('✅ MindMax impact simulation'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Launch UpliftCity'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
