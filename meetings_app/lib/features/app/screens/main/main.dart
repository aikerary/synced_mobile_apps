import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meetings_app/features/app/screens/home/home.dart';
import 'package:meetings_app/features/app/screens/calendar/calendar.dart';
import 'package:meetings_app/features/app/screens/subscriptions/subscriptions.dart';
import 'package:meetings_app/features/app/screens/speakers/speakers_screen.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Agregamos la nueva pestaña de Speakers.
  final List<Widget> _pages = const [
    HomeScreen(),
    CalendarScreen(),
    SubscriptionsScreen(),
    SpeakersScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Permite más de 3 tabs
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: dark ? LColors.light : LColors.dark,
        unselectedItemColor: dark ? LColors.textWhite : LColors.darkGrey,
        backgroundColor: dark ? LColors.dark : LColors.light,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            activeIcon: Icon(Iconsax.home_2),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.calendar_1),
            activeIcon: Icon(Iconsax.calendar),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.notification),
            activeIcon: Icon(Iconsax.notification5),
            label: 'Suscripciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.people),
            activeIcon: Icon(Iconsax.profile_2user),
            label: 'Speakers',
          ),
        ],
      ),
    );
  }
}
