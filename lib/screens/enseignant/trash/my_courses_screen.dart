import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/bottom_nav_bar.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  int _currentNavIndex = 1;

  final List<Map<String, dynamic>> _courses = [
    {
      'title': 'Arabic for Professionals',
      'students': 45,
      'rating': '4.9',
      'status': 'active',
      'category': 'LANGUAGES',
    },
    {
      'title': 'French Advanced',
      'students': 32,
      'rating': '4.8',
      'status': 'active',
      'category': 'LANGUAGES',
    },
    {
      'title': 'JavaScript Basics',
      'students': 50,
      'rating': '4.7',
      'status': 'active',
      'category': 'CODING',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/enseignant/home', (route) => false);
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/offers', (route) => false);
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/enseignant/profile', (route) => false);
              break;
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Formation',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      )),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, '/enseignant/create-course'),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('Manage your courses',
                  style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 16,
                      fontFamily: 'Inter')),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 8),
                itemCount: _courses.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  return _CourseManageCard(
                    title: course['title'] as String,
                    students: course['students'] as int,
                    rating: course['rating'] as String,
                    status: course['status'] as String,
                    category: course['category'] as String,
                    onEdit: () {},
                    onDelete: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseManageCard extends StatelessWidget {
  final String title;
  final int students;
  final String rating;
  final String status;
  final String category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CourseManageCard({
    required this.title,
    required this.students,
    required this.rating,
    required this.status,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: ShapeDecoration(
        color: const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // ── Left info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('$students students',
                        style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                            fontFamily: 'Inter')),
                    const SizedBox(width: 12),
                    Text('⭐ $rating',
                        style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                            fontFamily: 'Inter')),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius:
                            BorderRadius.circular(100),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Actions ──
          Row(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: AppColors.primary, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFFB2C36),
                      size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
