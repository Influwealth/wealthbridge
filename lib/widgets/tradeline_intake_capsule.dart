import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TradelineIntakeCapsule extends StatefulWidget {
  const TradelineIntakeCapsule({super.key});

  @override
  State<TradelineIntakeCapsule> createState() => _TradelineIntakeCapsuleState();
}

class _TradelineIntakeCapsuleState extends State<TradelineIntakeCapsule> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final _fullNameController = TextEditingController();
  final _ssnController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();

  // Form state variables
  DateTime? _selectedDateOfBirth;
  String? _selectedCreditScore;
  bool _isLoading = false;

  final List<String> _creditScoreRanges = [
    '<500',
    '500–600',
    '600–700',
    '700+',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _ssnController.dispose();
    _monthlyIncomeController.dispose();
    super.dispose();
  }

  /// Format SSN with masks (XXX-XX-XXXX)
  String _formatSSN(String value) {
    value = value.replaceAll('-', '').replaceAll(' ', '');
    if (value.length <= 3) {
      return value;
    } else if (value.length <= 5) {
      return '${value.substring(0, 3)}-${value.substring(3)}';
    } else {
      return '${value.substring(0, 3)}-${value.substring(3, 5)}-${value.substring(5, 9)}';
    }
  }

  /// Open date picker for date of birth
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  /// Validate form and submit
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCreditScore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your credit score range'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call with 2-second delay
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Tradeline request submitted. You\'ll be matched shortly.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 3),
          ),
        );

        // Optional: Reset form after successful submission
        _formKey.currentState!.reset();
        _fullNameController.clear();
        _ssnController.clear();
        _monthlyIncomeController.clear();
        setState(() {
          _selectedDateOfBirth = null;
          _selectedCreditScore = null;
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
        title: const Text('Tradeline Intake Capsule'),
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

                    // SSN Field (Masked)
                    TextFormField(
                      controller: _ssnController,
                      decoration: InputDecoration(
                        labelText: 'Social Security Number',
                        hintText: 'XXX-XX-XXXX',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 11, // 9 digits + 2 hyphens
                      onChanged: (value) {
                        final formattedValue = _formatSSN(value);
                        if (formattedValue != value) {
                          _ssnController.value = TextEditingValue(
                            text: formattedValue,
                            selection: TextSelection.collapsed(
                              offset: formattedValue.length,
                            ),
                          );
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'SSN is required';
                        }
                        final cleanedValue = value.replaceAll('-', '');
                        if (cleanedValue.length != 9) {
                          return 'SSN must be 9 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date of Birth Field
                    GestureDetector(
                      onTap: () => _selectDateOfBirth(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          hintText: 'Select your date of birth',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          _selectedDateOfBirth != null
                              ? DateFormat(
                                  'MMM dd, yyyy',
                                ).format(_selectedDateOfBirth!)
                              : 'Tap to select',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedDateOfBirth != null
                                ? Colors.black
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Credit Score Range Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCreditScore,
                      decoration: InputDecoration(
                        labelText: 'Credit Score Range',
                        prefixIcon: const Icon(Icons.trending_up),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      hint: const Text('Select your credit score range'),
                      items: _creditScoreRanges.map((range) {
                        return DropdownMenuItem(
                          value: range,
                          child: Text(range),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCreditScore = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a credit score range';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Monthly Income Field
                    TextFormField(
                      controller: _monthlyIncomeController,
                      decoration: InputDecoration(
                        labelText: 'Monthly Income',
                        hintText: 'Enter your monthly income',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Monthly income is required';
                        }
                        final income = int.tryParse(value);
                        if (income == null || income <= 0) {
                          return 'Please enter a valid income amount';
                        }
                        return null;
                      },
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
                                  Color.fromARGB(
                                      (0.8 * 255).round(), 255, 255, 255),
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Submit Tradeline Request',
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
