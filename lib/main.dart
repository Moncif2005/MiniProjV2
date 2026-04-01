import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:minipr/firebase_options.dart';
import 'package:minipr/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/auth/create_account_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/offers_screen.dart';
import 'screens/home/learn_screen.dart';
import 'screens/learn/lesson_screen.dart';
import 'screens/notification/notification_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/certificates_screen.dart';
import 'screens/profile/applied_jobs_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/profile/learning_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Formanova',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      initialRoute: '/signup',
      routes: {
        '/signup':          (context) => const SignUpScreen(),
        '/create-account':  (context) => const CreateAccountScreen(),
        '/home':            (context) => const HomeScreen(),
        '/offers':          (context) => const OffersScreen(),
        '/learn':           (context) => const LearnScreen(),
        '/lesson':          (context) => const LessonScreen(),
        '/notifications':   (context) => const NotificationScreen(),
        '/profile':         (context) => const ProfileScreen(),
        '/edit-profile':    (context) => const EditProfileScreen(),
        '/certificates':    (context) => const CertificatesScreen(),
        '/applied-jobs':    (context) => const AppliedJobsScreen(),
        '/settings':        (context) => const SettingsScreen(),
        '/learning-history':(context) => const LearningHistoryScreen(),
      },
    );
  }
}