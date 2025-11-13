import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// AP2 Models
class AffiliateAccount {
  final String affiliateId;
  final String name;
  final String email;
  final String phone;
  final String organization;
  final String tier; // 'Bronze', 'Silver', 'Gold', 'Platinum'
  final double tierMultiplier;
  final double totalEarnings;
  final double pendingPayout;
  final DateTime joinDate;
  final bool isActive;
  final String? stripeAccountId;
  final String? stablecoinWalletAddress;

  AffiliateAccount({
    required this.affiliateId,
    required this.name,
    required this.email,
    required this.phone,
    required this.organization,
    required this.tier,
    required this.tierMultiplier,
    required this.totalEarnings,
    required this.pendingPayout,
    required this.joinDate,
    required this.isActive,
    this.stripeAccountId,
    this.stablecoinWalletAddress,
  });

  Map<String, dynamic> toJson() => {
        'affiliateId': affiliateId,
        'name': name,
        'email': email,
        'phone': phone,
        'organization': organization,
        'tier': tier,
        'tierMultiplier': tierMultiplier,
        'totalEarnings': totalEarnings,
        'pendingPayout': pendingPayout,
        'joinDate': joinDate.toIso8601String(),
        'isActive': isActive,
        'stripeAccountId': stripeAccountId,
        'stablecoinWalletAddress': stablecoinWalletAddress,
      };
}

class CommissionEvent {
  final String eventId;
  final String affiliateId;
  final String capsuleTriggered; // Which capsule generated this commission
  final String
      userAction; // 'signup', 'funding_approved', 'tradeline_added', etc.
  final double baseAmount;
  final double tierBonus;
  final double totalCommission;
  final double? stripeAmount;
  final String? stablecoinAmount;
  final String paymentMethod; // 'stripe', 'stablecoin', 'hybrid'
  final String status; // 'pending', 'processing', 'completed', 'failed'
  final DateTime createdAt;
  final String? xmcpOrchestrationId;

  CommissionEvent({
    required this.eventId,
    required this.affiliateId,
    required this.capsuleTriggered,
    required this.userAction,
    required this.baseAmount,
    required this.tierBonus,
    required this.totalCommission,
    this.stripeAmount,
    this.stablecoinAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.xmcpOrchestrationId,
  });

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'affiliateId': affiliateId,
        'capsuleTriggered': capsuleTriggered,
        'userAction': userAction,
        'baseAmount': baseAmount,
        'tierBonus': tierBonus,
        'totalCommission': totalCommission,
        'stripeAmount': stripeAmount,
        'stablecoinAmount': stablecoinAmount,
        'paymentMethod': paymentMethod,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'xmcpOrchestrationId': xmcpOrchestrationId,
      };
}

class AP2Capsule extends StatefulWidget {
  const AP2Capsule({super.key});

  @override
  State<AP2Capsule> createState() => _AP2CapsuleState();
}

class _AP2CapsuleState extends State<AP2Capsule> {
  // Sample affiliate accounts
  late List<AffiliateAccount> _affiliates;
  late List<CommissionEvent> _commissionHistory;
  int _selectedAffiliateIndex = 0;
  bool _isProcessing = false;
  String? _selectedPaymentMethod = 'hybrid';

  // Tier configuration
  final Map<String, double> _tierMultipliers = {
    'Bronze': 1.0,
    'Silver': 1.25,
    'Gold': 1.5,
    'Platinum': 2.0,
  };

  // Commission rates by capsule
  final Map<String, double> _capsuleCommissionRates = {
    'tradeline_intake': 25.0,
    'funding_lookup': 50.0,
    'government_access': 15.0,
    'snap_reallocation': 20.0,
    'partner_signup': 100.0,
    'tax_automation': 30.0,
  };

  @override
  void initState() {
    super.initState();
    _initializeAffiliates();
    _loadCommissionHistory();
  }

