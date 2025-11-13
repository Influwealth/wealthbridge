import 'package:flutter/material.dart';

class GovernmentAccessCapsule extends StatefulWidget {
  const GovernmentAccessCapsule({super.key});

  @override
  State<GovernmentAccessCapsule> createState() =>
      _GovernmentAccessCapsuleState();
}

class _GovernmentAccessCapsuleState extends State<GovernmentAccessCapsule> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _dunsController = TextEditingController();
  final TextEditingController _naicsController = TextEditingController();
  final TextEditingController _eftAccountController = TextEditingController();
  String _samStatus = 'Not Started';
  bool _isLoading = false; // Declare _isLoading

  final List<String> samStatuses = [
    'Not Started',
    'In Progress',
    'Verified',
    'Expired',
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _dunsController.dispose();
    _naicsController.dispose();
    _eftAccountController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // Set loading to true
    });

    try {
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Government registration submitted successfully!'),
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
      appBar: AppBar(title: const Text('Government Access'), centerTitle: true),
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
                              'Government Registration',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Complete your SAM.gov and EFT registration',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 20),
                            // Business Name
                            TextFormField(
                              controller: _businessNameController,
                              decoration: InputDecoration(
                                labelText: 'Business Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.business),
                              ),
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Enter business name'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            // DUNS Number
                            TextFormField(
                              controller: _dunsController,
                              decoration: InputDecoration(
                                labelText: 'DUNS Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.numbers),
                                helperText: '9-digit Dun & Bradstreet number',
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Enter DUNS number';
                                }
                                if (value!.length != 9) {
                                  return 'DUNS must be 9 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // NAICS Code
                            TextFormField(
                              controller: _naicsController,
                              decoration: InputDecoration(
                                labelText: 'NAICS Code',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.category),
                                helperText: '6-digit industry classification',
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Enter NAICS code';
                                }
                                if (value!.length != 6) {
                                  return 'NAICS must be 6 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // SAM.gov Status
                            DropdownButtonFormField<String>(
                              initialValue: _samStatus,
                              decoration: InputDecoration(
                                labelText: 'SAM.gov Status',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: samStatuses
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _samStatus = value!);
                              },
                            ),
                            const SizedBox(height: 16),
                            // EFT Account Setup
                            TextFormField(
                              controller: _eftAccountController,
                              decoration: InputDecoration(
                                labelText: 'EFT Account (Bank Routing)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.account_balance),
                                helperText: '9-digit routing number',
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Enter routing number';
                                }
                                if (value!.length != 9) {
                                  return 'Routing number must be 9 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            // Document Upload Placeholder
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.cloud_upload, size: 32),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Upload Supporting Documents',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Text(
                                    'EIN Certificate, Articles of Incorporation',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.attach_file,
                                      size: 16,
                                    ),
                                    label: const Text('Select Files'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Submit Button
                            ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _submitRegistration,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Register for Government Access',
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
