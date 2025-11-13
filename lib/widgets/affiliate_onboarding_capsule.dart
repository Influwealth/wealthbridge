import 'package:flutter/material.dart';

class AffiliateOnboardingCapsule extends StatefulWidget {
  const AffiliateOnboardingCapsule({super.key});

  @override
  State<AffiliateOnboardingCapsule> createState() =>
      _AffiliateOnboardingCapsuleState();
}

class _AffiliateOnboardingCapsuleState
    extends State<AffiliateOnboardingCapsule> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _organizationController = TextEditingController();
  final _referralCodeController = TextEditingController();
  final _socialMediaController = TextEditingController();
  final _stripeAccountController = TextEditingController();
  final _plaidAccountController = TextEditingController();

  // Form state variables
  String? _selectedCapsuleType;
  bool _isLoading = false;
  bool _stripeConnected = false;
  bool _plaidConnected = false;

  final List<String> _capsuleTypes = [
    'Tradeline',
    'Funding',
    'Outreach',
    'Credit Repair',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    _referralCodeController.dispose();
    _socialMediaController.dispose();
    _stripeAccountController.dispose();
    _plaidAccountController.dispose();
    super.dispose();
  }

  /// Format phone number to (XXX) XXX-XXXX
  String _formatPhoneNumber(String value) {
    value = value.replaceAll(RegExp(r'[^\d]'), '');
    if (value.length <= 3) {
      return value;
    } else if (value.length <= 6) {
      return '(${value.substring(0, 3)}) ${value.substring(3)}';
    } else {
      return '(${value.substring(0, 3)}) ${value.substring(3, 6)}-${value.substring(6, 10)}';
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// Simulate Stripe connection
  Future<void> _connectStripe() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call to connect Stripe
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _stripeConnected = true;
          _stripeAccountController.text = 'Stripe Account Connected ✓';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Stripe account connected successfully'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error connecting Stripe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Simulate Plaid connection
  Future<void> _connectPlaid() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call to connect Plaid
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _plaidConnected = true;
          _plaidAccountController.text = 'Plaid Account Connected ✓';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Plaid account connected successfully'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error connecting Plaid: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Validate form and submit
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCapsuleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a capsule type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_stripeConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please connect your Stripe account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_plaidConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please connect your Plaid account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate backend onboarding with 2-second delay
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Welcome aboard! Your capsule access is being provisioned.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 4),
          ),
        );

        // Reset form after successful submission
        _formKey.currentState!.reset();
        _fullNameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _organizationController.clear();
        _referralCodeController.clear();
        _socialMediaController.clear();
        _stripeAccountController.clear();
        _plaidAccountController.clear();

        setState(() {
          _selectedCapsuleType = null;
          _stripeConnected = false;
          _plaidConnected = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 32.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Affiliate Onboarding Capsule'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.blue.shade600,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Full Name Field
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Full name is required';
                        }
                        if (value.length < 2) {
                          return 'Full name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'Enter your email address',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!_isValidEmail(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Number Field (Masked)
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '(XXX) XXX-XXXX',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: 14, // (XXX) XXX-XXXX
                      onChanged: (value) {
                        final formattedValue = _formatPhoneNumber(value);
                        if (formattedValue != value) {
                          _phoneController.value = TextEditingValue(
                            text: formattedValue,
                            selection: TextSelection.collapsed(
                              offset: formattedValue.length,
                            ),
                          );
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        final cleanedValue = value.replaceAll(
                          RegExp(r'[^\d]'),
                          '',
                        );
                        if (cleanedValue.length != 10) {
                          return 'Phone number must be 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Organization Name Field
                    TextFormField(
                      controller: _organizationController,
                      decoration: InputDecoration(
                        labelText: 'Organization Name',
                        hintText: 'Enter your organization name',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Organization name is required';
                        }
                        if (value.length < 2) {
                          return 'Organization name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Capsule Type Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCapsuleType,
                      decoration: InputDecoration(
                        labelText: 'Capsule Type',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      hint: const Text('Select a capsule type'),
                      items: _capsuleTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCapsuleType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a capsule type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Referral Code Field
                    TextFormField(
                      controller: _referralCodeController,
                      decoration: InputDecoration(
                        labelText: 'Referral Code',
                        hintText: 'Enter your referral code',
                        prefixIcon: const Icon(Icons.code),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Referral code is required';
                        }
                        if (value.length < 3) {
                          return 'Referral code must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Social Media Handle Field
                    TextFormField(
                      controller: _socialMediaController,
                      decoration: InputDecoration(
                        labelText: 'Social Media Handle',
                        hintText: 'Enter your social media handle',
                        prefixIcon: const Icon(Icons.share),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Social media handle is required';
                        }
                        if (value.length < 2) {
                          return 'Social media handle must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Stripe Account Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.payment, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Stripe Account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (_stripeConnected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _connectStripe,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _stripeConnected
                                  ? Colors.green.shade600
                                  : Colors.blue.shade600,
                              disabledBackgroundColor: Colors.grey.shade400,
                            ),
                            child: Text(
                              _stripeConnected
                                  ? 'Stripe Connected ✓'
                                  : 'Connect Stripe Account',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Plaid Account Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.account_balance, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Plaid Account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (_plaidConnected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _connectPlaid,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _plaidConnected
                                  ? Colors.green.shade600
                                  : Colors.blue.shade600,
                              disabledBackgroundColor: Colors.grey.shade400,
                            ),
                            child: Text(
                              _plaidConnected
                                  ? 'Plaid Connected ✓'
                                  : 'Connect Plaid Account',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        disabledBackgroundColor: Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withAlpha(204),
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Join Affiliate Network',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
