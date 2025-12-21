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
    const Color accentAmber = Color(0xFFFFB65C);
    const Color accentMagenta = Color(0xFFCB3CFF);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0B1224),
            Color(0xFF0E1A36),
            Color(0xFF0A1C2F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Stablecoin Factory'),
          centerTitle: true,
        ),
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
                      center: Alignment.topLeft,
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
                              colorScheme.primary.withOpacity(0.7),
                              accentMagenta.withOpacity(0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.secondary.withOpacity(0.3),
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
                                  'Create Your Stablecoin',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 14,
                                            color: accentAmber.withOpacity(0.45),
                                          ),
                                        ],
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Neon-grade issuance with secure mint toggles.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white70,
                                        height: 1.4,
                                      ),
                                ),
                                const SizedBox(height: 20),
                                // Token Name
                                TextFormField(
                                  controller: _tokenNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Token Name',
                                    prefixIcon: Icon(Icons.card_giftcard),
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
                                  decoration: const InputDecoration(
                                    labelText: 'Symbol (e.g., USD)',
                                    prefixIcon: Icon(Icons.monetization_on),
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
                                  decoration: const InputDecoration(
                                    labelText: 'Initial Supply',
                                    prefixIcon: Icon(Icons.stacked_bar_chart),
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
                                  decoration: const InputDecoration(
                                    labelText: 'Recipient Wallet Address',
                                    prefixIcon: Icon(Icons.wallet_giftcard),
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
                                  decoration: const InputDecoration(
                                    labelText: 'Use Case',
                                    prefixIcon: Icon(Icons.description),
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
                                  activeColor: colorScheme.secondary,
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
                                      gradient: LinearGradient(
                                        colors: [
                                          colorScheme.secondary
                                              .withOpacity(0.2),
                                          accentAmber.withOpacity(0.25),
                                        ],
                                      ),
                                      border: Border.all(
                                        color:
                                            colorScheme.secondary.withOpacity(0.5),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Token Created',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.secondary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SelectableText(
                                          _tokenAddress!,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 11,
                                            color: Colors.white,
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
