import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'firebase_options.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: StudyPlannerApp()));
}

class StudyPlannerApp extends ConsumerWidget {
  const StudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(      debugShowCheckedModeBanner: false,
      title: 'StudyPlanner',
      theme: buildTheme(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}