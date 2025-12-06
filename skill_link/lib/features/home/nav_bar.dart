import 'package:skill_link/features/add_property/presentation/view/add_property_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link'
    '/features/dashbaord/presentation/view/dashboard.dart';
import 'package:skill_link/features/explore/presentation/view/explore_page.dart';
import 'package:skill_link/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:skill_link/features/favourite/presentation/pages/favourite_page.dart';
import 'package:skill_link/features/booking/presentation/view/booking_page.dart';
import 'package:skill_link/features/profile/presentation/view/profile.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/chat/presentation/page/chat_page.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_state.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index, bool isworker, List<Widget> pages) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    if (index < 0 || index >= pages.length) return;

    final nextPage = pages[index];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileViewModel, ProfileState>(
      builder: (context, state) {
        final user = state.user;
        final isworker = user?.stakeholder?.trim().toLowerCase() == 'worker';
        final items = <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          // Message/chat item
          const BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Message',
          ),
          if (isworker)
            const BottomNavigationBarItem(
              icon: Icon(Icons.add_box),
              label: 'Add Property',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favourite',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Booking',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];

        // Build pages in the same order as items so the index maps directly
        final pages = <Widget>[
          const DashboardPage(),
          BlocProvider(
            create: (context) => serviceLocator<ExploreBloc>(),
            child: const ExplorePage(),
          ),
          // Message page expects currentUserId; provide from profile state if available
          ChatPage(currentUserId: user?.userId ?? ''),
          if (isworker) const AddPropertyPresentation(),
          const FavouritePage(),
          const BookingPage(),
          const ProfilePage(),
        ];

        return BottomNavigationBar(
          backgroundColor: const Color(0xFF807B7B),
          currentIndex: _selectedIndex.clamp(0, items.length - 1),
          selectedItemColor: const Color(0xFF003366),
          unselectedItemColor: Colors.grey,
          onTap: (index) => _onItemTapped(index, isworker, pages),
          items: items,
        );
      },
    );
  }
}
