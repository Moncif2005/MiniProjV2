import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../enseignant/enseignant_courses_screen.dart';
import '../shared/offers_screen.dart';
import '../enseignant/enseignant_profile_screen.dart';

// ✅ ملاحظة: اسم الكلاس هنا EnseignantHomeScreen (كما في ملفك الأصلي)
// تأكد أن main.dart يشير لهذا الاسم بالضبط: '/enseignant/home': (context) => const EnseignantHomeScreen(),

class EnseignantHomeScreen extends StatefulWidget {
  const EnseignantHomeScreen({super.key});

  @override
  State<EnseignantHomeScreen> createState() => _EnseignantHomeScreenState();
}

class _EnseignantHomeScreenState extends State<EnseignantHomeScreen> {
  // ✅ المؤشر الذي يتحكم في التبويب المعروض
  int _currentIndex = 0;

  // ✅ قائمة الصفحات التي سيتم التبديل بينها (محفوظة في الذاكرة)
  final List<Widget> _pages = [
    // Tab 0: المحتوى الرئيسي (تم فصله في كلاس مستقل)
    _HomeTabContent(),

    // Tab 1: صفحة كورساتي
    const EnseignantCoursesScreen(),

    // Tab 2: صفحة الوظائف (مشتركة مع الأدوار الأخرى)
    const OffersScreen(),

    // Tab 3: صفحة البروفايل
    const ProfileEnseignantScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ✅ الـ BottomNavBar هنا: يتحكم فقط في تغيير _currentIndex
bottomNavigationBar: BottomNavBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  items: const [
    NavBarItem(icon: Icons.home_rounded, label: 'Home'),
    NavBarItem(icon: Icons.menu_book_rounded, label: 'Courses'), // ✅ كورساتي
    NavBarItem(icon: Icons.work_rounded, label: 'Work'), // ✅ الوظائف (عرض فقط)
    NavBarItem(icon: Icons.person_rounded, label: 'Profile'),
  ],
),
      // ✅ IndexedStack: يعرض الصفحة النشطة فقط، ويحفظ حالة الصفحات الأخرى
      body: IndexedStack(index: _currentIndex, children: _pages),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ✅ الكلاس الجديد: محتوى التبويب الرئيسي (الصفحة الأولى)
// ─────────────────────────────────────────────────────────────────────────────
class _HomeTabContent extends StatefulWidget {
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
    final displayName = user.name.isNotEmpty ? user.firstName : 'Alex';

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
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Ready to inspire minds today?',
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),

                // ── Bell ──
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
                  child: Stack(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: ShapeDecoration(
                          color: c.surface,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1.24, color: c.border),
                            borderRadius: BorderRadius.circular(14),
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
                        child: Icon(
                          Icons.notifications_outlined,
                          color: c.textSecondary,
                          size: 20,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: c.surface, width: 1.24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Search Bar ──
            Container(
              decoration: ShapeDecoration(
                color: c.surface,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1.24, color: c.border),
                  borderRadius: BorderRadius.circular(16),
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
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: c.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search courses to manage...',
                  hintStyle: TextStyle(
                    color: c.textMuted,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: c.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── My Courses Banner ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFB9F8CF),
                    blurRadius: 15,
                    offset: Offset(0, 10),
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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '3 active courses • 127 students',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.80),
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.bar_chart_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Create New Course Button ──
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/enseignant/create-course',
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: AppColors.green,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Create New Course',
                            style: TextStyle(
                              color: AppColors.green,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── My Courses Section ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Courses',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // ✅ عند الضغط على "See all" نغير التبويب بدلاً من التنقل لصفحة جديدة
                TextButton(
                  onPressed: () {
                    // نجد الـ State للأب ونغير التبويب لـ 1 (كورساتي)
                    final parentState = context
                        .findAncestorStateOfType<_EnseignantHomeScreenState>();
                    parentState?._changeTab(1);
                  },
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: c.primary,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Course Cards ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TeacherCourseCard(
                    title: 'Arabic for Professionals',
                    category: 'LANGUAGES',
                    instructor: 'Ahmed Hassan',
                    rating: '4.9',
                    imageUrl: 'https://placehold.co/238x128',
                  ),
                  const SizedBox(width: 16),
                  _TeacherCourseCard(
                    title: 'UX/UI Advanced Motion',
                    category: 'DESIGN',
                    instructor: 'Sarah Jenkins',
                    rating: '4.9',
                    imageUrl: 'https://placehold.co/238x128',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ✅ دالة مساعدة لتغيير التبويب من داخل المحتوى
// ─────────────────────────────────────────────────────────────────────────────
extension on _EnseignantHomeScreenState {
  void _changeTab(int index) {
    setState(() => _currentIndex = index);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Teacher Course Card (نفس الكود الأصلي - لم يتغير) ──
// ─────────────────────────────────────────────────────────────────────────────
class _TeacherCourseCard extends StatelessWidget {
  final String title;
  final String category;
  final String instructor;
  final String rating;
  final String imageUrl;

  const _TeacherCourseCard({
    required this.title,
    required this.category,
    required this.instructor,
    required this.rating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: 240,
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thumbnail ──
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  imageUrl,
                  width: 240,
                  height: 128,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 240,
                    height: 128,
                    color: c.border,
                    child: Icon(Icons.image_outlined, color: c.textMuted),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Info ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  instructor,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFD08700),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
