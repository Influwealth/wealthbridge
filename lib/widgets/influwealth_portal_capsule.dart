import 'package:flutter/material.dart';

class InfluWealthPortalCapsule extends StatelessWidget {
  const InfluWealthPortalCapsule({super.key});

  @override
  Widget build(BuildContext context) {
    final resources = [
      ('Getting Started', 'Start here with onboarding guides and system setup'),
      ('Capsule Tutorials', 'Learn how to use all 23 WealthBridge capsules'),
      ('Affiliate Training', 'Complete training for affiliate partners'),
      ('IRS Integration', 'Link to IRS tax portal and resources'),
      ('DOL Compliance', 'Department of Labor compliance documentation'),
      ('SAM.gov Access', 'Federal contracting and bidding portal'),
      ('Google MCP', 'Model Context Protocol integration guide'),
      ('API Documentation', 'Developer API reference and integration'),
    ];

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00695C), Color(0xFF00897B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('🌍 InfluWealth Portal'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.teal[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Central Education & Resource Hub',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your one-stop shop for financial education, compliance, and system documentation',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Resources & Documentation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...resources.map((resource) {
              final (title, description) = resource;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.book, color: Colors.teal),
                  title: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text(description, style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
              );
            }),
            const SizedBox(height: 24),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Need Help?',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Contact Support'),
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