  void _initializeAffiliates() {
    _affiliates = [
      AffiliateAccount(
        affiliateId: 'AFF_001',
        name: 'Maria Rodriguez',
        email: 'maria@community.org',
        phone: '+1-555-0101',
        organization: 'Community Finance Network',
        tier: 'Gold',
        tierMultiplier: 1.5,
        totalEarnings: 12500.00,
        pendingPayout: 2850.00,
        joinDate: DateTime(2024, 6, 15),
        isActive: true,
        stripeAccountId: 'acct_maria_stripe',
        stablecoinWalletAddress: '0xMaria1234...8901',
      ),
      AffiliateAccount(
        affiliateId: 'AFF_002',
        name: 'James Chen',
        email: 'james@fintech.io',
        phone: '+1-555-0102',
        organization: 'FinTech Accelerator',
        tier: 'Platinum',
        tierMultiplier: 2.0,
        totalEarnings: 28750.00,
        pendingPayout: 5600.00,
        joinDate: DateTime(2024, 3, 20),
        isActive: true,
        stripeAccountId: 'acct_james_stripe',
        stablecoinWalletAddress: '0xJames5678...2345',
      ),
      AffiliateAccount(
        affiliateId: 'AFF_003',
        name: 'Aisha Thompson',
        email: 'aisha@nonprofit.org',
        phone: '+1-555-0103',
        organization: 'Credit Justice Initiative',
        tier: 'Silver',
        tierMultiplier: 1.25,
        totalEarnings: 4200.00,
        pendingPayout: 875.00,
        joinDate: DateTime(2024, 9, 10),
        isActive: true,
        stripeAccountId: 'acct_aisha_stripe',
        stablecoinWalletAddress: '0xAisha9012...6789',
      ),
    ];
  }

  void _loadCommissionHistory() {
    _commissionHistory = [
      CommissionEvent(
        eventId: 'EVT_001',
        affiliateId: 'AFF_001',
        capsuleTriggered: 'tradeline_intake',
        userAction: 'tradeline_added',
        baseAmount: 25.0,
        tierBonus: 12.5,
        totalCommission: 37.5,
        stripeAmount: 37.5,
        paymentMethod: 'stripe',
        status: 'completed',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        xmcpOrchestrationId: 'XMCP_tradeline_001',
      ),
      CommissionEvent(
        eventId: 'EVT_002',
        affiliateId: 'AFF_002',
        capsuleTriggered: 'partner_signup',
        userAction: 'new_partner_onboarded',
        baseAmount: 100.0,
        tierBonus: 100.0,
        totalCommission: 200.0,
        stablecoinAmount: '200.00 USDC',
        paymentMethod: 'stablecoin',
        status: 'processing',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        xmcpOrchestrationId: 'XMCP_partner_signup_001',
      ),
    ];
  }

  double _calculateCommission(String capsule, String tier) {
    final baseRate = _capsuleCommissionRates[capsule] ?? 0.0;
    final tierMult = _tierMultipliers[tier] ?? 1.0;
    return baseRate * tierMult;
  }

