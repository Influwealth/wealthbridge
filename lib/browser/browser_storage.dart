import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

abstract class BrowserProfileStorage {
  Future<void> init();
  Future<void> recordVisit(String url, String? title);
  Future<void> recordDownload(String url, {String? fileName});
  Future<List<BrowserVisit>> history();
  Future<List<BrowserDownload>> downloads();
  Future<void> persistCookiesForUrl(String url);
  Future<void> restoreCookies();
}

class BrowserStorageManager implements BrowserProfileStorage {
  BrowserStorageManager();

  late final File _historyFile;
  late final File _downloadsFile;
  late final File _cookiesFile;
  final List<BrowserVisit> _visits = [];
  final List<BrowserDownload> _downloadRecords = [];
  final CookieManager _cookieManager = CookieManager.instance();

  @override
  Future<void> init() async {
    final supportDir = await getApplicationSupportDirectory();
    _historyFile = File('${supportDir.path}/browser_history.json');
    _downloadsFile = File('${supportDir.path}/browser_downloads.json');
    _cookiesFile = File('${supportDir.path}/browser_cookies.json');

    await _hydrateHistory();
    await _hydrateDownloads();
    await restoreCookies();
  }

  @override
  Future<void> recordVisit(String url, String? title) async {
    _visits.add(
      BrowserVisit(
        url: url,
        title: title ?? url,
        visitedAt: DateTime.now(),
      ),
    );
    await _historyFile.writeAsString(
      jsonEncode(_visits.map((e) => e.toJson()).toList()),
      flush: true,
    );
  }

  @override
  Future<void> recordDownload(String url, {String? fileName}) async {
    _downloadRecords.add(
      BrowserDownload(
        url: url,
        fileName: fileName,
        downloadedAt: DateTime.now(),
      ),
    );
    await _downloadsFile.writeAsString(
      jsonEncode(_downloadRecords.map((e) => e.toJson()).toList()),
      flush: true,
    );
  }

  @override
  Future<List<BrowserVisit>> history() async => List.unmodifiable(_visits);

  @override
  Future<List<BrowserDownload>> downloads() async =>
      List.unmodifiable(_downloadRecords);

  @override
  Future<void> persistCookiesForUrl(String url) async {
    try {
      final cookies = await _cookieManager.getCookies(url: WebUri(url));
      if (cookies.isEmpty) return;
      final persistedCookies = cookies.map((cookie) {
        return {
          'name': cookie.name,
          'value': cookie.value,
          'domain': cookie.domain ?? Uri.parse(url).host,
          'path': cookie.path ?? '/',
          'isSecure': cookie.isSecure ?? false,
          'isHttpOnly': cookie.isHttpOnly ?? false,
        };
      }).toList();
      await _cookiesFile.writeAsString(jsonEncode(persistedCookies), flush: true);
    } catch (err, stack) {
      if (kDebugMode) {
        debugPrint('Failed to persist cookies: $err\n$stack');
      }
    }
  }

  @override
  Future<void> restoreCookies() async {
    if (!await _cookiesFile.exists()) return;
    final raw = await _cookiesFile.readAsString();
    if (raw.isEmpty) return;
    final decoded = jsonDecode(raw) as List<dynamic>;
    for (final entry in decoded) {
      final cookie = entry as Map<String, dynamic>;
      await _cookieManager.setCookie(
        url: WebUri('https://${cookie['domain']}'),
        name: cookie['name'] as String,
        value: cookie['value'] as String,
        domain: cookie['domain'] as String,
        path: cookie['path'] as String,
        isSecure: cookie['isSecure'] as bool,
        isHttpOnly: cookie['isHttpOnly'] as bool,
      );
    }
  }

  Future<void> _hydrateHistory() async {
    if (!await _historyFile.exists()) {
      await _historyFile.create(recursive: true);
      return;
    }
    final raw = await _historyFile.readAsString();
    if (raw.isEmpty) return;
    final decoded = jsonDecode(raw) as List<dynamic>;
    _visits.clear();
    _visits.addAll(
      decoded.map((entry) => BrowserVisit.fromJson(entry as Map<String, dynamic>)),
    );
  }

  Future<void> _hydrateDownloads() async {
    if (!await _downloadsFile.exists()) {
      await _downloadsFile.create(recursive: true);
      return;
    }
    final raw = await _downloadsFile.readAsString();
    if (raw.isEmpty) return;
    final decoded = jsonDecode(raw) as List<dynamic>;
    _downloadRecords.clear();
    _downloadRecords.addAll(
      decoded
          .map((entry) => BrowserDownload.fromJson(entry as Map<String, dynamic>)),
    );
  }
}

class BrowserVisit {
  BrowserVisit({
    required this.url,
    required this.title,
    required this.visitedAt,
  });

  final String url;
  final String title;
  final DateTime visitedAt;

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'visitedAt': visitedAt.toIso8601String(),
      };

  factory BrowserVisit.fromJson(Map<String, dynamic> json) {
    return BrowserVisit(
      url: json['url'] as String,
      title: json['title'] as String,
      visitedAt: DateTime.parse(json['visitedAt'] as String),
    );
  }
}

class BrowserDownload {
  BrowserDownload({
    required this.url,
    required this.downloadedAt,
    this.fileName,
  });

  final String url;
  final String? fileName;
  final DateTime downloadedAt;

  Map<String, dynamic> toJson() => {
        'url': url,
        'fileName': fileName,
        'downloadedAt': downloadedAt.toIso8601String(),
      };

  factory BrowserDownload.fromJson(Map<String, dynamic> json) {
    return BrowserDownload(
      url: json['url'] as String,
      fileName: json['fileName'] as String?,
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
    );
  }
}

class InMemoryBrowserStorage implements BrowserProfileStorage {
  final List<BrowserVisit> visits = [];
  final List<BrowserDownload> downloadsLog = [];
  final List<Map<String, dynamic>> cookies = [];

  @override
  Future<void> init() async {}

  @override
  Future<List<BrowserDownload>> downloads() async =>
      List.unmodifiable(downloadsLog);

  @override
  Future<List<BrowserVisit>> history() async => List.unmodifiable(visits);

  @override
  Future<void> persistCookiesForUrl(String url) async {
    cookies.add({'url': url});
  }

  @override
  Future<void> recordDownload(String url, {String? fileName}) async {
    downloadsLog.add(
      BrowserDownload(url: url, fileName: fileName, downloadedAt: DateTime.now()),
    );
  }

  @override
  Future<void> recordVisit(String url, String? title) async {
    visits.add(
      BrowserVisit(url: url, title: title ?? url, visitedAt: DateTime.now()),
    );
  }

  @override
  Future<void> restoreCookies() async {}
}
