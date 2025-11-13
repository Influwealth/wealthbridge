import 'dart:convert';

import 'package:flutter/material.dart';

// Data Models
class EntityRegistration {
  final String entityId;
  final String businessName;
  final String entityType; // LLC, S-Corp, C-Corp
  final String ein;
  final String status;
  final String legalZoomTicket;
  final String zenBusinessTicket;
  final String incfileTicket;
  final DateTime createdAt;
  final String vaultGemmaEncrypted;
  final String xmcpOrchestrationId;

  EntityRegistration({
    required this.entityId,
    required this.businessName,
    required this.entityType,
    required this.ein,
    required this.status,
    required this.legalZoomTicket,
    required this.zenBusinessTicket,
    required this.incfileTicket,
    required this.createdAt,
    required this.vaultGemmaEncrypted,
    required this.xmcpOrchestrationId,
  });

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'businessName': businessName,
        'entityType': entityType,
        'ein': ein,
        'status': status,
        'legalZoomTicket': legalZoomTicket,
        'zenBusinessTicket': zenBusinessTicket,
        'incfileTicket': incfileTicket,
        'createdAt': createdAt.toIso8601String(),
        'vaultGemmaEncrypted': vaultGemmaEncrypted,
        'xmcpOrchestrationId': xmcpOrchestrationId,
      };
}

class DocumentSyncRecord {
  final String syncId;
  final String entityId;
  final String documentType;
  final String fileName;
  final String vaultGemmaHash;
  final String syncStatus;
  final DateTime syncedAt;

  DocumentSyncRecord({
    required this.syncId,
    required this.entityId,
    required this.documentType,
    required this.fileName,
    required this.vaultGemmaHash,
    required this.syncStatus,
    required this.syncedAt,
  });

  Map<String, dynamic> toJson() => {
        'syncId': syncId,
        'entityId': entityId,
        'documentType': documentType,
        'fileName': fileName,
        'vaultGemmaHash': vaultGemmaHash,
        'syncStatus': syncStatus,
        'syncedAt': syncedAt.toIso8601String(),
      };
}

class CompanySetupCapsule extends StatefulWidget {
  const CompanySetupCapsule({super.key});

  @override
  State<CompanySetupCapsule> createState() => _CompanySetupCapsuleState();
}

class _CompanySetupCapsuleState extends State<CompanySetupCapsule> {
  late List<EntityRegistration> entities;
  late List<DocumentSyncRecord> documents;
  String selectedEntityId = '';
  String selectedProvider = 'LegalZoom';
  String newEntityType = 'LLC';

  @override
  void initState() {
    super.initState();
    _initializeEntities();
    _initializeDocuments();
  }

  void _initializeEntities() {
    entities = [
      EntityRegistration(
        entityId: 'ENT-001',
        businessName: 'TechVenture Innovations LLC',
        entityType: 'LLC',
        ein: '12-3456789',
        status: 'Registered',
        legalZoomTicket: 'LZ-2025-11-001',
        zenBusinessTicket: 'ZB-2025-11-001',
        incfileTicket: 'IF-2025-11-001',
        createdAt: DateTime(2025, 10, 20),
        vaultGemmaEncrypted: '🔐 ENCRYPTED',
        xmcpOrchestrationId: 'xmcp-setup-001',
      ),
      EntityRegistration(
        entityId: 'ENT-002',
        businessName: 'Green Energy S-Corp',
        entityType: 'S-Corp',
        ein: '98-7654321',
        status: 'In Progress',
        legalZoomTicket: 'LZ-2025-11-002',
        zenBusinessTicket: '',
        incfileTicket: 'IF-2025-11-002',
        createdAt: DateTime(2025, 11, 01),
        vaultGemmaEncrypted: '🔐 ENCRYPTED',
        xmcpOrchestrationId: 'xmcp-setup-002',
      ),
    ];
    if (entities.isNotEmpty) {
      selectedEntityId = entities.first.entityId;
    }
  }

