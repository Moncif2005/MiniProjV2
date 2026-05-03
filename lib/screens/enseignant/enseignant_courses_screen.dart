import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:minipr/screens/enseignant/edit_course_screen.dart';

import 'package:minipr/screens/shared/course_details_screen.dart';

import 'package:minipr/screens/shared/public_teacher_profile_screen.dart';

import 'package:minipr/services/courses_service.dart';

import '../../theme/app_colors.dart';

import '../../services/courses_service.dart';

import '../../models/course_model.dart';
import '../../l10n/app_localizations.dart';

class EnseignantCoursesScreen extends StatefulWidget {
  const EnseignantCoursesScreen({super.key});

  @override
  State<EnseignantCoursesScreen> createState() => _EnseignantCoursesScreenState();
}

class _EnseignantCoursesScreenState extends State<EnseignantCoursesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        title: Text(AppLocalizations.of(context).navCourses, style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: c.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: AppLocalizations.of(context).myCourses),
            const Tab(text: 'Explore'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ✅ التبويب الأول: كورساتي
          _MyCoursesTab(),
          
          // ✅ التبويب الثاني: استكشاف (منظم ومطور)
          _ExploreCoursesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/enseignant/create-course'),
        backgroundColor: AppColors.green,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(AppLocalizations.of(context).newCourse, style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ✅ التبويب الأول: كورساتي (مع شريط البحث)
// ─────────────────────────────────────────────────────────────
class _MyCoursesTab extends StatefulWidget {
  @override
  State<_MyCoursesTab> createState() => _MyCoursesTabState();
}

class _MyCoursesTabState extends State<_MyCoursesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return Center(child: Text(AppLocalizations.of(context).pleaseSignIn));

    return Column(
      children: [
        // ── Search Bar ──
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Container(
            decoration: ShapeDecoration(
              color: c.surface,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1.24, color: c.border),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).searchCourse,
                hintStyle: TextStyle(color: c.textMuted),
                prefixIcon: Icon(Icons.search, color: c.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: c.textMuted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),
        ),

        // ── Course List (Filtered) ──
        Expanded(
          child: StreamBuilder<List<CourseModel>>(
            stream: CoursesService().getCoursesByInstructor(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined, size: 64, color: c.textMuted),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context).noPublishedCourses, style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context).startFirstCourse, style: TextStyle(color: c.textSecondary)),
                    ],
                  ),
                );
              }

              var courses = snapshot.data!;
              
              // ✅ تطبيق فلتر البحث
              if (_searchQuery.isNotEmpty) {
                courses = courses.where((course) =>
                  course.title.toLowerCase().contains(_searchQuery) ||
                  course.category.toLowerCase().contains(_searchQuery) ||
                  course.description.toLowerCase().contains(_searchQuery)
                ).toList();
              }

              if (courses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: c.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isEmpty 
                            ? AppLocalizations.of(context).noPublishedCourses
                            : '${AppLocalizations.of(context).noMatches} "$_searchQuery"',
                        style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return _MyCourseCard(course: course, c: c);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
// ─────────────────────────────────────────────────────────────
// ✅ التبويب الثاني: استكشاف
// ─────────────────────────────────────────────────────────────
class _ExploreCoursesTab extends StatefulWidget {
  @override
  State<_ExploreCoursesTab> createState() => _ExploreCoursesTabState();
}

// ─────────────────────────────────────────────────────────────
// ✅ التبويب الثاني: استكشاف (مع فلترة محسّنة)
// ─────────────────────────────────────────────────────────────
class _ExploreCoursesTabState extends State<_ExploreCoursesTab> {
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = ['All', 'Langues', 'Design', 'Coding', 'Business', 'Marketing'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      children: [
        // ── Search Bar ──
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Container(
            decoration: ShapeDecoration(
              color: c.surface,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1.24, color: c.border),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).searchCourse,
                hintStyle: TextStyle(color: c.textMuted),
                prefixIcon: Icon(Icons.search, color: c.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: c.textMuted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),
        ),

        // ── Category Filters ──
        SizedBox(
          height: 45,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat || (_selectedCategory == null && index == 0);
              
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = (index == 0 ? null : cat)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : c.surface,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: isSelected ? AppColors.primary : c.border),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : c.textSecondary,
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // ── Course List (Filtered by Search AND Category) ──
        Expanded(
          child: StreamBuilder<List<CourseModel>>(
            stream: CoursesService().getPublishedCourses(category: _selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: c.textMuted),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).noCoursesFound,
                        style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter'),
                      ),
                    ],
                  ),
                );
              }

              var courses = snapshot.data!;
              
              // ✅ تطبيق فلتر البحث على النتائج
              if (_searchQuery.isNotEmpty) {
                courses = courses.where((course) =>
                  course.title.toLowerCase().contains(_searchQuery) ||
                  course.instructorName.toLowerCase().contains(_searchQuery) ||
                  course.category.toLowerCase().contains(_searchQuery) ||
                  course.description.toLowerCase().contains(_searchQuery)
                ).toList();
              }

              if (courses.isEmpty) {
                return Center(
                  child: Text(
                    '${AppLocalizations.of(context).noMatches} "$_searchQuery"',
                    style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter'),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return _ExploreCourseCard(course: course, c: c);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ✅ بطاقة كورساتي المحسّنة (تتناسق مع نظام التصميم الموحد)
// ─────────────────────────────────────────────────────────────
class _MyCourseCard extends StatelessWidget {
  final CourseModel course;
  final ThemeColors c;
  const _MyCourseCard({required this.course, required this.c});

  // ✅ دالة لتحديد لون التمييز حسب الفئة
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

  // ✅ دالة عرض خيارات الإدارة (تعديل/حذف)
  void _showManageOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.manage_accounts_rounded, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context).manageCourse, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
        ]),
        content: Text('Actions for "${course.title}"?', style: TextStyle(color: c.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context).cancel, style: TextStyle(color: c.textSecondary))),
          
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => EditCourseScreen(courseId: course.id)));
            },
            icon: Icon(Icons.edit_rounded, color: AppColors.primary),
            label: Text(AppLocalizations.of(context).edit, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
          
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              bool? confirmDelete = await showDialog<bool>(
                context: context,
                builder: (ctx2) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text(AppLocalizations.of(context).deleteCourse, style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
                  content: Text(AppLocalizations.of(context).areYouSure),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx2, false), child: Text(AppLocalizations.of(context).cancel)),
                    FilledButton(onPressed: () => Navigator.pop(ctx2, true), style: FilledButton.styleFrom(backgroundColor: AppColors.red), child: Text(AppLocalizations.of(context).delete)),
                  ],
                ),
              );
              if (confirmDelete == true) {
                final success = await CoursesService().deleteCourse(course.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'Course deleted' : 'Failed'), backgroundColor: success ? AppColors.green : AppColors.red, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  );
                }
              }
            },
            icon: Icon(Icons.delete_outline_rounded, color: AppColors.red),
            label: Text(AppLocalizations.of(context).delete, style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _categoryColor(course.category);
    final isDark = context.isDark;
    
    // تحديد خصائص الشارة حسب الحالة
    Color statusColor;
    String statusText;
    IconData statusIcon;
    String? message;

    switch (course.status) {
      case 'approved':
        statusColor = AppColors.green;
        statusText = 'Published';
        statusIcon = Icons.check_circle_rounded;
        message = null;
        break;
      case 'rejected':
        statusColor = AppColors.red;
        statusText = AppLocalizations.of(context).rejected;
        statusIcon = Icons.cancel_rounded;
        message = 'Check admin feedback';
        break;
      default: // pending
        statusColor = Colors.orange;
        statusText = 'Pending';
        statusIcon = Icons.pending_rounded;
        message = 'Waiting for approval';
    }

    return GestureDetector(
      onTap: () => _showManageOptions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border, width: 1.24),
          boxShadow: isDark 
              ? [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: accentColor.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)), BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Column(
          children: [
            // ✅ شريط علوي ملون حسب الفئة
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.4)]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header: Icon + Title + Status ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(isDark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: accentColor.withOpacity(0.2), width: 1.24),
                        ),
                        child: Icon(Icons.menu_book_rounded, color: accentColor, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700, height: 1.2),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${course.totalLessons} ${AppLocalizations.of(context).lessons} • ${course.unitsCount} ${AppLocalizations.of(context).units}',
                              style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                      ),
                      // ✅ شارة الحالة (مصممة مثل _DetailPill)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 10, color: statusColor),
                            const SizedBox(width: 4),
                            Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ✅ رسالة توضيحية للحالة (إن وجدت)
                  if (message != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: statusColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 14, color: statusColor),
                          const SizedBox(width: 6),
                          Expanded(child: Text(message, style: TextStyle(color: c.textSecondary, fontSize: 11, fontFamily: 'Inter'))),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // ── Divider ──
                  Divider(color: c.border.withOpacity(0.6), thickness: 1, height: 1, indent: 4, endIndent: 4),
                  const SizedBox(height: 12),

                  // ── Footer: Price + Manage Button ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // السعر
                      Row(
                        children: [
                          Icon(Icons.workspace_premium_rounded, size: 14, color: AppColors.green),
                          const SizedBox(width: 4),
                          Text(
                            '${course.certificatePrice} DZD',
                            style: TextStyle(color: AppColors.green, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                          ),
                          Text(' / cert', style: TextStyle(color: c.textMuted, fontSize: 11, fontFamily: 'Inter')),
                        ],
                      ),
                      
                      // زر الإدارة (مصمم مثل _ActionButton)
                      GestureDetector(
                        onTap: () => _showManageOptions(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.manage_accounts_rounded, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(AppLocalizations.of(context).manage, style: TextStyle(color: AppColors.primary, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
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
// ─────────────────────────────────────────────────────────────
// ✅ بطاقة استكشاف الكورسات (محسّنة)
// ─────────────────────────────────────────────────────────────
class _ExploreCourseCard extends StatelessWidget {
  final CourseModel course;
  final ThemeColors c;
  const _ExploreCourseCard({required this.course, required this.c});

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
    final accentColor = _categoryColor(course.category);
    final isDark = context.isDark;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailsScreen(courseId: course.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border, width: 1.24),
          boxShadow: isDark 
              ? [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: accentColor.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)), BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Column(
          children: [
            // شريط علوي ملون
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.4)]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Teacher Avatar + Title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PublicTeacherProfileScreen(teacherId: course.instructorId))),
                        child: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: accentColor.withOpacity(0.2), width: 1.24),
                          ),
                          child: Icon(Icons.school_rounded, color: accentColor, size: 24),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700, height: 1.2),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PublicTeacherProfileScreen(teacherId: course.instructorId))),
                              child: Text(
                                'By ${course.instructorName}',
                                style: TextStyle(color: AppColors.primary, fontSize: 12, fontFamily: 'Inter', decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Pills: Category + Lessons
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      _CoursePill(icon: Icons.category_rounded, text: course.category, color: accentColor),
                      _CoursePill(icon: Icons.menu_book_rounded, text: '${course.totalLessons} lessons', color: AppColors.green),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Divider
                  Divider(color: c.border.withOpacity(0.6), thickness: 1, height: 1, indent: 4, endIndent: 4),
                  const SizedBox(height: 12),

                  // Footer: Price + View Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.workspace_premium_rounded, size: 14, color: AppColors.green),
                          const SizedBox(width: 4),
                          Text(
                            '${course.certificatePrice} DZD',
                            style: TextStyle(color: AppColors.green, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailsScreen(courseId: course.id))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: accentColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(AppLocalizations.of(context).view, style: TextStyle(color: accentColor, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios_rounded, size: 10, color: accentColor),
                            ],
                          ),
                        ),
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

// ── Course Pill Widget (قابل لإعادة الاستخدام) ──
class _CoursePill extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color color;
  const _CoursePill({this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: icon == null ? 14 : 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.1 : 0.07),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(text, style: TextStyle(color: color, fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}