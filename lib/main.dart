import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:minipr/firebase_options.dart';
import 'package:minipr/screens/auth_wrapper.dart';
import 'package:minipr/screens/recruteur/applicants_screen.dart';
import 'package:minipr/screens/recruteur/edit_offer_screen.dart';
import 'package:minipr/screens/recruteur/manage_offer_screen.dart';
import 'package:minipr/screens/recruteur/recruiter_applicants_screen.dart';
import 'package:minipr/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/auth/create_account_screen.dart';

// ── Étudiant ──
import 'screens/etudiant/home_etudiant_screen.dart';
import 'screens/etudiant/learn_etudiant_screen.dart';
import 'screens/etudiant/profile_etudiant_screen.dart';

// ── Enseignant ──
import 'screens/enseignant/trash/home_enseignant_screen.dart';
import 'screens/enseignant/enseignant_courses_screen.dart';
import 'screens/enseignant/enseignant_profile_screen.dart';
import 'screens/enseignant/create_course_screen.dart';

// ── Recruteur ──
import 'screens/recruteur/home_recruteur_screen.dart';
import 'screens/recruteur/jobs_recruteur_screen.dart';
import 'screens/recruteur/profile_recruteur_screen.dart';
import 'screens/recruteur/post_job_screen.dart';

// ── Shared (role-aware navigation) ──
import 'screens/shared/offers_screen.dart';
import 'screens/shared/learn_screen.dart';
import 'screens/shared/lesson_screen.dart';
import 'screens/shared/notification_screen.dart';
import 'screens/shared/edit_profile_screen.dart';
import 'screens/shared/certificates_screen.dart';
import 'screens/shared/applied_jobs_screen.dart';
import 'screens/shared/settings_screen.dart';
import 'screens/shared/learning_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: const AuthWrapper(),
      routes: {
        '/signup': (context) => const SignUpScreen(),
        '/create-account': (context) => const CreateAccountScreen(),
        //انا بدلتها هاذي لما يكون المستخدم مسجل دخول يروح لهوم سكرين واذا ماكانش مسجل دخول يروح لصفحة تسجيل الدخول
        '/home': (context) => const AuthWrapper(),

        // ── Étudiant routes ──
        '/etudiant/home': (context) => const HomeEtudiantScreen(),
        '/etudiant/learn': (context) => const LearnEtudiantScreen(),
        '/etudiant/profile': (context) => const ProfileEtudiantScreen(),

        // ── Enseignant routes ──
        '/enseignant/home': (context) => const HomeEnseignantScreen(),
        '/enseignant/courses': (context) => const EnseignantCoursesScreen(),
        '/enseignant/profile': (context) => const ProfileEnseignantScreen(),
        '/enseignant/create-course': (context) => const CreateCourseScreen(),

        // ── Recruteur routes ──
        '/recruteur/home': (context) => const HomeRecruteurScreen(),
        '/recruteur/jobs': (context) => const JobsRecruteurScreen(),
        '/recruteur/profile': (context) => const ProfileRecruteurScreen(),
        '/recruteur/post-job': (context) => const PostJobScreen(),
        '/recruteur/manage-offer': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          if (args == null)
            return const Scaffold(
              body: Center(child: Text('Invalid arguments')),
            );
          return ManageOfferScreen(offer: args);
        },
        '/recruteur/edit-offer': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          if (args == null)
            return const Scaffold(body: Center(child: Text('Invalid')));
          return EditOfferScreen(offer: args);
        },
        '/recruteur/applicants': (context) => const RecruiterApplicantsScreen(),

        // ── Shared routes (role-aware navigation) ──
        '/offers': (context) => const OffersScreen(),
        '/learn': (context) => const LearnScreen(),
        '/lesson': (context) => const LessonScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/certificates': (context) => const CertificatesScreen(),
        '/applied-jobs': (context) => const AppliedJobsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/learning-history': (context) => const LearningHistoryScreen(),
      },
    );
  }
}
