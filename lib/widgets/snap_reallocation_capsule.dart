import 'package:flutter/material.dart';

class SNAPReallocationCapsule extends StatefulWidget {
  const SNAPReallocationCapsule({super.key});

  @override
  State<SNAPReallocationCapsule> createState() =>
      _SNAPReallocationCapsuleState();
}

class _SNAPReallocationCapsuleState extends State<SNAPReallocationCapsule> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _reallocationResult;

  final TextEditingController _householdController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _snapAmountController = TextEditingController();
  bool _enableHotline = false;
  bool _enableDonation = false;
  bool _isLoading = false; // Declare _isLoading

  @override
  void dispose() {
    _householdController.dispose();
    _zipController.dispose();
    _snapAmountController.dispose();
    super.dispose();
  }

  Future<void> _calculateReallocation() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // Set loading to true
    });

    try {
      // Simulate AI optimization calculation
      await Future.delayed(const Duration(seconds: 3));

      final currentAmount = double.parse(_snapAmountController.text);
      final optimizedAmount = currentAmount * 1.15; // 15% improvement
      final savings = optimizedAmount - currentAmount;

      setState(() {
        _reallocationResult = {
          'currentAmount': currentAmount,
          'optimizedAmount': optimizedAmount,
          'savings': savings,
          'recommendation': 'Reallocate to maximize fresh produce purchases',
        };
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Optimization calculated! You could save \$${savings.toStringAsFixed(2)} monthly.'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Set loading to false
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final colorScheme = Theme.of(context).colorScheme;
    const Color accentMagenta = Color(0xFFCB3CFF);
    const Color accentAmber = Color(0xFFFFB65C);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0C1224),
            Color(0xFF0E1B36),
            Color(0xFF0A1B30),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('SNAP Reallocation'), centerTitle: true),
        body: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        colorScheme.secondary.withOpacity(0.12),
                        Colors.transparent,
                      ],
                      center: Alignment.topRight,
                      radius: 0.9,
                    ),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary.withOpacity(0.7),
                              accentMagenta.withOpacity(0.55),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: accentAmber.withOpacity(0.28),
                              blurRadius: 16,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(17),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Optimize Your SNAP Benefits',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 12,
                                            color: colorScheme.secondary
                                                .withOpacity(0.35),
                                          ),
                                        ],
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'AI-powered analysis to maximize your benefits',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.white70,
                                      ),
                                ),
                                const SizedBox(height: 20),
                                // Household Size
                                TextFormField(
                                  controller: _householdController,
                                  decoration: const InputDecoration(
                                    labelText: 'Household Size',
                                    prefixIcon: Icon(Icons.people),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Enter household size';
                                    }
                                    if (int.tryParse(value!) == null) {
                                      return 'Enter a valid number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                // ZIP Code
                                TextFormField(
                                  controller: _zipController,
                                  decoration: const InputDecoration(
                                    labelText: 'ZIP Code',
                                    prefixIcon: Icon(Icons.location_on),
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Enter ZIP code';
                                    }
                                    if (value!.length != 5) {
                                      return 'ZIP must be 5 digits';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Current SNAP Amount
                                TextFormField(
                                  controller: _snapAmountController,
                                  decoration: const InputDecoration(
                                    labelText: 'Current Monthly SNAP Amount (\$)',
                                    prefixIcon: Icon(Icons.attach_money),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Enter SNAP amount';
                                    }
                                    if (double.tryParse(value!) == null) {
                                      return 'Enter a valid amount';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                // Optional Features
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colorScheme.secondary
                                            .withOpacity(0.12),
                                        Colors.white.withOpacity(0.03),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: colorScheme.secondary
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        CheckboxListTile(
                                          activeColor: colorScheme.secondary,
                                          title:
                                              const Text('Enable AI Hotline'),
                                          subtitle: const Text(
                                            'Get voice-guided budget assistance',
                                          ),
                                          value: _enableHotline,
                                          onChanged: (value) {
                                            setState(
                                              () =>
                                                  _enableHotline = value ?? false,
                                            );
                                          },
                                        ),
                                        CheckboxListTile(
                                          activeColor: accentAmber,
                                          title:
                                              const Text('Enable Donation Flow'),
                                          subtitle: const Text(
                                            'Share surplus benefits for community impact',
                                          ),
                                          value: _enableDonation,
                                          onChanged: (value) {
                                            setState(
                                              () => _enableDonation =
                                                  value ?? false,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Calculate Button
                                ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _calculateReallocation,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text(
                                    'Calculate Optimization',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                // Results
                                if (_reallocationResult != null) ...[
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          colorScheme.secondary
                                              .withOpacity(0.18),
                                          accentAmber.withOpacity(0.22),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: colorScheme.secondary
                                            .withOpacity(0.4),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Optimization Results',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.secondary,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Current Monthly Amount:'),
                                            Text(
                                              '\$${_reallocationResult!['currentAmount'].toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Optimized Amount:'),
                                            Text(
                                              '\$${_reallocationResult!['optimizedAmount'].toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Monthly Savings:'),
                                            Text(
                                              '\$${_reallocationResult!['savings'].toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: accentAmber,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Recommendation: ${_reallocationResult!['recommendation']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
