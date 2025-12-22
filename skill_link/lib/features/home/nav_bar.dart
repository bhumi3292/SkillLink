import 'package:skill_link/features/add_worker/presentation/view/add_worker_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/dashbaord/presentation/view/dashboard.dart';
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

  void _onItemTapped(int index, bool isWorker) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const DashboardPage();
        break;
      case 1:
        nextPage = BlocProvider(create: (context) => serviceLocator<ExploreBloc>(), child: const ExplorePage());
        break;
      case 2:
        final user = context.read<ProfileViewModel>().state.user;
        nextPage = ChatPage(currentUserId: user?.userId ?? '');
        break;
      case 3:
        if (isWorker) {
          nextPage = const AddWorkerPresentation();
        } else {
          nextPage = const FavouritePage();
        }
        break;
      case 4:
        if (isWorker) {
          nextPage = const FavouritePage();
        } else {
          nextPage = const BookingPage();
        }
        break;
      case 5:
        if (isWorker) {
          nextPage = const BookingPage();
        } else {
          nextPage = const ProfilePage();
        }
        break;
      case 6:
        nextPage = const ProfilePage();
        break;
      default:
        nextPage = const DashboardPage();
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
        final isWorker = user?.stakeholder?.trim().toLowerCase() == 'worker';

        final items = <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          const BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: 'Message'),
          if (isWorker)
            const BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add Worker'),
          const BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favourite'),
          const BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Booking'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];

        return BottomNavigationBar(
          backgroundColor: const Color(0xFF807B7B),
          currentIndex: _selectedIndex.clamp(0, items.length - 1),
          selectedItemColor: const Color(0xFF003366),
          unselectedItemColor: Colors.grey,
          onTap: (index) => _onItemTapped(index, isWorker),
          items: items,
          type: BottomNavigationBarType.fixed, // Use fixed type for more than 3 items
        );
      },
    );
  }
}
