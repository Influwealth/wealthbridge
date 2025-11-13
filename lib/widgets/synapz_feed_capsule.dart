import 'package:flutter/material.dart';

class SocialPost {
  final String postId;
  final String capsuleName;
  final String content;
  final String? aiGeneratedSummary;
  final DateTime postedAt;
  final int likes;
  final int shares;

  SocialPost({
    required this.postId,
    required this.capsuleName,
    required this.content,
    required this.aiGeneratedSummary,
    required this.postedAt,
    required this.likes,
    required this.shares,
  });
}

class SynapzFeedCapsule extends StatefulWidget {
  const SynapzFeedCapsule({super.key});

  @override
  State<SynapzFeedCapsule> createState() => _SynapzFeedCapsuleState();
}

class _SynapzFeedCapsuleState extends State<SynapzFeedCapsule> {
  late List<SocialPost> posts;

  @override
  void initState() {
    super.initState();
    posts = [
      SocialPost(
        postId: 'POST-001',
        capsuleName: 'AP2 Payout System',
        content:
            '🎯 New affiliate tier unlocked! Maria Garcia reached Platinum status with \$28.75K in earnings.',
        aiGeneratedSummary: 'Affiliate milestone achievement',
        postedAt: DateTime(2025, 11, 10),
        likes: 342,
        shares: 48,
      ),
      SocialPost(
        postId: 'POST-002',
        capsuleName: 'FACTIIV Credit',
        content:
            '📊 Credit scores improved across community! Average score up 45 points this quarter.',
        aiGeneratedSummary: 'Community credit building success',
        postedAt: DateTime(2025, 11, 09),
        likes: 567,
        shares: 89,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFFFFC0CB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('📱 SynapzFeed'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          post.capsuleName,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Nov ${post.postedAt.day}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(post.content, style: const TextStyle(fontSize: 14)),
                  if (post.aiGeneratedSummary != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '✨ ${post.aiGeneratedSummary}',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text('${post.likes}',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 16),
                      const Icon(Icons.share, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text('${post.shares}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
