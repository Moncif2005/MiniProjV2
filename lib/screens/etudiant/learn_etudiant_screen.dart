import 'package:flutter/material.dart';
import 'package:minipr/screens/shared/course_details_screen.dart';
import 'package:minipr/screens/shared/public_teacher_profile_screen.dart';
import '../../theme/app_colors.dart';
import '../../services/courses_service.dart';
import '../../models/course_model.dart';
import '../../services/rating_service.dart'; // ✅ استيراد خدمة التقييمات

class LearnEtudiantScreen extends StatefulWidget {
  const LearnEtudiantScreen({super.key});

  @override
  State<LearnEtudiantScreen> createState() => _LearnEtudiantScreenState();
}

class _LearnEtudiantScreenState extends State<LearnEtudiantScreen> {
  int _currentNavIndex = 1;
  String? _selectedCategory; 
  final TextEditingController _searchController = TextEditingController(); // ✅ متحكم البحث
  String _searchQuery = ''; // ✅ نص البحث الحالي

  final List<String> _categories = [
    'All',
    'Langues',
    'Design',
    'Coding',
    'Business',
    'Marketing',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header & Search Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
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
                  // ✅ أيقونة البحث أصبحت جزءاً من حقل البحث أدناه، يمكن إزالتها أو تركها كزر إضافي
                ],
              ),
            ),

            // ✅✅✅ حقل البحث الجديد ✅✅✅
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: ShapeDecoration(
                  color: c.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.24, color: c.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search courses or teachers...',
                    hintStyle: TextStyle(color: c.textMuted),
                    prefixIcon: Icon(Icons.search, color: c.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
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
                  final cat = _categories[index];
                  final isSelected =
                      _selectedCategory == cat ||
                      (_selectedCategory == null && index == 0);

                  return GestureDetector(
                    onTap: () => setState(
                      () => _selectedCategory = (index == 0 ? null : cat),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : c.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : c.border,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : c.textSecondary,
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

            // ── Course List (From Firestore + Local Filter) ✅ ──
            Expanded(
              child: StreamBuilder<List<CourseModel>>(
                stream: CoursesService().getPublishedCourses(
                  category:
                      (_selectedCategory == null || _selectedCategory == 'All')
                      ? null
                      : _selectedCategory,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: c.textMuted,
                          ),
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
                    );
                  }

                  var courses = snapshot.data!;

                  // ✅✅✅ تطبيق فلتر البحث محلياً ✅✅✅
                  if (_searchQuery.isNotEmpty) {
                    courses = courses.where((course) {
                      final titleMatch = course.title.toLowerCase().contains(_searchQuery);
                      final instructorMatch = course.instructorName.toLowerCase().contains(_searchQuery);
                      return titleMatch || instructorMatch;
                    }).toList();
                  }

                  if (courses.isEmpty) {
                     return Center(
                      child: Text('No matches for "$_searchQuery"', style: TextStyle(color: c.textMuted)),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return _EtudiantCourseCard(
                        courseId: course.id, // ✅ نمرر المعرف لجلب التقييم
                        title: course.title,
                        instructor: course.instructorName,
                        instructorId: course.instructorId,
                        // rating: '5.0', // ❌ حذفنا القيمة الثابتة
                        category: course.category,
                        duration: '${course.totalLessons} lessons',
                        lessons: course.totalLessons,
                        enrolled: false,
                        progress: 0.0,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseDetailsScreen(courseId: course.id),
                            ),
                          );
                        },
                      );
                    },
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

// ── بطاقة الكورس للطالب (مع تقييم ديناميكي وأفاتار قابل للنقر) ──
class _EtudiantCourseCard extends StatelessWidget {
  final String courseId; // ✅ إضافة المعرف
  final String title;
  final String instructor;
  final String instructorId;
  final String category;
  final String duration;
  final int lessons;
  final bool enrolled;
  final double progress;
  final VoidCallback onTap;

  const _EtudiantCourseCard({
    required this.courseId,
    required this.title,
    required this.instructor,
    required this.instructorId,
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublicTeacherProfileScreen(teacherId: instructorId),
                      ),
                    );
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
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
                          
                          // ✅✅✅ عرض التقييم الحقيقي ديناميكياً ✅✅✅
                          StreamBuilder<Map<String, dynamic>>(
                            stream: RatingService().getCourseRatingStats(courseId),
                            builder: (context, snap) {
                              final stats = snap.data ?? {'average': 0.0, 'count': 0};
                              final avg = stats['average'] as double;
                              final count = stats['count'] as int;
                              
                              return Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFD08700),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    count > 0 ? avg.toStringAsFixed(1) : 'New',
                                    style: TextStyle(
                                      color: c.textSecondary,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      GestureDetector(
                        onTap: () {
                           Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PublicTeacherProfileScreen(teacherId: instructorId),
                              ),
                            );
                        },
                        child: Text(
                          instructor,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontFamily: 'Inter',
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
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
                          Icon(
                            Icons.access_time_rounded,
                            color: c.textMuted,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: TextStyle(
                              color: c.textMuted,
                              fontSize: 12,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                      fontFamily: 'Inter',
                    ),
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
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
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
                    'View Course',
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