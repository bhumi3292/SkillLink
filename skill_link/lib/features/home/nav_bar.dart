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
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_state.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index, bool isworker) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    Widget nextPage;

    // Adjust index if Add Property is present
    int adjustedIndex = index;
    if (isworker && index > 1) adjustedIndex = index - 1;

    switch (adjustedIndex) {
      case 0:
        nextPage = const DashboardPage();
        break;
      case 1:
        nextPage = BlocProvider(
          create: (context) => serviceLocator<ExploreBloc>(),
          child: const ExplorePage(),
        );
        break;
      case 2:
        nextPage = const FavouritePage();
        break;
      case 3:
        nextPage = const BookingPage();
        break;
      case 4:
        nextPage = const ProfilePage();
        break;
      default:
        return;
    }

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
        return BottomNavigationBar(
          backgroundColor: const Color(0xFF807B7B),
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF003366),
          unselectedItemColor: Colors.grey,
          onTap: (index) => _onItemTapped(index, isworker),
          items: items,
        );
      },
    );
  }
}
