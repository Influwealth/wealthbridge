import 'package:flutter/material.dart';
import 'dart:math';

class FundingLookupCapsule extends StatefulWidget {
  const FundingLookupCapsule({super.key});

  @override
  State<FundingLookupCapsule> createState() => _FundingLookupCapsuleState();
}

class _FundingLookupCapsuleState extends State<FundingLookupCapsule> {
  final _formKey = GlobalKey<FormState>();

  String _fundingType = 'Grant';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _useCaseController = TextEditingController();
  String _urgencyLevel = 'Medium';
  bool _isLoading = false; // Declare _isLoading

  final List<String> fundingTypes = ['Grant', 'Loan', 'Credit Line'];
  final List<String> urgencyLevels = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void dispose() {
    _amountController.dispose();
    _useCaseController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // Set loading to true
    });

    try {
      // Simulate matching logic with delay
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Found ${(Random().nextDouble() * 5).toInt() + 3} matching opportunities!'),
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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0C1224),
            Color(0xFF0F1B38),
            Color(0xFF0A1A31),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Funding Lookup'), centerTitle: true),
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
                      center: Alignment.bottomLeft,
                      radius: 0.95,
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
                              colorScheme.primary.withOpacity(0.65),
                              accentMagenta.withOpacity(0.45),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: accentMagenta.withOpacity(0.25),
                              blurRadius: 18,
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
                                  'Find Funding Opportunities',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 16,
                                            color: colorScheme.secondary
                                                .withOpacity(0.35),
                                          ),
                                        ],
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tailored matches with neon clarity for your fastest approvals.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white70,
                                        height: 1.4,
                                      ),
                                ),
                                const SizedBox(height: 20),
                                // Funding Type Dropdown
                                DropdownButtonFormField<String>(
                                  dropdownColor:
                                      Colors.black.withOpacity(0.8),
                                  initialValue: _fundingType,
                                  decoration: InputDecoration(
                                    labelText: 'Funding Type',
                                  ),
                                  items: fundingTypes
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() => _fundingType = value!);
                                  },
                                  validator: (value) => value == null
                                      ? 'Select a funding type'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                // Requested Amount
                                TextFormField(
                                  controller: _amountController,
                                  decoration: const InputDecoration(
                                    labelText: 'Requested Amount (\$)',
                                    prefixIcon: Icon(Icons.attach_money),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter an amount';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Enter a valid number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Use Case
                                TextFormField(
                                  controller: _useCaseController,
                                  decoration: const InputDecoration(
                                    labelText: 'Use Case',
                                    prefixIcon: Icon(Icons.description),
                                  ),
                                  maxLines: 3,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Describe your use case';
                                    }
                                    if (value.length < 10) {
                                      return 'Use case must be at least 10 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Urgency Level
                                DropdownButtonFormField<String>(
                                  dropdownColor:
                                      Colors.black.withOpacity(0.8),
                                  initialValue: _urgencyLevel,
                                  decoration: const InputDecoration(
                                    labelText: 'Urgency Level',
                                  ),
                                  items: urgencyLevels
                                      .map(
                                        (level) => DropdownMenuItem(
                                          value: level,
                                          child: Text(level),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() => _urgencyLevel = value!);
                                  },
                                ),
                                const SizedBox(height: 24),
                                // Submit Button
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text(
                                    'Search Opportunities',
                                    style: TextStyle(fontSize: 16),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
