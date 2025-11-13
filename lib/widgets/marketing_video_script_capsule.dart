import 'package:flutter/material.dart';

class MarketingVideoScriptCapsule extends StatelessWidget {
  const MarketingVideoScriptCapsule({super.key});

  @override
  Widget build(BuildContext context) {
    final videoScript = [
      (
        '0:00-0:30',
        'Hook & Intro',
        'Welcome to WealthBridge - Your sovereign financial ecosystem. One platform. 23 capsules. Infinite possibilities.'
      ),
      (
        '0:30-1:30',
        'Account Creation',
        'Sign up in 90 seconds. Enter your info. Verify email. Boom - you\'re in. No paperwork. No waiting.'
      ),
      (
        '1:30-2:30',
        'System Tour',
        'Meet the 23 capsules: AP2 (affiliates), FACTIIV (credit), Admin Dashboard, InfluWealth Portal, and 19 more financial tools.'
      ),
      (
        '2:30-3:30',
        'Integration Hub',
        'One login for everything: IRS, DOL, SAM.gov, Google MCP. We\'re the plug for all your compliance needs.'
      ),
      (
        '3:30-4:00',
        'Admin Access',
        'Admins see it all: metrics, audit logs, blockchain transactions, payment processing, dispute management.'
      ),
      (
        '4:00-5:00',
        'Call to Action',
        'Join thousands building wealth. Start your journey today. WealthBridge - Financial uplift for everyone.'
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6D00), Color(0xFFFFB74D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('🎥 Marketing Video Script'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.orange[50],
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('5-Minute Onboarding Video Script',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                        'Complete timeline for demo video showing account creation, capsule tour, admin dashboard, and integration hub.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...videoScript.map((segment) {
              final (timestamp, section, content) = segment;
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
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              timestamp,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              section,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(content,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 13)),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text('Export Full Script'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
