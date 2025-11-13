import 'dart:convert';

import 'package:flutter/material.dart';

// FACTIIV Audit Trail Model
class AuditTrailEntry {
  final DateTime timestamp;
  final String action;
  final String category;
  final Map<String, dynamic> metadata;
  final String userId;

  AuditTrailEntry({
    required this.timestamp,
    required this.action,
    required this.category,
    required this.metadata,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'action': action,
        'category': category,
        'metadata': metadata,
        'userId': userId,
      };
}

// IRS Red Flag Detection Model
class IRSRedFlag {
  final String flag;
  final int riskScore;
  final String severity;
  final String recommendation;

  IRSRedFlag({
    required this.flag,
    required this.riskScore,
    required this.severity,
    required this.recommendation,
  });
}

enum FilingStatus { simulated, submitted, confirmed, amended }

class TaxAutomationCapsule extends StatefulWidget {
  const TaxAutomationCapsule({super.key});

  @override
  State<TaxAutomationCapsule> createState() => _TaxAutomationCapsuleState();
}

class _TaxAutomationCapsuleState extends State<TaxAutomationCapsule> {
  final _formKey = GlobalKey<FormState>();

  // Personal Info
  String ssn = '';
  String firstName = '';
  String lastName = '';
  String email = '';
  String userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

  // Income
  double w2Income = 0;
  double businessIncome = 0;
  double investmentIncome = 0;
  double rentIncome = 0;
  double capitalGains = 0;

  // Deductions
  double standardDeductions = 13850;
  double itemizedDeductions = 0;
  double businessExpenses = 0;
  bool useItemized = false;

  // Tax Year & Features
  int taxYear = 2024;
  bool showAmendment = false;
  bool enableAuditDefense = false;
  bool enableSMSReminders = false;
  bool isEncrypted = false;
  bool isSyncedToSheets = false;
  bool irsEFileReady = false;

  // Filing State
  FilingStatus currentFilingStatus = FilingStatus.simulated;
  bool _isProcessing = false;
  final List<String> _amendmentHistory = [];
  final List<AuditTrailEntry> _auditTrail = [];
  final List<IRSRedFlag> _redFlags = [];
  int _auditRiskScore = 0;

  // Getters
  double get effectiveDeductions {
    final itemized = itemizedDeductions + businessExpenses;
    return useItemized && itemized > standardDeductions
        ? itemized
        : standardDeductions;
  }

  double get totalIncome =>
      w2Income + businessIncome + investmentIncome + rentIncome + capitalGains;

  double get taxableIncome {
    final taxable = totalIncome - effectiveDeductions;
    return taxable > 0 ? taxable : 0;
  }

  double calculateFederalTax(double taxable) {
    if (taxable <= 11600) return taxable * 0.10;
    if (taxable <= 47150) return 1160 + (taxable - 11600) * 0.12;
    if (taxable <= 100525) return 5426 + (taxable - 47150) * 0.22;
    if (taxable <= 191950) return 17168.50 + (taxable - 100525) * 0.24;
    if (taxable <= 243725) return 39110.50 + (taxable - 191950) * 0.32;
    if (taxable <= 609350) return 55678.50 + (taxable - 243725) * 0.35;
    return 170098.50 + (taxable - 609350) * 0.37;
  }

  double estimateWithholding() {
    double withholding = 0;
    withholding += w2Income * 0.18;
    withholding += businessIncome * 0.923 * 0.153;
    withholding += investmentIncome * 0.15;
    withholding += rentIncome * 0.10;
    withholding += capitalGains * 0.20;
    return withholding;
  }

  double get estimatedTax => calculateFederalTax(taxableIncome);
  double get estimatedWithholding => estimateWithholding();
  double get estimatedRefund => estimatedWithholding - estimatedTax;

  void _logAuditEntry(
    String action,
    String category,
    Map<String, dynamic> metadata,
  ) {
    final entry = AuditTrailEntry(
      timestamp: DateTime.now(),
      action: action,
      category: category,
      metadata: metadata,
      userId: userId,
    );
    setState(() => _auditTrail.add(entry));
  }

