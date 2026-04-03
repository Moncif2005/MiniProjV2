import 'package:flutter/material.dart';
import '../../widgets/learning_course_card.dart';

class LearningHistoryScreen extends StatelessWidget {
  const LearningHistoryScreen({super.key});

  // ── Stats Data ──
  static const _stats = [
    {
      'value': '3',
      'label': 'cours actifs',
      'icon': Icons.school_rounded,
      'colors': [Color(0xFF2B7FFF), Color(0xFF4F39F6)],
    },
    {
      'value': '2',
      'label': 'cours complétés',
      'icon': Icons.check_circle_rounded,
      'colors': [Color(0xFF00C950), Color(0xFF009966)],
    },
    {
      'value': '7',
      'label': 'jours consécutifs',
      'icon': Icons.local_fire_department_rounded,
      'colors': [Color(0xFFFF6900), Color(0xFFE7000B)],
    },
    {
      'value': '70.5h',
      'label': "d'apprentissage",
      'icon': Icons.access_time_rounded,
      'colors': [Color(0xFFAD46FF), Color(0xFFE60076)],
    },
  ];

  // ── Courses Data ──
  static const _courses = [
    {
      'title': 'Arabic for Professionals',
      'category': 'Languages',
      'status': CourseStatus.inProgress,
      'progress': 0.75,
      'lessons': '18/24 leçons',
      'timeSpent': '12h 30min',
      'lastAccessed': 'Today',
      'rating': null,
    },
    {
      'title': 'Flutter Development',
      'category': 'Programming',
      'status': CourseStatus.inProgress,
      'progress': 0.40,
      'lessons': '4/10 leçons',
      'timeSpent': '8h 15min',
      'lastAccessed': 'Yesterday',
      'rating': null,
    },
    {
      'title': 'UX Design Fundamentals',
      'category': 'Design',
      'status': CourseStatus.completed,
      'progress': 1.0,
      'lessons': '20/20 leçons',
      'timeSpent': '25h 45min',
      'lastAccessed': '3 days ago',
      'rating': '⭐⭐⭐⭐⭐',
    },
    {
      'title': 'French Advanced',
      'category': 'Languages',
      'status': CourseStatus.completed,
      'progress': 1.0,
      'lessons': '30/30 leçons',
      'timeSpent': '20h 00min',
      'lastAccessed': '1 week ago',
      'rating': '⭐⭐⭐⭐',
    },
    {
      'title': 'JavaScript ES6+',
      'category': 'Programming',
      'status': CourseStatus.inProgress,
      'progress': 0.15,
      'lessons': '3/20 leçons',
      'timeSpent': '4h 20min',
      'lastAccessed': '2 weeks ago',
      'rating': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // ── App Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1.24),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: Color(0xFF171717),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Historique d'apprentissage",
                      style: TextStyle(
                        color: Color(0xFF171717),
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "5 cours • 70.5h d'apprentissage",
                      style: TextStyle(
                        color: Color(0xFF737373),
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Scrollable Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats Grid ──
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _stats.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.04,
                        ),
                    itemBuilder: (context, index) {
                      final stat = _stats[index];
                      return _StatCard(
                        value: stat['value'] as String,
                        label: stat['label'] as String,
                        icon: stat['icon'] as IconData,
                        colors: stat['colors'] as List<Color>,
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Section Title ──
                  const Text(
                    'Tous les cours',
                    style: TextStyle(
                      color: Color(0xFF171717),
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Course Cards ──
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      return LearningCourseCard(
                        title: course['title'] as String,
                        category: course['category'] as String,
                        status: course['status'] as CourseStatus,
                        progress: course['progress'] as double,
                        lessons: course['lessons'] as String,
                        timeSpent: course['timeSpent'] as String,
                        lastAccessed: course['lastAccessed'] as String,
                        rating: course['rating'] as String?,
                        onAction: () {
                          Navigator.pushNamed(context, '/lesson');
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card Widget ──
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final List<Color> colors;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon Box ──
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const Spacer(),

          // ── Value ──
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),

          // ── Label ──
          Opacity(
            opacity: 0.80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
