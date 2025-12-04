import 'package:flutter/material.dart';
import 'package:skill_link/features/profile/presentation/view/edit_profile_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        title: const Text('Settings'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preferences', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: _notificationsEnabled,
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                    title: const Text('Enable Notifications'),
                    secondary: const Icon(Icons.notifications_active_outlined),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: _darkModeEnabled,
                    onChanged: (val) => setState(() => _darkModeEnabled = val),
                    title: const Text('Dark Mode'),
                    secondary: const Icon(Icons.dark_mode_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Account & Privacy', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: _privateAccount,
                    onChanged: (val) => setState(() => _privateAccount = val),
                    title: const Text('Private Account'),
                    secondary: const Icon(Icons.lock_outline),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.password_outlined),
                    title: const Text('Change Password'),
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
                          const SnackBar(content: Text('User not found. Please try again.'), backgroundColor: Colors.red),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
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
                    const SnackBar(content: Text('Settings saved!'), backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 