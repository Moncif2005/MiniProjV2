import 'package:flutter/material.dart';
import 'package:minipr/screens/shared/offers_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/offers_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'jobs_recruteur_screen.dart';
import 'profile_recruteur_screen.dart';

class HomeRecruteurScreen extends StatefulWidget {
  const HomeRecruteurScreen({super.key});

  @override
  State<HomeRecruteurScreen> createState() => _HomeRecruteurScreenState();
}

class _HomeRecruteurScreenState extends State<HomeRecruteurScreen> {
  // ✅ المؤشر الذي يتحكم في التبويب المعروض
  int _currentIndex = 0;
  
  // ✅ خدمة الوظائف لجلب البيانات من Firestore
  final _offersService = OffersService();

  // ✅ قائمة الصفحات التي سيتم التبديل بينها (محفوظة في الذاكرة)
  final List<Widget> _pages = [
    // Tab 0: المحتوى الرئيسي (تم فصله في كلاس مستقل)
    _HomeTabContent(),
    
    // Tab 1: صفحة وظائفي (تعرض فقط وظائف هذا المسؤول)
    const JobsRecruteurScreen(),
    
    // Tab 2: صفحة الوظائف العامة (مشتركة - عرض فقط)
    const OffersScreen(),
    
    // Tab 3: صفحة بروفايل الشركة
    const ProfileRecruteurScreen(),
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
    NavBarItem(icon: Icons.business_center_rounded, label: 'Jobs'), // ✅ وظائفي
    NavBarItem(icon: Icons.people_rounded, label: 'Applicants'), // ✅ المتقدمين
    NavBarItem(icon: Icons.person_rounded, label: 'Profile'),
  ],
),      
      // ✅ IndexedStack: يعرض الصفحة النشطة فقط، ويحفظ حالة الصفحات الأخرى
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
  final _offersService = OffersService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final user = context.watch<UserProvider>();
    final displayName = user.name.isNotEmpty ? user.firstName : 'there';
    final recruiterId = FirebaseAuth.instance.currentUser?.uid;

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
                      'Find your next great hire',
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
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

            // ── Search ──
            Container(
              decoration: ShapeDecoration(
                color: c.surface,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1.24, color: c.border),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: c.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search candidates...',
                  hintStyle: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter'),
                  prefixIcon: Icon(Icons.search_rounded, color: c.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Stats Banner (مع بيانات حقيقية من Firestore) ──
            recruiterId == null
                ? const Center(child: Text('Please sign in'))
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _offersService.getOffersByRecruiter(recruiterId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _LoadingBanner(c: c);
                      }
                      
                      final jobs = snapshot.data ?? [];
                      final activeCount = jobs.where((j) => j['isActive'] == true).length;
                      final totalApplicants = jobs.fold(0, (sum, j) => sum + ((j['applicationsCount'] as int?) ?? 0));

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.gradientPurple,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33AD46FF),
                              blurRadius: 15,
                              offset: Offset(0, 10),
                              spreadRadius: -3,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Recruitment Hub',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      jobs.isEmpty
                                          ? 'No job posts yet — create your first!'
                                          : '$activeCount active job post${activeCount != 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        color: Color(0xFFEFD9FD),
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
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.work_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/recruteur/post-job'),
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
                                    Icon(Icons.add_rounded, color: AppColors.purple, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Post a New Job',
                                      style: TextStyle(
                                        color: AppColors.purple,
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
                      );
                    },
                  ),

            const SizedBox(height: 32),

            // ── Stats Row (بيانات حقيقية) ──
            recruiterId == null
                ? const SizedBox.shrink()
                : StreamBuilder<Map<String, dynamic>>(
                    stream: _getRecruiterStatsStream(recruiterId),
                    builder: (context, snapshot) {
                      final stats = snapshot.data ?? {'jobsPosted': 0, 'totalApplicants': 0, 'hiredCount': 0};
                      
                      return Row(
                        children: [
                          _StatCard(
                            c: c,
                            value: '${stats['totalApplicants'] ?? 0}',
                            label: 'Total\nApplicants',
                            icon: Icons.people_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            c: c,
                            value: '${stats['jobsPosted'] ?? 0}',
                            label: 'Active\nJobs',
                            icon: Icons.work_rounded,
                            color: AppColors.green,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            c: c,
                            value: '${stats['hiredCount'] ?? 0}',
                            label: 'Hired\nCandidates',
                            icon: Icons.check_circle_rounded,
                            color: AppColors.purple,
                          ),
                        ],
                      );
                    },
                  ),

            const SizedBox(height: 32),

            // ── Posted Jobs Preview ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Posted Jobs',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // ✅ الانتقال لتبويب "وظائفي" بدلاً من صفحة جديدة
                    final parentState = context.findAncestorStateOfType<_HomeRecruteurScreenState>();
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

            // ── Jobs List (من Firestore) ──
            recruiterId == null
                ? const SizedBox.shrink()
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _offersService.getOffersByRecruiter(recruiterId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final jobs = snapshot.data ?? [];
                      
                      if (jobs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Icon(Icons.work_off_outlined, size: 48, color: c.textMuted),
                                const SizedBox(height: 12),
                                Text(
                                  'No jobs posted yet',
                                  style: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter'),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Post your first job above!',
                                  style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // عرض أول 3 وظائف فقط كمعاينة
                      return Column(
                        children: jobs.take(3).map((job) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PostedJobCard(c: c, job: job),
                        )).toList(),
                      );
                    },
                  ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ✅ دالة مساعدة لجلب إحصائيات المسؤول كـ Stream
  Stream<Map<String, dynamic>> _getRecruiterStatsStream(String recruiterId) {
    return _offersService.getOffersByRecruiter(recruiterId).map((jobs) {
      final activeCount = jobs.where((j) => j['isActive'] == true).length;
      final totalApplicants = jobs.fold(0, (sum, j) => sum + ((j['applicationsCount'] as int?) ?? 0));
      // ملاحظة: hiredCount يحتاج استعلام إضافي، نضعه 0 مؤقتاً أو نضيفه في OffersService
      return {
        'jobsPosted': activeCount,
        'totalApplicants': totalApplicants,
        'hiredCount': 0, // يمكن تحسينه لاحقاً
      };
    });
  }
}

// ── Helper: Loading Banner ──
Widget _LoadingBanner({required ThemeColors c}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppColors.gradientPurple,
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Center(
      child: CircularProgressIndicator(color: Colors.white),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ✅ دالة مساعدة لتغيير التبويب من داخل المحتوى
// ─────────────────────────────────────────────────────────────────────────────
extension on _HomeRecruteurScreenState {
  void _changeTab(int index) {
    setState(() => _currentIndex = index);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Helper Widgets (نفسها كما هي - لم تتغير) ──
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final ThemeColors c;
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.c,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: c.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.24, color: c.border),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 22,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 11,
                fontFamily: 'Inter',
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostedJobCard extends StatelessWidget {
  final ThemeColors c;
  final Map<String, dynamic> job;
  const _PostedJobCard({required this.c, required this.job});

  @override
  Widget build(BuildContext context) {
    final isActive = job['isActive'] ?? true;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? AppColors.greenLight : c.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.work_outline_rounded,
              color: isActive ? AppColors.green : c.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title'] as String,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.people_outline_rounded, size: 12, color: c.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${job['applicationsCount'] ?? 0} applicants',
                      style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter'),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.visibility_outlined, size: 12, color: c.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${job['views'] ?? 0} views',
                      style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppColors.greenLight : c.iconBg,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              isActive ? 'Active' : 'Closed',
              style: TextStyle(
                color: isActive ? AppColors.green : c.textSecondary,
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}