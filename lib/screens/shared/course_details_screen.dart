import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minipr/screens/shared/lesson_player_screen.dart';
import 'package:minipr/screens/shared/payment_screen.dart';
import 'package:minipr/screens/shared/public_teacher_profile_screen.dart';
import 'package:minipr/services/progress_service.dart';
import 'package:minipr/services/rating_service.dart';
import '../../theme/app_colors.dart';
import '../../models/course_model.dart';
import '../../services/courses_service.dart';
import '../../l10n/app_localizations.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;
  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late Future<CourseModel?> _courseFuture;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _courseFuture = CoursesService().getCourseById(widget.courseId);
    _courseFuture.then((course) {
      if (course != null) {
        ProgressService().updateTotalLessons(course.id, course.totalLessons);
      }
    });
  }

  // ✅ دالة إظهار نافذة التقييم (مصممة بشكل احترافي)
  void _showRatingDialog(BuildContext context, String courseId) {
    int selectedRating = 0;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.star_rounded, color: Colors.amber, size: 24),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context).rateThisCourse, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
        ]),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context).howWasExperience, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  icon: Icon(index < selectedRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 36),
                  onPressed: () => setState(() => selectedRating = index + 1),
                )),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context).cancel)),
          FilledButton(
            onPressed: selectedRating == 0 ? null : () async {
              await RatingService().rateCourse(courseId, selectedRating);
              if (mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(AppLocalizations.of(context).submitRating),
          ),
        ],
      ),
    );
  }

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

    return Scaffold(
      backgroundColor: c.bg,
      body: FutureBuilder<CourseModel?>(
        future: _courseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Course not found', style: TextStyle(color: c.textPrimary)));
          }

          final course = snapshot.data!;
          final accentColor = _categoryColor(course.category);

          return CustomScrollView(
            slivers: [
              // ── App Bar with Image Background (محسّن) ──
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: c.surface,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // صورة الخلفية مع تدرج
                      if (course.imageUrl != null && course.imageUrl!.isNotEmpty)
                        Image.network(course.imageUrl!, fit: BoxFit.cover)
                      else
                        Container(color: accentColor.withOpacity(0.2), child: Icon(Icons.menu_book_rounded, size: 80, color: accentColor.withOpacity(0.5))),
                      
                      // تدرج علوي لسلاسة الانتقال
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                          ),
                        ),
                      ),
                      
                      // شريط الفئة الملون في الأعلى
                      Positioned(top: 40, left: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(100)),
                          child: Text(course.category.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                        ),
                      ),
                    ],
                  ),
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
                  title: Text(course.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
                ),
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: c.surface.withOpacity(0.9), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
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
                      // ✅ Teacher Section (محسّن)
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PublicTeacherProfileScreen(teacherId: course.instructorId))),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
                          child: Row(
                            children: [
                              Container(width: 44, height: 44, decoration: BoxDecoration(color: accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: accentColor.withOpacity(0.3))),
                                child: Icon(Icons.school_rounded, color: accentColor, size: 22)),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(course.instructorName, style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                                ],
                              )),
                              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: c.textMuted),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ Stats & Progress Pills (مصممة مثل JobCard)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
                        child: Column(
                          children: [
                            // الصف الأول: الإحصائيات
                            Wrap(
                              spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
                              children: [
                                _CourseStatPill(icon: Icons.play_circle_outline_rounded, label: '${course.totalLessons} Lessons', color: accentColor),
                                StreamBuilder<Map<String, dynamic>>(
                                  stream: RatingService().getCourseRatingStats(course.id),
                                  builder: (context, ratingSnap) {
                                    final stats = ratingSnap.data ?? {'average': 0.0, 'count': 0};
                                    final avg = stats['average'] as double;
                                    final count = stats['count'] as int;
                                    return _CourseStatPill(icon: Icons.star_rounded, label: count > 0 ? '${avg.toStringAsFixed(1)} ($count)' : 'New', color: const Color(0xFFD08700));
                                  },
                                ),
                                _CourseStatPill(icon: Icons.people_alt_rounded, label: '${course.enrolledStudents} Students', color: AppColors.purple),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(color: c.border.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            // الصف الثاني: شريط التقدم
                            StreamBuilder<double>(
                              stream: ProgressService().getCourseProgressStream(course.id),
                              builder: (context, snap) {
                                final progress = snap.data ?? 0.0;
                                final percentage = (progress * 100).toInt();
                                return Column(
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${AppLocalizations.of(context).yourProgress}: $percentage%', style: TextStyle(color: c.textPrimary, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                                        Text('$percentage%', style: TextStyle(color: accentColor, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: accentColor.withOpacity(0.2), valueColor: AlwaysStoppedAnimation(accentColor)),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ✅ About Section (مع "اقرأ المزيد")
                      Text(AppLocalizations.of(context).aboutThisCourse, style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border.withOpacity(0.5))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(course.description,
                              maxLines: _isDescriptionExpanded ? null : 4,
                              overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: TextStyle(color: c.textSecondary.withOpacity(0.9), fontSize: 14, fontFamily: 'Inter', height: 1.6),
                            ),
                            if (course.description.length > 150)
                              TextButton(
                                onPressed: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                child: Text(_isDescriptionExpanded ? 'Show less' : 'Read more', style: TextStyle(color: accentColor, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ✅ Curriculum Section
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context).courseContent, style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                          Text('${course.totalLessons} Lessons', style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Inter')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: _CourseCurriculum(courseId: course.id, accentColor: accentColor, c: c),
                      ),
                      const SizedBox(height: 120), // مساحة للـ BottomBar
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      // ── Bottom Action Bar (محسّن) ──
      bottomNavigationBar: FutureBuilder<CourseModel?>(
        future: _courseFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final course = snapshot.data!;
          final c = context.colors;
          final accentColor = _categoryColor(course.category);

          return Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(color: c.surface, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -8))], border: Border(top: BorderSide(color: c.border))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context).certificatePrice, style: TextStyle(color: c.textMuted, fontSize: 11, fontFamily: 'Inter')),
                        Text('${course.certificatePrice} DZD', style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                      ],
                    ),
                    const Spacer(),
                    StreamBuilder<int?>(
                      stream: RatingService().getUserRatingStream(course.id),
                      builder: (context, snap) {
                        final userRating = snap.data;
                        return OutlinedButton.icon(
                          onPressed: () => _showRatingDialog(context, course.id),
                          icon: Icon(userRating != null ? Icons.star : Icons.star_border_outlined, color: userRating != null ? Colors.amber : accentColor, size: 18),
                          label: Text(userRating != null ? 'Rated' : 'Rate', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13)),
                          style: OutlinedButton.styleFrom(side: BorderSide(color: userRating != null ? Colors.amber.withOpacity(0.5) : accentColor.withOpacity(0.3)), backgroundColor: userRating != null ? Colors.amber.withOpacity(0.1) : Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // أزرار الإجراء الرئيسية
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(course: course))),
                          icon: const Icon(Icons.payment_rounded, size: 18),
                          label: Text('Get Certificate', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 14)),
                          style: OutlinedButton.styleFrom(foregroundColor: accentColor, side: BorderSide(color: accentColor, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(height: 52,
                        child: ElevatedButton.icon(
                  // في القسم السفلي (Bottom Action Bar) داخل ElevatedButton.icon:
onPressed: () async {
  final lessonsSnap = await FirebaseFirestore.instance
      .collection('courses')
      .doc(course.id)
      .collection('lessons')
      .orderBy('unitNumber')
      .orderBy('orderInUnit')
      .limit(1)
      .get();
      
  if (lessonsSnap.docs.isNotEmpty && context.mounted) {
    final firstLesson = lessonsSnap.docs.first;
    final data = firstLesson.data();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonPlayerScreen(
          videoUrl: data['videoUrl'] ?? '',
          lessonTitle: data['title'] ?? 'Lesson',
          courseId: course.id,
          lessonId: firstLesson.id,
          lessonType: data['type'] ?? 'video',
          isLocked: false,
          description: data['description'] ?? '',
          // ✅✅✅ أضف هذا السطر: ✅✅✅
          isFirstLesson: true, // ← هذا ما كان ناقصاً!
        ),
      ),
    );
  }
},
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: Text(AppLocalizations.of(context).startLearning, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15)),
                          style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 4, shadowColor: accentColor.withOpacity(0.4)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ✅ كبسولة الإحصائيات (مطابقة لـ _DetailPill في JobCard)
class _CourseStatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _CourseStatPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(isDark ? 0.12 : 0.08), borderRadius: BorderRadius.circular(100), border: Border.all(color: color.withOpacity(0.25))),
      child: Row(mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 14, color: color), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w600))],
      ),
    );
  }
}

