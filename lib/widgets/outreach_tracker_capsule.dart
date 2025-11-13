import 'package:flutter/material.dart';

class OutreachTrackerCapsule extends StatefulWidget {
  const OutreachTrackerCapsule({super.key});

  @override
  State<OutreachTrackerCapsule> createState() => _OutreachTrackerCapsuleState();
}

class _OutreachTrackerCapsuleState extends State<OutreachTrackerCapsule> {
  String? _successMessage;

  final List<Map<String, dynamic>> contacts = [
    {
      'name': 'John Smith',
      'org': 'ABC Financial Corp',
      'email': 'john@abcfinance.com',
      'status': 'Contacted',
      'lastFollowUp': '2025-01-10',
      'notes': 'Interested in grant opportunities',
    },
    {
      'name': 'Sarah Johnson',
      'org': 'Community Development Inc',
      'email': 'sarah@cdi.org',
      'status': 'Pending',
      'lastFollowUp': '2025-01-08',
      'notes': 'Awaiting response to initial outreach',
    },
    {
      'name': 'Michael Chen',
      'org': 'Tech Accelerator Fund',
      'email': 'michael@taccel.io',
      'status': 'Contacted',
      'lastFollowUp': '2025-01-12',
      'notes': 'Scheduled call for next week',
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Contacted':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'No Response':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showContactModal() {
    showDialog(
      context: context,
      builder: (context) => const _ContactFormModal(),
    ).then((value) {
      if (value == true) {
        setState(() {
          _successMessage = 'Contact added successfully!';
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _successMessage = null);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Outreach Tracker'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: _showContactModal,
        tooltip: 'Add Contact',
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Outreach Contacts',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return _contactCard(contact, isMobile);
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_successMessage != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _successMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _contactCard(Map<String, dynamic> contact, bool isMobile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact['name'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        contact['org'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      contact['status'] as String,
                    ).withAlpha(51),
                    border: Border.all(
                      color: _getStatusColor(contact['status'] as String),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    contact['status'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(contact['status'] as String),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              contact['email'] as String,
              style: const TextStyle(fontSize: 11, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              'Notes: ${contact['notes']}',
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Last Follow-up: ${contact['lastFollowUp']}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mail, size: 16),
                    label: const Text('Follow-up'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
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

class _ContactFormModal extends StatefulWidget {
  const _ContactFormModal();

  @override
  State<_ContactFormModal> createState() => __ContactFormModalState();
}

class __ContactFormModalState extends State<_ContactFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _orgController = TextEditingController();
  final _emailController = TextEditingController();
  String _status = 'Pending';

  @override
  void dispose() {
    _nameController.dispose();
    _orgController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Contact'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Contact Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _orgController,
                decoration: InputDecoration(
                  labelText: 'Organization',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter organization' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Enter email';
                  if (!value!.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['Pending', 'Contacted', 'No Response']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, true);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
