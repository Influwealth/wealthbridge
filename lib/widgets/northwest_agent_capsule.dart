import 'dart:convert';

import 'package:flutter/material.dart';

// Data Models
class PartnerEntity {
  final String partnerId;
  final String companyName;
  final String ein;
  final String llcStatus;
  final String complianceLevel;
  final String registryStatus;
  final DateTime registeredDate;
  final String vaultGemmaEncrypted; // 🔐 indicator
  final String xmcpOrchestrationId;
  final String contactEmail;
  final String phone;

  PartnerEntity({
    required this.partnerId,
    required this.companyName,
    required this.ein,
    required this.llcStatus,
    required this.complianceLevel,
    required this.registryStatus,
    required this.registeredDate,
    required this.vaultGemmaEncrypted,
    required this.xmcpOrchestrationId,
    required this.contactEmail,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'partnerId': partnerId,
        'companyName': companyName,
        'ein': ein,
        'llcStatus': llcStatus,
        'complianceLevel': complianceLevel,
        'registryStatus': registryStatus,
        'registeredDate': registeredDate.toIso8601String(),
        'vaultGemmaEncrypted': vaultGemmaEncrypted,
        'xmcpOrchestrationId': xmcpOrchestrationId,
        'contactEmail': contactEmail,
        'phone': phone,
      };
}

class ComplianceAudit {
  final String auditId;
  final String partnerId;
  final DateTime auditDate;
  final String status;
  final String findings;
  final String recommendation;
  final String auditedBy;

  ComplianceAudit({
    required this.auditId,
    required this.partnerId,
    required this.auditDate,
    required this.status,
    required this.findings,
    required this.recommendation,
    required this.auditedBy,
  });

  Map<String, dynamic> toJson() => {
        'auditId': auditId,
        'partnerId': partnerId,
        'auditDate': auditDate.toIso8601String(),
        'status': status,
        'findings': findings,
        'recommendation': recommendation,
        'auditedBy': auditedBy,
      };
}

class SovereignOnboardingRecord {
  final String recordId;
  final String partnerId;
  final String stage;
  final List<String> documentsRequired;
  final List<String> documentsSubmitted;
  final String sovereignMeshStatus;
  final String meshNodeId;
  final DateTime createdAt;

  SovereignOnboardingRecord({
    required this.recordId,
    required this.partnerId,
    required this.stage,
    required this.documentsRequired,
    required this.documentsSubmitted,
    required this.sovereignMeshStatus,
    required this.meshNodeId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'recordId': recordId,
        'partnerId': partnerId,
        'stage': stage,
        'documentsRequired': documentsRequired,
        'documentsSubmitted': documentsSubmitted,
        'sovereignMeshStatus': sovereignMeshStatus,
        'meshNodeId': meshNodeId,
        'createdAt': createdAt.toIso8601String(),
      };
}

class NorthWestAgentCapsule extends StatefulWidget {
  const NorthWestAgentCapsule({super.key});

  @override
  State<NorthWestAgentCapsule> createState() => _NorthWestAgentCapsuleState();
}

class _NorthWestAgentCapsuleState extends State<NorthWestAgentCapsule> {
  late List<PartnerEntity> partners;
  late List<ComplianceAudit> audits;
  late List<SovereignOnboardingRecord> onboardingRecords;
  String selectedPartnerId = '';
  String filterComplianceLevel = 'All';

  @override
  void initState() {
    super.initState();
    _initializePartners();
    _initializeAudits();
    _initializeOnboarding();
  }

