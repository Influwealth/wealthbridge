import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// FACTIIV Models
class Tradeline {
  final String tradelineId;
  final String vendorName;
  final String accountNumber;
  final String status; // 'active', 'closed', 'delinquent'
  final double creditLimit;
  final double currentBalance;
  final int monthsOpen;
  final int paymentHistory; // 0-100 score
  final DateTime lastPaymentDate;
  final DateTime openDate;
  final String? notes;

  Tradeline({
    required this.tradelineId,
    required this.vendorName,
    required this.accountNumber,
    required this.status,
    required this.creditLimit,
    required this.currentBalance,
    required this.monthsOpen,
    required this.paymentHistory,
    required this.lastPaymentDate,
    required this.openDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'tradelineId': tradelineId,
        'vendorName': vendorName,
        'accountNumber': accountNumber,
        'status': status,
        'creditLimit': creditLimit,
        'currentBalance': currentBalance,
        'monthsOpen': monthsOpen,
        'paymentHistory': paymentHistory,
        'lastPaymentDate': lastPaymentDate.toIso8601String(),
        'openDate': openDate.toIso8601String(),
        'notes': notes,
      };
}

class BlockchainCreditReport {
  final String reportId;
  final String partnerId;
  final String partnerName;
  final String subject; // Individual name for report
  final String vaultGemmaEncrypted;
  final String blockchainHash; // On-chain reference
  final List<Tradeline> tradelines;
  final int creditScore;
  final DateTime reportDate;
  final String status; // 'draft', 'submitted', 'confirmed', 'disputed'
  final String? ap2CommissionTriggerId;
  final String jsonExportHash;

  BlockchainCreditReport({
    required this.reportId,
    required this.partnerId,
    required this.partnerName,
    required this.subject,
    required this.vaultGemmaEncrypted,
    required this.blockchainHash,
    required this.tradelines,
    required this.creditScore,
    required this.reportDate,
    required this.status,
    this.ap2CommissionTriggerId,
    required this.jsonExportHash,
  });

  Map<String, dynamic> toJson() => {
        'reportId': reportId,
        'partnerId': partnerId,
        'partnerName': partnerName,
        'subject': subject,
        'vaultGemmaEncrypted': vaultGemmaEncrypted,
        'blockchainHash': blockchainHash,
        'tradelines': tradelines.map((t) => t.toJson()).toList(),
        'creditScore': creditScore,
        'reportDate': reportDate.toIso8601String(),
        'status': status,
        'ap2CommissionTriggerId': ap2CommissionTriggerId,
        'jsonExportHash': jsonExportHash,
      };
}

class DisputeRecord {
  final String disputeId;
  final String reportId;
  final String tradelineId;
  final String reason;
  final String status; // 'open', 'under_review', 'resolved', 'rejected'
  final DateTime createdDate;
  final DateTime? resolvedDate;
  final String? resolution;

  DisputeRecord({
    required this.disputeId,
    required this.reportId,
    required this.tradelineId,
    required this.reason,
    required this.status,
    required this.createdDate,
    this.resolvedDate,
    this.resolution,
  });

  Map<String, dynamic> toJson() => {
        'disputeId': disputeId,
        'reportId': reportId,
        'tradelineId': tradelineId,
        'reason': reason,
        'status': status,
        'createdDate': createdDate.toIso8601String(),
        'resolvedDate': resolvedDate?.toIso8601String(),
        'resolution': resolution,
      };
}

class FACTIIVCapsule extends StatefulWidget {
  const FACTIIVCapsule({super.key});

  @override
  State<FACTIIVCapsule> createState() => _FACTIIVCapsuleState();
}

class _FACTIIVCapsuleState extends State<FACTIIVCapsule> {
  late List<BlockchainCreditReport> _creditReports;
  late List<DisputeRecord> _disputes;
  int _selectedReportIndex = 0;
  bool _isProcessing = false;

  // Form controllers for new report
  final _partnerNameController = TextEditingController();
  final _subjectNameController = TextEditingController();
  final _vendorNameController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _balanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCreditReports();
    _initializeDisputes();
  }

