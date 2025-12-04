import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skill_link/features/splash_screen/presentation/widgets/theme.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _updatePassword() {
    if (_formKey.currentState!.validate()) {
      // Handle password update logic here
      Get.snackbar(
        "Success",
        "Password updated successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: navyBlue,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: getApplication(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Reset Password"),
          backgroundColor: navyBlue,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                  value == null || !value.contains('@') ? 'Enter valid email' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) =>
                  value != null && value.length < 6 ? 'Password too short' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) =>
                  value != _newPasswordController.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _updatePassword,
                  child: const Text("Update Password"),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Get.toNamed('/login');
                  },
                  child: const Text(
                    "Go back to Login",
                    style: TextStyle(color: navyBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
