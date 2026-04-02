import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/signup_screen.dart';
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
// ── Étudiant ──
import 'screens/etudiant/home_etudiant_screen.dart';
import 'screens/etudiant/learn_etudiant_screen.dart';
import 'screens/etudiant/profile_etudiant_screen.dart';
// ── Enseignant ──
import 'screens/enseignant/home_enseignant_screen.dart';
import 'screens/enseignant/my_courses_screen.dart';
import 'screens/enseignant/enseignant_profile_screen.dart';
import 'screens/enseignant/create_course_screen.dart';
// ── Recruteur ──
import 'screens/recruteur/home_recruteur_screen.dart';
import 'screens/recruteur/jobs_recruteur_screen.dart';
import 'screens/recruteur/profile_recruteur_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
        '/signup':                   (context) => const SignUpScreen(),
        '/create-account':           (context) => const CreateAccountScreen(),
        '/home':                     (context) => const HomeScreen(),
        '/offers':                   (context) => const OffersScreen(),
        '/learn':                    (context) => const LearnScreen(),
        '/lesson':                   (context) => const LessonScreen(),
        '/notifications':            (context) => const NotificationScreen(),
        '/profile':                  (context) => const ProfileScreen(),
        '/edit-profile':             (context) => const EditProfileScreen(),
        '/certificates':             (context) => const CertificatesScreen(),
        '/applied-jobs':             (context) => const AppliedJobsScreen(),
        '/settings':                 (context) => const SettingsScreen(),
        '/learning-history':         (context) => const LearningHistoryScreen(),
        // ── Étudiant ──
        '/etudiant/home':            (context) => const HomeEtudiantScreen(),
        '/etudiant/learn':           (context) => const LearnEtudiantScreen(),
        '/etudiant/profile':         (context) => const ProfileEtudiantScreen(),
        // ── Enseignant ──
        '/enseignant/home':          (context) => const HomeEnseignantScreen(),
        '/enseignant-home':          (context) => const HomeEnseignantScreen(),
        '/enseignant/courses':       (context) => const MyCoursesScreen(),
        '/enseignant-courses':       (context) => const MyCoursesScreen(),
        '/enseignant/profile':       (context) => const EnseignantProfileScreen(),
        '/enseignant-profile':       (context) => const EnseignantProfileScreen(),
        '/enseignant/create-course': (context) => const CreateCourseScreen(),
        '/create-course':            (context) => const CreateCourseScreen(),
        // ── Recruteur ──
        '/recruteur/home':           (context) => const HomeRecruteurScreen(),
        '/recruteur/jobs':           (context) => const JobsRecruteurScreen(),
        '/recruteur/profile':        (context) => const ProfileRecruteurScreen(),
      },
    );
  }
}
