import 'package:flutter/material.dart';

import 'package:wealthbridge/browser/browser_shell.dart';
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
      'label': 'Home',
      'icon': Icons.language,
      'widget': const BrowserShell(),
    },
    {
      'label': 'Dashboard',
      'icon': Icons.dashboard,
      'widget': const CapsuleBankDashboard(),
    },
    {
      'label': 'Funding',
      'icon': Icons.account_balance,
      'widget': const FundingLookupCapsule(),
    },
    {
      'label': 'Stablecoin',
      'icon': Icons.currency_bitcoin,
      'widget': const StablecoinFactoryCapsule(),
    },
    {
      'label': 'Outreach',
      'icon': Icons.people,
      'widget': const OutreachTrackerCapsule(),
    },
    {
      'label': 'Government',
      'icon': Icons.business,
      'widget': const GovernmentAccessCapsule(),
    },
    {
      'label': 'SNAP',
      'icon': Icons.fastfood,
      'widget': const SNAPReallocationCapsule(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navigationItems[_selectedIndex]['widget'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
      ),
    );
  }
}
