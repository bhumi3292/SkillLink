import 'package:flutter/material.dart';
import 'package:skill_link/app/app.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/core/services/notification_service.dart';
import 'package:skill_link/cores/localization/localization_service.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await Get.putAsync(() => LocalizationService().init());
  await serviceLocator<NotificationService>().initialize();

  runApp(const MyApp());
}
