import 'package:flutter/material.dart';

class CapsuleBankDashboard extends StatefulWidget {
  const CapsuleBankDashboard({super.key});

  @override
  State<CapsuleBankDashboard> createState() => _CapsuleBankDashboardState();
}

class _CapsuleBankDashboardState extends State<CapsuleBankDashboard> {
  final List<Map<String, dynamic>> capsules = [
    {
      'name': 'Tradeline Intake',
      'status': 'Active',
      'earnings': '\$2,450',
      'date': 'Jan 15, 2025',
      'icon': Icons.credit_card,
    },
    {
      'name': 'Funding Lookup',
      'status': 'Pending',
      'earnings': '\$1,200',
      'date': 'Jan 10, 2025',
      'icon': Icons.account_balance,
    },
    {
      'name': 'Stablecoin Factory',
      'status': 'Active',
      'earnings': '\$3,875',
      'date': 'Jan 08, 2025',
      'icon': Icons.currency_bitcoin,
    },
    {
      'name': 'Outreach Tracker',
      'status': 'Needs Review',
      'earnings': '\$890',
      'date': 'Jan 05, 2025',
      'icon': Icons.people,
    },
    {
      'name': 'Government Access',
      'status': 'Active',
      'earnings': '\$5,200',
      'date': 'Jan 01, 2025',
      'icon': Icons.business,
    },
    {
      'name': 'SNAP Reallocation',
      'status': 'Active',
      'earnings': '\$1,650',
      'date': 'Dec 28, 2024',
      'icon': Icons.fastfood,
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Needs Review':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capsule Bank Dashboard'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _summaryCard('Total Earnings', '\$15,265', Colors.blue),
                    const SizedBox(width: 12),
                    _summaryCard('Stripe Balance', '\$8,420', Colors.purple),
                    const SizedBox(width: 12),
                    _summaryCard('Active Capsules', '5', Colors.green),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Capsules Grid
              Text(
                'Your Capsules',
                style: Theme.of(context).textTheme.headlineSmall,
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
                  return _capsuleCard(capsule);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        border: Border.all(color: color.withAlpha(77)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _capsuleCard(Map<String, dynamic> capsule) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  capsule['icon'] as IconData,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    capsule['name'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      capsule['status'] as String,
                    ).withAlpha(51),
                    border: Border.all(
                      color: _getStatusColor(capsule['status'] as String),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    capsule['status'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(capsule['status'] as String),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Earnings: ${capsule['earnings']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Updated: ${capsule['date']}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('View', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Edit', style: TextStyle(fontSize: 12)),
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
