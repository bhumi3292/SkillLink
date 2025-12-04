import 'package:flutter/material.dart';
import 'package:skill_link/app/app.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencies();
  runApp(const MyApp());
}
