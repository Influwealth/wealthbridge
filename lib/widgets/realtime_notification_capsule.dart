import 'package:flutter/material.dart';

class RealTimeNotificationCapsule extends StatefulWidget {
  const RealTimeNotificationCapsule({super.key});

  @override
  State<RealTimeNotificationCapsule> createState() =>
      _RealTimeNotificationCapsuleState();
}

class _RealTimeNotificationCapsuleState
    extends State<RealTimeNotificationCapsule> {
  // Placeholder for VaultGemma encryption status
  bool _isEncrypted = true;

  // Placeholder for notification preferences
  bool _enablePushNotifications = true;
  bool _enableSmsAlerts = false;
  bool _enableVoiceAlerts = false;

  // Sample data for testing
  final List<Map<String, String>> _sampleNotifications = [
    {
      'type': 'payout',
      'message': 'Payout of \$100 received!',
      'timestamp': '2023-10-26 10:00'
    },
    {
      'type': 'dispute',
      'message': 'Dispute #12345 updated.',
      'timestamp': '2023-10-26 10:30'
    },
    {
      'type': 'funding_match',
      'message': 'New funding match available!',
      'timestamp': '2023-10-26 11:00'
    },
  ];

  // XMCP Orchestration Hooks (placeholder for integration logic)
  void _triggerXMCPHook(String eventType, Map<String, dynamic> payload) {
    print('XMCP Hook Triggered: $eventType with payload $payload');
    // In a real scenario, this would interact with the XMCP orchestration system.
  }

  // JSON Export for audit and compliance
  Map<String, dynamic> toJson() {
    return {
      'capsuleName': 'RealTimeNotificationCapsule',
      'encryptionStatus': _isEncrypted,
      'notificationPreferences': {
        'pushNotifications': _enablePushNotifications,
        'smsAlerts': _enableSmsAlerts,
        'voiceAlerts': _enableVoiceAlerts,
      },
      'sampleNotifications': _sampleNotifications,
      // Add other relevant data for export
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Container(
        // Gradient header and color-coded UI
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isEncrypted
                ? [Colors.green.shade800, Colors.green.shade400]
                : [Colors.red.shade800, Colors.red.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Real-Time Notifications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // VaultGemma encryption status indicator
                  _isEncrypted
                      ? const Icon(Icons.lock, color: Colors.white)
                      : const Icon(Icons.lock_open, color: Colors.white),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _isEncrypted
                    ? 'Encryption: Active (VaultGemma)'
                    : 'Encryption: Inactive',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              const Text(
                'Notification Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SwitchListTile(
                title: const Text('Push Notifications',
                    style: TextStyle(color: Colors.white)),
                value: _enablePushNotifications,
                onChanged: (bool value) {
                  setState(() {
                    _enablePushNotifications = value;
                    _triggerXMCPHook('notification_preference_update',
                        {'type': 'push', 'enabled': value});
                  });
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white70,
                inactiveTrackColor: Colors.white30,
              ),
              SwitchListTile(
                title: const Text('SMS Alerts (Twilio)',
                    style: TextStyle(color: Colors.white)),
                value: _enableSmsAlerts,
                onChanged: (bool value) {
                  setState(() {
                    _enableSmsAlerts = value;
                    _triggerXMCPHook('notification_preference_update',
                        {'type': 'sms', 'enabled': value});
                  });
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white70,
                inactiveTrackColor: Colors.white30,
              ),
              SwitchListTile(
                title: const Text('Voice Alerts (Twilio)',
                    style: TextStyle(color: Colors.white)),
                value: _enableVoiceAlerts,
                onChanged: (bool value) {
                  setState(() {
                    _enableVoiceAlerts = value;
                    _triggerXMCPHook('notification_preference_update',
                        {'type': 'voice', 'enabled': value});
                  });
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white70,
                inactiveTrackColor: Colors.white30,
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Notifications (Sample Data)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ..._sampleNotifications
                  .map((notification) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${notification['timestamp']}: ${notification['message']}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ))
                  .toList(),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Simulate JSON export
                  print('Exporting RealTimeNotificationCapsule data to JSON:');
                  print(toJson());
                  _triggerXMCPHook('data_export', {
                    'capsule': 'RealTimeNotificationCapsule',
                    'format': 'json'
                  });
                },
                icon: const Icon(Icons.download, color: Colors.green),
                label: const Text('Export Data (JSON)',
                    style: TextStyle(color: Colors.green)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Registry-ready metadata
final Map<String, dynamic> realTimeNotificationCapsuleMetadata = {
  'name': 'RealTimeNotificationCapsule',
  'route': '/realtime_notifications',
  'category': 'Notifications',
  'icon': Icons.notifications.codePoint, // Storing codePoint for icon
  'color': Colors.green.value, // Storing color value
  'description':
      'Manages real-time push, SMS, and voice notifications for various events.',
  'encryptionRequired': true,
  'orchestrationHooks': ['notification_preference_update', 'data_export'],
};
