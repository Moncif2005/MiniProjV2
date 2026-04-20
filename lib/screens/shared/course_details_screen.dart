import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minipr/screens/shared/lesson_player_screen.dart';
import 'package:minipr/services/progress_service.dart';
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
                          Text('By ${course.instructorName}', style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter')),
                        ],
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
                                    _StatItem(icon: Icons.star_rounded, label: '5.0', c: c),
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
            child: Row(
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
                Expanded(
                  child: ElevatedButton(
                    onPressed: () { debugPrint('Start Learning pressed'); },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Start Learning', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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

// ✅✅✅ تعديل كلاس المنهج لإضافة القفل المتسلسل ✅✅✅
class _CourseCurriculum extends StatelessWidget {
  final String courseId;
  final ThemeColors c;
  const _CourseCurriculum({required this.courseId, required this.c});

  @override
  Widget build(BuildContext context) {
    // 1. جلب الدروس
    final lessonsStream = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .orderBy('unitNumber')
        .orderBy('orderInUnit')
        .snapshots();

    // 2. جلب الدروس المكتملة لهذا الكورس
    final completedStream = ProgressService().getCompletedLessonsStream(courseId);

    return StreamBuilder<List<DocumentSnapshot>>(
      stream: lessonsStream.map((snap) => snap.docs),
      builder: (context, lessonsSnap) {
        if (!lessonsSnap.hasData) return const Center(child: CircularProgressIndicator());
        
        final allLessons = lessonsSnap.data!;
        if (allLessons.isEmpty) return Text('No lessons yet', style: TextStyle(color: c.textMuted));

        // تجميع الدروس حسب الوحدات للعرض
        Map<int, List<DocumentSnapshot>> units = {};
        for (var lesson in allLessons) {
          final unitNum = lesson['unitNumber'] as int;
          if (!units.containsKey(unitNum)) units[unitNum] = [];
          units[unitNum]!.add(lesson);
        }

        // 3. الاستماع للتقدم لتحديد حالة القفل
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
                  children: entry.value.asMap().entries.map((indexedLesson) {
                    final index = indexedLesson.key;
                    final doc = indexedLesson.value;
                    final data = doc.data() as Map<String, dynamic>;
                    
                    // ✅ منطق القفل:
                    // الدرس مفتوح إذا كان هو الأول (index == 0 في وحدته أو الكورس كله؟ الأفضل ترتيب عالمي)
                    // لتبسيط الأمر: الدرس مفتوح إذا كان الدرس الذي يسبقه مباشرة في القائمة العامة مكتملاً.
                    
                    bool isLocked = false;
                    if (index > 0) {
                      // التحقق من الدرس السابق في نفس الوحدة أو الوحدة السابقة
                      // هنا نفترض الترتيب الخطي البسيط داخل الـ ExpansionTile
                      // للحصول على الدرس السابق بدقة، نحتاج لمعرفة موقعه في القائمة المسطحة
                      // لكن بما أننا داخل وحدة، فالدرس السابق هو إما السابق في نفس الوحدة أو آخر درس في الوحدة السابقة
                      
                      // طريقة أبسط: الدرس مقفل إذا لم يكن الدرس "السابق له في الترتيب العام" مكتملاً.
                      // سنستخدم معرف الدرس السابق.
                      String? prevLessonId;
                      if (index > 0) {
                         prevLessonId = entry.value[index - 1].id; // السابق في نفس الوحدة
                      } else {
                         // إذا كان أول درس في الوحدة، السابق هو آخر درس في الوحدة السابقة
                         int prevUnitKey = entry.key - 1;
                         if (units.containsKey(prevUnitKey) && units[prevUnitKey]!.isNotEmpty) {
                           prevLessonId = units[prevUnitKey]!.last.id;
                         }
                      }

                      // إذا وجدنا درساً سابقاً ولم يكن مكتملاً، فإن هذا الدرس مقفل
                      if (prevLessonId != null && !completedIds.contains(prevLessonId)) {
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
                      title: Text(
                        data['title'],
                        style: TextStyle(
                          color: isLocked ? c.textMuted : c.textPrimary,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                      trailing: isLocked 
                        ? null 
                        : Text(data['type'] == 'video' ? 'Video' : 'PDF', style: TextStyle(color: c.textMuted, fontSize: 10)),
                      onTap: isLocked ? null : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonPlayerScreen(
                              videoUrl: data['videoUrl'],
                              lessonTitle: data['title'],
                              courseId: courseId,
                              lessonId: doc.id,
                              lessonType: data['type'] ?? 'video',
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