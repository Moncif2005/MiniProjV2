import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minipr/screens/shared/course_details_screen.dart';
import '../../theme/app_colors.dart';
import '../../services/rating_service.dart'; // لاستخدام خدمة التقييمات
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
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        title: Text(AppLocalizations.of(context).teacherProfile, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: c.textPrimary), onPressed: () => Navigator.pop(context)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.teacherId).get(),
        builder: (context, userSnap) {
          if (!userSnap.hasData) return const Center(child: CircularProgressIndicator());
          
          final userData = userSnap.data!.data() as Map<String, dynamic>?;
          if (userData == null) return Center(child: Text(AppLocalizations.of(context).userNotFound, style: TextStyle(color: c.textMuted)));

          final teacherName = userData['displayName'] ?? userData['name'] ?? 'Unknown Teacher';
          final teacherBio = userData['bio'] ?? 'No bio available.';
          final teacherAvatar = userData['photoURL'] ?? userData['avatar'];

          return CustomScrollView(
            slivers: [
              // ── Header Section ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: teacherAvatar != null ? NetworkImage(teacherAvatar) : null,
                        child: teacherAvatar == null ? Icon(Icons.person, size: 50, color: AppColors.primary) : null,
                      ),
                      const SizedBox(height: 16),
                      Text(teacherName, style: TextStyle(color: c.textPrimary, fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      Text(teacherBio, textAlign: TextAlign.center, style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter', height: 1.5)),
                    ],
                  ),
                ),
              ),

              // ── Courses Section ──
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(AppLocalizations.of(context).coursesByTeacher, style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),

              // ── List of Teacher's Courses with Ratings ──
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('courses')
                    .where('instructorId', isEqualTo: widget.teacherId)
                    .where('isPublished', isEqualTo: true)
                    .snapshots(),
                builder: (context, coursesSnap) {
                  if (coursesSnap.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                  }
                  if (!coursesSnap.hasData || coursesSnap.data!.docs.isEmpty) {
                    return SliverToBoxAdapter(child: Center(child: Text(AppLocalizations.of(context).noCoursesPublished, style: const TextStyle(color: Colors.grey))));
                  }

                  final courses = coursesSnap.data!.docs;
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final courseData = courses[index].data() as Map<String, dynamic>;
                        final courseId = courses[index].id;
                        
                        // ✅✅✅ منطق ذكي لجلب السعر من أي حقل ممكن ✅✅✅
                        double fetchedPrice = 0.0;
                        if (courseData.containsKey('coursePrice')) {
                          fetchedPrice = (courseData['coursePrice'] ?? 0.0).toDouble();
                        } else if (courseData.containsKey('price')) {
                          fetchedPrice = (courseData['price'] ?? 0.0).toDouble();
                        } else if (courseData.containsKey('certificatePrice')) {
                          // إذا لم يوجد سعر للكورس، نستخدم سعر الشهادة كبديل مؤقت
                          fetchedPrice = (courseData['certificatePrice'] ?? 0.0).toDouble();
                        }

                        return _CourseCardWithRating(
                          courseId: courseId,
                          title: courseData['title'] ?? 'Untitled',
                          category: courseData['category'] ?? 'General',
                          imageUrl: courseData['imageUrl'],
                          price: fetchedPrice, // نمرر السعر المصحح
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CourseDetailsScreen(courseId: courseId),
                              ),
                            );
                          },
                          c: c,
                        );
                      },
                      childCount: courses.length,
                    ),
                  );
                },
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }
}

// ── بطاقة كورس مع تقييم ديناميكي وسعر صحيح ──
class _CourseCardWithRating extends StatelessWidget {
  final String courseId, title, category;
  final String? imageUrl;
  final double price;
  final VoidCallback onTap;
  final ThemeColors c;

  const _CourseCardWithRating({
    required this.courseId,
    required this.title, 
    required this.category, 
    this.imageUrl, 
    required this.price, 
    required this.onTap, 
    required this.c
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(imageUrl!, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: c.textMuted))
                  : Container(width: 80, height: 80, color: c.iconBg, child: Icon(Icons.image, color: c.textMuted)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category, style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(title, style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  
                  // ✅✅✅ عرض تقييم الكورس هنا ✅✅✅
                  StreamBuilder<Map<String, dynamic>>(
                    stream: RatingService().getCourseRatingStats(courseId),
                    builder: (context, snap) {
                      final stats = snap.data ?? {'average': 0.0, 'count': 0};
                      final avg = stats['average'] as double;
                      final count = stats['count'] as int;
                      
                      return Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            count > 0 ? '${avg.toStringAsFixed(1)} ($count)' : 'New',
                            style: TextStyle(color: c.textMuted, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 4),
                  
                  // ✅✅✅ عرض السعر بشكل دقيق ✅✅✅
                  Text(
                    price > 0 ? '${price.toStringAsFixed(2)} DZD' : 'Free', 
                    style: TextStyle(
                      color: price > 0 ? AppColors.green : AppColors.primary, 
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: c.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}