import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/auth/presentation/view/login.dart';
import 'package:skill_link/features/auth/presentation/view_model/login_view_model/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashViewModel extends Cubit<void> {
  SplashViewModel() : super(null);

  // Open Login View after 2 seconds
  Future<void> init(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2), () async {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => serviceLocator<LoginViewModel>(),
              child: Login(),
            ),
          ),
        );
      }
    });
  }
}
