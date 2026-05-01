import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:minipr/firebase_options.dart';
import 'package:minipr/l10n/app_localizations.dart';
import 'package:minipr/providers/locale_provider.dart';
import 'package:minipr/screens/enseignant/my_courses_screen.dart';
import 'package:minipr/screens/enseignant/enseignant_courses_screen.dart';
import 'services/fcm_service.dart';
import 'package:minipr/screens/auth_wrapper.dart';
import 'package:minipr/screens/splash_screen.dart';
import 'package:minipr/screens/enseignant/enseignant_home_screen.dart';
import 'package:minipr/screens/recruteur/applicants_screen.dart';
import 'package:minipr/screens/recruteur/edit_offer_screen.dart';
import 'package:minipr/screens/recruteur/manage_offer_screen.dart';
import 'package:minipr/screens/recruteur/recruiter_applicants_screen.dart';
import 'package:minipr/screens/shared/my_portfolio_screen.dart';
import 'package:minipr/screens/shared/public_profile_screen.dart';
import 'package:minipr/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/auth/create_account_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/new_password_screen.dart';
import 'screens/auth/choose_role_screen.dart';

// ── Étudiant ──
import 'screens/etudiant/home_etudiant_screen.dart';
import 'screens/etudiant/learn_etudiant_screen.dart';
import 'screens/etudiant/profile_etudiant_screen.dart';

// ── Enseignant ──
import 'screens/enseignant/enseignant_profile_screen.dart';
import 'screens/enseignant/create_course_screen.dart';

// ── Recruteur ──
import 'screens/recruteur/home_recruteur_screen.dart';
import 'screens/recruteur/jobs_recruteur_screen.dart';
import 'screens/recruteur/profile_recruteur_screen.dart';
import 'screens/recruteur/post_job_screen.dart';

// ── Shared ──
import 'screens/shared/offers_screen.dart';
import 'screens/shared/lesson_screen.dart';
import 'screens/shared/course_details_screen.dart';
import 'screens/shared/notification_screen.dart';
import 'screens/shared/edit_profile_screen.dart';
import 'screens/shared/certificates_screen.dart';
import 'screens/shared/applied_jobs_screen.dart';
import 'screens/shared/settings_screen.dart';
import 'screens/shared/learning_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final themeProvider = ThemeProvider();
  await themeProvider.loadThemePreference();

  final localeProvider = LocaleProvider();
  await localeProvider.loadLocalePreference();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
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
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'Formanova',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,

      // ── Localization ──
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const SplashScreen(),
      routes: {
        '/signup': (context) => const SignUpScreen(),
        '/create-account': (context) => const CreateAccountScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/new-password': (context) => const NewPasswordScreen(),
        '/choose-role': (context) {
          final uid = ModalRoute.of(context)?.settings.arguments as String?;
          if (uid == null) return const SignUpScreen();
          return ChooseRoleScreen(uid: uid);
        },
        '/home': (context) => const AuthWrapper(),

        // ── Étudiant ──
        '/etudiant/home': (context) => const HomeEtudiantScreen(),
        '/etudiant/learn': (context) =>
            const LearnEtudiantScreen(showBackButton: true),
        '/etudiant/profile': (context) => const ProfileEtudiantScreen(),

        // ── Enseignant ──
        '/enseignant/my-courses': (context) => const MyCoursesScreen(),
        '/enseignant/home': (context) => const EnseignantHomeScreen(),
        '/enseignant/courses': (context) => const EnseignantCoursesScreen(),
        '/enseignant/profile': (context) => const ProfileEnseignantScreen(),
        '/enseignant/create-course': (context) => const CreateCourseScreen(),

        // ── Recruteur ──
        '/recruteur/home': (context) => const HomeRecruteurScreen(),
        '/recruteur/jobs': (context) => const JobsRecruteurScreen(),
        '/recruteur/profile': (context) => const ProfileRecruteurScreen(),
        '/recruteur/post-job': (context) => const PostJobScreen(),
        '/recruteur/manage-offer': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null) {
            return const Scaffold(
                body: Center(child: Text('Invalid arguments')));
          }
          return ManageOfferScreen(offer: args);
        },
        '/recruteur/edit-offer': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null) {
            return const Scaffold(body: Center(child: Text('Invalid')));
          }
          return EditOfferScreen(offer: args);
        },
        '/recruteur/candidates': (context) =>
            const RecruiterApplicantsScreen(),
        '/recruteur/applicants': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null || args['offerId'] == null) {
            return Scaffold(
                body: Center(child: Text('Invalid job selection')));
          }
          return ApplicantsScreen(
            offerId: args['offerId'],
            offerTitle: args['offerTitle'] ?? 'Unknown Job',
          );
        },

        // ── Shared ──
        '/offers': (context) => const OffersScreen(),
        '/lesson': (context) {
          final courseId = ModalRoute.of(context)?.settings.arguments as String?;
          if (courseId == null) {
            return const Scaffold(body: Center(child: Text('Invalid course')));
          }
          return LessonScreen(courseId: courseId);
        },
        '/course-details': (context) {
          final courseId = ModalRoute.of(context)?.settings.arguments as String?;
          if (courseId == null) {
            return const Scaffold(body: Center(child: Text('Invalid course')));
          }
          return CourseDetailsScreen(courseId: courseId);
        },
        '/notifications': (context) => const NotificationScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/certificates': (context) => const CertificatesScreen(),
        '/applied-jobs': (context) => const AppliedJobsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/learning-history': (context) => const LearningHistoryScreen(),
        '/portfolio': (ctx) => const MyPortfolioScreen(),
        '/public/profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null ||
              args['userId'] == null ||
              args['role'] == null) {
            return Scaffold(
                body: Center(child: Text('Invalid profile request')));
          }
          return PublicProfileScreen(
            userId: args['userId'],
            role: args['role'] ?? 'user',
          );
        },
      },
    );
  }
}
