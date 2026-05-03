import 'package:flutter/material.dart';

import 'package:minipr/screens/shared/course_details_screen.dart';

import 'package:minipr/screens/shared/public_teacher_profile_screen.dart';

import '../../theme/app_colors.dart';

import '../../services/courses_service.dart';

import '../../models/course_model.dart';

import '../../services/rating_service.dart'; // ✅ استيراد خدمة التقييمات
import '../../l10n/app_localizations.dart';

class LearnEtudiantScreen extends StatefulWidget {
  /// When true, shows a back button in the header (used as standalone route).
  /// When false (default), acts as a tab inside HomeEtudiantScreen.
  final bool showBackButton;
  const LearnEtudiantScreen({super.key, this.showBackButton = false});

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
                children: [
                  if (widget.showBackButton) ...[
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: c.border, width: 1.24),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                  ],
                  Text(
                    'Learn',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
                    hintText: AppLocalizations.of(context).searchCoursesTeachers,
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
                            AppLocalizations.of(context).noCoursesFound,
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
                      child: Text('${AppLocalizations.of(context).noMatches} "$_searchQuery"', style: TextStyle(color: c.textMuted)),
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

// ── بطاقة الكورس للطالب (نسخة محسّنة واحترافية) ──
class _EtudiantCourseCard extends StatelessWidget {
  final String courseId;
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

  // ✅ دالة لتحديد لون الشريط العلوي حسب الفئة
  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'coding': return AppColors.cyan;
      case 'design': return AppColors.purple;
      case 'langues': return AppColors.green;
      case 'business': return AppColors.orange;
      case 'marketing': return AppColors.pink;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDark;
    final accentColor = _categoryColor(category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border, width: 1.5),
          boxShadow: isDark
              ? [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))]
              : [
                  BoxShadow(color: accentColor.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1)),
                ],
        ),
        child: Column(
          children: [
            // ✅ شريط علوي ملون حسب الفئة (مثل بطاقة الوظيفة)
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.4)]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header: Avatar + Title + Rating ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
                          ),
                          child: Icon(Icons.school_rounded, color: accentColor, size: 24),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700, height: 1.2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
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
                                'By $instructor',
                                style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ✅ التقييم مدمج بشكل أنيق
                      StreamBuilder<Map<String, dynamic>>(
                        stream: RatingService().getCourseRatingStats(courseId),
                        builder: (context, snap) {
                          final stats = snap.data ?? {'average': 0.0, 'count': 0};
                          final avg = stats['average'] as double;
                          final count = stats['count'] as int;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD08700).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFD08700).withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFFD08700), size: 10),
                                const SizedBox(width: 4),
                                Text(
                                  count > 0 ? avg.toStringAsFixed(1) : 'New',
                                  style: TextStyle(color: const Color(0xFFD08700), fontSize: 9, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ✅ كبسولات التفاصيل (تطابق تصميم الوظيفة)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _CoursePill(icon: Icons.category_rounded, text: category, color: accentColor),
                      _CoursePill(icon: Icons.menu_book_rounded, text: '$lessons lessons', color: AppColors.green),
                      _CoursePill(icon: Icons.access_time_rounded, text: duration, color: c.textSecondary),
                    ],
                  ),

                  // ✅ وصف مختصر للكورس (مثل بطاقة الوظيفة)
                  if (lessons > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: c.border.withOpacity(0.5)),
                      ),
                      child: Text(
                        '$lessons lessons covering practical skills in $category. Start learning today!',
                        style: TextStyle(color: c.textSecondary.withOpacity(0.9), fontSize: 12, fontFamily: 'Inter', height: 1.5),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ✅ فاصل أنيق
                  Divider(color: c.border.withOpacity(0.6), thickness: 1, height: 1, indent: 4, endIndent: 4),
                  const SizedBox(height: 14),

                  // ✅ زر الإجراء (مصمم مثل _ActionButton)
                  Row(
                    children: [
                      if (enrolled) ...[
                        // حالة الطالب المسجّل: شريط التقدم
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Progress', style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter')),
                                  Text('${(progress * 100).toInt()}%', style: TextStyle(color: accentColor, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor: accentColor.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation(accentColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // حالة غير المسجّل: زر "عرض الكورس"
                        Expanded(
                          child: GestureDetector(
                            onTap: onTap,
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.play_circle_outline_rounded, size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text('View Course', style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ كبسولة تفاصيل الكورس (مطابقة لـ _DetailPill في JobCard)
class _CoursePill extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color color;
  const _CoursePill({this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: icon == null ? 14 : 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.1 : 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
          ],
          Text(text, style: TextStyle(color: color, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}