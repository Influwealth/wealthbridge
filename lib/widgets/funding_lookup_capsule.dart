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
      appBar: AppBar(title: const Text('Funding Lookup'), centerTitle: true),
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
                              'Find Funding Opportunities',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 20),
                            // Funding Type Dropdown
                            DropdownButtonFormField<String>(
                              initialValue: _fundingType,
                              decoration: InputDecoration(
                                labelText: 'Funding Type',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
                              decoration: InputDecoration(
                                labelText: 'Requested Amount (\$)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.attach_money),
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
                              decoration: InputDecoration(
                                labelText: 'Use Case',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.description),
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
                              initialValue: _urgencyLevel,
                              decoration: InputDecoration(
                                labelText: 'Urgency Level',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
