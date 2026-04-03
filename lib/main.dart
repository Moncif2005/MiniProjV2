import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'providers/user_provider.dart';
import 'services/auth_service.dart';

// ── Auth ──
import 'screens/auth_wrapper.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/auth/create_account_screen.dart';

// ── Home / Shared ──
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
      // AuthWrapper: checks Firebase state → routes to correct home
      home: const AuthWrapper(),
      routes: {
        // ── Auth ──
        '/signup':                   (_) => const SignUpScreen(),
        '/create-account':           (_) => const CreateAccountScreen(),

        // ── Shared home screens ──
        '/home':                     (_) => const HomeScreen(),
        '/offers':                   (_) => const OffersScreen(),
        '/learn':                    (_) => const LearnScreen(),
        '/lesson':                   (_) => const LessonScreen(),
        '/notifications':            (_) => const NotificationScreen(),
        '/profile':                  (_) => const ProfileScreen(),
        '/edit-profile':             (_) => const EditProfileScreen(),
        '/certificates':             (_) => const CertificatesScreen(),
        '/applied-jobs':             (_) => const AppliedJobsScreen(),
        '/settings':                 (_) => const SettingsScreen(),
        '/learning-history':         (_) => const LearningHistoryScreen(),

        // ── Étudiant ──
        '/etudiant/home':            (_) => const HomeEtudiantScreen(),
        '/etudiant/learn':           (_) => const LearnEtudiantScreen(),
        '/etudiant/profile':         (_) => const ProfileEtudiantScreen(),

        // ── Enseignant ──
        '/enseignant/home':          (_) => const HomeEnseignantScreen(),
        '/enseignant-home':          (_) => const HomeEnseignantScreen(),
        '/enseignant/courses':       (_) => const MyCoursesScreen(),
        '/enseignant-courses':       (_) => const MyCoursesScreen(),
        '/enseignant/profile':       (_) => const EnseignantProfileScreen(),
        '/enseignant-profile':       (_) => const EnseignantProfileScreen(),
        '/enseignant/create-course': (_) => const CreateCourseScreen(),
        '/create-course':            (_) => const CreateCourseScreen(),

        // ── Recruteur ──
        '/recruteur/home':           (_) => const HomeRecruteurScreen(),
        '/recruteur/jobs':           (_) => const JobsRecruteurScreen(),
        '/recruteur/profile':        (_) => const ProfileRecruteurScreen(),
        '/recruteur/post-job':       (_) => const JobsRecruteurScreen(),
      },
    );
  }
}
