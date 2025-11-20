import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'customer_home_screen.dart';
import 'customer_rewards_screen.dart';
import 'customer_coupons_screen.dart';
import 'customer_history_screen.dart';
import 'customer_profile_screen.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      CustomerHomeScreen(onNavigateToTab: _navigateToTab),
      const CustomerRewardsScreen(),
      const CustomerCouponsScreen(),
      const CustomerHistoryScreen(),
      const CustomerProfileScreen(),
    ];
  }
  
  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF15151E),
          border: Border(
            top: BorderSide(color: Color(0xFF2A2A35), width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: const Color(0xFF00C2FF).withOpacity(0.2),
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home,
                color: _currentIndex == 0 ? const Color(0xFF00C2FF) : const Color(0xFFA0A0B5),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.card_giftcard,
                color: _currentIndex == 1 ? const Color(0xFF00C2FF) : const Color(0xFFA0A0B5),
              ),
              label: 'Rewards',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.receipt_long,
                color: _currentIndex == 2 ? const Color(0xFF00C2FF) : const Color(0xFFA0A0B5),
              ),
              label: 'Coupons',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.history,
                color: _currentIndex == 3 ? const Color(0xFF00C2FF) : const Color(0xFFA0A0B5),
              ),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person,
                color: _currentIndex == 4 ? const Color(0xFF00C2FF) : const Color(0xFFA0A0B5),
              ),
              label: 'Profile',
            ),
          ],
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
    );
  }
}