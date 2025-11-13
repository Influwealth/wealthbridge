import 'package:flutter/material.dart';

class TruthAlgorithmCapsule extends StatefulWidget {
  const TruthAlgorithmCapsule({super.key});

  @override
  State<TruthAlgorithmCapsule> createState() => _TruthAlgorithmCapsuleState();
}

class _TruthAlgorithmCapsuleState extends State<TruthAlgorithmCapsule> {
  bool _teachableModeEnabled = false;
  bool _isSimulating = false;
  String _simulationResult = '';
  double _truthScore = 0.0;
  List<String> _detectedIssues = [];

  final List<Map<String, dynamic>> _truthMetrics = [
    {'label': 'Propaganda Detection', 'score': 0.0, 'icon': Icons.warning},
    {'label': 'Bias Analysis', 'score': 0.0, 'icon': Icons.scale},
    {'label': 'Manipulation Index', 'score': 0.0, 'icon': Icons.psychology},
    {'label': 'Factuality Rating', 'score': 0.0, 'icon': Icons.verified},
  ];

  void _runTruthSimulation() {
    setState(() {
      _isSimulating = true;
      _detectedIssues = [];
    });

    // Simulate quantum logic processing
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _truthScore = (0.5 + (0.5 * (DateTime.now().millisecond % 100) / 100));

        _truthMetrics[0]['score'] =
            0.3 + (0.4 * (DateTime.now().millisecond % 50) / 50);
        _truthMetrics[1]['score'] =
            0.4 + (0.5 * (DateTime.now().millisecond % 60) / 60);
        _truthMetrics[2]['score'] =
            0.25 + (0.3 * (DateTime.now().millisecond % 40) / 40);
        _truthMetrics[3]['score'] = _truthScore;

        _detectedIssues = [
          'Loaded language detected',
          'Appeal to authority present',
          'Cherry-picked data points',
          'Emotional manipulation tactics',
        ];

        if (_teachableModeEnabled) {
          _simulationResult =
              'Teachable Insight: This content uses emotional framing. Try rephrasing with objective language.';
        } else {
          _simulationResult =
              'Truth Score: ${(_truthScore * 100).toStringAsFixed(1)}% - Multiple bias indicators found.';
        }

        _isSimulating = false;
      });
    });
  }

  void _simulateAlternateOutcome() {
    if (_truthScore == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Run Truth Simulation first to generate alternate outcomes.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alternate Outcome Simulation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Original Truth Score:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${(_truthScore * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 16),
              const Text('Alternative Interpretations:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildAlternateOutcome(
                  'Charitable Interpretation', 0.75, Colors.green),
              const SizedBox(height: 8),
              _buildAlternateOutcome('Neutral Perspective', 0.65, Colors.blue),
              const SizedBox(height: 8),
              _buildAlternateOutcome('Critical Analysis', 0.45, Colors.orange),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternateOutcome(String label, double score, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color.fromARGB(
                (0.2 * 255).round(), color.red, color.green, color.blue),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${(score * 100).toStringAsFixed(1)}%',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truth Algorithm Capsule'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Truth Algorithm Engine',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Detect propaganda, bias, and manipulation using quantum logic.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Truth Score Display
              if (_truthScore > 0)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Overall Truth Score',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTruthColor(_truthScore),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${(_truthScore * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _truthScore,
                              minHeight: 8,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getTruthColor(_truthScore),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Metrics Grid
              if (_truthScore > 0)
                Column(
                  children: [
                    const Text(
                      'Analysis Metrics',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: _truthMetrics.map((metric) {
                        return _buildMetricCard(metric);
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              // Detected Issues
              if (_detectedIssues.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detected Issues',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ..._detectedIssues.map((issue) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.flag, color: Colors.red, size: 18),
                            const SizedBox(width: 12),
                            Expanded(child: Text(issue)),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),

              // Simulation Result
              if (_simulationResult.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _simulationResult,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Teachable Mode Toggle
              SwitchListTile(
                title: const Text('Enable Teachable Mode'),
                subtitle: const Text(
                    'Provides educational insights instead of verdicts'),
                value: _teachableModeEnabled,
                onChanged: (val) {
                  setState(() {
                    _teachableModeEnabled = val;
                  });
                },
                activeThumbColor: Colors.deepPurple,
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSimulating ? null : _runTruthSimulation,
                      icon: _isSimulating
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.7),
                                ),
                              ),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(_isSimulating
                          ? 'Simulating...'
                          : 'Run Truth Simulation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _simulateAlternateOutcome,
                      icon: const Icon(Icons.compare_arrows),
                      label: const Text('Alternate Outcome'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Information Footer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'The Truth Algorithm uses quantum logic to analyze content and detect common manipulation tactics. Results are educational tools and should be verified with external sources.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(Map<String, dynamic> metric) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(metric['icon'] as IconData, color: Colors.deepPurple, size: 24),
          const SizedBox(height: 8),
          Text(
            metric['label'] as String,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '${((metric['score'] as double) * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _getTruthColor(metric['score'] as double),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTruthColor(double score) {
    if (score >= 0.7) return Colors.green;
    if (score >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
