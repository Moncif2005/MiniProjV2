import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minipr/screens/shared/lesson_player_screen.dart';
import 'package:minipr/screens/shared/public_teacher_profile_screen.dart';
import 'package:minipr/services/progress_service.dart';
import 'package:minipr/services/rating_service.dart'; // ✅ استيراد خدمة التقييمات
import '../../theme/app_colors.dart';
import '../../models/course_model.dart';
import '../../services/courses_service.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;
  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late Future<CourseModel?> _courseFuture;

  @override
  void initState() {
    super.initState();
    _courseFuture = CoursesService().getCourseById(widget.courseId);

    // ✅ تحديث العدد الكلي للدروس في قاعدة بيانات التقدم
    _courseFuture.then((course) {
      if (course != null) {
        ProgressService().updateTotalLessons(course.id, course.totalLessons);
      }
    });
  }

  // ✅ دالة إظهار نافذة التقييم
  void _showRatingDialog(BuildContext context, String courseId) {
    int selectedRating = 0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rate this Course', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('How was your experience?', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: selectedRating == 0
                      ? null
                      : () async {
                          await RatingService().rateCourse(courseId, selectedRating);
                          if (mounted) Navigator.pop(ctx);
                        },
                  child: const Text('Submit Rating'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: FutureBuilder<CourseModel?>(
        future: _courseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'Course not found',
                style: TextStyle(color: c.textPrimary),
              ),
            );
          }

          final course = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // ── App Bar with Image Background ──
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: c.surface,
                flexibleSpace: FlexibleSpaceBar(
                  background: course.imageUrl != null && course.imageUrl!.isNotEmpty
                      ? Image.network(course.imageUrl!, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.primaryLight,
                          child: Center(
                            child: Icon(Icons.menu_book_rounded, size: 64, color: AppColors.primary),
                          ),
                        ),
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                  title: Text(
                    course.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
                    ),
                  ),
                ),
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: c.surface.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary, size: 18),
                  ),
                ),
              ),

              // ── Content Body ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: TextStyle(color: c.textPrimary, fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.purpleLight,
                            child: Icon(Icons.person, size: 14, color: AppColors.purple),
                          ),
                          const SizedBox(width: 8),
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicTeacherProfileScreen(teacherId: course.instructorId),
      ),
    );
  },
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('By ${course.instructorName}', style: TextStyle(color: AppColors.primary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      const SizedBox(width: 4),
      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
    ],
  ),
),                        ],
                      ),
                      const SizedBox(height: 24),

                      // ✅ Stats & Progress
                      StreamBuilder<double>(
                        stream: ProgressService().getCourseProgressStream(course.id),
                        builder: (context, snap) {
                          final progress = snap.data ?? 0.0;
                          final percentage = (progress * 100).toInt();
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _StatItem(icon: Icons.play_circle_outline, label: '${course.totalLessons} Lessons', c: c),
                                    
                                    // ✅✅✅ تعديل عرض التقييم ليصبح ديناميكياً ✅✅✅
                                    StreamBuilder<Map<String, dynamic>>(
                                      stream: RatingService().getCourseRatingStats(course.id),
                                      builder: (context, ratingSnap) {
                                        final stats = ratingSnap.data ?? {'average': 0.0, 'count': 0};
                                        final avg = stats['average'] as double;
                                        final count = stats['count'] as int;
                                        
                                        String label = count > 0 ? '${avg.toStringAsFixed(1)} ($count)' : 'No ratings';
                                        return _StatItem(icon: Icons.star_rounded, label: label, c: c);
                                      },
                                    ),

                                    _StatItem(icon: Icons.people_alt_rounded, label: '${course.enrolledStudents} Students', c: c),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.trending_up_rounded, size: 16, color: AppColors.green),
                                    const SizedBox(width: 8),
                                    Text('Your Progress: $percentage%', style: TextStyle(color: c.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 6,
                                    backgroundColor: c.iconBg,
                                    valueColor: AlwaysStoppedAnimation(AppColors.green),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      Text('About this course', style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(course.description, style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter', height: 1.5)),
                      const SizedBox(height: 32),

                      Text('Course Content', style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),

                      Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: _CourseCurriculum(courseId: course.id, c: c),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: FutureBuilder<CourseModel?>(
        future: _courseFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final course = snapshot.data!;
          final c = context.colors;

          return Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: c.surface,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Certificate Price', style: TextStyle(color: c.textMuted, fontSize: 12)),
                        Text('${course.certificatePrice} €', style: TextStyle(color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Spacer(),
                    
                    // ✅ زر التقييم الواضح والمميز
                    StreamBuilder<int?>(
                      stream: RatingService().getUserRatingStream(course.id),
                      builder: (context, snap) {
                        final userRating = snap.data;
                        return OutlinedButton.icon(
                          onPressed: () => _showRatingDialog(context, course.id),
                          icon: Icon(
                            userRating != null ? Icons.star : Icons.star_border_outlined,
                            color: userRating != null ? Colors.amber : AppColors.primary,
                            size: 20,
                          ),
                          label: Text(
                            userRating != null ? 'Rated' : 'Rate Course',
                            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: userRating != null ? Colors.amber.withOpacity(0.5) : AppColors.primary.withOpacity(0.3)),
                            backgroundColor: userRating != null ? Colors.amber.withOpacity(0.1) : Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),

                // زر بدء التعلم يأخذ العرض الكامل في الأسفل
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () { debugPrint('Start Learning pressed'); },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Start Learning', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeColors c;
  const _StatItem({required this.icon, required this.label, required this.c});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter')),
      ],
    );
  }
}

class _CourseCurriculum extends StatelessWidget {
  final String courseId;
  final ThemeColors c;
  const _CourseCurriculum({required this.courseId, required this.c});

  @override
  Widget build(BuildContext context) {
    final lessonsStream = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .orderBy('unitNumber')
        .orderBy('orderInUnit')
        .snapshots();

    final completedStream = ProgressService().getCompletedLessonsStream(courseId);

    return StreamBuilder<List<DocumentSnapshot>>(
      stream: lessonsStream.map((snap) => snap.docs),
      builder: (context, lessonsSnap) {
        if (!lessonsSnap.hasData) return const Center(child: CircularProgressIndicator());
        
        final allLessons = lessonsSnap.data!;
        if (allLessons.isEmpty) return Text('No lessons yet', style: TextStyle(color: c.textMuted));

        List<DocumentSnapshot> flatLessons = [];
        Map<int, List<DocumentSnapshot>> units = {};
        
        for (var lesson in allLessons) {
          final unitNum = lesson['unitNumber'] as int;
          if (!units.containsKey(unitNum)) units[unitNum] = [];
          units[unitNum]!.add(lesson);
          flatLessons.add(lesson);
        }

        Map<String, int> lessonIndexMap = {};
        for (int i = 0; i < flatLessons.length; i++) {
          lessonIndexMap[flatLessons[i].id] = i;
        }

        return StreamBuilder<Set<String>>(
          stream: completedStream,
          builder: (context, completedSnap) {
            final completedIds = completedSnap.data ?? {};

            return Column(
              children: units.entries.map((entry) {
                return ExpansionTile(
                  childrenPadding: const EdgeInsets.only(left: 16),
                  backgroundColor: c.surface.withOpacity(0.5),
                  collapsedBackgroundColor: c.surface.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: c.border)),
                  title: Text('Unit ${entry.key}', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                  subtitle: Text('${entry.value.length} Lessons', style: TextStyle(color: c.textMuted, fontSize: 12)),
                  children: entry.value.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final currentGlobalIndex = lessonIndexMap[doc.id] ?? 0;
                    
                    bool isLocked = false;
                    if (currentGlobalIndex > 0) {
                      final prevLessonId = flatLessons[currentGlobalIndex - 1].id;
                      if (!completedIds.contains(prevLessonId)) {
                        isLocked = true;
                      }
                    }

                    final isCompleted = completedIds.contains(doc.id);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Icon(
                        isLocked ? Icons.lock_outline_rounded : (isCompleted ? Icons.check_circle_rounded : Icons.play_circle_outline_rounded),
                        color: isLocked ? c.textMuted : (isCompleted ? AppColors.green : AppColors.primary),
                        size: 20,
                      ),
                      title: Text(data['title'] ?? 'Untitled', style: TextStyle(color: isLocked ? c.textMuted : c.textPrimary, fontSize: 14, fontFamily: 'Inter')),
                      trailing: isLocked ? null : Text(data['type'] == 'video' ? 'Video' : 'PDF', style: TextStyle(color: c.textMuted, fontSize: 10)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonPlayerScreen(
                              videoUrl: data['videoUrl'],
                              lessonTitle: data['title'],
                              courseId: courseId,
                              lessonId: doc.id,
                              lessonType: data['type'] ?? 'video',
                              isLocked: isLocked,
                              description: data['description'] ?? '',
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}