import 'package:flutter/material.dart';

import 'package:wealthbridge/widgets/capsule_bank_dashboard_updated.dart';
import 'package:wealthbridge/widgets/funding_lookup_capsule.dart';
import 'package:wealthbridge/widgets/stablecoin_factory_capsule.dart';
import 'package:wealthbridge/widgets/outreach_tracker_capsule.dart';
import 'package:wealthbridge/widgets/government_access_capsule.dart';
import 'package:wealthbridge/widgets/snap_reallocation_capsule.dart';

void main() {
  runApp(const WealthBridgeApp());
}

class WealthBridgeApp extends StatelessWidget {
  const WealthBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WealthBridge',
      theme: ThemeData(
        primaryColor: const Color(0xFF7B1FA2),
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF7B1FA2),
          secondary: Color(0xFFFFD600),
          surface: Color(0xFFEDE7F6),
          error: Color(0xFFD32F2F),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF7B1FA2),
          elevation: 2,
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFEDE7F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFB39DDB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFB39DDB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF7B1FA2), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD32F2F)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF6200EA)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B1FA2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const WealthBridgeHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WealthBridgeHome extends StatefulWidget {
  const WealthBridgeHome({super.key});

  @override
  State<WealthBridgeHome> createState() => _WealthBridgeHomeState();
}

class _WealthBridgeHomeState extends State<WealthBridgeHome> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _navigationItems = [
    {
      'label': 'Dashboard',
      'icon': Icons.dashboard,
      'widget': const CapsuleBankDashboard(),
      'summary':
          'Bank-grade oversight for capsule earnings, velocity, and uptime.',
    },
    {
      'label': 'Funding',
      'icon': Icons.account_balance,
      'widget': const FundingLookupCapsule(),
      'summary':
          'Surface institutional, public-sector, and community capital sources.',
    },
    {
      'label': 'Stablecoin',
      'icon': Icons.currency_bitcoin,
      'widget': const StablecoinFactoryCapsule(),
      'summary':
          'Issue compliant, community-backed assets with auditable flows.',
    },
    {
      'label': 'Outreach',
      'icon': Icons.people,
      'widget': const OutreachTrackerCapsule(),
      'summary':
          'Coordinate trusted partners, volunteers, and outreach campaigns.',
    },
    {
      'label': 'Government',
      'icon': Icons.business,
      'widget': const GovernmentAccessCapsule(),
      'summary':
          'Stay aligned with SAM.gov, EIN, EFT, and procurement guardrails.',
    },
    {
      'label': 'SNAP',
      'icon': Icons.fastfood,
      'widget': const SNAPReallocationCapsule(),
      'summary':
          'Optimize household benefits and community redistribution options.',
    },
  ];

  final List<String> _commandPillars = const [
    'Sovereign browser shell',
    'Modular capsules',
    'Open infrastructure',
    'Compliance-ready rails',
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final Widget activeModule = KeyedSubtree(
      key: ValueKey(_selectedIndex),
      child: _navigationItems[_selectedIndex]['widget'] as Widget,
    );

    if (isWide) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Row(
            children: [
              _buildNavigationRail(),
              Expanded(
                child: Column(
                  children: [
                    _buildMissionHeader(isWide: isWide),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: activeModule,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildMissionHeader(isWide: isWide),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: activeModule,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMissionHeader({required bool isWide}) {
    final activeModule = _navigationItems[_selectedIndex];
    final Color accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isWide ? 24.0 : 16.0,
        16.0,
        isWide ? 24.0 : 16.0,
        12.0,
      ),
      child: Material(
        color: const Color(0xFFF4ECFB),
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, color: accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'WealthBridge Command Deck',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (isWide)
                    Chip(
                      label: const Text('Live'),
                      avatar: Icon(Icons.check_circle, color: accent, size: 18),
                      backgroundColor: accent.withAlpha(30),
                      labelStyle: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                activeModule['summary'] as String,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade800,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _commandPillars
                    .map(
                      (pillar) => Chip(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: accent.withAlpha(70)),
                        ),
                        avatar: Icon(
                          Icons.bolt_outlined,
                          size: 16,
                          color: accent,
                        ),
                        label: Text(
                          pillar,
                          style: TextStyle(
                            color: accent.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  NavigationRail _buildNavigationRail() {
    final bool extended = MediaQuery.of(context).size.width >= 1150;
    final Color accent = Theme.of(context).colorScheme.primary;

    return NavigationRail(
      selectedIndex: _selectedIndex,
      extended: extended,
      onDestinationSelected: _onDestinationSelected,
      selectedIconTheme: IconThemeData(color: accent),
      selectedLabelTextStyle: TextStyle(
        color: accent.withOpacity(0.9),
        fontWeight: FontWeight.w700,
      ),
      destinations: _navigationItems
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item['icon'] as IconData),
              selectedIcon: Icon(
                item['icon'] as IconData,
                color: accent,
              ),
              label: Text(item['label'] as String),
            ),
          )
          .toList(),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Icon(
          Icons.hub_outlined,
          color: accent.withOpacity(0.9),
        ),
      ),
      trailing: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'Command Scope',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: _commandPillars
                  .map(
                    (pillar) => Chip(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      label: Text(
                        pillar,
                        style: TextStyle(
                          color: accent.withOpacity(0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: accent.withAlpha(25),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onDestinationSelected,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF7B1FA2),
      unselectedItemColor: Colors.grey.shade600,
      elevation: 8,
      items: _navigationItems.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item['icon'] as IconData),
          label: item['label'] as String,
        );
      }).toList(),
    );
  }
}
