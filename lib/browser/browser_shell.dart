import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

import 'browser_models.dart';
import 'browser_storage.dart';

class BrowserShell extends StatefulWidget {
  const BrowserShell({
    super.key,
    this.initialUrl = 'https://flutter.dev',
    this.embedWebView = true,
    BrowserProfileStorage? storageManager,
  }) : storageManager = storageManager ?? BrowserStorageManager();

  final String initialUrl;
  final bool embedWebView;
  final BrowserProfileStorage storageManager;

  @override
  State<BrowserShell> createState() => _BrowserShellState();
}

class _BrowserShellState extends State<BrowserShell> {
  final List<BrowserTab> _tabs = [];
  final Map<String, InAppWebViewController?> _controllers = {};
  final TextEditingController _addressController = TextEditingController();
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  late final BrowserProfileStorage _storage;

  int _activeIndex = 0;
  int _tabCounter = 0;

  BrowserTab get _activeTab => _tabs[_activeIndex];

  @override
  void initState() {
    super.initState();
    _storage = widget.storageManager;
    unawaited(_storage.init());
    _createTab(widget.initialUrl);
  }

  @override
  void dispose() {
    _isLoading.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _BrowserHeader(
              tabs: _tabs,
              activeIndex: _activeIndex,
              isLoading: _isLoading,
              addressController: _addressController,
              canGoBack: _activeTab.canGoBack,
              canGoForward: _activeTab.canGoForward,
              onAddTab: () => _createTab(widget.initialUrl, setActive: true),
              onCloseTab: _closeTab,
              onSelectTab: _selectTab,
              onGoBack: _navigateBack,
              onGoForward: _navigateForward,
              onReload: _reload,
              onNavigateToAddress: _loadFromAddressBar,
            ),
            const Divider(height: 1),
            Expanded(
              child: Container(
                color: Colors.white,
                child: _tabs.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(
                        children: _tabs
                            .map(
                              (tab) => Offstage(
                                offstage: tab != _activeTab,
                                child: BrowserTabView(
                                  tab: tab,
                                  embedWebView: widget.embedWebView,
                                  onWebViewCreated: (controller) =>
                                      _controllers[tab.id] = controller,
                                  onTitleChanged: (title) =>
                                      _updateTitle(tab, title),
                                  onPageStarted: (url) =>
                                      _handlePageStarted(tab, url),
                                  onPageFinished: (url) =>
                                      _handlePageFinished(tab, url),
                                  onDownload: (request) =>
                                      _handleDownload(tab, request),
                                  onPermissionRequested:
                                      (resources, origin) async =>
                                          _handlePermissionRequest(
                                              tab, resources, origin),
                                  onError: (url, code, message) =>
                                      _handleLoadError(url, code, message),
                                  onCanGoBack: (canGoBack) {
                                    setState(() {
                                      tab.canGoBack = canGoBack;
                                    });
                                  },
                                  onCanGoForward: (canGoForward) {
                                    setState(() {
                                      tab.canGoForward = canGoForward;
                                    });
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createTab(String url, {bool setActive = true}) {
    final tabId = 'tab-${_tabCounter++}';
    final normalizedUrl = _normalizeUrl(url);
    final tab = BrowserTab(
      id: tabId,
      initialUrl: normalizedUrl,
      title: 'Home',
    );
    setState(() {
      _tabs.add(tab);
      if (setActive) {
        _activeIndex = _tabs.length - 1;
        _addressController.text = normalizedUrl;
      }
    });
  }

  void _closeTab(BrowserTab tab) {
    if (_tabs.length == 1) return;
    final closingIndex = _tabs.indexOf(tab);
    setState(() {
      _tabs.remove(tab);
      _controllers.remove(tab.id);
      if (_activeIndex >= _tabs.length) {
        _activeIndex = _tabs.length - 1;
      } else if (closingIndex <= _activeIndex && _activeIndex > 0) {
        _activeIndex -= 1;
      }
      _addressController.text = _activeTab.currentUrl;
    });
  }

  void _selectTab(int index) {
    setState(() {
      _activeIndex = index;
      _addressController.text = _activeTab.currentUrl;
    });
  }

  Future<void> _navigateBack() async {
    final controller = _controllers[_activeTab.id];
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
    }
  }

  Future<void> _navigateForward() async {
    final controller = _controllers[_activeTab.id];
    if (controller != null && await controller.canGoForward()) {
      await controller.goForward();
    }
  }

  Future<void> _reload() async {
    final controller = _controllers[_activeTab.id];
    await controller?.reload();
  }

  Future<void> _loadFromAddressBar(String value) async {
    final targetUrl = _normalizeUrl(value);
    _addressController.text = targetUrl;
    await _controllers[_activeTab.id]
        ?.loadUrl(urlRequest: URLRequest(url: WebUri(targetUrl)));
    setState(() {
      _activeTab.currentUrl = targetUrl;
    });
  }

  String _normalizeUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return widget.initialUrl;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return widget.initialUrl;
    if (uri.scheme.isEmpty) {
      return 'https://$trimmed';
    }
    return uri.toString();
  }

  void _updateTitle(BrowserTab tab, String? title) {
    setState(() {
      tab.title = title ?? tab.title;
    });
  }

  void _handlePageStarted(BrowserTab tab, String? url) {
    setState(() {
      _isLoading.value = true;
      tab.isLoading = true;
      if (url != null) {
        tab.currentUrl = url;
        _addressController.text = url;
      }
    });
  }

  void _handlePageFinished(BrowserTab tab, String? url) {
    setState(() {
      _isLoading.value = false;
      tab.isLoading = false;
      if (url != null) {
        tab.currentUrl = url;
        _addressController.text = url;
      }
    });
    unawaited(_storage.recordVisit(tab.currentUrl, tab.title));
    unawaited(_storage.persistCookiesForUrl(tab.currentUrl));
  }

  void _handleDownload(BrowserTab tab, DownloadStartRequest request) {
    unawaited(
      _storage.recordDownload(
        request.url.toString(),
        fileName: request.suggestedFilename,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download started: ${request.suggestedFilename ?? 'file'}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool> _handlePermissionRequest(
    BrowserTab tab,
    List<String> resources,
    Uri? origin,
  ) async {
    if (kDebugMode) {
      debugPrint(
        'Permission request on ${tab.currentUrl}: ${resources.join(', ')}',
      );
    }
    final requestMessage =
        'Allow ${origin?.host ?? 'site'} to access ${resources.join(', ')}?';
    final approved = await _showPermissionDialog(requestMessage);
    if (!approved) {
      return false;
    }

    final permissionsToRequest = _mapResourcesToPermissions(resources);
    for (final permission in permissionsToRequest) {
      final status = await permission.request();
      if (!status.isGranted) {
        return false;
      }
    }
    return true;
  }

  List<Permission> _mapResourcesToPermissions(List<String> resources) {
    final List<Permission> permissions = [];
    for (final resource in resources) {
      switch (resource) {
        case PermissionRequestResourceType.VIDEO_CAPTURE:
          permissions.add(Permission.camera);
          break;
        case PermissionRequestResourceType.AUDIO_CAPTURE:
          permissions.add(Permission.microphone);
          break;
        case PermissionRequestResourceType.GEOLOCATION:
          permissions.add(Platform.isIOS
              ? Permission.locationWhenInUse
              : Permission.location);
          break;
      }
    }
    return permissions;
  }

  Future<void> _handleLoadError(String? url, int code, String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error loading ${url ?? 'page'}: $message ($code)'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _showPermissionDialog(String message) async {
    final theme = Theme.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Permission request'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Deny'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text('Allow'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

class _BrowserHeader extends StatelessWidget {
  const _BrowserHeader({
    required this.tabs,
    required this.activeIndex,
    required this.isLoading,
    required this.addressController,
    required this.canGoBack,
    required this.canGoForward,
    required this.onAddTab,
    required this.onCloseTab,
    required this.onSelectTab,
    required this.onGoBack,
    required this.onGoForward,
    required this.onReload,
    required this.onNavigateToAddress,
  });

  final List<BrowserTab> tabs;
  final int activeIndex;
  final ValueNotifier<bool> isLoading;
  final TextEditingController addressController;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onAddTab;
  final void Function(BrowserTab tab) onCloseTab;
  final void Function(int index) onSelectTab;
  final VoidCallback onGoBack;
  final VoidCallback onGoForward;
  final VoidCallback onReload;
  final void Function(String value) onNavigateToAddress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final tab in tabs)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected: tabs.indexOf(tab) == activeIndex,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(tab.icon, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  tab.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => onCloseTab(tab),
                                  child: const Icon(Icons.close, size: 16),
                                ),
                              ],
                            ),
                            onSelected: (_) => onSelectTab(tabs.indexOf(tab)),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: 'New tab',
                        onPressed: onAddTab,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<bool>(
                valueListenable: isLoading,
                builder: (_, loading, __) {
                  return loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check, size: 18, color: Colors.green);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: canGoBack ? onGoBack : null,
                icon: const Icon(Icons.arrow_back),
              ),
              IconButton(
                onPressed: canGoForward ? onGoForward : null,
                icon: const Icon(Icons.arrow_forward),
              ),
              IconButton(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: addressController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    hintText: 'Search or enter website name',
                    isDense: true,
                    filled: true,
                  ),
                  onSubmitted: onNavigateToAddress,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => onNavigateToAddress(addressController.text),
                child: const Text('Go'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BrowserTabView extends StatelessWidget {
  const BrowserTabView({
    super.key,
    required this.tab,
    required this.onWebViewCreated,
    required this.onTitleChanged,
    required this.onPageStarted,
    required this.onPageFinished,
    required this.onDownload,
    required this.onPermissionRequested,
    required this.onError,
    required this.embedWebView,
    required this.onCanGoBack,
    required this.onCanGoForward,
  });

  final BrowserTab tab;
  final void Function(InAppWebViewController controller) onWebViewCreated;
  final void Function(String? title) onTitleChanged;
  final void Function(String? url) onPageStarted;
  final void Function(String? url) onPageFinished;
  final void Function(DownloadStartRequest request) onDownload;
  final Future<bool> Function(List<String> resources, Uri? origin)
      onPermissionRequested;
  final void Function(String? url, int code, String message) onError;
  final bool embedWebView;
  final void Function(bool canGoBack) onCanGoBack;
  final void Function(bool canGoForward) onCanGoForward;

  @override
  Widget build(BuildContext context) {
    if (!embedWebView) {
      return _BrowserPlaceholder(
        url: tab.currentUrl,
        onSimulateLoad: () {
          onPageStarted(tab.currentUrl);
          onTitleChanged('Example');
          onPageFinished(tab.currentUrl);
          onCanGoBack(true);
          onCanGoForward(true);
        },
        onSimulatePermission: () {
          onPermissionRequested(
            [PermissionRequestResourceType.GEOLOCATION],
            null,
          );
        },
      );
    }

    return InAppWebView(
      key: ValueKey('webview-${tab.id}'),
      initialSettings: InAppWebViewSettings(
        safeBrowsingEnabled: true,
        javaScriptEnabled: true,
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: true,
        useShouldOverrideUrlLoading: true,
        incognito: false,
      ),
      initialUrlRequest: URLRequest(url: WebUri(tab.initialUrl)),
      onWebViewCreated: (controller) async {
        onWebViewCreated(controller);
        onCanGoBack(await controller.canGoBack());
        onCanGoForward(await controller.canGoForward());
      },
      onTitleChanged: (controller, title) => onTitleChanged(title),
      onLoadStart: (controller, url) => onPageStarted(url?.toString()),
      onLoadStop: (controller, url) async {
        onCanGoBack(await controller.canGoBack());
        onCanGoForward(await controller.canGoForward());
        onPageFinished(url?.toString());
      },
      onDownloadStartRequest: (controller, request) => onDownload(request),
      shouldOverrideUrlLoading: (controller, action) async {
        final uri = action.request.url;
        if (uri == null) {
          return NavigationActionPolicy.CANCEL;
        }
        if (uri.scheme != 'https' && uri.scheme != 'http') {
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
      onReceivedError: (controller, request, error) =>
          onError(request.url?.toString(), error.type.value, error.description),
      onPermissionRequest: (controller, request) =>
          onPermissionRequested(request.resources, request.origin)
              .then((allowed) => PermissionResponse(
                    resources: request.resources,
                    action: allowed
                        ? PermissionResponseAction.GRANT
                        : PermissionResponseAction.DENY,
                  )),
      androidOnPermissionRequest: (controller, origin, resources) =>
          onPermissionRequested(resources, Uri.parse(origin))
              .then((allowed) => PermissionRequestResponse(
                    resources: resources,
                    action: allowed
                        ? PermissionRequestResponseAction.GRANT
                        : PermissionRequestResponseAction.DENY,
                  )),
      onGeolocationPermissionsShowPrompt: (controller, origin) async {
        final allowed = await onPermissionRequested(
          [PermissionRequestResourceType.GEOLOCATION],
          Uri.tryParse(origin),
        );
        return GeolocationPermissionShowPromptResponse(
          allow: allowed,
          retain: true,
        );
      },
    );
  }
}

class _BrowserPlaceholder extends StatelessWidget {
  const _BrowserPlaceholder({
    required this.url,
    required this.onSimulateLoad,
    required this.onSimulatePermission,
  });

  final String url;
  final VoidCallback onSimulateLoad;
  final VoidCallback onSimulatePermission;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.language, size: 64, color: Colors.grey.shade600),
          const SizedBox(height: 12),
          Text(
            'Embedded browser placeholder',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Would navigate to:\n$url',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: onSimulateLoad,
                icon: const Icon(Icons.downloading),
                label: const Text('Simulate load'),
              ),
              OutlinedButton.icon(
                onPressed: onSimulatePermission,
                icon: const Icon(Icons.lock_open),
                label: const Text('Simulate permission'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
