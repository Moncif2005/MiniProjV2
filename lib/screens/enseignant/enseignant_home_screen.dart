import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minipr/services/notifications_service.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../enseignant/enseignant_courses_screen.dart';
import '../shared/offers_screen.dart';
import '../enseignant/enseignant_profile_screen.dart';
import '../../services/courses_service.dart'; // ✅ استيراد خدمة الكورسات
import '../../models/course_model.dart';      // ✅ استيراد موديل الكورس
import '../shared/course_details_screen.dart'; // للانتقال للتفاصيل

class EnseignantHomeScreen extends StatefulWidget {
  const EnseignantHomeScreen({super.key});

  @override
  State<EnseignantHomeScreen> createState() => _EnseignantHomeScreenState();
}

class _EnseignantHomeScreenState extends State<EnseignantHomeScreen> {
  int _currentIndex = 0;

  // ✅ تعريف الـ Pages والـ Streams لتجنب إعادة البناء
  late final List<Widget> _pages;
  late final Stream<List<CourseModel>> _myCoursesStream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    // ✅ تهيئة الـ Stream لكورسات المعلم مرة واحدة
    _myCoursesStream = CoursesService().getCoursesByInstructor(uid);

    _pages = [
      _HomeTabContent(myCoursesStream: _myCoursesStream),
      const EnseignantCoursesScreen(),
      const OffersScreen(),
      const ProfileEnseignantScreen(),
    ];
  }

  void _changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _changeTab,
        items: const [
          NavBarItem(icon: Icons.home_rounded, label: 'Home'),
          NavBarItem(icon: Icons.menu_book_rounded, label: 'Courses'),
          NavBarItem(icon: Icons.work_rounded, label: 'Work'),
          NavBarItem(icon: Icons.person_rounded, label: 'Profile'),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _HomeTabContent extends StatefulWidget {
  final Stream<List<CourseModel>> myCoursesStream;
  const _HomeTabContent({required this.myCoursesStream});

  @override
  State<_HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<_HomeTabContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final user = context.watch<UserProvider>();
    final displayName = user.firstName.isNotEmpty ? user.firstName : 'Teacher';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $displayName!',
                      style: TextStyle(color: c.textPrimary, fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Ready to inspire minds today?',
                      style: TextStyle(color: c.textSecondary, fontSize: 16, fontFamily: 'Inter'),
                    ),
                  ],
                ),
                StreamBuilder<int>(
                  stream: NotificationsService().streamUnreadCount(FirebaseAuth.instance.currentUser?.uid ?? ''),
                  builder: (context, snap) {
                    final unreadCount = snap.data ?? 0;
                    final hasUnread = unreadCount > 0;
                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/notifications'),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 38, height: 38,
                            decoration: ShapeDecoration(
                              color: c.surface,
                              shape: RoundedRectangleBorder(side: BorderSide(width: 1.24, color: c.border), borderRadius: BorderRadius.circular(14)),
                              shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1)],
                            ),
                            child: Icon(Icons.notifications_outlined, color: c.textSecondary, size: 20),
                          ),
                          if (hasUnread)
                            Positioned(
                              top: 6, right: 6,
                              child: Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(color: AppColors.red, shape: BoxShape.circle, border: Border.all(color: c.surface, width: 1.24)),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Search Bar ──
            Container(
              decoration: ShapeDecoration(
                color: c.surface,
                shape: RoundedRectangleBorder(side: BorderSide(width: 1.24, color: c.border), borderRadius: BorderRadius.circular(16)),
                shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1)],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: c.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search your courses...',
                  hintStyle: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter'),
                  prefixIcon: Icon(Icons.search_rounded, color: c.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── My Courses Banner (Real Stats) ──
            StreamBuilder<List<CourseModel>>(
              stream: widget.myCoursesStream,
              builder: (context, snapshot) {
                // حساب الإحصائيات الحقيقية
                int activeCourses = 0;
                int totalStudents = 0;
                
                if (snapshot.hasData) {
                  final courses = snapshot.data!;
                  activeCourses = courses.length;
                  totalStudents = courses.fold(0, (sum, course) => sum + (course.enrolledStudents ?? 0));
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: c.isDark ? AppColors.green.withOpacity(0.25) : const Color(0xFFB9F8CF),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                        spreadRadius: -3,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'My Courses',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$activeCourses active • $totalStudents students',
                                style: TextStyle(color: Colors.white.withOpacity(0.80), fontSize: 14, fontFamily: 'Inter'),
                              ),
                            ],
                          ),
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.20), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/enseignant/create-course'),
                        child: Container(
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded, color: AppColors.green, size: 20),
                              SizedBox(width: 8),
                              Text('Create New Course', style: TextStyle(color: AppColors.green, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // ── My Courses Section (List) ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Courses',
                  style: TextStyle(color: c.textPrimary, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () {
                    context.findAncestorStateOfType<_EnseignantHomeScreenState>()?._changeTab(1);
                  },
                  child: Text('See all', style: TextStyle(color: c.primary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Real Course Cards from Firestore ──
            SizedBox(
              height: 280, // ارتفاع مناسب للبطاقة
              child: StreamBuilder<List<CourseModel>>(
                stream: widget.myCoursesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.book_outlined, size: 48, color: c.textMuted),
                          const SizedBox(height: 8),
                          Text('No courses yet.', style: TextStyle(color: c.textMuted)),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/enseignant/create-course'),
                            icon: const Icon(Icons.add),
                            label: const Text('Create First Course'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                          )
                        ],
                      ),
                    );
                  }

                  final courses = snapshot.data!;
                  // نأخذ آخر 5 كورسات
                  final recentCourses = courses.take(5).toList();

                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentCourses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final course = recentCourses[index];
                      return SizedBox(
                        width: 240,
                        child: _TeacherCourseCard(
                          courseId: course.id,
                          title: course.title,
                          category: course.category,
                          instructor: course.instructorName,
                          rating: '4.5', // TODO: ربط التقييم الحقيقي لاحقاً
                          imageUrl: course.imageUrl ?? 'https://placehold.co/238x128',
                          enrolledStudents: course.enrolledStudents ?? 0,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

extension on _EnseignantHomeScreenState {
  void _changeTab(int index) => setState(() => _currentIndex = index);
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Teacher Course Card (معدل ليدعم البيانات الحقيقية والنقر) ──
// ─────────────────────────────────────────────────────────────────────────────
class _TeacherCourseCard extends StatelessWidget {
  final String courseId;
  final String title;
  final String category;
  final String instructor;
  final String rating;
  final String imageUrl;
  final int enrolledStudents;

  const _TeacherCourseCard({
    required this.courseId,
    required this.title,
    required this.category,
    required this.instructor,
    required this.rating,
    required this.imageUrl,
    required this.enrolledStudents,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: () {
        // الانتقال لتفاصيل الكورس لإدارته أو عرضه
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailsScreen(courseId: courseId),
          ),
        );
      },
      child: Container(
        width: 240,
        decoration: ShapeDecoration(
          color: c.surface,
          shape: RoundedRectangleBorder(side: BorderSide(width: 1.24, color: c.border), borderRadius: BorderRadius.circular(16)),
          shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  child: Image.network(
                    imageUrl,
                    width: 240, height: 128, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 240, height: 128, color: c.border, child: Icon(Icons.image_outlined, color: c.textMuted)),
                  ),
                ),
                Positioned(
                  top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.90), borderRadius: BorderRadius.circular(10)),
                    child: Text(category, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(instructor, style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter')),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFD08700), size: 16),
                          const SizedBox(width: 4),
                          Text(rating, style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Text(
                        '$enrolledStudents Students',
                        style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Inter'),
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