import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/di/injection.dart';
import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Foundation Services
  final hiveService = HiveService();
  await hiveService.init();

  // Setup Dependency Injection after Hive is ready
  setupInjection();

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const MyApp());
}
