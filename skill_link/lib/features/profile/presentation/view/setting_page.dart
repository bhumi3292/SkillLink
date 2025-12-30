import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:skill_link/cores/localization/localization_service.dart';
import 'package:skill_link/features/auth/domain/entity/user_entity.dart';

import 'package:skill_link/features/profile/presentation/view/edit_worker_profile_page.dart';
import 'package:skill_link/features/profile/presentation/view/edit_profile_page.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_event.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_state.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:skill_link/features/auth/presentation/view/login.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<ProfileViewModel, ProfileState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red),
            );
          }
          if (state.isLogoutSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          final user = state.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('preferences'.tr,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('enable_notifications'.tr),
                        leading: const Icon(Icons.notifications_active_outlined),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _showNotificationPreferencesDialog(context, user),
                      ),
                      const Divider(height: 1),
                      SwitchListTile.adaptive(
                        value: _darkModeEnabled,
                        onChanged: (val) =>
                            setState(() => _darkModeEnabled = val),
                        title: Text('dark_mode'.tr),
                        secondary: const Icon(Icons.dark_mode_outlined),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.language_outlined),
                        title: Text('language'.tr),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              LocalizationService.to.getCurrentLanguageName(),
                              style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                        onTap: () => _showLanguagePicker(context),
                      ),
                    ],
                  ),
                ),
                if (user?.stakeholder == 'Worker' && user?.workerProfileId != null) ...[
                  const SizedBox(height: 28),
                  Text('Service Management',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.work_outline),
                      title: const Text('Edit Service Details'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditWorkerProfilePage(
                              workerProfileId: user!.workerProfileId!,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                Text('account_settings'.tr,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.password_outlined),
                        title: Text('change_password'.tr),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          if (user != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(user: user),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('User not found. Please try again.'),
                                  backgroundColor: Colors.red),
                            );
                          }
                        },
                      ),
                      const Divider(height: 1),
                       ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text('Privacy & Security'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showPrivacySecurityDialog(context);
                        },
                      ),
                       const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: const Text('Terms & Conditions'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Navigate to Terms & Conditions')),
                            );
                        },
                      ),
                       const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.security_outlined),
                        title: const Text('Privacy Policy'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Navigate to Privacy Policy')),
                            );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showLogoutDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('logout'.tr,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showNotificationPreferencesDialog(BuildContext context, UserEntity? user) {
    if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User data not loaded")));
        return;
    }
    
    // Default to true if preferences are null
    bool push = user.notificationPreferences?.push ?? true;
    bool booking = user.notificationPreferences?.booking ?? true;
    bool chat = user.notificationPreferences?.chat ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('enable_notifications'.tr),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   SwitchListTile(
                    title: const Text("Push Notifications"),
                    value: push,
                    onChanged: (val) => setState(() => push = val),
                  ),
                   SwitchListTile(
                    title: const Text("Booking Notifications"),
                    value: booking,
                    onChanged: (val) => setState(() => booking = val),
                  ),
                   SwitchListTile(
                    title: const Text("Chat Notifications"),
                    value: chat,
                    onChanged: (val) => setState(() => chat = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('cancel'.tr),
                ),
                TextButton(
                  onPressed: () {
                     context.read<ProfileViewModel>().add(
                        UpdateNotificationPreferencesEvent(
                          context: context,
                          push: push,
                          booking: booking,
                          chat: chat,
                        ),
                      );
                    Navigator.pop(context);
                  },
                  child: Text('save'.tr),
                ),
              ],
            );
          },
        );
      },
    );
  }

    void _showPrivacySecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Privacy & Security'),
          children: [
             SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                final user = context.read<ProfileViewModel>().state.user;
                if(user != null){
                     Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(user: user),
                          ),
                        );
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Change Password'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out from all devices (This feature requires backend session tracking)')),
                  );
                 // Call LogoutEvent just to be safe if desired, or assume implemented later
              },
               child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Logout from all devices', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('logout'.tr),
          content: Text('logout_confirm'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context.read<ProfileViewModel>().add(LogoutEvent(context: context));
              },
              child: Text('logout'.tr, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'choose_language'.tr,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildLanguageOption(
                context,
                'English',
                const Locale('en', 'US'),
              ),
              _buildLanguageOption(
                context,
                'नेपाली',
                const Locale('ne', 'NP'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, Locale locale) {
    final isSelected = LocalizationService.to.currentLocale.languageCode == locale.languageCode;
    return ListTile(
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
      onTap: () {
        LocalizationService.to.changeLocale(locale);
        Navigator.pop(context);
        setState(() {}); // Refresh setting page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('lang_updated'.tr),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }
}