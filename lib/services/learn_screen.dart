import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../providers/user_provider.dart';
import '../../services/learn_service.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  int _currentNavIndex  = 1;
  int _selectedCategory = 0;
  bool _showSearch      = false;
  String _searchQuery   = '';
  final _searchController = TextEditingController();

  final List<String> _categories = ['All', 'Languages', 'Design', 'Coding', 'Business'];
  final _learnService = LearnService();

  String? get _activeCategory => _selectedCategory == 0 ? null : _categories[_selectedCategory];

  Map<String, String> _routesForRole(UserRole role) {
    switch (role) {
      case UserRole.enseignant: return {'home': '/enseignant/home', 'offers': '/offers', 'profile': '/enseignant/profile'};
      case UserRole.recruteur:  return {'home': '/recruteur/home',  'offers': '/offers', 'profile': '/recruteur/profile'};
      case UserRole.etudiant:
      default:                  return {'home': '/etudiant/home',   'offers': '/offers', 'profile': '/etudiant/profile'};
    }
  }

  List<CourseModel> _applySearch(List<CourseModel> courses) {
    if (_searchQuery.isEmpty) return courses;
    final q = _searchQuery.toLowerCase();
    return courses.where((c) =>
        c.title.toLowerCase().contains(q) ||
        c.instructor.toLowerCase().contains(q) ||
        c.category.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final role = context.watch<UserProvider>().role;
    final nav  = _routesForRole(role);

    return Scaffold(
      backgroundColor: c.bg,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          switch (index) {
            case 0: Navigator.pushNamedAndRemoveUntil(context, nav['home']!,    (r) => false); break;
            case 2: Navigator.pushNamedAndRemoveUntil(context, nav['offers']!,  (r) => false); break;
            case 3: Navigator.pushNamedAndRemoveUntil(context, nav['profile']!, (r) => false); break;
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Learn', style: TextStyle(color: c.textPrimary, fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () => setState(() { _showSearch = !_showSearch; if (!_showSearch) { _searchController.clear(); _searchQuery = ''; } }),
                    child: Container(
                      width: 38, height: 38,
                      decoration: ShapeDecoration(
                        color: _showSearch ? AppColors.primary : c.surface,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1.24, color: _showSearch ? AppColors.primary : c.border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Icon(Icons.search_rounded, color: _showSearch ? Colors.white : c.textSecondary, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Field (conditional) ──
            if (_showSearch) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: ShapeDecoration(
                    color: c.surface,
                    shape: RoundedRectangleBorder(side: BorderSide(width: 1.24, color: c.border), borderRadius: BorderRadius.circular(14)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(color: c.textPrimary),
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search courses...',
                      hintStyle: TextStyle(color: c.textMuted, fontFamily: 'Inter'),
                      prefixIcon: Icon(Icons.search_rounded, color: c.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () { _searchController.clear(); setState(() => _searchQuery = ''); },
                              child: Icon(Icons.close_rounded, color: c.textMuted, size: 18))
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ],

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
                  final isSelected = _selectedCategory == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? c.textPrimary : c.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isSelected ? c.textPrimary : c.border),
                      ),
                      child: Text(_categories[index],
                          style: TextStyle(color: isSelected ? c.surface : c.textSecondary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ── Firebase Stream ──
            Expanded(
              child: StreamBuilder<List<CourseModel>>(
                stream: _learnService.streamCourses(category: _activeCategory),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Erreur de chargement', style: TextStyle(color: c.textMuted)));
                  }
                  final courses = _applySearch(snap.data ?? []);
                  if (courses.isEmpty) {
                    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.search_off_rounded, color: c.textMuted, size: 48),
                      const SizedBox(height: 16),
                      Text('Aucun cours trouvé', style: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter')),
                    ]));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return _LearnCourseCard(
                        title:      course.title,
                        instructor: course.instructor,
                        rating:     course.ratingFormatted,
                        category:   course.category,
                        duration:   course.durationFormatted,
                        lessons:    course.lessonsCount,
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

// ── Course Card ─────────────────────────────────────────────────────────────
class _LearnCourseCard extends StatelessWidget {
  final String title, instructor, rating, category, duration;
  final int lessons;

  const _LearnCourseCard({
    required this.title, required this.instructor, required this.rating,
    required this.category, required this.duration, required this.lessons,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1)],
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(child: Text(title, style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700))),
                Row(children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFD08700), size: 14),
                  const SizedBox(width: 2),
                  Text(rating, style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                ]),
              ]),
              const SizedBox(height: 4),
              Text(instructor, style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter')),
              const SizedBox(height: 8),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(100)),
                  child: Text(category, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Icon(Icons.access_time_rounded, color: c.textMuted, size: 12),
                const SizedBox(width: 4),
                Text(duration, style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Inter')),
                const SizedBox(width: 8),
                Icon(Icons.play_circle_outline_rounded, color: c.textMuted, size: 12),
                const SizedBox(width: 4),
                Text('$lessons leçons', style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Inter')),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}
