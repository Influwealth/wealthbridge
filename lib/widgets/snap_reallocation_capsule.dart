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
          backgroundColor: Colors.green,
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

    return Scaffold(
      appBar: AppBar(title: const Text('SNAP Reallocation'), centerTitle: true),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Optimize Your SNAP Benefits',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AI-powered analysis to maximize your benefits',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 20),
                            // Household Size
                            TextFormField(
                              controller: _householdController,
                              decoration: InputDecoration(
                                labelText: 'Household Size',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.people),
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
                              decoration: InputDecoration(
                                labelText: 'ZIP Code',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.location_on),
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
                              decoration: InputDecoration(
                                labelText: 'Current Monthly SNAP Amount (\$)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.attach_money),
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
                            Card(
                              color: Colors.blue.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    CheckboxListTile(
                                      title: const Text('Enable AI Hotline'),
                                      subtitle: const Text(
                                        'Get voice-guided budget assistance',
                                      ),
                                      value: _enableHotline,
                                      onChanged: (value) {
                                        setState(
                                          () => _enableHotline = value ?? false,
                                        );
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Enable Donation Flow'),
                                      subtitle: const Text(
                                        'Share surplus benefits for community impact',
                                      ),
                                      value: _enableDonation,
                                      onChanged: (value) {
                                        setState(
                                          () =>
                                              _enableDonation = value ?? false,
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
                                  color: Colors.green.shade50,
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Optimization Results',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
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
                                            color: Colors.green.shade700,
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
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade700,
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
