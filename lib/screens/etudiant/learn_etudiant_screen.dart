import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';

class LearnEtudiantScreen extends StatefulWidget {
  const LearnEtudiantScreen({super.key});

  @override
  State<LearnEtudiantScreen> createState() => _LearnEtudiantScreenState();
}

class _LearnEtudiantScreenState extends State<LearnEtudiantScreen> {
  int _currentNavIndex = 1;
  int _selectedCategory = 0;

  final List<String> _categories = [
    'All', 'Languages', 'Design', 'Coding', 'Business',
  ];

  final List<Map<String, dynamic>> _courses = [
    {
      'title': 'Arabic for Professionals',
      'instructor': 'Ahmed Hassan',
      'rating': '4.9',
      'category': 'Languages',
      'duration': '12h 30min',
      'lessons': 24,
      'enrolled': true,
      'progress': 0.45,
    },
    {
      'title': 'UX/UI Advanced Motion',
      'instructor': 'Sarah Jenkins',
      'rating': '4.8',
      'category': 'Design',
      'duration': '8h 15min',
      'lessons': 18,
      'enrolled': true,
      'progress': 0.70,
    },
    {
      'title': 'Flutter Development',
      'instructor': 'John Smith',
      'rating': '4.9',
      'category': 'Coding',
      'duration': '20h 00min',
      'lessons': 32,
      'enrolled': false,
      'progress': 0.0,
    },
    {
      'title': 'Business Strategy 101',
      'instructor': 'Marie Dupont',
      'rating': '4.7',
      'category': 'Business',
      'duration': '6h 45min',
      'lessons': 14,
      'enrolled': false,
      'progress': 0.0,
    },
    {
      'title': 'French Advanced',
      'instructor': 'Pierre Martin',
      'rating': '4.8',
      'category': 'Languages',
      'duration': '15h 00min',
      'lessons': 30,
      'enrolled': false,
      'progress': 0.0,
    },
    {
      'title': 'JavaScript ES6+',
      'instructor': 'Alex Turner',
      'rating': '4.9',
      'category': 'Coding',
      'duration': '10h 20min',
      'lessons': 20,
      'enrolled': false,
      'progress': 0.0,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedCategory == 0) return _courses;
    final cat = _categories[_selectedCategory];
    return _courses.where((c) => c['category'] == cat).toList();
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
                  context, '/etudiant/home', (route) => false);
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/offers', (route) => false);
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/etudiant/profile', (route) => false);
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Learn',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: ShapeDecoration(
                      color: c.surface,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1.24, color: c.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Icon(Icons.search_rounded,
                        color: c.textSecondary, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Category Filters ──
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategory == index;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? c.textPrimary : c.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? c.textPrimary : c.border,
                        ),
                      ),
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected ? c.surface : c.textSecondary,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
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
              child: _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              color: c.textMuted, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'No courses found',
                            style: TextStyle(
                              color: c.textMuted,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final course = _filtered[index];
                        return _EtudiantCourseCard(
                          title: course['title'] as String,
                          instructor: course['instructor'] as String,
                          rating: course['rating'] as String,
                          category: course['category'] as String,
                          duration: course['duration'] as String,
                          lessons: course['lessons'] as int,
                          enrolled: course['enrolled'] as bool,
                          progress: course['progress'] as double,
                          onTap: () => Navigator.pushNamed(
                              context, '/lesson'),
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

class _EtudiantCourseCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String rating;
  final String category;
  final String duration;
  final int lessons;
  final bool enrolled;
  final double progress;
  final VoidCallback onTap;

  const _EtudiantCourseCard({
    required this.title,
    required this.instructor,
    required this.rating,
    required this.category,
    required this.duration,
    required this.lessons,
    required this.enrolled,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Color(0xFFD08700), size: 14),
                              const SizedBox(width: 2),
                              Text(rating,
                                  style: TextStyle(
                                    color: c.textSecondary,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  )),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(instructor,
                          style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 13,
                              fontFamily: 'Inter')),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.access_time_rounded,
                              color: c.textMuted, size: 12),
                          const SizedBox(width: 4),
                          Text(duration,
                              style: TextStyle(
                                  color: c.textMuted,
                                  fontSize: 12,
                                  fontFamily: 'Inter')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Progress bar (if enrolled) ──
            if (enrolled) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Inter'),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.primaryLight,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Enroll Now',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
