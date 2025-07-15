import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    show
        InAppLocalhostServer,
        InAppWebViewController,
        WebViewEnvironment,
        WebViewEnvironmentSettings;
import 'package:inapp_webview_test/example/chrome_safari_browser_example.screen.dart' show ChromeSafariBrowserExampleScreen;
import 'package:inapp_webview_test/example/headless_in_app_webview.screen.dart' show HeadlessInAppWebViewExampleScreen;
import 'package:inapp_webview_test/example/in_app_browser_example.screen.dart' show InAppBrowserExampleScreen;
import 'package:inapp_webview_test/example/in_app_webiew_example.screen.dart' show InAppWebViewExampleScreen;
import 'package:inapp_webview_test/example/web_authentication_session_example.screen.dart' show WebAuthenticationSessionExampleScreen;
import 'package:inapp_webview_test/save_load_web_archive.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart' show PointerInterceptor;

final localhostServer = InAppLocalhostServer(documentRoot: 'assets');
WebViewEnvironment? webViewEnvironment;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    final availableVersion = await WebViewEnvironment.getAvailableVersion();
    assert(
      availableVersion != null,
      'Failed to find an installed WebView2 runtime or non-stable Microsoft Edge installation.',
    );

    webViewEnvironment = await WebViewEnvironment.create(
      settings: WebViewEnvironmentSettings(userDataFolder: 'custom_path'),
    );
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }
  
  runApp(const MyApp());
}

PointerInterceptor myDrawer({required BuildContext context}) {
  var children = [
    ListTile(
      title: Text('SaveLoadWebArchive'),
      onTap: () {
        Navigator.pushReplacementNamed(context, '/SaveLoadWebArchive');
      },
    ),
  ];
  
  return PointerInterceptor(
    child: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('flutter_inappwebview example'),
          ),
          ...children,
        ],
      ),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => SaveLoadWebArchive(),
      },
    );
  }
}
