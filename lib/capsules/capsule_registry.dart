import 'package:flutter/material.dart';
import 'package:wealthbridge/widgets/admin_dashboard_capsule.dart';
import 'package:wealthbridge/widgets/affiliate_onboarding_capsule.dart';
import 'package:wealthbridge/widgets/ap2_capsule.dart';
import 'package:wealthbridge/widgets/bridge_builder_capsule.dart';
import 'package:wealthbridge/widgets/capsule_bank_dashboard_updated.dart';
import 'package:wealthbridge/widgets/capsule_quest_uplift_city.dart';
import 'package:wealthbridge/widgets/company_setup_capsule.dart';
import 'package:wealthbridge/widgets/ecosystem_map_capsule.dart';
import 'package:wealthbridge/widgets/factiiv_capsule.dart';
import 'package:wealthbridge/widgets/funding_lookup_capsule.dart';
import 'package:wealthbridge/widgets/government_access_capsule.dart';
import 'package:wealthbridge/widgets/influwealth_portal_capsule.dart';
import 'package:wealthbridge/widgets/marketing_video_script_capsule.dart';
import 'package:wealthbridge/widgets/mindmax_simulation_capsule.dart';
import 'package:wealthbridge/widgets/northwest_agent_capsule.dart';
import 'package:wealthbridge/widgets/outreach_tracker_capsule.dart';
import 'package:wealthbridge/widgets/partner_signup_capsule.dart';
import 'package:wealthbridge/widgets/snap_reallocation_capsule.dart';
import 'package:wealthbridge/widgets/stablecoin_factory_capsule.dart';
import 'package:wealthbridge/widgets/synapz_feed_capsule.dart';
import 'package:wealthbridge/widgets/tax_automation_capsule.dart';
import 'package:wealthbridge/widgets/tradeline_intake_capsule.dart';
// Import all capsule widgets
import 'package:wealthbridge/widgets/truth_algorithm_capsule.dart';
import 'package:wealthbridge/widgets/multi_tenant_capsule.dart';
import 'package:wealthbridge/widgets/quantum_ai_simulation_capsule.dart';
import 'package:wealthbridge/widgets/infrastructure_capsule.dart';
import 'package:wealthbridge/widgets/rlusd_routing_capsule.dart';
import 'package:wealthbridge/widgets/data_commons_capsule.dart';

/// Metadata class for capsule registration
/// Stores essential information for dynamic routing and UI display
class CapsuleMetadata {
  final String id;
  final String name;
  final String route;
  final String description;
  final IconData icon;
  final Color color;
  final String category;
  final Widget widget;
  final bool enabled;
  final String? version;

  CapsuleMetadata({
    required this.id,
    required this.name,
    required this.route,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.widget,
    this.enabled = true,
    this.version,
  });
}

/// Central Capsule Registry
/// Manages all available capsules in WealthBridge platform
class CapsuleRegistry {
  static final CapsuleRegistry _instance = CapsuleRegistry._internal();

  factory CapsuleRegistry() {
    return _instance;
  }

  CapsuleRegistry._internal();

