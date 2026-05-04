import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minipr/screens/shared/course_details_screen.dart';
import '../../theme/app_colors.dart';
import '../../services/rating_service.dart';
import '../../l10n/app_localizations.dart';

class PublicTeacherProfileScreen extends StatefulWidget {
  final String teacherId;
  const PublicTeacherProfileScreen({super.key, required this.teacherId});

  @override
  State<PublicTeacherProfileScreen> createState() => _PublicTeacherProfileScreenState();
}

class _PublicTeacherProfileScreenState extends State<PublicTeacherProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: ShapeDecoration(
                        color: c.surface,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1.24, color: c.border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: c.textSecondary, size: 18),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppLocalizations.of(context).teacherProfile,
                    style: TextStyle(color: c.textPrimary, fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 24),

              // ── Profile Card ──
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(widget.teacherId).get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) return const Center(child: CircularProgressIndicator());
                  
                  final userData = userSnap.data!.data() as Map<String, dynamic>?;
                  if (userData == null) return Center(child: Text(AppLocalizations.of(context).userNotFound, style: TextStyle(color: c.textMuted)));

                  final teacherName = userData['displayName'] ?? userData['name'] ?? 'Unknown Teacher';
                  final teacherBio = userData['bio'] ?? 'No bio available.';
                  final teacherAvatar = userData['photoURL'] ?? userData['avatar'];

                  return Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: c.surface,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1.24, color: c.border),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1)],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 96,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: AppColors.gradientBlue),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Column(
                            children: [
                              // Avatar
                              Transform.translate(
                                offset: const Offset(0, -48),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 96, height: 96,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: c.surface,
                                        border: Border.all(color: c.border, width: 4),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: ClipOval(
                                        child: teacherAvatar != null && teacherAvatar.isNotEmpty
                                            ? Image.network(teacherAvatar, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildInitials(c, teacherName))
                                            : _buildInitials(c, teacherName),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Name + Bio
                              Transform.translate(
                                offset: const Offset(0, -40),
                                child: Column(
                                  children: [
                                    Text(teacherName, style: TextStyle(color: c.textPrimary, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 8),
                                    if (teacherBio.isNotEmpty && teacherBio != 'No bio available.')
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(teacherBio, textAlign: TextAlign.center, style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter', height: 1.4)),
                                      )
                                    else
                                      Text('Professional instructor', style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter', fontStyle: FontStyle.italic)),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(100)),
                                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                                        Icon(Icons.star_rounded, color: AppColors.primary, size: 12),
                                        const SizedBox(width: 4),
                                        Text('Teacher', style: TextStyle(color: AppColors.primary, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                                      ]),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // ✅✅✅ Stats with Streams (محسّن) ✅✅✅
                              Transform.translate(
                                offset: const Offset(0, -24),
                                child: _TeacherStatsStream(teacherId: widget.teacherId),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ── Courses Section ──
              Text(AppLocalizations.of(context).coursesByTeacher, style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),

              // Courses List
              StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('courses')
    .where('instructorId', isEqualTo: widget.teacherId)
    .where('status', isEqualTo: 'approved')  // ← التصحيح هنا!
    .snapshots(),                builder: (context, coursesSnap) {
                  if (coursesSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!coursesSnap.hasData || coursesSnap.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(Icons.school_outlined, size: 48, color: c.textMuted),
                            const SizedBox(height: 12),
                            Text(AppLocalizations.of(context).noCoursesPublished, style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter')),
                          ],
                        ),
                      ),
                    );
                  }

                  final courses = coursesSnap.data!.docs;
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final courseData = courses[index].data() as Map<String, dynamic>;
                      final courseId = courses[index].id;
                      double price = 0.0;
                      if (courseData.containsKey('coursePrice')) {
                        price = (courseData['coursePrice'] ?? 0.0).toDouble();
                      } else if (courseData.containsKey('price')) {
                        price = (courseData['price'] ?? 0.0).toDouble();
                      }

                      return _SimpleCourseCard(
                        courseId: courseId,
                        title: courseData['title'] ?? 'Untitled',
                        category: courseData['category'] ?? 'General',
                        imageUrl: courseData['imageUrl'],
                        price: price,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailsScreen(courseId: courseId))),
                        c: c,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitials(ThemeColors c, String name) {
    final initials = name.isNotEmpty ? name.split(' ').map((e) => e[0]).take(2).join().toUpperCase() : 'T';
    return Container(
      color: AppColors.primaryLight,
      child: Center(child: Text(initials, style: const TextStyle(color: AppColors.primary, fontSize: 28, fontFamily: 'Inter', fontWeight: FontWeight.w700))),
    );
  }
}

// ── ✅✅✅ Widget جديد: إحصائيات المعلم مع Streams ✅✅✅ ──
// ── ✅✅✅ Widget جديد: إحصائيات المعلم مع Streams (مصحح) ✅✅✅ ──
class _TeacherStatsStream extends StatelessWidget {
  final String teacherId;
  const _TeacherStatsStream({required this.teacherId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    return StreamBuilder<QuerySnapshot>(
      // ✅✅✅ التصحيح: استخدام 'status' بدلاً من 'isPublished' ✅✅✅
      stream: FirebaseFirestore.instance
          .collection('courses')
          .where('instructorId', isEqualTo: teacherId)
          .where('status', isEqualTo: 'approved')  // ← التصحيح هنا!
          .snapshots(),
      builder: (context, snapshot) {
        // أثناء التحميل: أظهر أرقاماً افتراضية أنيقة
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _StatsRow(courses: '—', students: '—', rating: '—', c: c);
        }
        
        // في حالة الخطأ: أظهر شرطات
        if (!snapshot.hasData) {
          return _StatsRow(courses: '—', students: '—', rating: '—', c: c);
        }

        final courses = snapshot.data!.docs;
        final coursesCount = courses.length;
        
        // إذا لم يكن هناك كورسات: أظهر أصفاراً أنيقة
        if (coursesCount == 0) {
          return _StatsRow(courses: '0', students: '0', rating: '—', c: c);
        }

        // ✅ حساب الإحصائيات من البيانات الحقيقية
        int totalStudents = 0;
        double totalRating = 0.0;
        int ratingCount = 0;

        for (var doc in courses) {
          final data = doc.data() as Map<String, dynamic>;
          
          // عدد الطلاب: دعم الحقول القديمة والجديدة بأمان
          final enrolledRaw = data['enrolledStudents'] ?? data['enrolledCount'] ?? 0;
          if (enrolledRaw is int) {
            totalStudents += enrolledRaw;
          } else if (enrolledRaw is num) {
            totalStudents += enrolledRaw.toInt();
          }
          
          // ✅✅✅ التقييم: حساب آمن يتجاهل null والقيم غير الصحيحة ✅✅✅
          final ratingRaw = data['rating'];
          if (ratingRaw != null && ratingRaw is num) {
            final rating = ratingRaw.toDouble();
            if (rating > 0) {
              totalRating += rating;
              ratingCount++;
            }
          }
        }

        final avgRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;

        return _StatsRow(
          courses: '$coursesCount',
          students: _formatNumber(totalStudents),
          rating: avgRating > 0 ? avgRating.toStringAsFixed(1) : '—',
          c: c,
        );
      },
    );
  }

  // ✅ تنسيق الأرقام الكبيرة
  String _formatNumber(int num) {
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}k';
    return '$num';
  }
}

// ── ✅ Widget صغير: صف الإحصائيات (قابل لإعادة الاستخدام) ──
class _StatsRow extends StatelessWidget {
  final String courses, students, rating;
  final ThemeColors c;
  const _StatsRow({required this.courses, required this.students, required this.rating, required this.c});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatItem(value: courses, label: 'COURSES', textColor: c.textPrimary, labelColor: c.textMuted),
        Container(width: 1, height: 32, color: c.border, margin: const EdgeInsets.symmetric(horizontal: 16)),
        _StatItem(value: students, label: 'STUDENTS', textColor: c.textPrimary, labelColor: c.textMuted),
        Container(width: 1, height: 32, color: c.border, margin: const EdgeInsets.symmetric(horizontal: 16)),
        _StatItem(value: rating, label: 'RATING', textColor: c.textPrimary, labelColor: c.textMuted),
      ],
    );
  }
}

// ── Stat Item (نفسه كما هو) ──
class _StatItem extends StatelessWidget {
  final String value, label;
  final Color textColor, labelColor;
  const _StatItem({required this.value, required this.label, required this.textColor, required this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: textColor, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        Text(label, style: TextStyle(color: labelColor, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w700, letterSpacing: 1)),
      ],
    );
  }
}

// ── Simple Course Card (نفسه كما هو) ──
class _SimpleCourseCard extends StatelessWidget {
  final String courseId, title, category;
  final String? imageUrl;
  final double price;
  final VoidCallback onTap;
  final ThemeColors c;

  const _SimpleCourseCard({required this.courseId, required this.title, required this.category, this.imageUrl, required this.price, required this.onTap, required this.c});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: c.surface,
          shape: RoundedRectangleBorder(side: BorderSide(width: 1.24, color: c.border), borderRadius: BorderRadius.circular(16)),
          shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 72, height: 72,
                color: AppColors.primaryLight,
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 24))
                    : Icon(Icons.menu_book_rounded, color: AppColors.primary.withOpacity(0.6), size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: c.textPrimary, fontSize: 15, fontFamily: 'Inter', fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(category, style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter')),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(price > 0 ? '${price.toStringAsFixed(0)} DZD' : 'Free', style: TextStyle(color: price > 0 ? AppColors.green : AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Inter')),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios_rounded, color: c.textMuted, size: 14),
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