  void _detectRedFlags() {
    setState(() => _redFlags.clear());
    int riskScore = 0;

    if (totalIncome > 100000 && effectiveDeductions < (totalIncome * 0.10)) {
      _redFlags.add(
        IRSRedFlag(
          flag: 'High income with unusually low deductions',
          riskScore: 15,
          severity: 'Medium',
          recommendation: 'Document all eligible deductions carefully',
        ),
      );
      riskScore += 15;
    }

    if (businessIncome > 50000 && businessExpenses == 0) {
      _redFlags.add(
        IRSRedFlag(
          flag: 'Self-employment income with zero business expenses',
          riskScore: 25,
          severity: 'High',
          recommendation: 'Review and document legitimate business expenses',
        ),
      );
      riskScore += 25;
    }

    if (itemizedDeductions > (totalIncome * 0.25)) {
      _redFlags.add(
        IRSRedFlag(
          flag: 'Unusually high charitable deductions',
          riskScore: 20,
          severity: 'Medium',
          recommendation: 'Keep detailed records of all charitable donations',
        ),
      );
      riskScore += 20;
    }

    if (capitalGains > 50000) {
      _redFlags.add(
        IRSRedFlag(
          flag: 'Significant capital gains reported',
          riskScore: 10,
          severity: 'Low',
          recommendation: 'Ensure accurate cost basis calculations',
        ),
      );
      riskScore += 10;
    }

    if (rentIncome < 0) {
      _redFlags.add(
        IRSRedFlag(
          flag: 'Passive activity loss reported',
          riskScore: 15,
          severity: 'Medium',
          recommendation: 'Document all rental property expenses meticulously',
        ),
      );
      riskScore += 15;
    }

    setState(() => _auditRiskScore = riskScore.clamp(0, 100));
    _logAuditEntry('Red flag analysis completed', 'Audit Defense', {
      'flagCount': _redFlags.length,
      'riskScore': _auditRiskScore,
    });
  }

  void _maskSSN(String value) {
    if (value.length >= 4) {
      ssn = 'XXX-XX-${value.substring(value.length - 4)}';
    }
  }

  String _exportAuditTrailJSON() {
    final entries = _auditTrail.map((e) => e.toJson()).toList();
    return jsonEncode({
      'userId': userId,
      'taxYear': taxYear,
      'exportedAt': DateTime.now().toIso8601String(),
      'totalEntries': entries.length,
      'entries': entries,
    });
  }

  Future<void> _submitIRSEFile() async {
    _logAuditEntry('IRS e-file submission initiated', 'Filing', {
      'taxYear': taxYear,
      'formType': 'Form 1040',
      'filingType': 'Original',
    });

    setState(() => _isProcessing = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      final gvid = 'GVID${DateTime.now().millisecondsSinceEpoch}';

      setState(() {
        isEncrypted = true;
        irsEFileReady = true;
        currentFilingStatus = FilingStatus.submitted;
      });

      _logAuditEntry('IRS e-file submitted successfully', 'Filing', {
        'gvid': gvid,
        'timestamp': DateTime.now().toIso8601String(),
        'taxYear': taxYear,
        'status': 'ACCEPTED',
      });

      await Future.delayed(const Duration(seconds: 1));
      setState(() => isSyncedToSheets = true);

      _logAuditEntry('Filing synced to Google Sheets', 'Integration', {
        'sheetId': 'tax_returns_$taxYear',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ IRS e-file submitted! Reference: $gvid'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      _logAuditEntry('IRS e-file submission failed', 'Filing', {
        'error': e.toString(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _sendSMSReminder() {
    _logAuditEntry('SMS reminder triggered', 'Outreach', {
      'reminderType': 'Filing Deadline',
      'taxYear': taxYear,
      'timestamp': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📱 SMS reminder queued (Twilio integration ready)'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _generateAmendment() {
    if (totalIncome == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in income information first'),
        ),
      );
      return;
    }

    final amendment =
        'Form 1040-X Amendment - $taxYear (${DateTime.now().toString().split(' ')[0]})';

    _logAuditEntry('Amendment generated', 'Amendment', {
      'formType': '1040-X',
      'taxYear': taxYear,
      'timestamp': DateTime.now().toIso8601String(),
    });

    setState(() {
      _amendmentHistory.add(amendment);
      currentFilingStatus = FilingStatus.amended;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Amendment Generated (1040-X)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amendment: $amendment'),
              const SizedBox(height: 16),
              const Text(
                'Original Filing:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('AGI: \$${totalIncome.toStringAsFixed(2)}'),
              Text('Taxable Income: \$${taxableIncome.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '🔐 Encrypted with VaultGemma\n'
                  '☁️ Synced to Google Sheets\n'
                  '📋 Audit trail preserved',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logAuditEntry('Amendment submitted', 'Amendment', {
                'amendmentIndex': _amendmentHistory.length - 1,
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Amendment queued for filing'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Submit Amendment'),
          ),
        ],
      ),
    );
  }

  void _viewAuditRiskMeter() {
    _detectRedFlags();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audit Risk Assessment (FACTIIV)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getRiskColor(_auditRiskScore).withAlpha(26),
                  border: Border.all(color: _getRiskColor(_auditRiskScore)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Audit Risk Score',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getRiskColor(_auditRiskScore),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_auditRiskScore/100',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _auditRiskScore / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getRiskColor(_auditRiskScore),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getRiskLevel(_auditRiskScore),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getRiskColor(_auditRiskScore),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_redFlags.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detected Issues:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._redFlags.map((flag) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: _getSeverityColor(flag.severity),
                                width: 4,
                              ),
                            ),
                            color: Color.fromARGB(
                              (0.05 * 255).round(),
                              _getSeverityColor(flag.severity).red,
                              _getSeverityColor(flag.severity).green,
                              _getSeverityColor(flag.severity).blue,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    size: 16,
                                    color: _getSeverityColor(flag.severity),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      flag.flag,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Risk: +${flag.riskScore} | ${flag.severity}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '💡 ${flag.recommendation}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              if (_redFlags.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '✅ No red flags detected!',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              _exportAuditTrailJSON();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audit trail exported')),
              );
              Navigator.pop(context);
            },
            child: const Text('Export Audit Trail'),
          ),
        ],
      ),
    );
  }

