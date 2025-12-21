import 'dart:ui';

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
    const Color primaryIndigo = Color(0xFF1B1F4A);
    const Color electricTeal = Color(0xFF00E8D7);
    const Color neonMagenta = Color(0xFFCB3CFF);
    const Color solarAmber = Color(0xFFFFB65C);
    const Color midnightSurface = Color(0xFF0E162A);
    const Color cloudSurface = Color(0xFFF2F4FB);

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryIndigo,
      secondary: electricTeal,
      surface: cloudSurface,
      error: const Color(0xFFFE5E7A),
      onPrimary: Colors.white,
      onSecondary: const Color(0xFF04121D),
      onSurface: const Color(0xFF0F172A),
      onError: Colors.white,
    );

    return MaterialApp(
      title: 'WealthBridge',
      theme: ThemeData(
        primaryColor: primaryIndigo,
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: midnightSurface,
        cardTheme: CardTheme(
          color: Colors.white.withOpacity(0.9),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          shadowColor: neonMagenta.withOpacity(0.12),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: colorScheme.onPrimary,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.4,
          ),
          shadowColor: electricTeal.withOpacity(0.2),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: electricTeal.withOpacity(0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: electricTeal.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: electricTeal, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.error, width: 2),
          ),
          prefixIconColor: electricTeal,
          labelStyle: TextStyle(
            color: electricTeal,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          floatingLabelStyle: TextStyle(
            color: neonMagenta,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: neonMagenta.withOpacity(0.35),
              ),
            ],
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: electricTeal,
            foregroundColor: colorScheme.onSecondary,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 6,
            shadowColor: neonMagenta.withOpacity(0.35),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: electricTeal,
            side: BorderSide(color: electricTeal),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white.withOpacity(0.06),
          selectedColor: electricTeal.withOpacity(0.22),
          shadowColor: neonMagenta.withOpacity(0.2),
          labelStyle: const TextStyle(color: Colors.white),
          shape: StadiumBorder(
            side: BorderSide(color: electricTeal.withOpacity(0.6)),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black.withOpacity(0.4),
          selectedItemColor: electricTeal,
          unselectedItemColor: Colors.white70,
          elevation: 12,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
        ),
        dialogBackgroundColor: cloudSurface,
        shadowColor: neonMagenta.withOpacity(0.25),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0B1224),
            Color(0xFF121D3F),
            Color(0xFF0B1E35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  color: Colors.white.withOpacity(0.02),
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: _navigationItems[_selectedIndex]['widget'] as Widget,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: _navigationItems.map((item) {
                return BottomNavigationBarItem(
                  icon: Icon(item['icon'] as IconData),
                  label: item['label'] as String,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