  void _initializePartners() {
    partners = [
      PartnerEntity(
        partnerId: 'NWA-001',
        companyName: 'TechVenture Partners LLC',
        ein: '12-3456789',
        llcStatus: 'Active',
        complianceLevel: 'Tier 1',
        registryStatus: 'Verified',
        registeredDate: DateTime(2025, 10, 15),
        vaultGemmaEncrypted: '🔐 ENCRYPTED',
        xmcpOrchestrationId: 'xmcp-nwa-001-mesh',
        contactEmail: 'compliance@techventure.com',
        phone: '(503) 555-0100',
      ),
      PartnerEntity(
        partnerId: 'NWA-002',
        companyName: 'Sustainable Growth LLC',
        ein: '98-7654321',
        llcStatus: 'Active',
        complianceLevel: 'Tier 2',
        registryStatus: 'In Review',
        registeredDate: DateTime(2025, 11, 01),
        vaultGemmaEncrypted: '🔐 ENCRYPTED',
        xmcpOrchestrationId: 'xmcp-nwa-002-mesh',
        contactEmail: 'admin@sustgrowth.com',
        phone: '(503) 555-0200',
      ),
      PartnerEntity(
        partnerId: 'NWA-003',
        companyName: 'Community Impact Inc',
        ein: '55-1234567',
        llcStatus: 'Pending',
        complianceLevel: 'Onboarding',
        registryStatus: 'Pending',
        registeredDate: DateTime(2025, 11, 08),
        vaultGemmaEncrypted: '🔐 ENCRYPTED',
        xmcpOrchestrationId: 'xmcp-nwa-003-mesh',
        contactEmail: 'info@communityimpact.org',
        phone: '(503) 555-0300',
      ),
    ];
    if (partners.isNotEmpty) {
      selectedPartnerId = partners.first.partnerId;
    }
  }

  void _initializeAudits() {
    audits = [
      ComplianceAudit(
        auditId: 'AUD-001',
        partnerId: 'NWA-001',
        auditDate: DateTime(2025, 11, 05),
        status: 'Passed',
        findings:
            'All compliance requirements met. EIN verified. LLC status confirmed.',
        recommendation: 'Approve for Tier 1 sovereign mesh integration.',
        auditedBy: 'Compliance Officer - Sarah Chen',
      ),
      ComplianceAudit(
        auditId: 'AUD-002',
        partnerId: 'NWA-002',
        auditDate: DateTime(2025, 11, 08),
        status: 'In Review',
        findings:
            'Pending additional documentation verification. Tax ID cross-check needed.',
        recommendation: 'Schedule second audit after document submission.',
        auditedBy: 'Compliance Officer - Marcus Johnson',
      ),
    ];
  }

  void _initializeOnboarding() {
    onboardingRecords = [
      SovereignOnboardingRecord(
        recordId: 'ONB-001',
        partnerId: 'NWA-001',
        stage: 'Complete',
        documentsRequired: [
          'Articles of Incorporation',
          'EIN Letter',
          'Banking Authorization',
          'Compliance Questionnaire'
        ],
        documentsSubmitted: [
          'Articles of Incorporation',
          'EIN Letter',
          'Banking Authorization',
          'Compliance Questionnaire'
        ],
        sovereignMeshStatus: '✅ Connected',
        meshNodeId: 'mesh-node-nwa-001',
        createdAt: DateTime(2025, 10, 15),
      ),
      SovereignOnboardingRecord(
        recordId: 'ONB-002',
        partnerId: 'NWA-002',
        stage: 'In Progress',
        documentsRequired: [
          'Articles of Incorporation',
          'EIN Letter',
          'Banking Authorization',
          'Compliance Questionnaire',
          'Board Resolution'
        ],
        documentsSubmitted: ['Articles of Incorporation', 'EIN Letter'],
        sovereignMeshStatus: '⏳ Pending',
        meshNodeId: 'mesh-node-nwa-002',
        createdAt: DateTime(2025, 11, 01),
      ),
    ];
  }

