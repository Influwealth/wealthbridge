import 'package:flutter/material.dart';

class StablecoinFactoryCapsule extends StatefulWidget {
  const StablecoinFactoryCapsule({super.key});

  @override
  State<StablecoinFactoryCapsule> createState() =>
      _StablecoinFactoryCapsuleState();
}

class _StablecoinFactoryCapsuleState extends State<StablecoinFactoryCapsule> {
  final _formKey = GlobalKey<FormState>();
  bool _autoMint = false;
  String? _tokenAddress;
  bool _isLoading = false; // Declare _isLoading

  final TextEditingController _tokenNameController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _supplyController = TextEditingController();
  final TextEditingController _walletController = TextEditingController();
  final TextEditingController _useCaseController = TextEditingController();

  @override
  void dispose() {
    _tokenNameController.dispose();
    _symbolController.dispose();
    _supplyController.dispose();
    _walletController.dispose();
    _useCaseController.dispose();
    super.dispose();
  }

  Future<void> _createToken() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // Set loading to true
    });

    try {
      // Simulate token creation and minting
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        _tokenAddress =
            '0x${List<int>.generate(40, (i) => (i % 10).toInt()).join()}';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Token created successfully!\nAddress: ${_tokenAddress!.substring(0, 10)}...'),
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
      appBar: AppBar(
        title: const Text('Stablecoin Factory'),
        centerTitle: true,
      ),
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
                              'Create Your Stablecoin',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 20),
                            // Token Name
                            TextFormField(
                              controller: _tokenNameController,
                              decoration: InputDecoration(
                                labelText: 'Token Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.card_giftcard),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter token name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Symbol
                            TextFormField(
                              controller: _symbolController,
                              decoration: InputDecoration(
                                labelText: 'Symbol (e.g., USD)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.monetization_on),
                              ),
                              maxLength: 5,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter symbol';
                                }
                                if (value.length > 5) {
                                  return 'Symbol max 5 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Supply
                            TextFormField(
                              controller: _supplyController,
                              decoration: InputDecoration(
                                labelText: 'Initial Supply',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.stacked_bar_chart),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter supply amount';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Enter a valid number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Recipient Wallet
                            TextFormField(
                              controller: _walletController,
                              decoration: InputDecoration(
                                labelText: 'Recipient Wallet Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.wallet_giftcard),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter wallet address';
                                }
                                if (!value.startsWith('0x') ||
                                    value.length != 42) {
                                  return 'Enter valid Ethereum address';
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
                              maxLines: 2,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Describe your use case';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Auto-mint Checkbox
                            CheckboxListTile(
                              title: const Text('Auto-mint on testnet'),
                              subtitle: const Text(
                                'Automatically mint tokens to recipient',
                              ),
                              value: _autoMint,
                              onChanged: (value) {
                                setState(() => _autoMint = value!);
                              },
                            ),
                            const SizedBox(height: 24),
                            // Create Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _createToken,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Create Token',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            if (_tokenAddress != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Token Created',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SelectableText(
                                      _tokenAddress!,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
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
