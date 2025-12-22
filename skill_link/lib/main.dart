import 'package:flutter/material.dart';
import 'package:skill_link/app/app.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await serviceLocator<NotificationService>().initialize();

  runApp(const MyApp());
}
