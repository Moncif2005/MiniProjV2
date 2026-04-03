import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';

class EnseignantCoursesScreen extends StatefulWidget {
  const EnseignantCoursesScreen({super.key});

  @override
  State<EnseignantCoursesScreen> createState() =>
      _EnseignantCoursesScreenState();
}

class _EnseignantCoursesScreenState
    extends State<EnseignantCoursesScreen> {
  int _currentNavIndex = 1;
  int _selectedFilter = 0;
  final _filters = ['All', 'Languages', 'Design', 'Coding', 'Business'];

  final List<Map<String, dynamic>> _courses = [
    {
      'title': 'Arabic for Professionals',
      'instructor': 'Ahmed Hassan',
      'rating': '4.9',
      'category': 'LANGUAGES',
      'imageUrl': 'https://placehold.co/283x192',
      'duration': '20h 00m',
      'lessons': 30,
      'students': 45,
      'status': 'active',
    },
    {
      'title': 'French: Conversational Mastery',
      'instructor': 'Sophie Lefebvre',
      'rating': '4.8',
      'category': 'LANGUAGES',
      'imageUrl': 'https://placehold.co/283x192',
      'duration': '15h 30m',
      'lessons': 25,
      'students': 32,
      'status': 'active',
    },
    {
      'title': 'Advanced English for Tech',
      'instructor': 'James Wilson',
      'rating': '4.7',
      'category': 'LANGUAGES',
      'imageUrl': 'https://placehold.co/283x192',
      'duration': '12h 45m',
      'lessons': 18,
      'students': 50,
      'status': 'active',
    },
    {
      'title': 'Mastering Figma for Mobile',
      'instructor': 'David Miller',
      'rating': '4.8',
      'category': 'DESIGN',
      'imageUrl': 'https://placehold.co/283x192',
      'duration': '12h 30m',
      'lessons': 24,
      'students': 38,
      'status': 'active',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 0) return List.from(_courses);
    final cats = ['', 'LANGUAGES', 'DESIGN', 'CODING', 'BUSINESS'];
    return _courses
        .where((c) => c['category'] == cats[_selectedFilter])
        .toList();
  }

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
                  context, '/enseignant/home', (r) => false);
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/offers', (r) => false);
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/enseignant/profile', (r) => false);
              break;
          }
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  24, 24, 24, 0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Formation',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Upgrade your professional skills',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Search ──
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24),
              child: Container(
                decoration: ShapeDecoration(
                  color: c.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: 1.24, color: c.border),
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    hintStyle: TextStyle(
                      color: c.textMuted,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: c.textSecondary),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(
                            vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Filter Chips ──
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24),
                itemCount: _filters.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final active = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(
                        () => _selectedFilter = index),
                    child: AnimatedContainer(
                      duration: const Duration(
                          milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : c.surface,
                        borderRadius:
                            BorderRadius.circular(100),
                        border: Border.all(
                          color: active
                              ? AppColors.primary
                              : c.border,
                        ),
                        boxShadow: active
                            ? const [
                                BoxShadow(
                                  color: Color(0xFFDBEAFE),
                                  blurRadius: 15,
                                  offset: Offset(0, 10),
                                  spreadRadius: -3,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          color: active
                              ? Colors.white
                              : c.textSecondary,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ── Course List ──
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final course = _filtered[index];
                  return _TeacherCourseListCard(
                    course: course,
                    onEdit: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, '/create-course'),
        backgroundColor: AppColors.green,
        icon: const Icon(Icons.add_rounded,
            color: Colors.white),
        label: const Text(
          'Nouveau cours',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TeacherCourseListCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onEdit;

  const _TeacherCourseListCard(
      {required this.course, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: Image.network(
                  course['imageUrl'] as String,
                  width: double.infinity,
                  height: 192,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 192,
                    color: c.border,
                    child: Icon(Icons.image_outlined,
                        color: c.textMuted, size: 40),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: 0.90),
                        borderRadius:
                            BorderRadius.circular(100),
                      ),
                      child: Text(
                        course['category'] as String,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xE500C950),
                        borderRadius:
                            BorderRadius.circular(100),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.quiz_rounded,
                              color: Colors.white,
                              size: 12),
                          SizedBox(width: 4),
                          Text(
                            'QUIZ + GAMES',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Info ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        course['title'] as String,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFD08700),
                            size: 16),
                        const SizedBox(width: 4),
                        Text(
                          course['rating'] as String,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'By ${course['instructor']}',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                    color: const Color(0xFFFAFAFA),
                    thickness: 1.24),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            color: c.textSecondary,
                            size: 16),
                        const SizedBox(width: 4),
                        Text(
                          course['duration'] as String,
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                            Icons
                                .menu_book_rounded,
                            color: c.textSecondary,
                            size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${course['lessons']} Lessons',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onEdit,
                      child: Text(
                        '${course['students']} étudiants',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
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
        ],
      ),
    );
  }
}