  void _initializeCreditReports() {
    _creditReports = [
      BlockchainCreditReport(
        reportId: 'REPORT_001',
        partnerId: 'PARTNER_001',
        partnerName: 'Small Business Lender LLC',
        subject: 'John Smith',
        vaultGemmaEncrypted: '🔐 ENCRYPTED',
        blockchainHash: '0x7f4a3c2e9b1d5a8c6f3e2d1a',
        tradelines: [
          Tradeline(
            tradelineId: 'TL_001',
            vendorName: 'Community Finance Network',
            accountNumber: 'ACT-****-1234',
            status: 'active',
            creditLimit: 5000,
            currentBalance: 1200,
            monthsOpen: 24,
            paymentHistory: 95,
            lastPaymentDate: DateTime.now().subtract(const Duration(days: 3)),
            openDate: DateTime(2022, 6, 15),
          ),
          Tradeline(
            tradelineId: 'TL_002',
            vendorName: 'Digital Commerce Partner',
            accountNumber: 'ACT-****-5678',
            status: 'active',
            creditLimit: 10000,
            currentBalance: 3500,
            monthsOpen: 18,
            paymentHistory: 98,
            lastPaymentDate: DateTime.now().subtract(const Duration(days: 7)),
            openDate: DateTime(2023, 1, 20),
          ),
        ],
        creditScore: 750,
        reportDate: DateTime.now(),
        status: 'confirmed',
        ap2CommissionTriggerId: 'EVT_001',
        jsonExportHash: 'SHA256_hash_001',
      ),
      BlockchainCreditReport(
        reportId: 'REPORT_002',
        partnerId: 'PARTNER_002',
        partnerName: 'Fintech Growth Hub',
        subject: 'Maria Garcia',
        vaultGemmaEncrypted: '🔐 ENCRYPTED',
        blockchainHash: '0x9c2d5f8a1b4e7c3a6d9f2e5b',
        tradelines: [
          Tradeline(
            tradelineId: 'TL_003',
            vendorName: 'Vendor A',
            accountNumber: 'ACT-****-9012',
            status: 'active',
            creditLimit: 15000,
            currentBalance: 8750,
            monthsOpen: 36,
            paymentHistory: 92,
            lastPaymentDate: DateTime.now().subtract(const Duration(days: 5)),
            openDate: DateTime(2021, 3, 10),
          ),
        ],
        creditScore: 720,
        reportDate: DateTime.now().subtract(const Duration(days: 7)),
        status: 'submitted',
        jsonExportHash: 'SHA256_hash_002',
      ),
    ];
  }

  void _initializeDisputes() {
    _disputes = [
      DisputeRecord(
        disputeId: 'DSP_001',
        reportId: 'REPORT_001',
        tradelineId: 'TL_001',
        reason: 'Account incorrectly marked as delinquent',
        status: 'resolved',
        createdDate: DateTime.now().subtract(const Duration(days: 14)),
        resolvedDate: DateTime.now().subtract(const Duration(days: 7)),
        resolution: 'Verified as current, marked accurate',
      ),
    ];
  }

