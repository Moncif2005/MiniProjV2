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
  int _coursesCount = 0;
  int _studentsCount = 0;
  double _averageRating = 0.0;
  bool _statsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_statsLoaded) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    try {
      final coursesSnap = await FirebaseFirestore.instance
          .collection('courses')
          .where('instructorId', isEqualTo: widget.teacherId)
          .where('isPublished', isEqualTo: true)
          .get();

      int totalStudents = 0;
      double totalRating = 0.0;
      int ratingCount = 0;

      for (var doc in coursesSnap.docs) {
        final data = doc.data();
final enrolled = data['enrolledStudents'] ?? data['enrolledCount'] ?? 0;
totalStudents += enrolled is int ? enrolled : (enrolled as num).toInt();        
        final rating = (data['rating'] ?? 0.0).toDouble();
        if (rating > 0) {
          totalRating += rating;
          ratingCount++;
        }
      }

      if (mounted) {
        setState(() {
          _coursesCount = coursesSnap.docs.length;
          _studentsCount = totalStudents;
          _averageRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;
          _statsLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading teacher stats: $e');
    }
  }

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
                      width: 38,
                      height: 38,
                      decoration: ShapeDecoration(
                        color: c.surface,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1.24, color: c.border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: c.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                  Spacer(),
                                    Text(
                    AppLocalizations.of(context).teacherProfile,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
Spacer()
                ],
              ),
              const SizedBox(height: 24),

              // ── Profile Card ──
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(widget.teacherId).get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final userData = userSnap.data!.data() as Map<String, dynamic>?;
                  if (userData == null) {
                    return Center(child: Text(AppLocalizations.of(context).userNotFound, style: TextStyle(color: c.textMuted)));
                  }

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
                      shadows: const [
                        BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
                      ],
                    ),
                    child: Column(
                      children: [
                        // تدرج علوي بسيط
                        Container(
                          height: 96,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: AppColors.gradientBlue,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Column(
                            children: [
                              // ── Avatar ─
                              Transform.translate(
                                offset: const Offset(0, -48),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 96,
                                      height: 96,
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
                              
                              // ── Name + Bio ──
                              Transform.translate(
                                offset: const Offset(0, -40),
                                child: Column(
                                  children: [
                                    Text(
                                      teacherName,
                                      style: TextStyle(
                                        color: c.textPrimary,
                                        fontSize: 20,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    if (teacherBio.isNotEmpty && teacherBio != 'No bio available.')
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          teacherBio,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: c.textSecondary,
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            height: 1.4,
                                          ),
                                        ),
                                      )
                                    else
                                      Text(
                                        'Professional instructor',
                                        style: TextStyle(
                                          color: c.textMuted,
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),

                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.star_rounded, color: AppColors.primary, size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Teacher',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // ── Stats ──
                              Transform.translate(
                                offset: const Offset(0, -24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _StatItem(
                                      value: '$_coursesCount',
                                      label: 'COURSES',
                                      textColor: c.textPrimary,
                                      labelColor: c.textMuted,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 32,
                                      color: c.border,
                                      margin: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    _StatItem(
                                      value: _studentsCount > 1000 ? '${(_studentsCount / 1000).toStringAsFixed(1)}k' : '$_studentsCount',
                                      label: 'STUDENTS',
                                      textColor: c.textPrimary,
                                      labelColor: c.textMuted,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 32,
                                      color: c.border,
                                      margin: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    _StatItem(
                                      value: _averageRating > 0 ? _averageRating.toStringAsFixed(1) : '—',
                                      label: 'RATING',
                                      textColor: c.textPrimary,
                                      labelColor: c.textMuted,
                                    ),
                                  ],
                                ),
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
              Text(
                AppLocalizations.of(context).coursesByTeacher,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // قائمة الكورسات
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('courses')
                    .where('instructorId', isEqualTo: widget.teacherId)
                    .where('isPublished', isEqualTo: true)
                    .snapshots(),
                builder: (context, coursesSnap) {
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
                            Text(
                              AppLocalizations.of(context).noCoursesPublished,
                              style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter'),
                            ),
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
                      
                      // جلب السعر
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseDetailsScreen(courseId: courseId),
                          ),
                        ),
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
    final initials = name.isNotEmpty 
        ? name.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'T';
    
    return Container(
      color: AppColors.primaryLight,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 28,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Stat Item ──
class _StatItem extends StatelessWidget {
  final String value, label;
  final Color textColor, labelColor;
  const _StatItem({
    required this.value,
    required this.label,
    required this.textColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 10,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

// ── Simple Course Card (نفس نمط البروفايل - بسيط وأنيق) ──
class _SimpleCourseCard extends StatelessWidget {
  final String courseId, title, category;
  final String? imageUrl;
  final double price;
  final VoidCallback onTap;
  final ThemeColors c;

  const _SimpleCourseCard({
    required this.courseId,
    required this.title,
    required this.category,
    this.imageUrl,
    required this.price,
    required this.onTap,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: c.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.24, color: c.border),
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
          ],
        ),
        child: Row(
          children: [
            // صورة مصغرة بسيطة
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 72,
                height: 72,
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
                  Text(
                    title,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        price > 0 ? '${price.toStringAsFixed(0)} DZD' : 'Free',
                        style: TextStyle(
                          color: price > 0 ? AppColors.green : AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: c.textMuted,
                        size: 14,
                      ),
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