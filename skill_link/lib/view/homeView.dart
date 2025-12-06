import 'package:skill_link/features/chat/presentation/page/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import flutter_bloc

// Import your HeaderNav widget
import 'package:skill_link/features/home/header_nav.dart'; // Ensure this path is correct

// Import your BLoC and State for user profile
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_event.dart'; // Needed to dispatch event
import 'package:skill_link/features/profile/presentation/view_model/profile_state.dart';

// Other page imports for BottomNavigationBar
import 'package:skill_link/features/dashbaord/presentation/view/dashboard.dart';
import 'package:skill_link/features/explore/presentation/view/explore_page.dart';
import 'package:skill_link/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:skill_link/features/booking/presentation/view/booking_page.dart';
import 'package:skill_link/features/profile/presentation/view/profile.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';

class HomeView extends StatefulWidget {
  final int initialIndex;

  const HomeView({super.key, this.initialIndex = 0});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  bool _initialProfileHandled = false;
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    // Request profile load so HeaderNav and Chat can get current user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().add(
        FetchUserProfileEvent(context: context),
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<ProfileViewModel, dynamic>(
      (vm) => vm.state.user,
    );

    final List<Widget> pages = [
      DashboardPage(onSeeAllTap: () => _onItemTapped(1)),
      BlocProvider(
        create: (context) => serviceLocator<ExploreBloc>(),
        child: const ExplorePage(),
      ),
      // Message tab -> Chat page
      ChatPage(currentUserId: user?.userId ?? ''),
      const BookingPage(),
      const ProfilePage(),
    ];

    return BlocListener<ProfileViewModel, ProfileState>(
      listener: (context, state) {
        // Only on the first time the profile becomes available, set the initial index.
        // This avoids forcing the UI back to Home if the user manually navigates (e.g., taps Profile).
        if (!_initialProfileHandled && state.user != null) {
          _initialProfileHandled = true;
          if (_selectedIndex != widget.initialIndex) {
            setState(() {
              _selectedIndex = widget.initialIndex;
            });
          }
        }
      },
      child: Scaffold(
        appBar: HeaderNav(
          user: context.select<ProfileViewModel, dynamic>(
            (vm) => vm.state.user,
          ),
        ),
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          elevation: 12,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF003366),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_outlined),
              label: 'Message',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_online),
              label: 'Booking',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