  Future<void> _submitTradeline() async {
    if (_partnerNameController.text.isEmpty ||
        _subjectNameController.text.isEmpty ||
        _vendorNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      final newTradeline = Tradeline(
        tradelineId: 'TL_${DateTime.now().millisecondsSinceEpoch}',
        vendorName: _vendorNameController.text,
        accountNumber:
            'ACT-****-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        status: 'active',
        creditLimit: double.tryParse(_creditLimitController.text) ?? 0,
        currentBalance: double.tryParse(_balanceController.text) ?? 0,
        monthsOpen: 1,
        paymentHistory: 100,
        lastPaymentDate: DateTime.now(),
        openDate: DateTime.now(),
      );

      // Update or create new report
      if (_selectedReportIndex < _creditReports.length) {
        final report = _creditReports[_selectedReportIndex];
        final updatedTradelines = [...report.tradelines, newTradeline];
        final creditScore = _calculateCreditScore(updatedTradelines);

        final updatedReport = BlockchainCreditReport(
          reportId: report.reportId,
          partnerId: report.partnerId,
          partnerName: report.partnerName,
          subject: report.subject,
          vaultGemmaEncrypted: report.vaultGemmaEncrypted,
          blockchainHash:
              '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
          tradelines: updatedTradelines,
          creditScore: creditScore,
          reportDate: DateTime.now(),
          status: 'draft',
          ap2CommissionTriggerId: report.ap2CommissionTriggerId,
          jsonExportHash: _generateHash(),
        );

        setState(() {
          _creditReports[_selectedReportIndex] = updatedReport;
        });
      }

      _partnerNameController.clear();
      _subjectNameController.clear();
      _vendorNameController.clear();
      _creditLimitController.clear();
      _balanceController.clear();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Tradeline submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  int _calculateCreditScore(List<Tradeline> tradelines) {
    if (tradelines.isEmpty) return 600;

    double avgPaymentHistory =
        tradelines.fold(0.0, (sum, t) => sum + t.paymentHistory) /
            tradelines.length;
    double utilization = 0;
    double totalLimit = 0;
    double totalBalance = 0;

    for (var t in tradelines) {
      totalLimit += t.creditLimit;
      totalBalance += t.currentBalance;
    }

    if (totalLimit > 0) {
      utilization = (totalBalance / totalLimit) * 100;
    }

    double score = 300 + (avgPaymentHistory * 3.5) - (utilization * 1.5);
    return score.clamp(300, 850).toInt();
  }

  String _generateHash() {
    return 'SHA256_${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
  }

  Future<void> _submitToBlockchain() async {
    if (_selectedReportIndex >= _creditReports.length) return;

    setState(() => _isProcessing = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      final report = _creditReports[_selectedReportIndex];
      final blockchainHash =
          '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16).padLeft(40, '0')}';

      final updatedReport = BlockchainCreditReport(
        reportId: report.reportId,
        partnerId: report.partnerId,
        partnerName: report.partnerName,
        subject: report.subject,
        vaultGemmaEncrypted: report.vaultGemmaEncrypted,
        blockchainHash: blockchainHash,
        tradelines: report.tradelines,
        creditScore: report.creditScore,
        reportDate: DateTime.now(),
        status: 'submitted',
        ap2CommissionTriggerId: 'EVT_${DateTime.now().millisecondsSinceEpoch}',
        jsonExportHash: report.jsonExportHash,
      );

      setState(() {
        _creditReports[_selectedReportIndex] = updatedReport;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Report submitted to blockchain!\nReference: ${blockchainHash.substring(0, 16)}...',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _fileDispute(String tradelineId) async {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Dispute'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Dispute Reason',
            border: OutlineInputBorder(),
            hintText: 'e.g., Incorrectly marked as delinquent',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!mounted) return;
              if (controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }

              final dispute = DisputeRecord(
                disputeId: 'DSP_${DateTime.now().millisecondsSinceEpoch}',
                reportId: _creditReports[_selectedReportIndex].reportId,
                tradelineId: tradelineId,
                reason: controller.text,
                status: 'open',
                createdDate: DateTime.now(),
              );

              setState(() => _disputes.add(dispute));

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Dispute filed successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
            ),
            child: const Text('File Dispute'),
          ),
        ],
      ),
    );
  }

  String _exportReportJSON() {
    if (_selectedReportIndex >= _creditReports.length) return '{}';
    final report = _creditReports[_selectedReportIndex];
    return jsonEncode({
      'report': report.toJson(),
      'disputes': _disputes
          .where((d) => d.reportId == report.reportId)
          .map((d) => d.toJson())
          .toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'encryptionMethod': 'VaultGemma',
    });
  }

  Color _getScoreColor(int score) {
    if (score >= 750) return Colors.green;
    if (score >= 700) return Colors.blue;
    if (score >= 650) return Colors.orange;
    return Colors.red;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'submitted':
        return Colors.blue;
      case 'draft':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FACTIIV: B2B Blockchain Credit Reporting'),
        backgroundColor: Colors.teal[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal[700]!, Colors.teal[300]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Decentralized Credit Network',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '🔗 Blockchain • 🔐 VaultGemma • 📊 B2B Tradelines • 💰 AP2 Integration',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Report Selection
              const Text(
                'Select Credit Report',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (_creditReports.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                    value: _selectedReportIndex,
                    isExpanded: true,
                    underline: const SizedBox(),
                    onChanged: (idx) =>
                        setState(() => _selectedReportIndex = idx ?? 0),
                    items: _creditReports
                        .asMap()
                        .entries
                        .map((entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.value.subject,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            entry.value.partnerName,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            _getStatusColor(entry.value.status)
                                                .withAlpha(51),
                                        border: Border.all(
                                          color: _getStatusColor(
                                              entry.value.status),
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        entry.value.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(
                                              entry.value.status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              const SizedBox(height: 24),

              // Report Details
              if (_selectedReportIndex < _creditReports.length)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.teal[200]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.teal[50],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _creditReports[_selectedReportIndex]
                                        .subject,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _creditReports[_selectedReportIndex]
                                        .partnerName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getScoreColor(
                                      _creditReports[_selectedReportIndex]
                                          .creditScore),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Credit Score',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      _creditReports[_selectedReportIndex]
                                          .creditScore
                                          .toString(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  'Report ID',
                                  _creditReports[_selectedReportIndex]
                                      .reportId
                                      .substring(0, 12),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  'Created',
                                  DateFormat('MMM dd').format(
                                      _creditReports[_selectedReportIndex]
                                          .reportDate),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  'Tradelines',
                                  _creditReports[_selectedReportIndex]
                                      .tradelines
                                      .length
                                      .toString(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lock,
                                    size: 14, color: Colors.teal),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'VaultGemma: ${_creditReports[_selectedReportIndex].vaultGemmaEncrypted}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.link,
                                    size: 14, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Blockchain: ${_creditReports[_selectedReportIndex].blockchainHash.substring(0, 20)}...',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tradelines Section
                    const Text(
                      'Tradelines',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ..._creditReports[_selectedReportIndex]
                        .tradelines
                        .map((tradeline) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tradeline.vendorName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          tradeline.accountNumber,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tradeline.status == 'active'
                                          ? Colors.green[100]
                                          : Colors.red[100],
                                      border: Border.all(
                                        color: tradeline.status == 'active'
                                            ? Colors.green[700]!
                                            : Colors.red[700]!,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      tradeline.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: tradeline.status == 'active'
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildTradelineDetail(
                                    'Limit',
                                    '\$${tradeline.creditLimit.toStringAsFixed(0)}',
                                  ),
                                  _buildTradelineDetail(
                                    'Balance',
                                    '\$${tradeline.currentBalance.toStringAsFixed(0)}',
                                  ),
                                  _buildTradelineDetail(
                                    'Payment History',
                                    '${tradeline.paymentHistory}%',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _fileDispute(tradeline.tradelineId),
                                  icon: const Icon(Icons.flag, size: 16),
                                  label: const Text('File Dispute'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange[700],
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // Add New Tradeline
                    const Text(
                      'Add Tradeline',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _vendorNameController,
                            decoration: InputDecoration(
                              labelText: 'Vendor Name',
                              prefixIcon: const Icon(Icons.business),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _creditLimitController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Credit Limit',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _balanceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Current Balance',
                              prefixIcon: const Icon(Icons.account_balance),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isProcessing ? null : _submitTradeline,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal[700],
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Add Tradeline'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Blockchain Submission
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _submitToBlockchain,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.link),
                        label: Text(_isProcessing
                            ? 'Submitting...'
                            : 'Submit to Blockchain'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Disputes Section
                    if (_disputes.isNotEmpty)
                      Column(
                        children: [
                          const Text(
                            'Dispute History',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._disputes
                              .where((d) =>
                                  d.reportId ==
                                  _creditReports[_selectedReportIndex].reportId)
                              .map((dispute) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.orange[300]!,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.orange[50],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            dispute.reason,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: dispute.status == 'resolved'
                                                ? Colors.green[100]
                                                : Colors.orange[100],
                                            border: Border.all(
                                              color:
                                                  dispute.status == 'resolved'
                                                      ? Colors.green[700]!
                                                      : Colors.orange[700]!,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            dispute.status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  dispute.status == 'resolved'
                                                      ? Colors.green[700]
                                                      : Colors.orange[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Filed: ${DateFormat('MMM dd, yyyy').format(dispute.createdDate)}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (dispute.resolution != null)
                                      Column(
                                        children: [
                                          const SizedBox(height: 8),
                                          Text(
                                            'Resolution: ${dispute.resolution}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 24),
                        ],
                      ),

                    // Export & AP2 Integration
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _exportReportJSON();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '✅ Report exported (VaultGemma encrypted)',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Export JSON'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[700],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✅ Triggered AP2 commission: EVT_${_creditReports[_selectedReportIndex].ap2CommissionTriggerId ?? DateTime.now().millisecondsSinceEpoch}',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            },
                            icon: const Icon(Icons.monetization_on),
                            label: const Text('Trigger AP2'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple[700],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.teal[700]),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Blockchain B2B Credit Network',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '🔗 Immutable tradeline ledger\n'
                      '🔐 VaultGemma data encryption\n'
                      '📊 Partner verification system\n'
                      '💰 AP2 commission triggers\n'
                      '📋 JSON export with full audit trail\n'
                      '⚖️ Dispute resolution framework',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildTradelineDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _partnerNameController.dispose();
    _subjectNameController.dispose();
    _vendorNameController.dispose();
    _creditLimitController.dispose();
    _balanceController.dispose();
    super.dispose();
  }
}
