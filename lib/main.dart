import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'package:oping/models/manga.dart';
import 'package:oping/screens/home_screen.dart';
import 'package:oping/services/chapter_storage_service.dart';
import 'package:oping/services/manga_dex_service.dart';
import 'package:oping/services/notification_service.dart';
import 'package:oping/services/tracked_manga_service.dart';
import 'package:oping/workers/chapter_check_worker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Each init step is isolated so a failure in one doesn't prevent the app
  // from launching. The UI degrades gracefully: notifications or background
  // polling may be unavailable, but the screen always renders.
  try {
    await migrateLegacyOnePieceSubscription();
  } catch (e, st) {
    FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st));
  }

  try {
    await NotificationService().initialize();
  } catch (e, st) {
    FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st));
  }

  try {
    final intervalMinutes = await ChapterStorageService().getPollIntervalMinutes();
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      WorkerTask.taskName,
      WorkerTask.taskName,
      frequency: Duration(minutes: intervalMinutes),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  } catch (e, st) {
    FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st));
  }

  runApp(const OPingApp());
}

/// Idempotent first-launch migration. If the legacy `last_seen_chapter_number`
/// SharedPreferences key exists and `tracked_manga` does not, seed the tracked
/// list with One Piece carrying that legacy chapter number — so existing users
/// keep getting notifications without re-subscribing.
Future<void> migrateLegacyOnePieceSubscription() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey(TrackedMangaService.storageKey)) return;

  final legacy = prefs.getDouble('last_seen_chapter_number');
  final service = TrackedMangaService();
  if (legacy != null) {
    await service.add(const Manga(
      id: MangaDexService.onePieceMangaId,
      title: 'One Piece',
    ));
    await service.updateLastSeen(MangaDexService.onePieceMangaId, legacy);
  } else {
    await service.initializeIfMissing();
  }
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
