import 'package:flutter/material.dart';

class CapsuleBankDashboard extends StatefulWidget {
  const CapsuleBankDashboard({super.key});

  @override
  State<CapsuleBankDashboard> createState() => _CapsuleBankDashboardState();
}

class _CapsuleBankDashboardState extends State<CapsuleBankDashboard> {
  final List<Map<String, dynamic>> capsules = [
    {
      'name': 'Funding Lookup',
      'status': 'Active',
      'earnings': '\$2,450',
      'date': 'Jan 15, 2025',
      'icon': Icons.account_balance,
    },
    {
      'name': 'Stablecoin Factory',
      'status': 'Pending',
      'earnings': '\$1,200',
      'date': 'Jan 10, 2025',
      'icon': Icons.currency_bitcoin,
    },
    {
      'name': 'Outreach Tracker',
      'status': 'Active',
      'earnings': '\$3,875',
      'date': 'Jan 08, 2025',
      'icon': Icons.people,
    },
    {
      'name': 'Government Access',
      'status': 'Needs Review',
      'earnings': '\$890',
      'date': 'Jan 05, 2025',
      'icon': Icons.business,
    },
    {
      'name': 'SNAP Reallocation',
      'status': 'Active',
      'earnings': '\$5,200',
      'date': 'Jan 01, 2025',
      'icon': Icons.fastfood,
    },
  ];

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    const Color magenta = Color(0xFFCB3CFF);
    const Color amber = Color(0xFFFFB65C);

    switch (status) {
      case 'Active':
        return colorScheme.secondary;
      case 'Pending':
        return amber;
      case 'Needs Review':
        return magenta;
      default:
        return colorScheme.onSurface.withOpacity(0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.12),
            colorScheme.secondary.withOpacity(0.08),
            const Color(0xFF0C1A33).withOpacity(0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Capsule Bank Dashboard'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.9),
                  const Color(0xFF0F1F40).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        colorScheme.secondary.withOpacity(0.15),
                        Colors.transparent,
                      ],
                      radius: 1,
                      center: Alignment.topRight,
                    ),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _summaryCard(
                            context,
                            'Total Earnings',
                            '\$15,265',
                            colorScheme.primary,
                            colorScheme.secondary,
                          ),
                          const SizedBox(width: 12),
                          _summaryCard(
                            context,
                            'Stripe Balance',
                            '\$8,420',
                            colorScheme.secondary,
                            const Color(0xFFCB3CFF),
                          ),
                          const SizedBox(width: 12),
                          _summaryCard(
                            context,
                            'Active Capsules',
                            '4',
                            const Color(0xFFFFB65C),
                            colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Capsules Grid
                    Text(
                      'Your Capsules',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : 2,
                        childAspectRatio: isMobile ? 1.2 : 1.1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: capsules.length,
                      itemBuilder: (context, index) {
                        final capsule = capsules[index];
                        return _capsuleCard(capsule, colorScheme);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context,
    String title,
    String value,
    Color startColor,
    Color endColor,
  ) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            startColor.withOpacity(0.9),
            endColor.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.24),
        ),
        boxShadow: [
          BoxShadow(
            color: endColor.withOpacity(0.45),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _capsuleCard(Map<String, dynamic> capsule, ColorScheme colorScheme) {
    final statusColor = _getStatusColor(capsule['status'] as String, colorScheme);

    return Card(
      elevation: 6,
      color: Colors.white.withOpacity(0.08),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      shadowColor: colorScheme.secondary.withOpacity(0.25),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.9),
                        colorScheme.secondary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.secondary.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    capsule['icon'] as IconData,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    capsule['name'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    border: Border.all(
                      color: statusColor.withOpacity(0.6),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    capsule['status'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Earnings: ${capsule['earnings']}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
            Text(
              'Updated: ${capsule['date']}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('View', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Activate',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