// ── Curriculum Section (محسّن مع ألوان ديناميكية) ──
class _CourseCurriculum extends StatelessWidget {
  final String courseId;
  final Color accentColor;
  final ThemeColors c;
  const _CourseCurriculum({required this.courseId, required this.accentColor, required this.c});

  @override
  Widget build(BuildContext context) {
    final lessonsStream = FirebaseFirestore.instance.collection('courses').doc(courseId).collection('lessons').orderBy('unitNumber').orderBy('orderInUnit').snapshots();
    final completedStream = ProgressService().getCompletedLessonsStream(courseId);

    return StreamBuilder<List<DocumentSnapshot>>(
      stream: lessonsStream.map((snap) => snap.docs),
      builder: (context, lessonsSnap) {
        if (!lessonsSnap.hasData) return const Center(child: CircularProgressIndicator());
        final allLessons = lessonsSnap.data!;
        if (allLessons.isEmpty) return Text(AppLocalizations.of(context).noLessonsYet, style: TextStyle(color: c.textMuted));

        List<DocumentSnapshot> flatLessons = [];
        Map<int, List<DocumentSnapshot>> units = {};
        for (var lesson in allLessons) {
          final unitNum = lesson['unitNumber'] as int;
          if (!units.containsKey(unitNum)) units[unitNum] = [];
          units[unitNum]!.add(lesson);
          flatLessons.add(lesson);
        }
        Map<String, int> lessonIndexMap = {};
        for (int i = 0; i < flatLessons.length; i++) lessonIndexMap[flatLessons[i].id] = i;

        return StreamBuilder<Set<String>>(
          stream: completedStream,
          builder: (context, completedSnap) {
            final completedIds = completedSnap.data ?? {};
            return Column(children: units.entries.map((entry) {
              return ExpansionTile(
                childrenPadding: const EdgeInsets.only(left: 8),
                backgroundColor: c.surface.withOpacity(0.4),
                collapsedBackgroundColor: c.surface.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: c.border.withOpacity(0.6))),
                collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: c.border)),
                iconColor: accentColor,
                collapsedIconColor: c.textMuted,
                title: Text('Unit ${entry.key}', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 15)),
                subtitle: Text('${entry.value.length} Lessons', style: TextStyle(color: c.textMuted, fontSize: 12)),
                children: entry.value.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final currentGlobalIndex = lessonIndexMap[doc.id] ?? 0;
                  bool isLocked = currentGlobalIndex > 0 && !completedIds.contains(flatLessons[currentGlobalIndex - 1].id);
                  final isCompleted = completedIds.contains(doc.id);
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    leading: Container(width: 32, height: 32, decoration: BoxDecoration(color: isLocked ? c.iconBg : (isCompleted ? accentColor.withOpacity(0.12) : accentColor.withOpacity(0.08)), borderRadius: BorderRadius.circular(8), border: Border.all(color: isLocked ? c.border : (isCompleted ? accentColor : accentColor.withOpacity(0.3)))),
                      child: Icon(isLocked ? Icons.lock_outline_rounded : (isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded), color: isLocked ? c.textMuted : (isCompleted ? accentColor : accentColor), size: 16)),
                    title: Text(data['title'] ?? 'Untitled', style: TextStyle(color: isLocked ? c.textMuted.withOpacity(0.7) : c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal)),
                    trailing: isLocked ? null : Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(6)), child: Text(data['type'] == 'video' ? 'Video' : 'PDF', style: TextStyle(color: c.textMuted, fontSize: 10, fontWeight: FontWeight.w500))),
                    onTap: isLocked ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonPlayerScreen(videoUrl: data['videoUrl'], lessonTitle: data['title'], courseId: courseId, lessonId: doc.id, lessonType: data['type'] ?? 'video', isLocked: isLocked, description: data['description'] ?? ''))),
                  );
                }).toList(),
              );
            }).toList());
          },
        );
      },
    );
  }
}