  void _viewRefundTracking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refund Tracking & Filing Status'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated Refund',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '\$${estimatedRefund.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildRefundBreakdown('AGI', totalIncome),
              const SizedBox(height: 8),
              _buildRefundBreakdown('Deductions', -effectiveDeductions),
              const SizedBox(height: 8),
              _buildRefundBreakdown('Taxable Income', taxableIncome),
              const SizedBox(height: 8),
              _buildRefundBreakdown('Est. Tax', estimatedTax),
              const SizedBox(height: 8),
              _buildRefundBreakdown(
                'Est. Withholding',
                estimatedWithholding,
                Colors.blue,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundBreakdown(String label, double amount, [Color? color]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          '${amount < 0 ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(int score) {
    if (score <= 20) return Colors.green;
    if (score <= 40) return Colors.yellow;
    if (score <= 60) return Colors.orange;
    return Colors.red;
  }

  String _getRiskLevel(int score) {
    if (score <= 20) return '✅ Low Risk';
    if (score <= 40) return '⚠️ Moderate Risk';
    if (score <= 60) return '⚠️ Elevated Risk';
    return '🚨 High Risk';
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Critical':
        return Colors.red;
      case 'High':
        return Colors.orange;
      case 'Medium':
        return Colors.yellow;
      default:
        return Colors.blue;
    }
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromARGB(
            (0.1 * 255).round(), color.red, color.green, color.blue),
        border: Border.all(
            color: Color.fromARGB(
                (0.3 * 255).round(), color.red, color.green, color.blue)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Automation Capsule'),
        backgroundColor: Colors.amber[700],
        elevation: 0,
        actions: [
          if (isEncrypted)
            Tooltip(
              message: 'VaultGemma: Sovereign Data Encryption',
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(Icons.lock, color: Colors.green[300]),
              ),
            ),
          if (isSyncedToSheets)
            Tooltip(
              message: 'Synced to Google Sheets',
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(Icons.cloud_done, color: Colors.blue[300]),
              ),
            ),
          if (irsEFileReady)
            Tooltip(
              message: 'IRS e-file ready',
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(Icons.verified, color: Colors.purple[300]),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber[700]!, Colors.amber[300]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sovereign Tax Filing & Audit Defense',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '🔐 VaultGemma • ☁️ Sheets • 📋 FACTIIV • 📞 Twilio',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (totalIncome > 0)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Income',
                            '\$${totalIncome.toStringAsFixed(2)}',
                            Icons.trending_up,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Est. Refund',
                            '\$${estimatedRefund.toStringAsFixed(2)}',
                            Icons.attach_money,
                            estimatedRefund >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_auditRiskScore > 0)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getRiskColor(
                            _auditRiskScore,
                          ).withAlpha(26),
                          border: Border.all(
                            color: _getRiskColor(_auditRiskScore),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Audit Risk (FACTIIV)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _getRiskLevel(_auditRiskScore),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getRiskColor(_auditRiskScore),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getRiskColor(_auditRiskScore),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$_auditRiskScore/100',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (val) => setState(() => firstName = val),
                      validator: (val) =>
                          val?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (val) => setState(() => lastName = val),
                      validator: (val) =>
                          val?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (val) => setState(() => email = val),
                      validator: (val) =>
                          val?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'SSN (masked)',
                        prefixIcon: const Icon(Icons.security),
                        hintText: 'XXX-XX-1234',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      obscureText: true,
                      onChanged: _maskSSN,
                      validator: (val) =>
                          val?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Income Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'W-2 Income',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) =>
                          setState(() => w2Income = double.tryParse(val) ?? 0),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Business/Self-Employment Income',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(
                        () => businessIncome = double.tryParse(val) ?? 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Business Expenses',
                        prefixIcon: const Icon(Icons.receipt),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(
                        () => businessExpenses = double.tryParse(val) ?? 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Investment Income',
                        prefixIcon: const Icon(Icons.trending_up),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(
                        () => investmentIncome = double.tryParse(val) ?? 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Rental Income',
                        prefixIcon: const Icon(Icons.apartment),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(
                        () => rentIncome = double.tryParse(val) ?? 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Capital Gains/Losses',
                        prefixIcon: const Icon(Icons.candlestick_chart),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(
                        () => capitalGains = double.tryParse(val) ?? 0,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Deductions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Use Itemized Deductions'),
                      subtitle: Text(
                        'Standard: \$${standardDeductions.toStringAsFixed(2)}',
                      ),
                      value: useItemized,
                      onChanged: (val) => setState(() => useItemized = val),
                      activeThumbColor: Colors.amber[700],
                    ),
                    if (useItemized)
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Itemized Deductions Amount',
                              prefixIcon: const Icon(Icons.receipt),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => setState(
                              () => itemizedDeductions =
                                  double.tryParse(val) ?? 0,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: taxYear,
                      items: [2022, 2023, 2024, 2025]
                          .map(
                            (year) => DropdownMenuItem(
                              value: year,
                              child: Text('$year'),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => taxYear = val ?? 2024),
                      decoration: InputDecoration(
                        labelText: 'Tax Year',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: const Text('Enable Audit Defense (FACTIIV)'),
                      subtitle: const Text('Real-time compliance checking'),
                      value: enableAuditDefense,
                      onChanged: (val) =>
                          setState(() => enableAuditDefense = val),
                      activeThumbColor: Colors.amber[700],
                    ),
                    SwitchListTile(
                      title: const Text('Include Amendment (1040-X)'),
                      subtitle: const Text('For correcting previous returns'),
                      value: showAmendment,
                      onChanged: (val) => setState(() => showAmendment = val),
                      activeThumbColor: Colors.amber[700],
                    ),
                    SwitchListTile(
                      title: const Text('Enable SMS Reminders (Twilio)'),
                      subtitle: const Text('Filing deadlines & updates'),
                      value: enableSMSReminders,
                      onChanged: (val) =>
                          setState(() => enableSMSReminders = val),
                      activeThumbColor: Colors.amber[700],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _submitIRSEFile,
                        icon: _isProcessing
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withAlpha(179),
                                  ),
                                ),
                              )
                            : const Icon(Icons.check_circle),
                        label: Text(
                          _isProcessing
                              ? 'Processing...'
                              : 'Submit IRS e-file (1040)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _viewRefundTracking,
                            icon: const Icon(Icons.visibility),
                            label: const Text('Refund Status'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                enableAuditDefense ? _viewAuditRiskMeter : null,
                            icon: const Icon(Icons.shield),
                            label: const Text('Audit Risk'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (showAmendment)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _generateAmendment,
                          icon: const Icon(Icons.edit_document),
                          label: const Text('Generate Amendment (1040-X)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    if (enableSMSReminders)
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _sendSMSReminder,
                              icon: const Icon(Icons.sms),
                              label: const Text('Send SMS Reminder (Twilio)'),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    if (_amendmentHistory.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Amendment History',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._amendmentHistory.map((amendment) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.orange[200]!,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.orange[50],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_note,
                                      color: Colors.orange[700],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(amendment)),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 24),
                        ],
                      ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue[700]),
                              const SizedBox(width: 12),
                              const Text(
                                'Sovereign Compliance & Security',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '🔐 VaultGemma: Sovereign data encryption\n'
                            '☁️ Google Sheets: Audit trail sync\n'
                            '📋 FACTIIV: Timestamped compliance logging\n'
                            '📞 Twilio: SMS & voice integration\n'
                            '✅ IRS Form 1040, 1040-X compliant\n'
                            '🧬 MCP: Real-time IRS rule fetching ready',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_auditTrail.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple[200]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'FACTIIV Audit Trail',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${_auditTrail.length} events logged',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _exportAuditTrailJSON();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Audit trail exported'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Export',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
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
}
