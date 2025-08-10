import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart'; // สำหรับการโหลด locale ภาษาไทย
import 'firebase_options.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/login_phone_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/post/post_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/post/post_form_screen.dart';
import 'screens/favorite_screen.dart';
import 'screens/post/choose_photo_screen.dart';
import 'screens/post/edit_post_form_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/notification/notification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // โหลด locale ภาษาไทย (หรือจะใส่ null เพื่อโหลดทุกภาษา)
  await initializeDateFormatting('th', null);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/loginphone',
          builder: (context, state) => LoginPhoneScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/post',
          builder: (context, state) => const PostScreen(),
        ),
        GoRoute(
          path: '/edit_profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/postform',
          builder: (context, state) => const PostFormScreen(),
        ),
        GoRoute(
          path: '/favorite',
          builder: (context, state) => const FavoriteScreen(),
        ),
        GoRoute(
          path: '/choose_photo',
          builder: (context, state) => const ChoosePhotoScreen(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatScreen(),
        ),
        GoRoute(
          path: '/notification',
          builder: (context, state) => const NotificationScreen(),
        ),
        GoRoute(
          path: '/postedit/:id',
          builder: (context, state) {
            final postId = state.pathParameters['id']!;
            return EditPostFormScreen(postId: postId);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Local Community Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
