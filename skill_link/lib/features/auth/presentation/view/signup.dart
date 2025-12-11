import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:skill_link/features/auth/presentation/view_model/register_view_model/register_event.dart';
import 'package:skill_link/features/auth/presentation/view_model/register_view_model/register_state.dart';
import 'package:skill_link/features/auth/presentation/view_model/register_view_model/register_view_model.dart';
import 'package:skill_link/cores/common/snackbar/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for the form fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedStakeholder;
  String _selectedCountryCode = '+977';
  String? _errorMessage;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final List<String> _stakeholders = ['Hirer', 'Worker'];
  final Color navyBlue = const Color(0xFF003366);

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _confirmPasswordVisible = !_confirmPasswordVisible;
    });
  }

  void _selectStakeholder(String? value) {
    setState(() {
      _selectedStakeholder = value;
    });
  }

  String? _validateFullName(String? value) =>
      (value == null || value.isEmpty) ? 'Enter your full name' : null;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // phone validation is handled by the phone field's validator

  String? _validateStakeholder(String? value) =>
      (value == null || value.isEmpty) ? 'Please select a role' : null;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool _passwordsMatch() =>
      _passwordController.text == _confirmPasswordController.text;

  void _onSignupPressed() {
    setState(() {
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      if (!_passwordsMatch()) {
        setState(() {
          _errorMessage = '⚠️ Passwords do not match.';
        });
        return;
      }

      context.read<RegisterUserViewModel>().add(
        RegisterNewUserEvent(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber:
              _selectedCountryCode + _phoneNumberController.text.trim(),
          stakeholder: _selectedStakeholder!.toLowerCase(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          context: context,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      errorText:
          (label == "Password" || label == "Confirm Password") &&
                  _errorMessage != null &&
                  !_passwordsMatch()
              ? _errorMessage
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<RegisterUserViewModel, RegisterUserState>(
        listener: (context, state) {
          if (state.isSuccess) {
            showMySnackbar(
              context: context,
              content: 'User registered successfully! Please log in.',
              isSuccess: true,
            );
            Navigator.pushReplacementNamed(context, '/login');
          } else if (state.errorMessage != null && !state.isLoading) {
            showMySnackbar(
              context: context,
              content: state.errorMessage!,
              isSuccess: false,
            );
            // keep prints for now; will clean avoid_print warnings later
            // ignore: avoid_print
            print("Registration Error (from BLoC): ${state.errorMessage}");
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/logo.png", height: 80),
                    const SizedBox(height: 20),
                    Text(
                      "SkillLink",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: navyBlue,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Create your account",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Full Name
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                        controller: _fullNameController,
                        decoration: _inputDecoration(
                          "Full Name",
                          Icons.person_outline,
                        ),
                        validator: _validateFullName,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Email
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: _inputDecoration(
                          "E-mail",
                          Icons.email_outlined,
                        ),
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Phone Number (intl_phone_field)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: IntlPhoneField(
                        controller: _phoneNumberController,
                        decoration: _inputDecoration(
                          "Phone Number",
                          Icons.phone_outlined,
                        ),
                        initialCountryCode:
                            _selectedCountryCode.replaceAll('+', '') == '977'
                                ? 'NP'
                                : null,
                        onCountryChanged: (country) {
                          setState(() {
                            _selectedCountryCode = '+${country.dialCode}';
                          });
                        },
                        onChanged: (phone) {
                          _phoneNumberController.text = phone.number;
                          setState(() {
                            _selectedCountryCode = '+${phone.countryCode}';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.number.isEmpty) {
                            return 'Enter your phone number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Stakeholder Dropdown
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedStakeholder,
                        decoration: _inputDecoration(
                          "Stake Holder",
                          Icons.person_pin,
                        ),
                        items:
                            _stakeholders.map((stakeholder) {
                              return DropdownMenuItem(
                                value: stakeholder,
                                child: Text(stakeholder),
                              );
                            }).toList(),
                        onChanged: _selectStakeholder,
                        validator: _validateStakeholder,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Password
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        decoration: _inputDecoration(
                          "Password",
                          Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Confirm Password
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_confirmPasswordVisible,
                        decoration: _inputDecoration(
                          "Confirm Password",
                          Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: _toggleConfirmPasswordVisibility,
                          ),
                        ),
                        validator: _validateConfirmPassword,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                    ],

                    state.isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _onSignupPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: navyBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Signup",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                    const SizedBox(height: 15),

                    // Login Redirect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: navyBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Connect with us",
                        style: TextStyle(
                          color: navyBlue,
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
}
