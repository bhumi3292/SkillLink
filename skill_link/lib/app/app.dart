import 'package:skill_link/features/admin/presentation/view/admin_bookings_view.dart';
import 'package:skill_link/features/admin/presentation/view/dispute_resolution_view.dart';
import 'package:skill_link/features/admin/presentation/view/user_directory_view.dart';
import 'package:skill_link/features/admin/presentation/view/category_management_view.dart';
import 'package:skill_link/features/admin/presentation/view/admin_dashboard.dart';
import 'package:skill_link/features/admin/presentation/banner/banner_list_page.dart';
import 'package:skill_link/features/admin/presentation/view/worker_verification_list_page.dart';
import 'package:skill_link/features/admin/presentation/view/worker_verification_detail_page.dart';
import 'package:skill_link/features/admin/presentation/view/admin_payments_view.dart';
import 'package:skill_link/features/profile/presentation/view/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:skill_link/cores/localization/app_translations.dart';
import 'package:skill_link/cores/localization/localization_service.dart';
import 'dart:async';

import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/admin/presentation/view_model/admin_cubit.dart';
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
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';

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
            GetPage(
              name: '/admin/dashboard',
              page: () => const AdminDashboard(),
            ),
            GetPage(
              name: '/admin/worker-requests',
              page: () => const WorkerVerificationListPage(),
            ),
            GetPage(
              name: '/admin/workers/detail',
              page: () {
                final args = Get.arguments;
                if (args is ExploreWorkerEntity) {
                  return WorkerVerificationDetailPage(worker: args);
                }
                return const Scaffold(
                  body: Center(child: Text("Invalid Arguments")),
                );
              },
            ),
            GetPage(
              name: '/admin/categories',
              page: () => const CategoryManagementView(),
            ),
            GetPage(
              name: '/admin/users',
              page: () => const UserDirectoryView(),
            ),
            GetPage(
              name: '/admin/disputes',
              page: () => const DisputeResolutionView(),
            ),
            GetPage(
              name: '/admin/bookings',
              page: () => const AdminBookingsView(),
            ),
            GetPage(
              name: '/admin/banners',
              page:
                  () => BlocProvider(
                    create:
                        (context) =>
                            serviceLocator<AdminCubit>()..fetchAllBanners(),
                    child: const AdminBannerListPage(),
                  ),
            ),
            GetPage(
              name: '/payment-history',
              page: () => const AdminPaymentsView(),
            ),
            GetPage(
              name: '/admin/payments',
              page: () => const AdminPaymentsView(),
            ),
          ],
        ),
      ),
    );
  }
}
