import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcplus/component/dependency_injection.dart';
import 'package:pcplus/firebase_options.dart';
import 'package:pcplus/route.dart';
import 'package:pcplus/pages/splash/splash.dart';
import 'package:pcplus/sample/comment.dart';
import 'package:pcplus/sample/voice_search.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  DependencyInjection.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PC Plus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
