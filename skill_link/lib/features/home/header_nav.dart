import 'package:flutter/material.dart';
import 'package:skill_link/features/auth/domain/entity/user_entity.dart'; // Import UserEntity
import 'package:skill_link/features/add_property/presentation/view/add_worker_presentation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeaderNav extends StatefulWidget implements PreferredSizeWidget {
  final UserEntity? user;
  final VoidCallback? onworkerHomePressed;

  const HeaderNav({super.key, this.user, this.onworkerHomePressed});

  @override
  State<HeaderNav> createState() => _HeaderNavState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Standard AppBar height
}

class _HeaderNavState extends State<HeaderNav> {
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Prefer role from the provided user entity (if any), otherwise fall back
    // to the value loaded from SharedPreferences.
    final stakeholderFromUser = widget.user?.stakeholder?.trim().toLowerCase();
    final effectiveRole =
        (stakeholderFromUser != null && stakeholderFromUser.isNotEmpty)
            ? stakeholderFromUser
            : _role?.trim().toLowerCase();
    debugPrint('HeaderNav effectiveRole: $effectiveRole');
    return AppBar(
      backgroundColor: const Color(0xFF003366),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          debugPrint("Menu button pressed");
        },
      ),
      centerTitle: true,
      actions: [
        if (effectiveRole == 'worker')
          IconButton(
            icon: const Icon(Icons.add_home_work_outlined, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddWorkerPresentation(),
                ),
              );
              widget.onworkerHomePressed?.call();
              debugPrint("worker Home icon pressed (via callback)");
            },
          ),
        // Chat icon removed from header; message/chat is accessible from bottom navigation
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {
            debugPrint("Notifications button pressed");
          },
        ),
      ],
    );
  }
}
