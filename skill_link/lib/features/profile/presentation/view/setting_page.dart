import 'package:flutter/material.dart';
import 'package:skill_link/features/profile/presentation/view/edit_profile_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:skill_link/cores/localization/localization_service.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _privateAccount = false;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('preferences'.tr, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: _notificationsEnabled,
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                    title: Text('enable_notifications'.tr),
                    secondary: const Icon(Icons.notifications_active_outlined),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: _darkModeEnabled,
                    onChanged: (val) => setState(() => _darkModeEnabled = val),
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
                          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () => _showLanguagePicker(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('account_settings'.tr, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: _privateAccount,
                    onChanged: (val) => setState(() => _privateAccount = val),
                    title: Text('private_account'.tr),
                    secondary: const Icon(Icons.lock_outline),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.password_outlined),
                    title: Text('change_password'.tr),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      final user = context.read<ProfileViewModel>().state.user;
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(user: user),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('User not found. Please try again.'), backgroundColor: Colors.red),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: Text('delete_account'.tr, style: const TextStyle(color: Colors.red)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                    onTap: () {
                      // TODO: Handle account deletion
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Delete Account tapped!'), backgroundColor: Colors.red),
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
                onPressed: () {
                  // TODO: Save settings to backend or local storage
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('save_changes'.tr), backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('save_changes'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
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