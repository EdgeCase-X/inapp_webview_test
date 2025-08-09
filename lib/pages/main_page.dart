import 'dart:io';

import 'package:auto_validate/auto_validate.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inapp_webview_test/main.dart' show logger;
import 'package:path_provider/path_provider.dart';

import '../tools/web_archive_manager.dart';
import '../widgets/archive_grid_widget.dart';
import '../widgets/webview_tab_widget.dart';
import '../widgets/webview_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey mainWebViewKey = GlobalKey();

  InAppWebViewController? mainWebViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    allowFileAccessFromFileURLs: true,
    allowFileAccess: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
  );

  PullToRefreshController? pullToRefreshController;

  final FocusNode urlFocusNode = FocusNode();
  late TabController _tabController;

  final urlController = TextEditingController();

  List<FileSystemEntity> _mhtFiles = [];

  String archiveFileName = "";
  String url = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();
    // Set focus to the TextField on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      urlFocusNode.requestFocus();
    });

    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(color: Colors.blue),
      onRefresh: () async {
        await mainWebViewController?.reload();
      },
    );

    _tabController = TabController(length: 2, vsync: this);

    _loadMhtFiles();
  }

  Future<void> _loadMhtFiles() async {
    final dir = await getExternalStorageDirectory();
    if (dir != null) {
      final files =
          dir.listSync().where((f) => f.path.endsWith('.mht')).toList();

      setState(() => _mhtFiles = files);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EdgeCaseX POC"),
        bottom: _tabBarMenu(context),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [_webViewTab(context), _archiveGrid()],
        ),
      ),
    );
  }

  TabBar _tabBarMenu(BuildContext context) => TabBar(
    controller: _tabController,
    tabs: [
      Tab(icon: Icon(Icons.web), text: 'Navigate'),
      Tab(icon: Icon(Icons.grid_view), text: 'Archives'),
    ],
  );

  WebViewTabWidget _webViewTab(BuildContext context) => WebViewTabWidget(
    urlController: urlController,
    urlFocusNode: urlFocusNode,
    mainWebViewController: mainWebViewController,
    progress: progress,
    mainWebView: _mainWebView(),
    onUrlSubmitted: (value) async {
      if (value.isEmpty) {
        Fluttertoast.showToast(
          msg: 'Please enter a URL or search query',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        urlFocusNode.requestFocus();
        
        return;
      }

      // Regex: starts with http://, https://, or www.
      final urlPattern = RegExp(r'^(https?://|www\.)', caseSensitive: false);
      final revisedUrl =
          urlPattern.hasMatch(value) ? value : 'https://www.$value';
      final isValidURL = revisedUrl.isValidURL;

      setState(() {
        this.url =
            isValidURL ? revisedUrl : 'https://www.google.com/search?q=$value';
        urlController.text = this.url;
      });

      final urlForRequest = WebUri(url);
      await mainWebViewController?.loadUrl(
        urlRequest: URLRequest(url: urlForRequest),
      );

      if (isValidURL) {
        archiveFileName =
            '${urlForRequest.host}_${DateTime.now().millisecondsSinceEpoch}_archive.mht';
        // Archive the web page
        await _archive(archiveFileName);
      }
    },
    onArchiveCreated: () async {
      
    },
  );

  Widget _mainWebView() => WebViewWidget(
    webViewKey: mainWebViewKey,
    controller: mainWebViewController,
    settings: settings,
    pullToRefreshController: pullToRefreshController,
    progress: progress,
    urlController: urlController,
    onWebViewCreated: (controller) {
      setState(() {
        mainWebViewController = controller;
      });
    },
    onUrlChanged: (newUrl) {
      setState(() {
        url = newUrl;
        urlController.text = newUrl;
      });
    },
  );

  Widget _archiveGrid() => ArchiveGridWidget(mhtFiles: _mhtFiles);

  Future<void> _archive(String fileName) async {
    final success = await WebArchiveManager.saveWebArchive(
      mainWebViewController,
      fileName,
    );

    if (!mounted) return;

    if (success) {
      logger.d("WebView archived to: $fileName");
      Fluttertoast.showToast(msg: 'Archive saved!');
    } else {
      logger.e("ERROR: Error archiving WebView.");
      Fluttertoast.showToast(msg: 'Failed to save archive!');
    }
  }
}