  Future<void> _triggerCommissionEvent(
      String capsuleName, String action) async {
    if (_selectedAffiliateIndex >= _affiliates.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No affiliate selected')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final affiliate = _affiliates[_selectedAffiliateIndex];
      final commissionAmount =
          _calculateCommission(capsuleName, affiliate.tier);
      final eventId = 'EVT_${DateTime.now().millisecondsSinceEpoch}';

      // Simulate XMCP agent orchestration call
      await _orchestrateXMCPAgent(eventId, affiliate, capsuleName);
      if (!mounted) return;

      // Create commission event
      final event = CommissionEvent(
        eventId: eventId,
        affiliateId: affiliate.affiliateId,
        capsuleTriggered: capsuleName,
        userAction: action,
        baseAmount: commissionAmount / (affiliate.tierMultiplier),
        tierBonus:
            commissionAmount - (commissionAmount / affiliate.tierMultiplier),
        totalCommission: commissionAmount,
        stripeAmount: _selectedPaymentMethod == 'stripe' ||
                _selectedPaymentMethod == 'hybrid'
            ? commissionAmount * 0.98 // 2% Stripe fee
            : null,
        stablecoinAmount: _selectedPaymentMethod == 'stablecoin' ||
                _selectedPaymentMethod == 'hybrid'
            ? '${(commissionAmount * 0.5).toStringAsFixed(2)} USDC'
            : null,
        paymentMethod: _selectedPaymentMethod ?? 'hybrid',
        status: 'pending',
        createdAt: DateTime.now(),
        xmcpOrchestrationId: eventId,
      );

      setState(() {
        _commissionHistory.insert(0, event);
        _affiliates[_selectedAffiliateIndex] = AffiliateAccount(
          affiliateId: affiliate.affiliateId,
          name: affiliate.name,
          email: affiliate.email,
          phone: affiliate.phone,
          organization: affiliate.organization,
          tier: affiliate.tier,
          tierMultiplier: affiliate.tierMultiplier,
          totalEarnings: affiliate.totalEarnings + commissionAmount,
          pendingPayout: affiliate.pendingPayout + commissionAmount,
          joinDate: affiliate.joinDate,
          isActive: affiliate.isActive,
          stripeAccountId: affiliate.stripeAccountId,
          stablecoinWalletAddress: affiliate.stablecoinWalletAddress,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Commission triggered: \$${commissionAmount.toStringAsFixed(2)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _orchestrateXMCPAgent(
    String eventId,
    AffiliateAccount affiliate,
    String capsule,
  ) async {
    // Simulate XMCP agent orchestration for multi-step payout process
    await Future.delayed(const Duration(seconds: 1));

    // In production: Call MCP server with:
    // - affiliateId, eventId, capsuleName
    // - Payment method (Stripe/stablecoin)
    // - Retry logic for failed payouts
    // - Webhook callbacks for payment confirmation
  }

  Future<void> _processPayout(CommissionEvent event) async {
    setState(() => _isProcessing = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      final updatedEvents = _commissionHistory
          .map((e) => e.eventId == event.eventId
              ? CommissionEvent(
                  eventId: e.eventId,
                  affiliateId: e.affiliateId,
                  capsuleTriggered: e.capsuleTriggered,
                  userAction: e.userAction,
                  baseAmount: e.baseAmount,
                  tierBonus: e.tierBonus,
                  totalCommission: e.totalCommission,
                  stripeAmount: e.stripeAmount,
                  stablecoinAmount: e.stablecoinAmount,
                  paymentMethod: e.paymentMethod,
                  status: 'completed',
                  createdAt: e.createdAt,
                  xmcpOrchestrationId: e.xmcpOrchestrationId,
                )
              : e)
          .toList();

      setState(() => _commissionHistory = updatedEvents);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Payout processed successfully'),
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

  String _exportCommissionJSON() {
    return jsonEncode({
      'affiliateAccounts': _affiliates.map((a) => a.toJson()).toList(),
      'commissionHistory': _commissionHistory.map((c) => c.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AP2: Affiliate Payout & Partner Tiers'),
        backgroundColor: Colors.deepPurple[700],
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
                    colors: [Colors.deepPurple[700]!, Colors.deepPurple[300]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Multi-Tier Affiliate Ecosystem',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '💰 Stripe + Stablecoin • 🧬 XMCP Orchestration • 📊 Real-time Tracking',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Affiliate Selection
              const Text(
                'Select Affiliate',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<int>(
                  value: _selectedAffiliateIndex,
                  isExpanded: true,
                  underline: const SizedBox(),
                  onChanged: (idx) =>
                      setState(() => _selectedAffiliateIndex = idx ?? 0),
                  items: _affiliates
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
                                          entry.value.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          entry.value.organization,
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
                                      color: Colors.deepPurple[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      entry.value.tier,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple[700],
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

              // Affiliate Details
              if (_selectedAffiliateIndex < _affiliates.length)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepPurple[200]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple[50],
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
                                    _affiliates[_selectedAffiliateIndex].name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _affiliates[_selectedAffiliateIndex]
                                        .organization,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
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
                                  color: Colors.deepPurple[700],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _affiliates[_selectedAffiliateIndex].tier,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Total Earnings',
                                  '\$${_affiliates[_selectedAffiliateIndex].totalEarnings.toStringAsFixed(2)}',
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Pending Payout',
                                  '\$${_affiliates[_selectedAffiliateIndex].pendingPayout.toStringAsFixed(2)}',
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Multiplier',
                                  '${_affiliates[_selectedAffiliateIndex].tierMultiplier}x',
                                  Colors.purple,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Member Since',
                                  DateFormat('MMM yyyy').format(
                                      _affiliates[_selectedAffiliateIndex]
                                          .joinDate),
                                  Colors.blue,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Payment Methods',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (_affiliates[_selectedAffiliateIndex]
                                        .stripeAccountId !=
                                    null)
                                  Row(
                                    children: [
                                      Icon(Icons.credit_card,
                                          size: 14,
                                          color: Colors.deepPurple[700]),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Stripe: ${_affiliates[_selectedAffiliateIndex].stripeAccountId}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_affiliates[_selectedAffiliateIndex]
                                        .stablecoinWalletAddress !=
                                    null)
                                  Column(
                                    children: [
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.account_balance_wallet,
                                              size: 14,
                                              color: Colors.amber[700]),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Stablecoin: ${_affiliates[_selectedAffiliateIndex].stablecoinWalletAddress}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              // Trigger Commission
              const Text(
                'Trigger Commission Event (Capsule Integration)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _capsuleCommissionRates.entries.map((entry) {
                  return ElevatedButton(
                    onPressed: _isProcessing
                        ? null
                        : () => _triggerCommissionEvent(
                              entry.key,
                              '${entry.key}_triggered',
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[700],
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      '${entry.key}\n\$${entry.value.toStringAsFixed(0)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Payment Method Selection
              const Text(
                'Payout Method',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'stripe',
                    label: Text('Stripe'),
                    icon: Icon(Icons.credit_card),
                  ),
                  ButtonSegment(
                    value: 'stablecoin',
                    label: Text('Stablecoin'),
                    icon: Icon(Icons.account_balance_wallet),
                  ),
                  ButtonSegment(
                    value: 'hybrid',
                    label: Text('Hybrid'),
                    icon: Icon(Icons.merge),
                  ),
                ],
                selected: {_selectedPaymentMethod ?? 'hybrid'},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _selectedPaymentMethod = newSelection.first);
                },
              ),
              const SizedBox(height: 24),

              // Commission History
              const Text(
                'Commission History',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (_commissionHistory.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'No commissions yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ..._commissionHistory.map((event) {
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.capsuleTriggered
                                        .replaceAll('_', ' ')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    event.userAction,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(event.status)
                                      .withAlpha(51),
                                  border: Border.all(
                                    color: _getStatusColor(event.status),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  event.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(event.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${event.totalCommission.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.green[700],
                                ),
                              ),
                              Text(
                                DateFormat('MMM dd, yyyy')
                                    .format(event.createdAt),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          if (event.stripeAmount != null ||
                              event.stablecoinAmount != null)
                            Column(
                              children: [
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    if (event.stripeAmount != null)
                                      Chip(
                                        avatar: const Icon(Icons.credit_card,
                                            size: 14),
                                        label: Text(
                                          '\$${event.stripeAmount!.toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        backgroundColor: Colors.blue[100],
                                      ),
                                    if (event.stablecoinAmount != null)
                                      Chip(
                                        avatar: const Icon(
                                            Icons.account_balance_wallet,
                                            size: 14),
                                        label: Text(
                                          event.stablecoinAmount!,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        backgroundColor: Colors.amber[100],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          if (event.status == 'pending')
                            Column(
                              children: [
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _processPayout(event),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                    ),
                                    child: const Text('Process Payout'),
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

              // Export Data
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _exportCommissionJSON();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data exported to JSON')),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Export Commission Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // XMCP Integration Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings, color: Colors.purple[700]),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'XMCP Agent Orchestration Ready',
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
                      '🧬 Agent routing for Stripe fallback\n'
                      '💰 Stablecoin disbursement automation\n'
                      '📊 Multi-step payout validation\n'
                      '🔄 Retry logic on failed transactions\n'
                      '📡 Webhook callbacks for confirmations',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        border: Border.all(color: color.withAlpha(77)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
