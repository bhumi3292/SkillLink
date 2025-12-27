import 'package:skill_link/features/profile/presentation/view/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:skill_link/cores/localization/app_translations.dart';
import 'package:skill_link/cores/localization/localization_service.dart';
import 'dart:async';

import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/splash_screen/presentation/view/splash_view.dart';
import 'package:skill_link/features/splash_screen/presentation/widgets/theme.dart'; // Assuming this is getApplication()
import 'package:skill_link/features/auth/presentation/view/login.dart';
import 'package:skill_link/features/auth/presentation/view/signup.dart';
import 'package:skill_link/view/forgetPassword.dart';
import 'package:skill_link/view/homeView.dart'; // Make sure this path is correct
import 'package:skill_link/features/dashbaord/presentation/view/dashboard.dart'; // Make sure this path is correct
import 'package:skill_link/features/add_worker/presentation/view/add_worker_presentation.dart';
import 'package:skill_link/features/auth/presentation/view/forgot_password_page.dart';
import 'package:skill_link/features/auth/presentation/view/reset_password_page.dart';
import 'package:skill_link/features/favourite/presentation/bloc/cart_bloc.dart';

// ViewModels
import 'package:skill_link/features/auth/presentation/view_model/login_view_model/login_view_model.dart';
import 'package:skill_link/features/auth/presentation/view_model/register_view_model/register_view_model.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:skill_link/features/notification/domain/notification_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies(); // Initialize all dependencies
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    // _handleIncomingLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CartBloc>(
      create: (_) => serviceLocator<CartBloc>(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => serviceLocator<LoginViewModel>()),
          BlocProvider(create: (_) => serviceLocator<RegisterUserViewModel>()),
          BlocProvider(create: (_) => serviceLocator<ProfileViewModel>()),
        ],
        child: GetMaterialApp(
          translations: AppTranslations(),
          locale: LocalizationService.to.currentLocale,
          fallbackLocale: LocalizationService.defaultLocale,
          navigatorKey: NotificationHandler.navigatorKey,
          title: 'SkillLink',
          debugShowCheckedModeBanner: false,
          theme: getApplication(),
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const SplashScreen()),
            GetPage(name: '/login', page: () => const Login()),
            GetPage(name: '/signup', page: () => const Signup()),
            GetPage(name: '/forget', page: () => const ForgetPassword()),
            GetPage(
              name: '/forgot-password',
              page: () => const ForgotPasswordPage(),
            ),
            GetPage(
              name: '/reset-password',
              page: () {
                final token = Get.parameters['token'] ?? '';
                return ResetPasswordPage(token: token);
              },
            ),
            GetPage(name: '/dashboard', page: () => const DashboardPage()),
            GetPage(name: '/home', page: () => const HomeView()),
            GetPage(name: '/profile', page: () => const ProfilePage()),
            GetPage(
              name: '/add-worker',
              page: () => const AddWorkerPresentation(),
            ),
          ],
        ),
      ),
    );
  }
}
