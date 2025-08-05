import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
      'title': 'Trusted Community',
      'desc':
          'Every user verifies their identity and address to ensure a safe and reliable experience',
      'image': 'assets/onboarding/onboarding-1.png',
    },
    {
      'title': 'Easy Item Listings',
      'desc':
          'Snap a photo, set your price, write details, and choose a category',
      'image': 'assets/onboarding/onboarding-2.png',
    },
    {
      'title': 'Smart Search & Chat',
      'desc':
          'Filter by category, price, or distance and chat with sellers in-app',
      'image': 'assets/onboarding/onboarding-3.png',
    },
    {
      'title': 'Get Started',
      'desc': 'Discover great deals and connect with people near you',
      'image': 'assets/onboarding/onboarding-4.png',
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    context.go('/home');
  }

  void _nextPage() {
    if (_currentIndex == pages.length - 1) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background
          Positioned.fill(
            child: Image.asset(
              'assets/onboarding/onboarding_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final item = pages[index];
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(item['image']!, height: 300),
                    const SizedBox(height: 30),
                    Text(item['title']!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )),
                    const SizedBox(height: 16),
                    Text(
                      item['desc']!,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              );
            },
          ),
          // 🔹 Next Button
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0F3F7),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _currentIndex == pages.length - 1 ? 'Get Started' : 'Next',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }
}
