import 'package:skill_link/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:skill_link/features/auth/presentation/view_model/login_view_model/login_state.dart';
import 'package:skill_link/features/auth/presentation/view_model/login_view_model/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:skill_link/view/homeView.dart';
import 'package:skill_link/cores/common/snackbar/snackbar.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_event.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'dart:async';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? selectedStakeholder;
  final List<String> stakeholders = ['worker', 'hirer'];
  bool _passwordVisible = false;

  StreamSubscription<dynamic>? _proximitySubscription;
  bool _isProximityLoginTriggered = false;

  @override
  void initState() {
    super.initState();
    _proximitySubscription = ProximitySensor.events.listen((int event) {
      if (event > 0 && !_isProximityLoginTriggered) {
        _handleLogin();
        // Reset after a short delay to allow for next login
        Future.delayed(const Duration(seconds: 2), () {
          _isProximityLoginTriggered = false;
        });
      } else if (event == 0) {
        _isProximityLoginTriggered = false;
      }
    });
  }

  @override
  void dispose() {
    _proximitySubscription?.cancel();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Super Admin bypass
      if (email == "bhumisubedi2018@gmail.com") {
        context.read<LoginViewModel>().add(
          LoginWithEmailAndPasswordEvent(
            username: email,
            password: password,
            stakeholder: "admin",
          ),
        );
        return;
      }

      final stakeholder = selectedStakeholder;

      if (stakeholder != null) {
        context.read<LoginViewModel>().add(
          LoginWithEmailAndPasswordEvent(
            username: email,
            password: password,
            stakeholder: stakeholder.toLowerCase(),
          ),
        );
      } else {
        showMySnackbar(
          context: context,
          content: 'select_stakeholder'.tr,
          isSuccess: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<LoginViewModel, LoginState>(
        listener: (context, state) {
          // Only react when not loading
          if (state.isLoading) return;

          // On success: show success message and navigate to Dashboard
          if (state.isSuccess) {
            showMySnackbar(
              context: context,
              content: 'login_success'.tr,
              isSuccess: true,
            );
            // fetch profile then navigate
            context.read<ProfileViewModel>().add(
              FetchUserProfileEvent(context: context),
            );
            if (state.role == 'admin') {
              Navigator.pushReplacementNamed(context, '/admin/dashboard');
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeView(initialIndex: 0),
                ),
              );
            }
            return;
          }

          // On failure: show error toast, do NOT navigate to signup
          if (!state.isSuccess && state.error != null) {
            showMySnackbar(
              context: context,
              content: '⚠️ ${state.error}',
              isSuccess: false,
            );
            return;
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset("assets/images/logo.png", height: 80),
                    const SizedBox(height: 20),
                    Text(
                      "SkillLink",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "welcome_back".tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration(
                        "email".tr,
                        Icons.email_outlined,
                      ),
                      validator:
                          (value) => value!.isEmpty ? 'email_error'.tr : null,
                    ),
                    const SizedBox(height: 15),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: "password".tr,
                        prefixIcon: const Icon(Icons.lock_outline),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      validator:
                          (value) =>
                              value!.isEmpty ? 'password_error'.tr : null,
                    ),
                    const SizedBox(height: 15),

                    // Stakeholder Dropdown
                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration(
                        "stakeholder".tr,
                        Icons.person_outline,
                      ),
                      initialValue: selectedStakeholder,
                      items:
                          stakeholders.map((stakeholder) {
                            return DropdownMenuItem(
                              value: stakeholder,
                              child: Text(stakeholder.tr),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStakeholder = value;
                        });
                      },
                      validator:
                          (value) => value == null ? 'role_error'.tr : null,
                    ),
                    const SizedBox(height: 25),

                    // Login Button (styled from global theme)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _handleLogin,
                        child:
                            state.isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(
                                  "login".tr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Forgot Password
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: Text(
                          "forgot_password".tr,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Signup Redirect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("no_account".tr),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            "signup".tr,
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "connect_with_us".tr,
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/fb.png", height: 30),
                        const SizedBox(width: 10),
                        Image.asset("assets/images/google.png", height: 30),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