  /// Complete list of all registered capsules
  static final List<CapsuleMetadata> capsules = [
    // 🧠 Intelligence & Analysis
    CapsuleMetadata(
      id: 'truth-algorithm',
      name: 'Truth Algorithm',
      route: '/truthAlgorithm',
      description:
          'Quantum logic engine to detect propaganda, bias, and manipulation. Simulate alternate outcomes with teachable insights.',
      icon: Icons.psychology,
      color: Colors.deepPurple,
      category: 'Intelligence',
      widget: const TruthAlgorithmCapsule(),
      version: '2.0',
    ),

    // 💳 Credit & Financial Access
    CapsuleMetadata(
      id: 'tradeline-intake',
      name: 'Tradeline Intake',
      route: '/tradelineIntake',
      description:
          'Secure credit profile intake with SSN masking, tradeline verification, and credit report analysis.',
      icon: Icons.credit_card,
      color: Colors.blue,
      category: 'Credit',
      widget: const TradelineIntakeCapsule(),
      version: '1.5',
    ),

    // 🏢 Partnerships & Onboarding
    CapsuleMetadata(
      id: 'partner-signup',
      name: 'Partner Signup',
      route: '/partnerSignup',
      description:
          'Institutional partner onboarding with validation, KYC integration, and real-time status tracking.',
      icon: Icons.business,
      color: Colors.indigo,
      category: 'Partnerships',
      widget: const PartnerSignupCapsule(),
      version: '1.0',
    ),

    CapsuleMetadata(
      id: 'affiliate-onboarding',
      name: 'Affiliate Onboarding',
      route: '/affiliateOnboarding',
      description:
          'Affiliate network integration with Stripe/Plaid, earnings tracking, and referral management.',
      icon: Icons.people_outline,
      color: Colors.teal,
      category: 'Partnerships',
      widget: const AffiliateOnboardingCapsule(),
      version: '1.2',
    ),

    CapsuleMetadata(
      id: 'ap2-capsule',
      name: 'AP2: Affiliate Payout',
      route: '/ap2Capsule',
      description:
          'Multi-tier affiliate ecosystem with Stripe/stablecoin payouts, XMCP orchestration, and capsule-triggered commissions.',
      icon: Icons.monetization_on,
      color: Colors.deepPurple,
      category: 'Partnerships',
      widget: const AP2Capsule(),
      version: '1.0',
    ),

    // 💰 Funding & Resources
    CapsuleMetadata(
      id: 'funding-lookup',
      name: 'Funding Lookup',
      route: '/fundingLookup',
      description:
          'AI-powered funding opportunity matcher connecting users to grants, loans, and investment vehicles.',
      icon: Icons.trending_up,
      color: Colors.green,
      category: 'Funding',
      widget: const FundingLookupCapsule(),
      version: '1.8',
    ),

    CapsuleMetadata(
      id: 'snap-reallocation',
      name: 'SNAP Reallocation',
      route: '/snapReallocation',
      description:
          'AI-powered optimization tool for SNAP benefits allocation and food security strategy.',
      icon: Icons.restaurant,
      color: Colors.orange,
      category: 'Benefits',
      widget: const SNAPReallocationCapsule(),
      version: '1.3',
    ),

    // 📋 Tax & Compliance
    CapsuleMetadata(
      id: 'tax-automation',
      name: 'Tax Automation',
      route: '/taxAutomation',
      description:
          'Secure tax filing, amendment generation, and refund tracking using VaultGemma and Sheets.',
      icon: Icons.receipt_long,
      color: Colors.amber,
      category: 'Tax',
      widget: const TaxAutomationCapsule(),
      version: '1.0',
    ),

    CapsuleMetadata(
      id: 'factiiv-capsule',
      name: 'FACTIIV: Blockchain Credit',
      route: '/factiivCapsule',
      description:
          'Decentralized B2B credit reporting with blockchain tradelines, VaultGemma encryption, and AP2 payout integration.',
      icon: Icons.link,
      color: Colors.teal,
      category: 'Credit',
      widget: const FACTIIVCapsule(),
      version: '1.0',
    ),

    // 🏛️ Government & Compliance
    CapsuleMetadata(
      id: 'government-access',
      name: 'Government Access',
      route: '/governmentAccess',
      description:
          'SAM.gov registration, EFT setup, and federal compliance flow for institutional access.',
      icon: Icons.account_balance,
      color: Colors.red,
      category: 'Government',
      widget: const GovernmentAccessCapsule(),
      version: '1.1',
    ),

    // 🚀 Blockchain & Innovation
    CapsuleMetadata(
      id: 'stablecoin-factory',
      name: 'Stablecoin Factory',
      route: '/stablecoinFactory',
      description:
          'Token creation interface for deploying custom stablecoins and community currencies.',
      icon: Icons.toll,
      color: Colors.yellow[700]!,
      category: 'Blockchain',
      widget: const StablecoinFactoryCapsule(),
      version: '0.9',
    ),

    // 📞 Engagement & Outreach
    CapsuleMetadata(
      id: 'outreach-tracker',
      name: 'Outreach Tracker',
      route: '/outreachTracker',
      description:
          'Contact management and campaign orchestration for community engagement and follow-up automation.',
      icon: Icons.contact_mail,
      color: Colors.cyan,
      category: 'Outreach',
      widget: const OutreachTrackerCapsule(),
      version: '1.4',
    ),

    // 📊 Dashboard & Overview
    CapsuleMetadata(
      id: 'capsule-dashboard',
      name: 'Capsule Dashboard',
      route: '/dashboard',
      description:
          'Central hub displaying earnings, capsule status, and navigation across all WealthBridge modules.',
      icon: Icons.dashboard,
      color: Colors.purple,
      category: 'Core',
      widget: const CapsuleBankDashboard(),
      version: '2.1',
    ),

    // 🌐 NorthWest Agent Capsule (NEW)
    CapsuleMetadata(
      id: 'northwest-agent',
      name: 'NorthWest Agent',
      route: '/northwestAgent',
      description:
          'Partner loop integration, compliance optics, sovereign onboarding with EIN/LLC tracking and registry sync.',
      icon: Icons.public,
      color: const Color(0xFF1B5E20),
      category: 'Partnerships',
      widget: const NorthWestAgentCapsule(),
      version: '1.0',
    ),

    // 🏢 Company Setup Capsule (NEW)
    CapsuleMetadata(
      id: 'company-setup',
      name: 'Company Setup',
      route: '/companySetup',
      description:
          'Entity registration via LegalZoom, ZenBusiness, Incfile with EIN registration and VaultGemma document sync.',
      icon: Icons.business,
      color: const Color(0xFF1565C0),
      category: 'Setup',
      widget: const CompanySetupCapsule(),
      version: '1.0',
    ),

    // 🧠 MindMax Simulation Capsule (NEW)
    CapsuleMetadata(
      id: 'mindmax-simulation',
      name: 'MindMax Simulation',
      route: '/mindmaxSimulation',
      description:
          'Predictive modeling for funding success, tax optimization, and outreach impact with deduction optimizer.',
      icon: Icons.trending_up,
      color: const Color(0xFF7E57C2),
      category: 'Simulation',
      widget: const MindMaxSimulationCapsule(),
      version: '1.0',
    ),

    // 🌉 BridgeBuilder Capsule (NEW)
    CapsuleMetadata(
      id: 'bridge-builder',
      name: 'BridgeBuilder',
      route: '/bridgeBuilder',
      description:
          'Nonprofit outreach automation, affiliate onboarding, and phone agent integration with Twilio.',
      icon: Icons.call,
      color: const Color(0xFFD32F2F),
      category: 'Outreach',
      widget: const BridgeBuilderCapsule(),
      version: '1.0',
    ),

    // 📱 SynapzFeed Capsule (NEW)
    CapsuleMetadata(
      id: 'synapz-feed',
      name: 'SynapzFeed',
      route: '/synapzFeed',
      description:
          'Social media feed for capsule updates, affiliate wins, and community engagement with AI summaries.',
      icon: Icons.feed,
      color: const Color(0xFFE91E63),
      category: 'Community',
      widget: const SynapzFeedCapsule(),
      version: '1.0',
    ),

    // 🎮 CapsuleQuest: UpliftCity (NEW)
    CapsuleMetadata(
      id: 'capsule-quest',
      name: 'CapsuleQuest: UpliftCity',
      route: '/upliftCity',
      description:
          'Roblox mentorship platform for youth onboarding with Team Create logic and mobile-only access.',
      icon: Icons.games,
      color: const Color(0xFF8B4513),
      category: 'Youth',
      widget: const CapsuleQuestUpliftCity(),
      version: '1.0',
    ),

    // ⚙️ Admin Dashboard Capsule (NEW)
    CapsuleMetadata(
      id: 'admin-dashboard',
      name: 'Admin Dashboard',
      route: '/adminDashboard',
      description:
          'Internal systems dashboard with capsule metrics, audit logs, blockchain transactions, and payment processing.',
      icon: Icons.admin_panel_settings,
      color: const Color(0xFF0D47A1),
      category: 'Admin',
      widget: const AdminDashboardCapsule(),
      version: '1.0',
    ),

    // 🌍 InfluWealth Portal Capsule (NEW)
    CapsuleMetadata(
      id: 'influwealth-portal',
      name: 'InfluWealth Portal',
      route: '/influWealth',
      description:
          'Central education and resource hub with onboarding guides, tutorials, and links to IRS, DOL, SAM.gov, Google MCP.',
      icon: Icons.school,
      color: const Color(0xFF00695C),
      category: 'Education',
      widget: const InfluWealthPortalCapsule(),
      version: '1.0',
    ),

    // 🎥 Marketing Video Script Capsule (NEW)
    CapsuleMetadata(
      id: 'marketing-video-script',
      name: 'Marketing Video Script',
      route: '/marketingVideo',
      description:
          '5-minute onboarding video script showing account creation, capsule tour, admin dashboard, and integration hub.',
      icon: Icons.videocam,
      color: const Color(0xFFFF6D00),
      category: 'Marketing',
      widget: const MarketingVideoScriptCapsule(),
      version: '1.0',
    ),

    // 🗺️ Ecosystem Map Capsule (NEW)
    CapsuleMetadata(
      id: 'ecosystem-map',
      name: 'Ecosystem Map',
      route: '/ecosystemMap',
      description:
          'Full WealthBridge architecture documentation with capsule interconnections, agent flows, and sovereign mesh logic.',
      icon: Icons.map,
      color: const Color(0xFF6A1B9A),
      category: 'Documentation',
      widget: const EcosystemMapCapsule(),
      version: '1.0',
    ),

    // 📊 Analytics
    CapsuleMetadata(
      id: 'analytics',
      name: 'Analytics Capsule',
      route: '/analytics',
      description: 'Provides insights into capsule usage and affiliate performance.',
      icon: Icons.analytics,
      color: Colors.blueGrey,
      category: 'Analytics',
      widget: const AnalyticsCapsule(),
    ),

    // 🏆 Leaderboard
    CapsuleMetadata(
      id: 'leaderboard',
      name: 'Leaderboard Capsule',
      route: '/leaderboard',
      description: 'Displays affiliate performance and rankings.',
      icon: Icons.leaderboard,
      color: Colors.deepOrange,
      category: 'Community',
      widget: const LeaderboardCapsule(),
    ),

    // 📱 Native App
    CapsuleMetadata(
      id: 'native-app',
      name: 'Native App Capsule',
      route: '/nativeApp',
      description: 'Scaffold for native iOS/Android application builds.',
      icon: Icons.smartphone,
      color: Colors.deepPurple,
      category: 'Development',
      widget: const NativeAppCapsule(),
    ),

    // 🔗 Blockchain
    CapsuleMetadata(
      id: 'polygon-smart-contract',
      name: 'Polygon Smart Contract',
      route: '/polygonSmartContract',
      description: 'Manages Polygon smart contract interactions and credit events.',
      icon: Icons.security,
      color: Colors.indigo,
      category: 'Blockchain',
      widget: const PolygonSmartContractCapsule(),
    ),

    // 🔔 Notifications
    CapsuleMetadata(
      id: 'realtime-notification',
      name: 'Real-Time Notification',
      route: '/realtimeNotification',
      description: 'Manages real-time push, SMS, and voice notifications.',
      icon: Icons.notifications,
      color: Colors.green,
      category: 'Notifications',
      widget: const RealTimeNotificationCapsule(),
    ),

    // 💳 Finance
    CapsuleMetadata(
      id: 'stripe-integration',
      name: 'Stripe Integration',
      route: '/stripeIntegration',
      description: 'Handles Stripe payment processing and payouts.',
      icon: Icons.credit_card,
      color: Colors.blue,
      category: 'Finance',
      widget: const StripeIntegrationCapsule(),
    ),

    // 🔒 Security
    CapsuleMetadata(
      id: 'vault-gemma-encryption',
      name: 'VaultGemma Encryption',
      route: '/vaultGemmaEncryption',
      description: 'Manages secure data encryption using VaultGemma.',
      icon: Icons.shield,
      color: Colors.indigo,
      category: 'Security',
      widget: const VaultGemmaEncryptionCapsule(),
    ),

    // 🏢 Enterprise Logic
    CapsuleMetadata(
      id: 'multi-tenant',
      name: 'Multi-Tenant Capsule',
      route: '/multiTenant',
      description:
          'Role-based access, team segmentation, and capsule isolation for enterprise clients.',
      icon: Icons.people,
      color: Colors.indigo,
      category: 'Enterprise',
      widget: const MultiTenantCapsule(),
      version: '1.0',
    ),

    // 🧠 Quantum AI Simulation
    CapsuleMetadata(
      id: 'quantum-ai-simulation',
      name: 'Quantum AI Simulation',
      route: '/quantumAISimulation',
      description:
          'Quantum-inspired financial modeling and credit prediction with tensor network logic.',
      icon: Icons.memory,
      color: Colors.blueGrey,
      category: 'Simulation',
      widget: const QuantumAISimulationCapsule(),
      version: '1.0',
    ),

    // 🧱 Infrastructure
    CapsuleMetadata(
      id: 'infrastructure',
      name: 'Infrastructure Capsule',
      route: '/infrastructure',
      description:
          'Overview of the WealthBridge infrastructure, including frontend, backend, database, and more.',
      icon: Icons.layers,
      color: Colors.grey,
      category: 'Infrastructure',
      widget: const InfrastructureCapsule(),
      version: '1.0',
    ),

    // Finance
    CapsuleMetadata(
      id: 'rlusd-routing-capsule',
      name: 'RLUSD Routing Capsule',
      route: '/rlusd',
      description:
          'Accepts RLUSD deposits, routes to credit, payout, and funding capsules, syncs with VaultGemma, integrates with XMCP orchestration.',
      icon: Icons.currency_exchange,
      color: Colors.teal,
      category: 'Finance',
      widget: const RLUSDRoutingCapsule(),
      version: '1.0',
    ),

    //Intelligence
    CapsuleMetadata(
      id: 'data-commons-capsule',
      name: 'Data Commons Capsule',
      route: '/dataCommons',
      description:
          'Imports and caches public datasets (IRS, census, World Bank, IMF), runs tensor simulations, syncs with MindMaxSimulationCapsule, supports query + export.',
      icon: Icons.dataset,
      color: Colors.green,
      category: 'Intelligence',
      widget: const DataCommonsCapsule(),
      version: '1.0',
    ),
  ];

