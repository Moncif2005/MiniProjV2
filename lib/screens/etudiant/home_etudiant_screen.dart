import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minipr/services/notifications_service.dart';
import 'package:minipr/services/offers_service.dart';
import 'package:minipr/widgets/home_job_card.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/continue_learning_card.dart';
import '../../widgets/course_card.dart';
import '../../widgets/job_card.dart';
import '../../services/learning_history_service.dart';
import '../../services/courses_service.dart'; // ✅ استيراد خدمة الكورسات
import '../../models/course_model.dart';      // ✅ استيراد موديل الكورس
import 'learn_etudiant_screen.dart';
import '../shared/offers_screen.dart';
import 'profile_etudiant_screen.dart';
import '../shared/course_details_screen.dart'; // للانتقال لتفاصيل الكورس

class HomeEtudiantScreen extends StatefulWidget {
  const HomeEtudiantScreen({super.key});

  @override
  State<HomeEtudiantScreen> createState() => _HomeEtudiantScreenState();
}

class _HomeEtudiantScreenState extends State<HomeEtudiantScreen> {
  int _currentIndex = 0;
  final TextEditingController _homeSearchController = TextEditingController();

  final List<Widget> _pages = [
    _HomeTabContent(searchController: null), // سيتم التعامل مع البحث بشكل منفصل أو تمريره
    const LearnEtudiantScreen(),
    const OffersScreen(),
    const ProfileEtudiantScreen(),
  ];

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
        items: [
          NavBarItem(icon: Icons.home_rounded,   label: AppLocalizations.of(context).navHome),
          NavBarItem(icon: Icons.school_rounded,  label: AppLocalizations.of(context).navLearn),
          NavBarItem(icon: Icons.work_rounded,    label: AppLocalizations.of(context).navWork),
          NavBarItem(icon: Icons.person_rounded,  label: AppLocalizations.of(context).navProfile),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex, 
        children: [
          _HomeTabContent(
            searchController: _homeSearchController,
            onSearchSubmitted: (query) {
              // عند الضغط على بحث، ننتقل لتاب Learn ونمرر النص (يتطلب تعديل بسيط في LearnEtudiantScreen لاستقبال النص)
              // للتبسيط الآن، سننتقل لتاب Learn فقط
              _changeTab(1);
            },
          ),
          const LearnEtudiantScreen(),
          const OffersScreen(),
          const ProfileEtudiantScreen(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _HomeTabContent extends StatefulWidget {
  final TextEditingController? searchController;
  final Function(String)? onSearchSubmitted;

  const _HomeTabContent({this.searchController, this.onSearchSubmitted});

  @override
  State<_HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<_HomeTabContent> {
  EnrollmentModel? _lastEnrollment;
  bool _enrollmentLoaded = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    widget.searchController?.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = (widget.searchController?.text ?? '').toLowerCase());
  }

  @override
  void dispose() {
    widget.searchController?.removeListener(_onSearchChanged);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_enrollmentLoaded) {
      _enrollmentLoaded = true;
      _loadLastEnrollment();
    }
  }

  // إعادة تحميل التقدم عند العودة للشاشة (مثلاً بعد إكمال درس)
  @override
  void didUpdateWidget(covariant _HomeTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadLastEnrollment();
  }

  Future<void> _loadLastEnrollment() async {
    final uid = context.read<UserProvider>().uid;
    if (uid == null || uid.isEmpty) return;

    final enrollments = await LearningHistoryService().fetchEnrollments(uid);

    // فقط الكورسات التي بدأها المستخدم ولم يكملها
    final inProgress = enrollments
        .where((e) => !e.isCompleted && e.progressPercent > 0)
        .toList();

    if (mounted) {
      setState(() {
        _lastEnrollment = inProgress.isNotEmpty ? inProgress.first : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final l    = AppLocalizations.of(context);
    final user = context.watch<UserProvider>();
    final displayName = user.firstName.isNotEmpty ? user.firstName : AppLocalizations.of(context).studentRole;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadLastEnrollment,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          physics: const AlwaysScrollableScrollPhysics(), // للسماح بالسحب للتحديث حتى لو المحتوى قليل
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
                      Text('${AppLocalizations.of(context).hello}, $displayName!',
                          style: TextStyle(color: c.textPrimary, fontSize: 24,
                              fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                      Text(AppLocalizations.of(context).platformSubtitle,
                          style: TextStyle(color: c.textSecondary, fontSize: 16,
                              fontFamily: 'Inter')),
                    ],
                  ),

                  // ── Bell with Dynamic Unread Badge ──
                  StreamBuilder<int>(
                    stream: NotificationsService().streamUnreadCount(
                      FirebaseAuth.instance.currentUser?.uid ?? '',
                    ),
                    builder: (context, snap) {
                      final unreadCount = snap.data ?? 0;
                      final hasUnread = unreadCount > 0;

                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/notifications'),
                        child: Stack(
                          clipBehavior: Clip.none,
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
                                  )
                                ],
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: c.textSecondary,
                                size: 20,
                              ),
                            ),
                            if (hasUnread)
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
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.24, color: c.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadows: const [BoxShadow(color: Color(0x19000000),
                      blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1)],
                ),
                child: TextField(
                  controller: widget.searchController,
                  style: TextStyle(color: c.textPrimary),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).searchCoursesJobs,
                    hintStyle: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter'),
                    prefixIcon: Icon(Icons.search_rounded, color: c.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: c.textMuted, size: 18),
                            onPressed: () {
                              widget.searchController?.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (value) {
                    if (widget.onSearchSubmitted != null) {
                      widget.onSearchSubmitted!(value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ── Continue Learning (Real Data) ──
              if (_lastEnrollment != null) ...[
                ContinueLearningCard(
                  title: AppLocalizations.of(context).continueLearning,
                  subtitle: '${_lastEnrollment!.courseTitle} · ${_lastEnrollment!.lessonsLabel}',
                  progress: _lastEnrollment!.progressPercent,
                  // courseId: _lastEnrollment!.courseId, 
                  // ✅ أضفنا onTap هنا للانتقال للكورس
                  onTap: () {
                    if (_lastEnrollment!.courseId.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CourseDetailsScreen(courseId: _lastEnrollment!.courseId),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 32),
              ],
              // ── Recommended for You (Real Data from Firestore) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context).recommendedForYou,
                      style: TextStyle(color: c.textPrimary, fontSize: 20,
                          fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () {
                       // الانتقال لتاب Learn
                       (context.findAncestorStateOfType<_HomeEtudiantScreenState>())?._changeTab(1);
                    },
                    child: Text(AppLocalizations.of(context).seeAll,
                        style: TextStyle(color: c.primary, fontSize: 14,
                            fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ✅✅✅ جلب الكورسات الحقيقية من Firestore ✅✅✅
              SizedBox(
                height: 230, // ارتفاع ثابت للقائمة الأفقية
                child: StreamBuilder<List<CourseModel>>(
                  stream: CoursesService().getPublishedCourses(), // جلب كل الكورسات المنشورة
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(AppLocalizations.of(context).noCoursesAvailable, 
                        style: TextStyle(color: c.textMuted)),
                      );
                    }

                    final courses = snapshot.data!;
                    // Filter by search query, then take 10
                    final filtered = _searchQuery.isEmpty
                        ? courses
                        : courses.where((course) =>
                            course.title.toLowerCase().contains(_searchQuery) ||
                            course.category.toLowerCase().contains(_searchQuery) ||
                            course.instructorName.toLowerCase().contains(_searchQuery)).toList();
                    final recentCourses = filtered.take(10).toList();

                    if (recentCourses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: c.textMuted),
                            const SizedBox(height: 8),
                            Text('No courses match "$_searchQuery"', style: TextStyle(color: c.textMuted)),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentCourses.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final course = recentCourses[index];
                        return SizedBox(
                          width: 240, // عرض ثابت للبطاقة
                          child: CourseCard(
                            title: course.title,
                            instructor: course.instructorName,
                            // نعرض التقييم الحقيقي إذا توفر، أو نضع قيمة افتراضية
                            rating: '4.5', // TODO: ربط التقييم الحقيقي هنا لاحقاً
                            category: course.category,
                            imageUrl: course.imageUrl ?? 'https://placehold.co/238x128',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CourseDetailsScreen(courseId: course.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 32),

              // ── New Opportunities (Real Data from OffersService) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context).newOpportunities,
                      style: TextStyle(color: c.textPrimary, fontSize: 20,
                          fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () {
                      (context.findAncestorStateOfType<_HomeEtudiantScreenState>())?._changeTab(2);
                    },
                    child: Text(AppLocalizations.of(context).seeAll,
                        style: TextStyle(color: c.primary, fontSize: 14,
                            fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ✅✅✅ جلب الوظائف الحقيقية باستخدام StreamBuilder ✅✅✅
              SizedBox(
                height: 300, // ارتفاع ثابت للقائمة العمودية القصيرة
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: OffersService().getActiveOffers(), // جلب العروض النشطة والمقبولة
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.work_outline_rounded, size: 48, color: c.textMuted),
                            const SizedBox(height: 8),
                            Text(AppLocalizations.of(context).noNewJobs, 
                            style: TextStyle(color: c.textMuted)),
                          ],
                        ),
                      );
                    }

                    final offers = snapshot.data!;
                    // نعرض آخر وظيفتين فقط في الصفحة الرئيسية
                    final recentOffers = offers.take(2).toList();

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentOffers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final offer = recentOffers[index];
                        
                        return HomeJobCard( // ✅ استخدام البطاقة الجديدة الصغيرة
                          offer: offer,
                          onTap: () {
                            // عند النقر، ننتقل لشاشة العروض الكاملة (OffersScreen)
                            // يمكن لاحقاً تمرير الـ offerId لفتح تفاصيل محددة
                            (context.findAncestorStateOfType<_HomeEtudiantScreenState>())?._changeTab(2);
                          },
                        );
                      },
                    );                  },
                ),
              ),
              
              const SizedBox(height: 24),            ],
          ),
        ),
      ),
    );
  }
}