  void _syncRegistryWithCapsules() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registry sync initiated with 13 capsules...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _triggerXMCPOrchestration(String partnerId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('XMCP orchestration triggered for $partnerId'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _exportComplianceAudit() {
    final selectedPartner =
        partners.firstWhere((p) => p.partnerId == selectedPartnerId);
    final auditData = {
      'partner': selectedPartner.toJson(),
      'relatedAudits': audits
          .where((a) => a.partnerId == selectedPartnerId)
          .map((a) => a.toJson())
          .toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
    final jsonString = jsonEncode(auditData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Compliance audit exported (${(jsonString.length / 1024).toStringAsFixed(2)} KB)'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Color _getComplianceLevelColor(String level) {
    if (level == 'Tier 1') return Colors.green;
    if (level == 'Tier 2') return Colors.orange;
    return Colors.red;
  }

  Color _getStatusColor(String status) {
    if (status == 'Verified') return Colors.green;
    if (status == 'In Review') return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final selectedPartner = partners.firstWhere(
      (p) => p.partnerId == selectedPartnerId,
      orElse: () => partners.first,
    );

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('🌐 NorthWest Agent Capsule'),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Partner Loop Integration & Sovereign Onboarding',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'EIN/LLC tracking, compliance optics, registry sync, XMCP orchestration',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Partner Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Partner Entity:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedPartnerId,
                      isExpanded: true,
                      items: partners
                          .map((p) => DropdownMenuItem(
                                value: p.partnerId,
                                child: Text(
                                    '${p.companyName} (${p.ein}) - ${p.registryStatus}'),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedPartnerId = value ?? ''),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Partner Details Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedPartner.companyName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(selectedPartner.registryStatus),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            selectedPartner.registryStatus,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('EIN:', selectedPartner.ein),
                    _buildDetailRow('LLC Status:', selectedPartner.llcStatus),
                    _buildDetailRow('Contact:', selectedPartner.contactEmail),
                    _buildDetailRow('Phone:', selectedPartner.phone),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Chip(
                          label: Text(selectedPartner.complianceLevel),
                          backgroundColor: _getComplianceLevelColor(
                              selectedPartner.complianceLevel),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(selectedPartner.vaultGemmaEncrypted),
                          backgroundColor: Colors.purple,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'XMCP ID: ${selectedPartner.xmcpOrchestrationId}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _syncRegistryWithCapsules,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Registry'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: () => _triggerXMCPOrchestration(selectedPartnerId),
                  icon: const Icon(Icons.settings_remote),
                  label: const Text('Trigger XMCP'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
                ElevatedButton.icon(
                  onPressed: _exportComplianceAudit,
                  icon: const Icon(Icons.download),
                  label: const Text('Export Audit'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Compliance Audit Section
            const Text('Compliance Audits',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...audits
                .where((a) => a.partnerId == selectedPartnerId)
                .map((audit) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(audit.auditId,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: audit.status == 'Passed'
                                        ? Colors.green
                                        : Colors.orange,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    audit.status,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                                'Date: ${audit.auditDate.toString().split(' ')[0]}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                            Text('Auditor: ${audit.auditedBy}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Text('Findings: ${audit.findings}',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    )),
            const SizedBox(height: 16),

            // Sovereign Onboarding Section
            const Text('Sovereign Mesh Onboarding',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...onboardingRecords
                .where((r) => r.partnerId == selectedPartnerId)
                .map((record) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(record.stage,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                Text(record.sovereignMeshStatus,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Mesh Node: ${record.meshNodeId}',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: Colors.grey[700])),
                            const SizedBox(height: 8),
                            Text(
                                'Required Docs: ${record.documentsRequired.length}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 11)),
                            Text(
                                'Submitted: ${record.documentsSubmitted.length}/${record.documentsRequired.length}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.blue)),
                            const SizedBox(height: 4),
                            ...record.documentsSubmitted.map((doc) => Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text('✅ $doc',
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.green)),
                                )),
                          ],
                        ),
                      ),
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              child: Text(value, style: TextStyle(color: Colors.grey[700]))),
        ],
      ),
    );
  }
}
