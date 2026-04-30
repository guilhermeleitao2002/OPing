import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'package:oping/screens/home_screen.dart';
import 'package:oping/services/notification_service.dart';
import 'package:oping/workers/chapter_check_worker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().initialize();

  await Workmanager().initialize(callbackDispatcher);

  await Workmanager().registerPeriodicTask(
    WorkerTask.taskName,
    WorkerTask.taskName,
    frequency: const Duration(hours: 1),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  runApp(const OPingApp());
}

class OPingApp extends StatelessWidget {
  const OPingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OPing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B3A6B),
          primary: const Color(0xFF1B3A6B),
          secondary: const Color(0xFFD4AF37),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B3A6B),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
