import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minipr/screens/recruteur/jobs_recruteur_screen.dart';
import 'package:minipr/screens/recruteur/profile_recruteur_screen.dart';
import 'package:minipr/screens/recruteur/recruiter_applicants_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/offers_service.dart';
import '../../widgets/bottom_nav_bar.dart';

class HomeRecruteurScreen extends StatefulWidget {
  const HomeRecruteurScreen({super.key});
  @override
  State<HomeRecruteurScreen> createState() => _HomeRecruteurScreenState();
}

class _HomeRecruteurScreenState extends State<HomeRecruteurScreen> {
  int _currentIndex = 0;
  final _offersService = OffersService();

  final List<Widget> _pages = [
    _HomeTabContent(),
    const JobsRecruteurScreen(),
    const RecruiterApplicantsScreen(),
    const ProfileRecruteurScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          NavBarItem(icon: Icons.home_rounded, label: 'Home'),
          NavBarItem(icon: Icons.business_center_rounded, label: 'Jobs'),
          NavBarItem(icon: Icons.people_rounded, label: 'Applicants'),
          NavBarItem(icon: Icons.person_rounded, label: 'Profile'),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ✅ محتوى التبويب الرئيسي
// ─────────────────────────────────────────────────────────────
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
    final displayName = user.name.isNotEmpty
        ? user.name.split(' ')[0]
        : 'there';
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

            // ── Stats Banner ──
            recruiterId == null
                ? const Center(child: Text('Please sign in'))
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _offersService.getOffersByRecruiter(recruiterId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return _LoadingBanner(c: c);
                      final jobs = snapshot.data ?? [];
                      final activeCount = jobs
                          .where((j) => j['isActive'] == true)
                          .length;
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
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/recruteur/post-job',
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
                                      color: AppColors.purple,
                                      size: 18,
                                    ),
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

            // ── Stats Row (✅ Hired Count الحقيقي الآن) ──
            recruiterId == null
                ? const SizedBox.shrink()
                : StreamBuilder<Map<String, dynamic>>(
                    stream: _getRecruiterStatsStream(recruiterId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Row(
                          children: [
                            _StatCard(
                              c: c,
                              value: '...',
                              label: 'Total\nApplicants',
                              icon: Icons.people_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              c: c,
                              value: '...',
                              label: 'Active\nJobs',
                              icon: Icons.work_rounded,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              c: c,
                              value: '...',
                              label: 'Hired\nCandidates',
                              icon: Icons.check_circle_rounded,
                              color: AppColors.purple,
                            ),
                          ],
                        );
                      }
                      final stats =
                          snapshot.data ??
                          {
                            'jobsPosted': 0,
                            'totalApplicants': 0,
                            'hiredCount': 0,
                          };
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
                          // ✅ هنا يظهر الرقم الحقيقي للمُوظَّفين
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
                    final parentState = context
                        .findAncestorStateOfType<_HomeRecruteurScreenState>();
                    parentState?.setState(() => parentState._currentIndex = 1);
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
        // IconButton(
        //   icon: const Icon(Icons.explore_outlined, size: 18),
        //   onPressed: () => Navigator.pushNamed(context, '/offers'), // يذهب للسوق العام
        //   tooltip: 'Browse Market',
        // ),

              ],
            ),
            const SizedBox(height: 12),

            // ── Jobs List (أول 3 وظائف) ──
            recruiterId == null
                ? const SizedBox.shrink()
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _offersService.getOffersByRecruiter(recruiterId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return const Center(child: CircularProgressIndicator());
                      final jobs = snapshot.data ?? [];
                      if (jobs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.work_off_outlined,
                                  size: 48,
                                  color: c.textMuted,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No jobs posted yet',
                                  style: TextStyle(
                                    color: c.textMuted,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                Text(
                                  'Post your first job above!',
                                  style: TextStyle(
                                    color: c.textMuted,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: jobs
                            .take(3)
                            .map(
                              (job) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _PostedJobCard(c: c, job: job),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ✅ دالة محسّنة: نفس منطق البروفايل الناجح (ضعها داخل _HomeTabContentState)
  Stream<Map<String, dynamic>> _getRecruiterStatsStream(String recruiterId) {
    return FirebaseFirestore.instance
        .collection('offers')
        .where('recruiterId', isEqualTo: recruiterId)
        .snapshots()
        .asyncMap((snapshot) async {
      int jobsPosted = 0, totalApplicants = 0, hiredCount = 0;
      final offerIds = snapshot.docs.map((d) => d.id).toList();

      for (var doc in snapshot.docs) {
        if (doc['isActive'] == true) jobsPosted++;
        totalApplicants += (doc['applicationsCount'] as num?)?.toInt() ?? 0;
      }

      if (offerIds.isNotEmpty) {
        final hired = await FirebaseFirestore.instance
            .collection('applications')
            .where('offerId', whereIn: offerIds.take(10).toList())
            .where('status', isEqualTo: 'accepted')
            .count()
            .get();
        hiredCount = hired.count ?? 0;
      }

      return {
        'jobsPosted': jobsPosted,
        'totalApplicants': totalApplicants,
        'hiredCount': hiredCount,
      };
    });
  }
}

// ── Helper: Loading Banner ──
Widget _LoadingBanner({required ThemeColors c}) => Container(
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
  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
);

// ── Helper: Stat Card ──
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
  Widget build(BuildContext context) => Expanded(
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

// ── Helper: Posted Job Card ──
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
                    Icon(
                      Icons.people_outline_rounded,
                      size: 12,
                      color: c.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${job['applicationsCount'] ?? 0} applicants',
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.visibility_outlined,
                      size: 12,
                      color: c.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${job['views'] ?? 0} views',
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
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

// ── Utility: لدمج الـ Streams (مطلوب للدالة أعلاه) ──
class Rx {
  static Stream<R> combineLatest2<T1, T2, R>(
    Stream<T1> s1,
    Stream<T2> s2,
    R Function(T1, T2) combiner,
  ) async* {
    T1? v1;
    T2? v2;
    bool has1 = false, has2 = false;
    await for (final val in s1) {
      v1 = val;
      has1 = true;
    }
    await for (final val in s2) {
      v2 = val;
      has2 = true;
      if (has1 && has2) yield combiner(v1!, v2!);
    }
  }
}
