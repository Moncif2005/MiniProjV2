import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../providers/user_provider.dart';
import '../../services/learn_service.dart';
import '../../screens/shared/course_details_screen.dart';
import '../../l10n/app_localizations.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  int _currentNavIndex = 1;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Languages',
    'Design',
    'Coding',
    'Business',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, String> _routesForRole(UserRole role) {
    switch (role) {
      case UserRole.enseignant:
        return {
          'home': '/enseignant/home',
          'offers': '/offers',
          'profile': '/enseignant/profile',
        };
      case UserRole.recruteur:
        return {
          'home': '/recruteur/home',
          'offers': '/offers',
          'profile': '/recruteur/profile',
        };
      case UserRole.etudiant:
      default:
        return {
          'home': '/etudiant/home',
          'offers': '/offers',
          'profile': '/etudiant/profile',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final role = context.watch<UserProvider>().role;
    final nav = _routesForRole(role);

    final l = AppLocalizations.of(context);
    final items = [
      NavBarItem(icon: Icons.home_rounded, label: l.navHome),
      NavBarItem(icon: Icons.school_rounded, label: l.navLearn),
      NavBarItem(icon: Icons.work_rounded, label: l.navWork),
      NavBarItem(icon: Icons.person_rounded, label: l.navProfile),
    ];

    return Scaffold(
      backgroundColor: c.bg,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        items: items,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                context,
                nav['home']!,
                (r) => false,
              );
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                context,
                nav['offers']!,
                (r) => false,
              );
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(
                context,
                nav['profile']!,
                (r) => false,
              );
              break;
          }
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                AppLocalizations.of(context).learn,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                  style: TextStyle(color: c.textPrimary, fontFamily: 'Inter'),
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(
                      context,
                    ).searchCoursesTeachers,
                    hintStyle: TextStyle(
                      color: c.textMuted,
                      fontFamily: 'Inter',
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: c.textMuted,
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: c.textMuted,
                              size: 18,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Category Filters ──
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = index == 0
                      ? _selectedCategory == null
                      : _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategory = index == 0 ? null : cat;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? c.textPrimary : c.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? c.textPrimary : c.border,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? c.surface : c.textSecondary,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ── Course List from Firestore ──
            Expanded(
              child: StreamBuilder<List<CourseModel>>(
                stream: LearnService().streamCourses(
                  category: _selectedCategory,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context).errorOccurred,
                        style: TextStyle(color: c.textMuted),
                      ),
                    );
                  }

                  final all = snapshot.data ?? [];
                  final courses = _searchQuery.isEmpty
                      ? all
                      : all
                            .where(
                              (course) =>
                                  course.title.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  course.instructor.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  course.category.toLowerCase().contains(
                                    _searchQuery,
                                  ),
                            )
                            .toList();

                  if (courses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            color: c.textMuted,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context).noCoursesFound,
                            style: TextStyle(
                              color: c.textMuted,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return _LearnCourseCard(
                        course: course,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CourseDetailsScreen(courseId: course.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Course Card ──
class _LearnCourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const _LearnCourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          color: c.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.24, color: c.border),
            borderRadius: BorderRadius.circular(24),
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
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  course.thumbnailUrl != null && course.thumbnailUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        course.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          course.title,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFD08700),
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            course.rating.toStringAsFixed(1),
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.instructor,
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 13,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          course.category,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time_rounded,
                        color: c.textMuted,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        course.durationFormatted,
                        style: TextStyle(
                          color: c.textMuted,
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.play_circle_outline_rounded,
                        color: c.textMuted,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.lessonsCount} lessons',
                        style: TextStyle(
                          color: c.textMuted,
                          fontSize: 12,
                          fontFamily: 'Inter',
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
