import 'package:flutter/material.dart';
import 'package:local_community_marketplace/screens/profile_screen.dart';
import 'package:local_community_marketplace/screens/home_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  const BottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        break;
      case 1:
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
        break;
      case 2:
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PostScreen()));
        break;
      case 3:
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        break;
      case 4:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      backgroundColor: const Color(0xFFE0F3F7),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icons/home.png'),
            size: 20,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icons/bell.png'),
            size: 20,
          ),
          label: 'Notification',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icons/more.png'),
            size: 20,
          ),
          label: 'Post',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icons/comment.png'),
            size: 20,
          ),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icons/user.png'),
            size: 20,
          ),
          label: 'User',
        ),
      ],
    );
  }
}
