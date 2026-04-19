import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/courses_service.dart';
import '../../models/course_model.dart';

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
        title: Text('Formation', style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: c.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'My Courses'),
            Tab(text: 'Explore'),
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
        label: const Text('Nouveau cours', style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ✅ التبويب الأول: كورساتي (كما هو)
// ─────────────────────────────────────────────────────────────
class _MyCoursesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Center(child: Text('Please sign in'));

    return StreamBuilder<List<CourseModel>>(
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
                Text('Aucun cours publié', style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Commencez par créer votre premier cours!', style: TextStyle(color: c.textSecondary)),
              ],
            ),
          );
        }

        final courses = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return _MyCourseCard(course: course, c: c);
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ✅ التبويب الثاني: استكشاف (منظم مع بحث وفلاتر)
// ─────────────────────────────────────────────────────────────
class _ExploreCoursesTab extends StatefulWidget {
  @override
  State<_ExploreCoursesTab> createState() => _ExploreCoursesTabState();
}

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
                hintText: 'Rechercher un cours...',
                hintStyle: TextStyle(color: c.textMuted),
                prefixIcon: Icon(Icons.search, color: c.textSecondary),
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

        // ── Course List (Filtered) ──
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
                      Text('No courses found', style: TextStyle(color: c.textPrimary, fontSize: 16)),
                    ],
                  ),
                );
              }

              // ✅ فلترة محلية للبحث (Search Filter)
              var courses = snapshot.data!;
              if (_searchQuery.isNotEmpty) {
                courses = courses.where((course) => 
                  course.title.toLowerCase().contains(_searchQuery) ||
                  course.instructorName.toLowerCase().contains(_searchQuery)
                ).toList();
              }

              if (courses.isEmpty) {
                 return Center(
                  child: Text('No matches for "$_searchQuery"', style: TextStyle(color: c.textMuted)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(24),
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
// ✅ بطاقة كورساتي
// ─────────────────────────────────────────────────────────────
class _MyCourseCard extends StatelessWidget {
  final CourseModel course;
  final ThemeColors c;
  const _MyCourseCard({required this.course, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.menu_book, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${course.totalLessons} leçons • ${course.unitsCount} unités', style: TextStyle(color: c.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${course.certificatePrice} € / Certificat', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: Text('Gérer', style: TextStyle(color: AppColors.primary)),
              )
            ],
          )
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ✅ بطاقة الاستكشاف
// ─────────────────────────────────────────────────────────────
class _ExploreCourseCard extends StatelessWidget {
  final CourseModel course;
  final ThemeColors c;
  const _ExploreCourseCard({required this.course, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: AppColors.purpleLight, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.school, color: AppColors.purple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('By ${course.instructorName}', style: TextStyle(color: c.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${course.certificatePrice} €', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: Text('View', style: TextStyle(color: AppColors.purple)),
              )
            ],
          )
        ],
      ),
    );
  }
}