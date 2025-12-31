import 'package:flutter/material.dart';

/// Lightweight model for tracking the state of a browser tab.
class BrowserTab {
  BrowserTab({
    required this.id,
    required this.initialUrl,
    this.title = 'New Tab',
  }) : currentUrl = initialUrl;

  final String id;
  final String initialUrl;

  String title;
  String currentUrl;
  bool canGoBack = false;
  bool canGoForward = false;
  bool isLoading = false;

  IconData get icon => Icons.language;
}
