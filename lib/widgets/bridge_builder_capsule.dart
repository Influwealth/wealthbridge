import 'package:flutter/material.dart';

class OutreachCampaign {
  final String campaignId;
  final String title;
  final int targetAudience;
  final String status;
  final List<String> followUpSequence;
  final String phoneAgentId;
  final String twilioConfig;
  final double estimatedImpact;
  final DateTime createdAt;

  OutreachCampaign({
    required this.campaignId,
    required this.title,
    required this.targetAudience,
    required this.status,
    required this.followUpSequence,
    required this.phoneAgentId,
    required this.twilioConfig,
    required this.estimatedImpact,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'campaignId': campaignId,
        'title': title,
        'targetAudience': targetAudience,
        'status': status,
        'followUpSequence': followUpSequence,
        'phoneAgentId': phoneAgentId,
        'estimatedImpact': estimatedImpact,
        'createdAt': createdAt.toIso8601String(),
      };
}

class BridgeBuilderCapsule extends StatefulWidget {
  const BridgeBuilderCapsule({super.key});

  @override
  State<BridgeBuilderCapsule> createState() => _BridgeBuilderCapsuleState();
}

class _BridgeBuilderCapsuleState extends State<BridgeBuilderCapsule> {
  late List<OutreachCampaign> campaigns;
  String selectedCampaignId = '';

  @override
  void initState() {
    super.initState();
    campaigns = [
      OutreachCampaign(
        campaignId: 'CAMP-001',
        title: 'Nonprofit Partnership Drive',
        targetAudience: 500,
        status: 'Active',
        followUpSequence: [
          'Day 1: Email Intro',
          'Day 3: Phone Call',
          'Day 7: Followup Email',
          'Day 14: Demo Invite'
        ],
        phoneAgentId: 'agent-twilio-001',
        twilioConfig: 'twilio-nonprofit-config',
        estimatedImpact: 0.35,
        createdAt: DateTime(2025, 11, 01),
      ),
      OutreachCampaign(
        campaignId: 'CAMP-002',
        title: 'Affiliate Onboarding',
        targetAudience: 250,
        status: 'Scheduled',
        followUpSequence: [
          'Day 1: Welcome Kit',
          'Day 2: Training Call',
          'Day 5: Platform Demo'
        ],
        phoneAgentId: 'agent-twilio-002',
        twilioConfig: 'twilio-affiliate-config',
        estimatedImpact: 0.58,
        createdAt: DateTime(2025, 11, 05),
      ),
    ];
    if (campaigns.isNotEmpty) selectedCampaignId = campaigns.first.campaignId;
  }

  @override
  Widget build(BuildContext context) {
    final selected = campaigns.firstWhere(
      (c) => c.campaignId == selectedCampaignId,
      orElse: () => campaigns.first,
    );

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD32F2F), Color(0xFFFF6F00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('🌉 BridgeBuilder Capsule'),
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
                    const Text('Nonprofit & Affiliate Outreach',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                        'Phone agent • Twilio integration • MindMax impact simulation',
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedCampaignId,
              isExpanded: true,
              items: campaigns
                  .map((c) => DropdownMenuItem(
                      value: c.campaignId, child: Text(c.title)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCampaignId = v ?? ''),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selected.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Target: ${selected.targetAudience} contacts',
                        style: TextStyle(color: Colors.grey[600])),
                    Text('Status: ${selected.status}',
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: selected.estimatedImpact),
                    const SizedBox(height: 4),
                    Text(
                        'Est. Impact: ${(selected.estimatedImpact * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Follow-up Sequence',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...selected.followUpSequence.asMap().entries.map((entry) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('${entry.key + 1}. ${entry.value}'),
                  ),
                )),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.phone),
              label: const Text('Launch Phone Campaign'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
