import 'package:flutter/material.dart';
import 'package:local_community_marketplace/components/navigation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
      backgroundColor: const Color(0xFFE0F3F7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFE0F3F7),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'User',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      Text(
                        'Natcha Laepankaew',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'User ID\n12345678',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Add edit profile action
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD1E9F2),
                      foregroundColor: Colors.black,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text("Purchase History"),
                    onTap: () {
                      // TODO: Navigate to Purchase History
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.store),
                    title: const Text("My Store"),
                    onTap: () {
                      // TODO: Navigate to My Store
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite_border),
                    title: const Text("My favorites"),
                    onTap: () {
                      // TODO: Navigate to Favorites
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Add log out logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD1E9F2),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        child: Text('Log Out'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