  void _initializeDocuments() {
    documents = [
      DocumentSyncRecord(
        syncId: 'DOC-001',
        entityId: 'ENT-001',
        documentType: 'Articles of Organization',
        fileName: 'articles_org_ent001.pdf',
        vaultGemmaHash: '0x7a3f2b8c9e1d4f6a5e2c8b3f9a1d4e7c',
        syncStatus: 'Synced',
        syncedAt: DateTime(2025, 10, 21),
      ),
      DocumentSyncRecord(
        syncId: 'DOC-002',
        entityId: 'ENT-001',
        documentType: 'EIN Confirmation Letter',
        fileName: 'ein_letter_ent001.pdf',
        vaultGemmaHash: '0x9f2e4c6a8b1d3e5f7a2c4e6b8d1f3a5c',
        syncStatus: 'Synced',
        syncedAt: DateTime(2025, 10, 22),
      ),
    ];
  }

  void _triggerEntityCreation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Entity creation triggered via $selectedProvider'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _syncVaultGemmaDocuments() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('VaultGemma document sync initiated...'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _exportEntityData() {
    final selectedEntity =
        entities.firstWhere((e) => e.entityId == selectedEntityId);
    final entityDocs =
        documents.where((d) => d.entityId == selectedEntityId).toList();
    final exportData = {
      'entity': selectedEntity.toJson(),
      'documents': entityDocs.map((d) => d.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
    final jsonString = jsonEncode(exportData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Entity data exported (${(jsonString.length / 1024).toStringAsFixed(2)} KB)'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Registered') return Colors.green;
    if (status == 'In Progress') return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final selectedEntity = entities.firstWhere(
      (e) => e.entityId == selectedEntityId,
      orElse: () => entities.first,
    );

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('🏢 Company Setup Capsule'),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Entity Registration & Document Management',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'LegalZoom, ZenBusiness, Incfile integration • EIN registration • LLC/S-Corp flows',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Entity Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Business Entity:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedEntityId,
                      isExpanded: true,
                      items: entities
                          .map((e) => DropdownMenuItem(
                                value: e.entityId,
                                child:
                                    Text('${e.businessName} (${e.entityType})'),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedEntityId = value ?? ''),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Entity Details
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedEntity.businessName,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Type: ${selectedEntity.entityType}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(selectedEntity.status),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            selectedEntity.status,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('EIN: ${selectedEntity.ein}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        'Created: ${selectedEntity.createdAt.toString().split(' ')[0]}',
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 12),
                    Chip(
                      label: Text(selectedEntity.vaultGemmaEncrypted),
                      backgroundColor: Colors.purple,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Provider Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Registration Provider:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['LegalZoom', 'ZenBusiness', 'Incfile']
                          .map((provider) {
                        return ChoiceChip(
                          label: Text(provider),
                          selected: selectedProvider == provider,
                          onSelected: (selected) =>
                              setState(() => selectedProvider = provider),
                        );
                      }).toList(),
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
                  onPressed: _triggerEntityCreation,
                  icon: const Icon(Icons.business),
                  label: const Text('Create Entity'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: _syncVaultGemmaDocuments,
                  icon: const Icon(Icons.security),
                  label: const Text('Sync Docs'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                ),
                ElevatedButton.icon(
                  onPressed: _exportEntityData,
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Provider Tickets
            const Text('Provider Tickets',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...[
              ('LegalZoom', selectedEntity.legalZoomTicket),
              ('ZenBusiness', selectedEntity.zenBusinessTicket),
              ('Incfile', selectedEntity.incfileTicket),
            ].map((pair) {
              final (provider, ticket) = pair;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 100,
                          child: Text(provider,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                      Expanded(
                        child: Text(
                          ticket.isEmpty ? 'Not submitted' : ticket,
                          style: TextStyle(
                            color: ticket.isEmpty ? Colors.grey : Colors.green,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Icon(
                        ticket.isEmpty ? Icons.schedule : Icons.check_circle,
                        color: ticket.isEmpty ? Colors.orange : Colors.green,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // VaultGemma Documents
            const Text('VaultGemma Synced Documents',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...documents
                .where((d) => d.entityId == selectedEntityId)
                .map((doc) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(doc.documentType,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    doc.syncStatus,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('File: ${doc.fileName}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                            Text(
                                'Hash: ${doc.vaultGemmaHash.substring(0, 20)}...',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: Colors.grey[500])),
                          ],
                        ),
                      ),
                    )),
          ],
        ),
      ),
    );
  }
}
