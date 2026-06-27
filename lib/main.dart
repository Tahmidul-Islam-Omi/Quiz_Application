import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_gate.dart';

// TEMPORARY: web-only config so the UI can be previewed in Chrome.
// Android uses google-services.json. Remove after design review.
const FirebaseOptions _webPreviewOptions = FirebaseOptions(
  apiKey: 'AIzaSyD0nfAEJenYW-STwQYziSskaJkCn2jCvO8',
  appId: '1:225570904865:android:c3deefcaf40289476efc60',
  messagingSenderId: '225570904865',
  projectId: 'quiz-application-a5838',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: kIsWeb ? _webPreviewOptions : null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Quiz Application',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}
