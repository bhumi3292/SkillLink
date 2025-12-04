import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/auth/domain/entity/user_entity.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_event.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_state.dart';
import 'package:skill_link/cores/common/snackbar/snackbar.dart';
// Make sure this import exists and points to your ImageUrlHelper file
// If you don't have one, you should create it as discussed previously.
import 'package:skill_link/cores/utils/image_url_helper.dart';


class EditProfilePage extends StatefulWidget {
  final UserEntity user;

  const EditProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          BlocBuilder<ProfileViewModel, ProfileState>(
            builder: (context, state) {
              return TextButton(
                onPressed: state.isLoading ? null : _saveChanges,
                child: const Text( // Changed to const
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileViewModel, ProfileState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            print("Edit profile page - Success message received: ${state.successMessage}"); // Debug print
            print("Edit profile page - Current user: ${state.user?.fullName}"); // Debug print
            showMySnackbar(
              context: context,
              content: state.successMessage!,
              isSuccess: true,
            );
            // Navigate back after successful update
            Navigator.pop(context, true);
          }
          if (state.errorMessage != null) {
            showMySnackbar(
              context: context,
              content: state.errorMessage!,
              isSuccess: false,
            );
          }
        },
        builder: (context, state) {
          _isLoading = state.isLoading;

          // Update controllers if user data has changed
          if (state.user != null &&
              (_fullNameController.text != state.user!.fullName ||
                  _emailController.text != state.user!.email ||
                  _phoneController.text != (state.user!.phoneNumber ?? ''))) {
            print("Edit profile page - Updating controllers with new data: ${state.user!.fullName}"); // Debug print
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _fullNameController.text = state.user!.fullName;
                  _emailController.text = state.user!.email;
                  _phoneController.text = state.user!.phoneNumber ?? '';
                });
              }
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          // Corrected line 143: Use ImageUrlHelper for consistent URL construction
                          // This ensures you use the base URL from ApiEndpoints.imageUrl
                          backgroundImage: (state.user?.profilePicture != null && state.user!.profilePicture!.isNotEmpty)
                              ? NetworkImage(ImageUrlHelper.constructImageUrl(state.user!.profilePicture))
                              : (widget.user.profilePicture != null && widget.user.profilePicture!.isNotEmpty)
                              ? NetworkImage(ImageUrlHelper.constructImageUrl(widget.user.profilePicture))
                              : null,
                          child: (state.user?.profilePicture == null || state.user!.profilePicture!.isEmpty) &&
                              (widget.user.profilePicture == null || widget.user.profilePicture!.isEmpty)
                              ? const Icon(Icons.person, size: 50, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Profile Picture',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the camera icon in the profile page to update your picture',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Personal Information Section
                  _buildSectionTitle('Personal Information'),
                  const SizedBox(height: 16),

                  // Full Name
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Full name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Full name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Email
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Phone Number
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (value.length < 10) {
                          return 'Phone number must be at least 10 digits';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Change Password Section
                  _buildSectionTitle('Change Password'),
                  const SizedBox(height: 8),

                  Text(
                    'Leave password fields empty if you don\'t want to change your password',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Current Password
                  _buildTextField(
                    controller: _currentPasswordController,
                    label: 'Current Password',
                    icon: Icons.lock,
                    obscureText: _obscureCurrentPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (_newPasswordController.text.isNotEmpty || _confirmPasswordController.text.isNotEmpty) {
                        if (value == null || value.isEmpty) {
                          return 'Current password is required to change password';
                        }
                        if (value.length < 6) {
                          return 'Current password must be at least 6 characters';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // New Password
                  _buildTextField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscureNewPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (value.length < 6) {
                          return 'New password must be at least 6 characters';
                        }
                        if (_confirmPasswordController.text.isNotEmpty &&
                            value != _confirmPasswordController.text) {
                          return 'New passwords do not match';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Confirm New Password
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (_newPasswordController.text.isNotEmpty) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF002B5B),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedName = _fullNameController.text.trim();
      final updatedEmail = _emailController.text.trim();
      final updatedPhone = _phoneController.text.trim();
      final currentPassword = _currentPasswordController.text;
      final newPassword = _newPasswordController.text;
      final confirmPassword = _confirmPasswordController.text;

      // Check if password fields are filled
      bool isChangingPassword = newPassword.isNotEmpty || confirmPassword.isNotEmpty;

      if (isChangingPassword) {
        // Validate password change
        if (currentPassword.isEmpty) {
          showMySnackbar(
            context: context,
            content: "Current password is required to change password",
            isSuccess: false,
          );
          return;
        }
        if (newPassword.isEmpty) {
          showMySnackbar(
            context: context,
            content: "New password is required",
            isSuccess: false,
          );
          return;
        }
        if (newPassword != confirmPassword) {
          showMySnackbar(
            context: context,
            content: "New passwords do not match",
            isSuccess: false,
          );
          return;
        }
      }

      // Send update event
      context.read<ProfileViewModel>().add(
        UpdateUserProfileEvent(
          context: context,
          fullName: updatedName,
          email: updatedEmail,
          phoneNumber: updatedPhone.isNotEmpty ? updatedPhone : null,
          currentPassword: currentPassword.isNotEmpty ? currentPassword : null,
          newPassword: newPassword.isNotEmpty ? newPassword : null,
        ),
      );
    }
  }
}