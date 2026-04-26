import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/courses_service.dart';
import '../../models/course_model.dart';
import '../../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(body: Center(child: Text(AppLocalizations.of(context).pleaseSignIn)));
    }

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        title: Text(AppLocalizations.of(context).myCourses, style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<CourseModel>>(
        stream: CoursesService().getCoursesByInstructor(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: c.textMuted),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context).noPublishedCourses, style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context).startFirstCourse, style: TextStyle(color: c.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/enseignant/create-course'),
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context).createCourse),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                  )
                ],
              ),
            );
          }

          final courses = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return _CourseCard(course: course, c: c);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/enseignant/create-course'),
        backgroundColor: AppColors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(AppLocalizations.of(context).newCourse, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final ThemeColors c;
  const _CourseCard({required this.course, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.menu_book, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${course.totalLessons} leçons • ${course.unitsCount} unités', style: TextStyle(color: c.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${course.certificatePrice} € / Certificat', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to Edit Course or View Lessons
                  // Navigator.pushNamed(context, '/enseignant/edit-course', arguments: course.id);
                },
                child: Text(AppLocalizations.of(context).manage, style: TextStyle(color: AppColors.primary)),
              )
            ],
          )
        ],
      ),
    );
  }
}