  /// Get all capsules
  List<CapsuleMetadata> getAllCapsules() => capsules;

  /// Get enabled capsules only
  List<CapsuleMetadata> getEnabledCapsules() =>
      capsules.where((c) => c.enabled).toList();

  /// Get capsule by ID
  CapsuleMetadata? getCapsuleById(String id) {
    try {
      return capsules.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get capsule by route
  CapsuleMetadata? getCapsuleByRoute(String route) {
    try {
      return capsules.firstWhere((c) => c.route == route);
    } catch (e) {
      return null;
    }
  }

  /// Get capsules by category
  List<CapsuleMetadata> getCapsulesByCategory(String category) =>
      capsules.where((c) => c.category == category && c.enabled).toList();

  /// Get all unique categories
  List<String> getCategories() =>
      capsules.map((c) => c.category).toSet().toList().cast<String>();

  /// Search capsules by name or description
  List<CapsuleMetadata> searchCapsules(String query) {
    final lowerQuery = query.toLowerCase();
    return capsules.where((c) {
      return (c.name.toLowerCase().contains(lowerQuery) ||
              c.description.toLowerCase().contains(lowerQuery)) &&
          c.enabled;
    }).toList();
  }

  /// Get capsule widget by ID
  Widget? getWidget(String id) => getCapsuleById(id)?.widget;

  /// Get route map for Navigator
  Map<String, WidgetBuilder> getRouteMap() {
    final routeMap = <String, WidgetBuilder>{};
    for (final capsule in getEnabledCapsules()) {
      routeMap[capsule.route] = (_) => capsule.widget;
    }
    return routeMap;
  }

  /// Get total count of capsules
  int getTotalCount() => capsules.length;

  /// Get enabled count
  int getEnabledCount() => getEnabledCapsules().length;
}

/// Utility extensions for easier access
extension CapsuleRegistryExt on BuildContext {
  CapsuleRegistry get capsuleRegistry => CapsuleRegistry();

  CapsuleMetadata? getCapsuleById(String id) =>
      CapsuleRegistry().getCapsuleById(id);

  List<CapsuleMetadata> getCapsulesByCategory(String category) =>
      CapsuleRegistry().getCapsulesByCategory(category);
}
